"""Dependency-free media-file import and bounded metadata inspection."""

from __future__ import annotations

import re
import wave
import base64
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, UnidentifiedImageError

from .model import Movie

MAX_MEDIA_FILES = 100_000
DEFAULT_DISK_TAG_PATTERN = r"(?i)(cd)[0-9]{1,3}"
MAX_DISK_TAG_PATTERN_LENGTH = 256
MEDIA_PICTURE_EXTENSIONS = (".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp")
MAX_MEDIA_PICTURE_BYTES = 64 * 1024 * 1024
MAX_MEDIA_PICTURE_PIXELS = 100_000_000
DEFAULT_MEDIA_EXTENSIONS = {
    "avi",
    "m2ts",
    "m4v",
    "mkv",
    "mov",
    "mp4",
    "mpeg",
    "mpg",
    "ogm",
    "ts",
    "vob",
    "webm",
    "wmv",
}
MAX_TITLE_FILTER_PATTERN_LENGTH = 256


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
    video_format: str = ""
    video_bitrate: int | None = None


_MP4_VIDEO_SUFFIXES = {".mp4", ".m4v", ".mov"}
_MP4_AUDIO_SUFFIXES = {".m4a"}
_OGG_AUDIO_SUFFIXES = {".ogg", ".oga"}


