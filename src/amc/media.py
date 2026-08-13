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
    """Inspect safe filesystem facts and WAV metadata when applicable."""
    path = Path(path)
    if not path.is_file():
        raise ValueError(f"media path is not a file: {path}")
    size = path.stat().st_size
    if size > max_file_bytes:
        raise ValueError(f"media file exceeds size limit: {size} > {max_file_bytes}")
    length = bitrate = None
    audio_format = ""
    if path.suffix.casefold() == ".wav":
        try:
            with wave.open(str(path), "rb") as stream:
                rate = stream.getframerate()
                frames = stream.getnframes()
                length = round(frames / rate) if rate else None
                bitrate = rate * stream.getsampwidth() * 8 * stream.getnchannels() // 1000
                audio_format = "PCM"
        except (EOFError, wave.Error) as error:
            raise ValueError(f"invalid WAV media file: {error}") from error
    return MediaInfo(
        str(path), path.stem, path.suffix, size, length, audio_format, bitrate
    )


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
    include = lambda item: (
        item.is_file()
        and (
            normalized_extensions is None
            or item.suffix.casefold() in normalized_extensions
        )
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
