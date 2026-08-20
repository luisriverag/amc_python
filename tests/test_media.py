import math
import wave
from pathlib import Path

import pytest

from amc.media import discover_media, inspect_media, movie_from_media
from amc.cli import main
from amc.storage import load


def _write_extended_be(value: float) -> bytes:
    """Encode a positive, finite value as a 10-byte IEEE 754 80-bit extended
    precision big-endian float, matching the classic AIFF sample-rate field
    (ported from CPython's historical ``aifc._write_float``)."""
    if value == 0:
        expon = himant = lomant = 0
    else:
        fmant, expon = math.frexp(value)
        expon += 16382
        fmant = math.ldexp(fmant, 32)
        himant = int(math.floor(fmant))
        fmant = math.ldexp(fmant - himant, 32)
        lomant = int(math.floor(fmant))
    return bytes([
        (expon >> 8) & 0xFF, expon & 0xFF,
        (himant >> 24) & 0xFF, (himant >> 16) & 0xFF,
        (himant >> 8) & 0xFF, himant & 0xFF,
        (lomant >> 24) & 0xFF, (lomant >> 16) & 0xFF,
        (lomant >> 8) & 0xFF, lomant & 0xFF,
    ])


def _write_aiff(
    path: Path,
    *,
    sample_rate: float,
    channels: int,
    bits_per_sample: int,
    total_samples: int,
    form_type: bytes = b"AIFF",
    compression_type: bytes | None = None,
    audio_bytes: bytes = b"",
) -> None:
    """Write a minimal, spec-shaped AIFF/AIFF-C file with a COMM chunk."""
    comm = (
        channels.to_bytes(2, "big")
        + total_samples.to_bytes(4, "big")
        + bits_per_sample.to_bytes(2, "big")
        + _write_extended_be(sample_rate)
    )
    if compression_type is not None:
        comm += compression_type
    chunks = b"COMM" + len(comm).to_bytes(4, "big") + comm
    if len(comm) % 2:
        chunks += b"\x00"
    if audio_bytes:
        ssnd = b"\x00\x00\x00\x00\x00\x00\x00\x00" + audio_bytes
        chunks += b"SSND" + len(ssnd).to_bytes(4, "big") + ssnd
        if len(ssnd) % 2:
            chunks += b"\x00"
    form_size = 4 + len(chunks)
    path.write_bytes(b"FORM" + form_size.to_bytes(4, "big") + form_type + chunks)


def _write_flac(
    path: Path,
    *,
    sample_rate: int,
    channels: int,
    bits_per_sample: int,
    total_samples: int,
    audio_bytes: bytes = b"",
) -> None:
    """Write a minimal, spec-shaped FLAC file with only a STREAMINFO block."""
    packed = (
        (sample_rate << 44)
        | ((channels - 1) << 41)
        | ((bits_per_sample - 1) << 36)
        | (total_samples & 0xF_FFFF_FFFF)
    )
    stream_info = (
        b"\x00\x00"  # minimum block size
        b"\x00\x00"  # maximum block size
        b"\x00\x00\x00"  # minimum frame size
        b"\x00\x00\x00"  # maximum frame size
        + packed.to_bytes(8, "big")
        + b"\x00" * 16  # MD5 of the unencoded audio
    )
    assert len(stream_info) == 34
    header = bytes([0x80]) + len(stream_info).to_bytes(3, "big")
    path.write_bytes(b"fLaC" + header + stream_info + audio_bytes)


def test_inspect_media_collects_portable_file_facts(tmp_path: Path):
    target = tmp_path / "Movie.mkv"
    target.write_bytes(b"media")
    info = inspect_media(target)
    assert (info.name, info.extension, info.size) == ("Movie", ".mkv", 5)
    movie = movie_from_media(target)
    assert (movie.title, movie.media_label, movie.media_type, movie.file_size) == (
        "Movie", "Movie.mkv", "MKV", 5
    )
    assert movie.extras == {"media_path": str(target)}


