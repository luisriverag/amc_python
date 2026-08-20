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
    """Inspect safe filesystem facts and WAV/FLAC/AIFF/MP3 metadata when applicable."""
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
    elif suffix in {".aif", ".aiff", ".aifc"}:
        length, bitrate = _inspect_aiff_common_chunk(path, size)
        audio_format = "AIFF"
    elif suffix == ".mp3":
        length, bitrate = _inspect_mp3(path, size)
        audio_format = "MP3"
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


_AIFF_MAX_CHUNKS = 64
_AIFF_PCM_COMPRESSION_TYPES = {b"NONE", b"sowt", b"twos", b"in24", b"in32"}


def _read_extended_be(data: bytes) -> float:
    """Decode a 10-byte big-endian IEEE 754 80-bit extended-precision float.

    AIFF stores its sample rate this way. Unlike double precision, the
    80-bit format has no implicit leading mantissa bit, so the value is the
    64-bit mantissa scaled directly by the unbiased exponent.
    """
    exponent = int.from_bytes(data[0:2], "big") & 0x7FFF
    mantissa = int.from_bytes(data[2:10], "big")
    if exponent == 0 and mantissa == 0:
        return 0.0
    return mantissa * (2.0 ** (exponent - 16383 - 63))


def _inspect_aiff_common_chunk(path: Path, size: int) -> tuple[int | None, int | None]:
    """Read the mandatory COMM chunk for duration and bitrate.

    AIFF/AIFF-C files are IFF containers: a four-byte ``FORM`` magic, a
    big-endian chunk size, and a form type (``AIFF`` is always uncompressed
    PCM; ``AIFF-C`` carries a four-character compression type that may or may
    not be PCM), followed by a sequence of chunks. Duration, channel count,
    and bit depth come from the mandatory ``COMM`` chunk, which may appear
    anywhere in the chunk sequence. Python's ``aifc`` module is deliberately
    not used: it is deprecated and removed starting in Python 3.13.
    """
    with path.open("rb") as stream:
        header = stream.read(12)
        if len(header) != 12 or header[0:4] != b"FORM" or header[8:12] not in (
            b"AIFF", b"AIFC",
        ):
            raise ValueError("invalid AIFF media file: missing FORM/AIFF marker")
        form_type = header[8:12]
        common = None
        for _ in range(_AIFF_MAX_CHUNKS):
            chunk_header = stream.read(8)
            if len(chunk_header) != 8:
                break
            chunk_id = chunk_header[0:4]
            chunk_size = int.from_bytes(chunk_header[4:8], "big")
            data = stream.read(chunk_size)
            if len(data) != chunk_size:
                raise ValueError("invalid AIFF media file: truncated chunk")
            if chunk_id == b"COMM":
                common = data
                break
            if chunk_size % 2:
                stream.read(1)
        if common is None or len(common) < 18:
            raise ValueError("invalid AIFF media file: missing COMM chunk")
    channels = int.from_bytes(common[0:2], "big")
    total_samples = int.from_bytes(common[2:6], "big")
    bits_per_sample = int.from_bytes(common[6:8], "big")
    sample_rate = _read_extended_be(common[8:18])
    if sample_rate <= 0 or total_samples == 0:
        return None, None
    length = round(total_samples / sample_rate)
    is_pcm = form_type == b"AIFF" or common[18:22] in _AIFF_PCM_COMPRESSION_TYPES
    if is_pcm:
        bitrate = round(sample_rate * bits_per_sample * channels / 1000)
    else:
        bitrate = round(size * 8 / total_samples * sample_rate / 1000)
    return length, bitrate


_MP3_BITRATES_KBPS = {
    # Keyed by (version_index, layer_index); see ISO/IEC 11172-3 frame header.
    # version_index: 0=MPEG2.5, 2=MPEG2, 3=MPEG1 (1 is reserved).
    # layer_index: 1=Layer III, 2=Layer II, 3=Layer I (0 is reserved).
    (3, 3): (0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, -1),
    (3, 2): (0, 32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384, -1),
    (3, 1): (0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, -1),
    (2, 3): (0, 32, 48, 56, 64, 80, 96, 112, 128, 144, 160, 176, 192, 224, 256, -1),
    (2, 2): (0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, -1),
    (2, 1): (0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, -1),
}
_MP3_BITRATES_KBPS[(0, 3)] = _MP3_BITRATES_KBPS[(2, 3)]
_MP3_BITRATES_KBPS[(0, 2)] = _MP3_BITRATES_KBPS[(2, 2)]
_MP3_BITRATES_KBPS[(0, 1)] = _MP3_BITRATES_KBPS[(2, 1)]
_MP3_SAMPLE_RATES = {
    3: (44100, 48000, 32000),  # MPEG1
    2: (22050, 24000, 16000),  # MPEG2
    0: (11025, 12000, 8000),  # MPEG2.5
}
_MP3_SEARCH_WINDOW_BYTES = 65536


