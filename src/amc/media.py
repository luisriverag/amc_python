"""Dependency-free media-file import and bounded metadata inspection."""

from __future__ import annotations

import wave
from dataclasses import dataclass
from pathlib import Path

from .model import Movie

MAX_MEDIA_FILES = 100_000


@dataclass(frozen=True, slots=True)
class MediaInfo:
    """Portable file facts available without optional codec libraries."""

    path: str
    name: str
    extension: str
    size: int
    length_seconds: int | None = None
    audio_format: str = ""
    audio_bitrate: int | None = None


def inspect_media(path: str | Path, *, max_file_bytes: int = 1024**4) -> MediaInfo:
    """Inspect safe filesystem facts and WAV/FLAC metadata when applicable."""
    path = Path(path)
    if not path.is_file():
        raise ValueError(f"media path is not a file: {path}")
    size = path.stat().st_size
    if size > max_file_bytes:
        raise ValueError(f"media file exceeds size limit: {size} > {max_file_bytes}")
    length = bitrate = None
    audio_format = ""
    suffix = path.suffix.casefold()
    if suffix == ".wav":
        try:
            with wave.open(str(path), "rb") as stream:
                rate = stream.getframerate()
                frames = stream.getnframes()
                length = round(frames / rate) if rate else None
                bitrate = rate * stream.getsampwidth() * 8 * stream.getnchannels() // 1000
                audio_format = "PCM"
        except (EOFError, wave.Error) as error:
            raise ValueError(f"invalid WAV media file: {error}") from error
    elif suffix == ".flac":
        length, bitrate = _inspect_flac_stream_info(path, size)
        audio_format = "FLAC"
    return MediaInfo(
        str(path), path.stem, path.suffix, size, length, audio_format, bitrate
    )


def _inspect_flac_stream_info(path: Path, size: int) -> tuple[int | None, int | None]:
    """Read the mandatory leading STREAMINFO block for duration and bitrate.

    See the FLAC format reference: a file begins with the four-byte magic
    ``fLaC`` followed by one or more metadata blocks; the first is always a
    34-byte STREAMINFO block carrying the sample rate, channel count, bit
    depth, and total sample count needed to compute duration.
    """
    with path.open("rb") as stream:
        if stream.read(4) != b"fLaC":
            raise ValueError("invalid FLAC media file: missing fLaC marker")
        header = stream.read(4)
        if len(header) != 4:
            raise ValueError("invalid FLAC media file: truncated metadata block header")
        block_type = header[0] & 0x7F
        block_length = int.from_bytes(header[1:4], "big")
        if block_type != 0 or block_length != 34:
            raise ValueError("invalid FLAC media file: missing STREAMINFO block")
        info = stream.read(34)
        if len(info) != 34:
            raise ValueError("invalid FLAC media file: truncated STREAMINFO block")
    packed = int.from_bytes(info[10:18], "big")
    sample_rate = packed >> 44
    total_samples = packed & 0xF_FFFF_FFFF
    if sample_rate == 0 or total_samples == 0:
        return None, None
    length = round(total_samples / sample_rate)
    bitrate = round(size * 8 / total_samples * sample_rate / 1000)
    return length, bitrate


def movie_from_media(path: str | Path) -> Movie:
    """Create a movie populated only with facts established by media inspection."""
    info = inspect_media(path)
    return Movie(
        title=info.name,
        media_label=Path(info.path).name,
        media_type=info.extension.lstrip(".").upper(),
        length=info.length_seconds,
        audio_format=info.audio_format,
        audio_bitrate=info.audio_bitrate,
        file_size=info.size,
        extras={"media_path": info.path},
    )


def discover_media(
    paths: list[str | Path],
    *,
    recursive: bool = False,
    extensions: set[str] | None = None,
    max_files: int = MAX_MEDIA_FILES,
) -> list[Path]:
    """Expand files and directories deterministically with an explicit count bound."""
    normalized_extensions = (
        {f".{item.lstrip('.').casefold()}" for item in extensions}
        if extensions is not None
        else None
    )
    def include(item: Path) -> bool:
        return item.is_file() and (
            normalized_extensions is None
            or item.suffix.casefold() in normalized_extensions
        )
    result: list[Path] = []
    for value in paths:
        path = Path(value)
        if path.is_file():
            if include(path):
                result.append(path)
        elif path.is_dir():
            candidates = path.rglob("*") if recursive else path.glob("*")
            result.extend(item for item in sorted(candidates) if include(item))
        else:
            raise ValueError(f"media path does not exist: {path}")
        if len(result) > max_files:
            raise ValueError(f"media import exceeds file-count limit: {max_files}")
    return result