def test_inspect_media_reads_wav_duration_and_audio(tmp_path: Path):
    target = tmp_path / "audio.wav"
    with wave.open(str(target), "wb") as stream:
        stream.setnchannels(2)
        stream.setsampwidth(2)
        stream.setframerate(8000)
        stream.writeframes(b"\0" * 32000)
    info = inspect_media(target)
    assert (info.length_seconds, info.audio_format, info.audio_bitrate) == (1, "PCM", 256)


def test_inspect_media_rejects_non_file_invalid_wav_and_size(tmp_path: Path):
    with pytest.raises(ValueError, match="not a file"):
        inspect_media(tmp_path)
    broken = tmp_path / "broken.wav"
    broken.write_bytes(b"broken")
    with pytest.raises(ValueError, match="invalid WAV"):
        inspect_media(broken)
    large = tmp_path / "large.mkv"
    large.write_bytes(b"123")
    with pytest.raises(ValueError, match="size limit"):
        inspect_media(large, max_file_bytes=2)


def test_inspect_media_reads_flac_duration_and_average_bitrate(tmp_path: Path):
    target = tmp_path / "audio.flac"
    _write_flac(
        target,
        sample_rate=44100,
        channels=2,
        bits_per_sample=16,
        total_samples=44100 * 3,
        audio_bytes=b"\0" * 5000,
    )

    info = inspect_media(target)

    assert info.length_seconds == 3
    assert info.audio_format == "FLAC"
    assert info.audio_bitrate == round(target.stat().st_size * 8 / 3 / 1000)


def test_inspect_media_flac_with_unknown_sample_count_has_no_duration(tmp_path: Path):
    target = tmp_path / "streamed.flac"
    _write_flac(
        target, sample_rate=44100, channels=2, bits_per_sample=16, total_samples=0,
    )

    info = inspect_media(target)

    assert info.audio_format == "FLAC"
    assert info.length_seconds is None
    assert info.audio_bitrate is None


def test_inspect_media_rejects_malformed_flac_files(tmp_path: Path):
    missing_marker = tmp_path / "missing-marker.flac"
    missing_marker.write_bytes(b"not a flac file")
    with pytest.raises(ValueError, match="missing fLaC marker"):
        inspect_media(missing_marker)

    truncated_header = tmp_path / "truncated-header.flac"
    truncated_header.write_bytes(b"fLaC\x80\x00")
    with pytest.raises(ValueError, match="truncated metadata block header"):
        inspect_media(truncated_header)

    wrong_block = tmp_path / "wrong-block.flac"
    wrong_block.write_bytes(b"fLaC" + bytes([0x81]) + (34).to_bytes(3, "big"))
    with pytest.raises(ValueError, match="missing STREAMINFO block"):
        inspect_media(wrong_block)

    truncated_info = tmp_path / "truncated-info.flac"
    header = bytes([0x80]) + (34).to_bytes(3, "big")
    truncated_info.write_bytes(b"fLaC" + header + b"\x00" * 10)
    with pytest.raises(ValueError, match="truncated STREAMINFO block"):
        inspect_media(truncated_info)


def test_inspect_media_reads_aiff_pcm_duration_and_exact_bitrate(tmp_path: Path):
    target = tmp_path / "audio.aiff"
    _write_aiff(
        target, sample_rate=44100.0, channels=2, bits_per_sample=16,
        total_samples=44100 * 2,
    )

    info = inspect_media(target)

    assert info.length_seconds == 2
    assert info.audio_format == "AIFF"
    assert info.audio_bitrate == round(44100 * 16 * 2 / 1000)


def test_inspect_media_reads_aifc_pcm_variant_with_exact_bitrate(tmp_path: Path):
    target = tmp_path / "audio.aifc"
    _write_aiff(
        target, sample_rate=48000.0, channels=1, bits_per_sample=16,
        total_samples=48000, form_type=b"AIFC", compression_type=b"sowt",
    )

    info = inspect_media(target)

    assert info.length_seconds == 1
    assert info.audio_bitrate == round(48000 * 16 * 1 / 1000)