def _mp3_tag_size(path: Path) -> int:
    """Return the byte size of a leading ID3v2 tag, or 0 when there is none.

    The 10-byte header holds a syncsafe (7 bits per byte) body size; when the
    footer-present flag is set, an identical 10-byte footer follows the body.
    """
    with path.open("rb") as stream:
        header = stream.read(10)
    if len(header) != 10 or header[0:3] != b"ID3":
        return 0
    flags = header[5]
    body = header[6:10]
    if any(byte & 0x80 for byte in body):
        return 0
    body_size = (body[0] << 21) | (body[1] << 14) | (body[2] << 7) | body[3]
    return 10 + body_size + (10 if flags & 0x10 else 0)


def _mp3_frame_header(word: int) -> tuple[int, int, int, int, int, int] | None:
    """Decode one 4-byte MPEG audio frame header, or None if not a valid sync."""
    if word & 0xFFE0_0000 != 0xFFE0_0000:
        return None
    version_index = (word >> 19) & 0x3
    layer_index = (word >> 17) & 0x3
    bitrate_index = (word >> 12) & 0xF
    sample_rate_index = (word >> 10) & 0x3
    padding = (word >> 9) & 0x1
    if version_index == 1 or layer_index == 0 or sample_rate_index == 3:
        return None
    table = _MP3_BITRATES_KBPS.get((version_index, layer_index))
    if table is None or not (0 < bitrate_index < 15):
        return None
    bitrate_kbps = table[bitrate_index]
    if bitrate_kbps <= 0:
        return None
    sample_rate = _MP3_SAMPLE_RATES[version_index][sample_rate_index]
    if layer_index == 3:
        frame_length = (12 * bitrate_kbps * 1000 // sample_rate + padding) * 4
    elif layer_index == 1 and version_index != 3:
        frame_length = 72 * bitrate_kbps * 1000 // sample_rate + padding
    else:
        frame_length = 144 * bitrate_kbps * 1000 // sample_rate + padding
    if frame_length <= 4:
        return None
    return version_index, layer_index, bitrate_kbps, sample_rate, padding, frame_length


def _inspect_mp3(path: Path, size: int) -> tuple[int | None, int | None]:
    """Estimate duration and bitrate from the first valid MPEG audio frame.

    MP3 has no mandatory duration field: unlike FLAC's STREAMINFO or AIFF's
    COMM chunk, only an optional Xing/Info/VBRI side header (not parsed here)
    declares an exact frame count. This computes a constant-bitrate estimate
    from the first frame's declared bitrate and the remaining audio byte
    count instead, which is exact for CBR files — the common case — and an
    approximation for variable-bitrate files, the same documented trade-off
    already made for AIFF-C's non-PCM branch.
    """
    offset = _mp3_tag_size(path)
    with path.open("rb") as stream:
        stream.seek(offset)
        window = stream.read(min(_MP3_SEARCH_WINDOW_BYTES, max(0, size - offset)))
    header = None
    frame_offset = None
    limit = len(window) - 3
    index = 0
    while index < limit:
        word = int.from_bytes(window[index:index + 4], "big")
        header = _mp3_frame_header(word)
        if header is not None:
            frame_offset = offset + index
            break
        index += 1
    if header is None or frame_offset is None:
        raise ValueError("invalid MP3 media file: no MPEG audio frame sync found")
    _version_index, _layer_index, bitrate_kbps, _sample_rate, _padding, _frame_length = header
    audio_bytes = size - frame_offset
    if size >= 128:
        with path.open("rb") as stream:
            stream.seek(size - 128)
            if stream.read(3) == b"TAG":
                audio_bytes -= 128
    if audio_bytes <= 0:
        return None, bitrate_kbps
    length = round(audio_bytes * 8 / (bitrate_kbps * 1000))
    return length, bitrate_kbps


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