def inspect_media(path: str | Path, *, max_file_bytes: int = 1024**4) -> MediaInfo:
    """Inspect safe filesystem facts and WAV/FLAC/AIFF/MP3/MP4/OGG metadata
    when applicable."""
    path = Path(path)
    if not path.is_file():
        raise ValueError(f"media path is not a file: {path}")
    size = path.stat().st_size
    if size > max_file_bytes:
        raise ValueError(f"media file exceeds size limit: {size} > {max_file_bytes}")
    length = bitrate = None
    audio_format = video_format = ""
    video_bitrate = None
    suffix = path.suffix.casefold()
    label = path.suffix.upper().lstrip(".")
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
    elif suffix in _OGG_AUDIO_SUFFIXES:
        length, bitrate = _inspect_ogg_vorbis(path, size)
        audio_format = label
    elif suffix in _MP4_AUDIO_SUFFIXES:
        length, bitrate = _inspect_mp4_movie_header(path, size)
        audio_format = label
    elif suffix in _MP4_VIDEO_SUFFIXES:
        length, video_bitrate = _inspect_mp4_movie_header(path, size)
        video_format = label
    return MediaInfo(
        str(path),
        path.stem,
        path.suffix,
        size,
        length,
        audio_format,
        bitrate,
        video_format,
        video_bitrate,
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
        if (
            len(header) != 12
            or header[0:4] != b"FORM"
            or header[8:12]
            not in (
                b"AIFF",
                b"AIFC",
            )
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
        word = int.from_bytes(window[index : index + 4], "big")
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


_OGG_PAGE_HEADER_SIZE = 27
_OGG_IDENTIFICATION_HEADER_SIZE = 30
_OGG_TAIL_SEARCH_BYTES = 65536


def _inspect_ogg_vorbis(path: Path, size: int) -> tuple[int | None, int | None]:
    """Read the Vorbis identification header and the stream's final granule
    position for duration and bitrate.

    Ogg is a page-based container: a four-byte ``OggS`` magic starts a fixed
    27-byte page header (including a per-page sample-count "granule
    position" and a serial number identifying which logical bitstream the
    page belongs to), followed by a lacing segment table that reassembles
    into one or more packets. This only supports the single most common
    shape — one Ogg Vorbis logical bitstream per file, whose mandatory
    Vorbis identification packet (``\\x01vorbis``, always small enough that
    real encoders fit it in the first page) declares sample rate and a
    nominal bitrate. Multiplexed streams (e.g. Ogg files also carrying
    Theora video) and Opus streams (``OpusHead`` instead of
    ``\\x01vorbis``) are out of scope and rejected with a clear error
    rather than guessed at. Total duration comes from the last page's
    granule position (total PCM samples), found the same bounded way MP3
    duration is estimated from a search window — here from the end of the
    file, since Ogg pages carry no leading index of where the stream ends.
    """
    with path.open("rb") as stream:
        header = stream.read(_OGG_PAGE_HEADER_SIZE)
        if len(header) != _OGG_PAGE_HEADER_SIZE or header[0:4] != b"OggS":
            raise ValueError("invalid Ogg media file: missing OggS marker")
        serial = header[14:18]
        segment_count = header[26]
        segment_table = stream.read(segment_count)
        if len(segment_table) != segment_count:
            raise ValueError("invalid Ogg media file: truncated segment table")
        first_packet_length = 0
        for lacing_value in segment_table:
            first_packet_length += lacing_value
            if lacing_value < 255:
                break
        packet = stream.read(first_packet_length)
        if (
            len(packet) != first_packet_length
            or len(packet) < _OGG_IDENTIFICATION_HEADER_SIZE
            or not packet.startswith(b"\x01vorbis")
        ):
            raise ValueError("invalid Ogg media file: missing Vorbis identification header")
        sample_rate = int.from_bytes(packet[12:16], "little")
        bitrate_nominal = int.from_bytes(packet[20:24], "little", signed=True)
    if sample_rate <= 0:
        return None, None
    tail_size = min(_OGG_TAIL_SEARCH_BYTES, size)
    with path.open("rb") as stream:
        stream.seek(size - tail_size)
        tail = stream.read(tail_size)
    total_samples = None
    index = tail.rfind(b"OggS")
    while index != -1:
        candidate = tail[index : index + _OGG_PAGE_HEADER_SIZE]
        if len(candidate) == _OGG_PAGE_HEADER_SIZE and candidate[14:18] == serial:
            granule = int.from_bytes(candidate[6:14], "little", signed=True)
            if granule >= 0:
                total_samples = granule
                break
        index = tail.rfind(b"OggS", 0, index)
    length = round(total_samples / sample_rate) if total_samples else None
    bitrate = bitrate_nominal // 1000 if bitrate_nominal > 0 else None
    if bitrate is None and length:
        bitrate = round(size * 8 / length / 1000)
    return length, bitrate


_MP4_MAX_TOP_LEVEL_BOXES = 64
_MP4_MAX_MOOV_BYTES = 64 * 1024 * 1024
_MP4_MAX_MOOV_CHILDREN = 64


def _read_mp4_box_header(stream, remaining: int) -> tuple[bytes, int, int] | None:
    """Read one ISO base media box header, returning (type, payload_size,
    header_size), resolving a size-0 "to end of file" box against *remaining*."""
    header = stream.read(8)
    if len(header) != 8:
        return None
    size = int.from_bytes(header[0:4], "big")
    box_type = header[4:8]
    header_size = 8
    if size == 1:
        extended = stream.read(8)
        if len(extended) != 8:
            return None
        size = int.from_bytes(extended, "big")
        header_size = 16
    elif size == 0:
        return box_type, remaining - header_size, header_size
    if size < header_size:
        return None
    return box_type, size - header_size, header_size


def _inspect_mp4_movie_header(path: Path, size: int) -> tuple[int | None, int | None]:
    """Read the ``moov``/``mvhd`` box for movie-level duration and an
    average bitrate.

    MP4/M4A/MOV files are ISO base media containers (the same box structure
    underlies all three): a flat sequence of top-level boxes, each a
    four-byte big-endian size, a four-character type, and a payload that
    may itself hold nested boxes; a box may declare size 1 for a 64-bit
    extended size following the header, or size 0 to mean "extends to end
    of file". Duration and its timescale live in the mandatory
    ``moov/mvhd`` box. There is no per-codec bitrate field at this level —
    that lives in codec-specific sample tables this reader does not parse,
    the same reason it does not attempt resolution, framerate, or a real
    codec name — so bitrate here is only an average over the whole
    file, the same documented trade-off already made for AIFF-C's non-PCM
    branch and MP3's VBR files. Top-level box payloads before ``moov`` are
    skipped via ``seek`` rather than read, since ``mdat`` (the actual media
    data) can be arbitrarily large; ``moov`` itself is read fully, bounded
    by ``_MP4_MAX_MOOV_BYTES``, since it is metadata expected to be small.
    """
    with path.open("rb") as stream:
        moov_payload = None
        for _ in range(_MP4_MAX_TOP_LEVEL_BOXES):
            position = stream.tell()
            header = _read_mp4_box_header(stream, size - position)
            if header is None:
                break
            box_type, payload_size, header_size = header
            if box_type == b"moov":
                if payload_size < 0 or payload_size > _MP4_MAX_MOOV_BYTES:
                    raise ValueError("invalid MP4 media file: moov box exceeds size limit")
                moov_payload = stream.read(payload_size)
                if len(moov_payload) != payload_size:
                    raise ValueError("invalid MP4 media file: truncated moov box")
                break
            if payload_size < 0:
                break
            stream.seek(position + header_size + payload_size)
        if moov_payload is None:
            raise ValueError("invalid MP4 media file: missing moov box")
    mvhd = None
    offset = 0
    for _ in range(_MP4_MAX_MOOV_CHILDREN):
        if offset + 8 > len(moov_payload):
            break
        child_size = int.from_bytes(moov_payload[offset : offset + 4], "big")
        child_type = moov_payload[offset + 4 : offset + 8]
        if child_size < 8 or offset + child_size > len(moov_payload):
            break
        if child_type == b"mvhd":
            mvhd = moov_payload[offset + 8 : offset + child_size]
            break
        offset += child_size
    if mvhd is None or len(mvhd) < 4:
        raise ValueError("invalid MP4 media file: missing mvhd box")
    version = mvhd[0]
    if version == 1:
        if len(mvhd) < 32:
            raise ValueError("invalid MP4 media file: truncated mvhd box")
        timescale = int.from_bytes(mvhd[20:24], "big")
        duration = int.from_bytes(mvhd[24:32], "big")
    else:
        if len(mvhd) < 20:
            raise ValueError("invalid MP4 media file: truncated mvhd box")
        timescale = int.from_bytes(mvhd[12:16], "big")
        duration = int.from_bytes(mvhd[16:20], "big")
    if timescale <= 0 or duration <= 0:
        return None, None
    length = round(duration / timescale)
    bitrate = round(size * 8 / length / 1000) if length else None
    return length, bitrate


def movie_from_media(
    path: str | Path,
    *,
    extraction: str = "full",
    title_filter_pattern: str | None = None,
) -> Movie:
    """Create a movie populated only with facts established by media inspection.

    `Movie.length` is minutes, matching upstream's own documented unit for
    the "Length" field (`options_en.html`: "Read the length of the file (in
    minutes) and put it in the 'Length' field") and every other place this
    port already treats it as minutes (the GUI statistics dialog's "Total
    length (minutes)" label, `$$ITEM_LENGTH`'s upstream tag). `MediaInfo.
    length_seconds` stays in seconds, the natural unit for a single media
    file's exact duration; this is the one boundary that converts between
    the two, rounding to the nearest whole minute.
    """
    if extraction not in {"full", "defer", "skip"}:
        raise ValueError("media extraction mode must be 'full', 'defer', or 'skip'")
    media_path = Path(path)
    title_filter = None
    if title_filter_pattern is not None:
        if not isinstance(title_filter_pattern, str):
            raise TypeError("title filter pattern must be a string")
        if not title_filter_pattern or len(title_filter_pattern) > MAX_TITLE_FILTER_PATTERN_LENGTH:
            raise ValueError(
                "title filter pattern must contain 1 to "
                f"{MAX_TITLE_FILTER_PATTERN_LENGTH} characters"
            )
        try:
            title_filter = re.compile(title_filter_pattern)
        except re.error as error:
            raise ValueError(f"invalid title filter pattern: {error}") from error
    if extraction == "full":
        info = inspect_media(media_path)
    else:
        if not media_path.is_file():
            raise ValueError(f"media path is not a file: {media_path}")
        info = MediaInfo(
            str(media_path),
            media_path.stem,
            media_path.suffix,
            media_path.stat().st_size if extraction == "defer" else 0,
        )
    length_minutes = round(info.length_seconds / 60) if info.length_seconds is not None else None
    extras = {"media_path": info.path}
    if extraction != "full":
        extras["media_analysis"] = "pending" if extraction == "defer" else "skipped"
    title = info.name
    if title_filter is not None:
        title = " ".join(title_filter.sub(" ", title).split()).strip(" ._-")
    return Movie(
        title=title,
        media_label=Path(info.path).name,
        media_type=info.extension.lstrip(".").upper(),
        length=length_minutes,
        audio_format=info.audio_format,
        audio_bitrate=info.audio_bitrate,
        video_format=info.video_format,
        video_bitrate=info.video_bitrate,
        file_size=info.size if extraction != "skip" else None,
        extras=extras,
    )


def merge_media_parts(
    entries: list[tuple[Path, Movie]],
    *,
    disk_tag_pattern: str = DEFAULT_DISK_TAG_PATTERN,
) -> list[Movie]:
    """Merge adjacent, same-directory media parts with matching stripped names.

    The first part supplies descriptive fields. Durations and sizes are summed,
    bitrates use upstream's iterative pairwise average, and every source path is
    retained in ``extras["media_parts"]``.
    """
    if not isinstance(disk_tag_pattern, str):
        raise TypeError("disk tag pattern must be a string")
    if not disk_tag_pattern or len(disk_tag_pattern) > MAX_DISK_TAG_PATTERN_LENGTH:
        raise ValueError(
            f"disk tag pattern must contain 1 to {MAX_DISK_TAG_PATTERN_LENGTH} characters"
        )
    try:
        disk_tag = re.compile(disk_tag_pattern)
    except re.error as error:
        raise ValueError(f"invalid disk tag pattern: {error}") from error

    def key(path: Path) -> tuple[Path, str] | None:
        stripped, count = disk_tag.subn("", path.stem)
        return (path.parent, stripped.casefold()) if count else None

    merged: list[Movie] = []
    previous_key: tuple[Path, str] | None = None
    previous_path: Path | None = None
    for path, movie in entries:
        current_key = key(path)
        if current_key is None or current_key != previous_key:
            merged.append(Movie.from_dict(movie.to_dict()))
        else:
            target = merged[-1]
            if movie.length is not None:
                target.length = (target.length or 0) + movie.length
            if movie.file_size is not None:
                target.file_size = (target.file_size or 0) + movie.file_size
            for field_name in ("video_bitrate", "audio_bitrate"):
                old = getattr(target, field_name)
                new = getattr(movie, field_name)
                if new is not None:
                    setattr(target, field_name, new if old is None else round((old + new) / 2))
            if target.media_count is None:
                target.media_count = 1
                target.extras["media_parts"] = [str(previous_path)]
            target.media_count += 1
            target.extras["media_parts"].append(str(path))
        previous_key = current_key
        previous_path = path
    return merged


def attach_media_pictures(
    entries: list[tuple[Path, Movie]],
    *,
    embed: bool = False,
    folder_picture_name: str = "folder",
    max_bytes: int = MAX_MEDIA_PICTURE_BYTES,
    max_pixels: int = MAX_MEDIA_PICTURE_PIXELS,
) -> list[Movie]:
    """Attach same-stem or configured folder pictures to imported movies."""
    if not isinstance(folder_picture_name, str):
        raise TypeError("folder picture name must be a string")
    if Path(folder_picture_name).name != folder_picture_name or not folder_picture_name:
        raise ValueError("folder picture name must be a non-empty file name without a path")
    if isinstance(max_bytes, bool) or not isinstance(max_bytes, int) or max_bytes < 0:
        raise ValueError("max_bytes must be a non-negative integer")
    if isinstance(max_pixels, bool) or not isinstance(max_pixels, int) or max_pixels < 1:
        raise ValueError("max_pixels must be a positive integer")

    result: list[Movie] = []
    directory_images: dict[Path, dict[str, Path]] = {}
    for media_path, source_movie in entries:
        movie = Movie.from_dict(source_movie.to_dict())
        if media_path.parent not in directory_images:
            index: dict[str, Path] = {}
            for candidate in sorted(media_path.parent.iterdir()):
                if candidate.is_file() and candidate.suffix.casefold() in MEDIA_PICTURE_EXTENSIONS:
                    index.setdefault(candidate.name.casefold(), candidate)
            directory_images[media_path.parent] = index
        index = directory_images[media_path.parent]
        candidate_names = [
            f"{base_name}{extension}".casefold()
            for base_name in (media_path.stem, folder_picture_name)
            for extension in MEDIA_PICTURE_EXTENSIONS
        ]
        picture = next((index[name] for name in candidate_names if name in index), None)
        if picture is not None:
            movie.picture = str(picture)
            if embed:
                size = picture.stat().st_size
                if size > max_bytes:
                    raise ValueError(f"media picture exceeds size limit: {size} > {max_bytes}")
                data = picture.read_bytes()
                try:
                    with Image.open(picture) as image:
                        if image.width * image.height > max_pixels:
                            raise ValueError(
                                "media picture exceeds pixel limit: "
                                f"{image.width * image.height} > {max_pixels}"
                            )
                        image.verify()
                except (OSError, UnidentifiedImageError) as error:
                    raise ValueError(f"invalid media picture: {picture}: {error}") from error
                movie.picture = picture.name
                movie.extras["native_picture_base64"] = base64.b64encode(data).decode("ascii")
        result.append(movie)
    return result


def discover_media(
    paths: list[str | Path],
    *,
    recursive: bool = False,
    max_depth: int | None = None,
    extensions: set[str] | None = None,
    max_files: int = MAX_MEDIA_FILES,
) -> list[Path]:
    """Expand files and directories deterministically with explicit bounds.

    ``max_depth`` counts directory levels below each supplied directory: zero
    scans only that directory, one also scans its immediate children, and so
    on.  It implies recursive discovery; ``None`` retains the older
    ``recursive`` all-or-nothing behavior.
    """
    if max_depth is not None and (
        isinstance(max_depth, bool) or not isinstance(max_depth, int) or max_depth < 0
    ):
        raise ValueError("media import maximum depth must be a non-negative integer")
    normalized_extensions = (
        {f".{item.lstrip('.').casefold()}" for item in extensions}
        if extensions is not None
        else None
    )

    def include(item: Path) -> bool:
        return item.is_file() and (
            normalized_extensions is None or item.suffix.casefold() in normalized_extensions
        )

    result: list[Path] = []

    def directory_files(directory: Path):
        if not recursive and max_depth is None:
            yield from sorted(directory.iterdir())
            return

        def walk(current: Path, depth: int):
            for child in sorted(current.iterdir()):
                if child.is_dir() and not child.is_symlink():
                    if max_depth is None or depth < max_depth:
                        yield from walk(child, depth + 1)
                else:
                    yield child

        yield from walk(directory, 0)

    for value in paths:
        path = Path(value)
        if path.is_file():
            if include(path):
                result.append(path)
        elif path.is_dir():
            for item in directory_files(path):
                if include(item):
                    result.append(item)
                    if len(result) > max_files:
                        raise ValueError(f"media import exceeds file-count limit: {max_files}")
        else:
            raise ValueError(f"media path does not exist: {path}")
        if len(result) > max_files:
            raise ValueError(f"media import exceeds file-count limit: {max_files}")
    return result