def test_inspect_media_reads_aifc_compressed_variant_with_average_bitrate(
    tmp_path: Path,
):
    target = tmp_path / "audio.aifc"
    _write_aiff(
        target, sample_rate=44100.0, channels=2, bits_per_sample=16,
        total_samples=44100 * 3, form_type=b"AIFC", compression_type=b"ima4",
        audio_bytes=b"\0" * 5000,
    )

    info = inspect_media(target)

    assert info.length_seconds == 3
    assert info.audio_bitrate == round(target.stat().st_size * 8 / 3 / 1000)


def test_inspect_media_aiff_with_zero_sample_count_has_no_duration(tmp_path: Path):
    target = tmp_path / "streamed.aiff"
    _write_aiff(
        target, sample_rate=44100.0, channels=2, bits_per_sample=16,
        total_samples=0,
    )

    info = inspect_media(target)

    assert info.audio_format == "AIFF"
    assert info.length_seconds is None
    assert info.audio_bitrate is None


def test_inspect_media_rejects_malformed_aiff_files(tmp_path: Path):
    missing_marker = tmp_path / "missing-marker.aiff"
    missing_marker.write_bytes(b"not an aiff file at all!!!!")
    with pytest.raises(ValueError, match="missing FORM/AIFF marker"):
        inspect_media(missing_marker)

    truncated_chunk = tmp_path / "truncated-chunk.aiff"
    truncated_chunk.write_bytes(
        b"FORM" + (18).to_bytes(4, "big") + b"AIFF"
        + b"COMM" + (18).to_bytes(4, "big") + b"\x00" * 4
    )
    with pytest.raises(ValueError, match="truncated chunk"):
        inspect_media(truncated_chunk)

    missing_comm = tmp_path / "missing-comm.aiff"
    missing_comm.write_bytes(
        b"FORM" + (12).to_bytes(4, "big") + b"AIFF"
        + b"JUNK" + (0).to_bytes(4, "big")
    )
    with pytest.raises(ValueError, match="missing COMM chunk"):
        inspect_media(missing_comm)


def test_cli_import_media_is_atomic_before_save(tmp_path: Path):
    catalog = tmp_path / "catalog.json"
    good = tmp_path / "good.mkv"
    good.write_bytes(b"media")
    assert main(["-c", str(catalog), "import-media", str(good)]) == 0
    assert load(catalog).get(1).title == "good"
    previous = catalog.read_bytes()
    assert main([
        "-c", str(catalog), "import-media", str(good), str(tmp_path / "missing.mkv")
    ]) == 2
    assert catalog.read_bytes() == previous


def test_discover_media_expands_directories_deterministically_and_bounds_count(
    tmp_path: Path,
):
    (tmp_path / "b.mkv").write_bytes(b"b")
    (tmp_path / "a.mkv").write_bytes(b"a")
    nested = tmp_path / "nested"
    nested.mkdir()
    (nested / "c.mkv").write_bytes(b"c")
    assert [path.name for path in discover_media([tmp_path])] == ["a.mkv", "b.mkv"]
    assert [path.name for path in discover_media([tmp_path], recursive=True)] == [
        "a.mkv", "b.mkv", "c.mkv"
    ]
    with pytest.raises(ValueError, match="file-count limit"):
        discover_media([tmp_path], recursive=True, max_files=2)
    assert [path.name for path in discover_media(
        [tmp_path], recursive=True, extensions={"MKV"}
    )] == ["a.mkv", "b.mkv", "c.mkv"]


def test_cli_import_media_directory_recursively(tmp_path: Path):
    media = tmp_path / "media"
    nested = media / "nested"
    nested.mkdir(parents=True)
    (media / "one.mkv").write_bytes(b"one")
    (nested / "two.mkv").write_bytes(b"two")
    (media / "ignored.txt").write_bytes(b"ignored")
    catalog = tmp_path / "catalog.json"
    assert main([
        "-c", str(catalog), "import-media", str(media), "--recursive",
        "--extensions", "mkv,mp4",
    ]) == 0
    assert [movie.title for movie in load(catalog)] == ["two", "one"]
