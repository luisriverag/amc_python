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


def _mp3_frame(*, bitrate_kbps: int = 128, sample_rate: int = 44100, padding: int = 0) -> bytes:
    """Build one zero-padded MPEG1 Layer III frame at the given bitrate/rate."""
    bitrate_table = (0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, -1)
    bitrate_index = bitrate_table.index(bitrate_kbps)
    sample_rate_index = {44100: 0, 48000: 1, 32000: 2}[sample_rate]
    word = 0xFFE00000
    word |= 0b11 << 19  # MPEG1
    word |= 0b01 << 17  # Layer III
    word |= 0b1 << 16  # protection bit set (no CRC), unused by the parser
    word |= bitrate_index << 12
    word |= sample_rate_index << 10
    word |= padding << 9
    frame_length = 144 * bitrate_kbps * 1000 // sample_rate + padding
    header = word.to_bytes(4, "big")
    return header + b"\0" * (frame_length - len(header))


def _write_mp3(
    target: Path, *, frames: int, bitrate_kbps: int = 128, sample_rate: int = 44100,
) -> None:
    frame = _mp3_frame(bitrate_kbps=bitrate_kbps, sample_rate=sample_rate)
    target.write_bytes(frame * frames)


def test_inspect_media_reads_mp3_cbr_duration_and_bitrate(tmp_path: Path):
    target = tmp_path / "audio.mp3"
    _write_mp3(target, frames=50, bitrate_kbps=128, sample_rate=44100)

    info = inspect_media(target)

    assert info.audio_format == "MP3"
    assert info.audio_bitrate == 128
    expected_length = round(target.stat().st_size * 8 / (128 * 1000))
    assert info.length_seconds == expected_length


def test_inspect_media_mp3_skips_a_leading_id3v2_tag(tmp_path: Path):
    target = tmp_path / "tagged.mp3"
    tag_body = b"\0" * 100
    tag = b"ID3" + bytes([4, 0, 0]) + bytes([
        (len(tag_body) >> 21) & 0x7F, (len(tag_body) >> 14) & 0x7F,
        (len(tag_body) >> 7) & 0x7F, len(tag_body) & 0x7F,
    ]) + tag_body
    frame = _mp3_frame(bitrate_kbps=192, sample_rate=48000)
    target.write_bytes(tag + frame * 20)

    info = inspect_media(target)

    assert info.audio_format == "MP3"
    assert info.audio_bitrate == 192


def test_inspect_media_mp3_ignores_a_trailing_id3v1_tag(tmp_path: Path):
    target = tmp_path / "id3v1.mp3"
    _write_mp3(target, frames=30, bitrate_kbps=128, sample_rate=44100)
    audio_only_size = target.stat().st_size
    with target.open("ab") as stream:
        stream.write(b"TAG" + b"\0" * 125)

    info = inspect_media(target)

    assert info.audio_bitrate == 128
    assert info.length_seconds == round(audio_only_size * 8 / (128 * 1000))


def test_inspect_media_rejects_files_with_no_mp3_frame_sync(tmp_path: Path):
    target = tmp_path / "not-really.mp3"
    target.write_bytes(b"not an mp3 file" * 100)
    with pytest.raises(ValueError, match="no MPEG audio frame sync found"):
        inspect_media(target)


def test_inspect_media_mp3_layer1_frame_length_formula(tmp_path: Path):
    """Exercise the Layer I ((coefficient * bitrate / rate + padding) * 4)
    frame-length formula, distinct from the Layer II/III formula every other
    MP3 test uses."""
    bitrate_kbps, sample_rate = 256, 44100
    word = 0xFFE00000
    word |= 0b11 << 19  # MPEG1
    word |= 0b11 << 17  # Layer I
    bitrate_table = (0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, -1)
    word |= bitrate_table.index(bitrate_kbps) << 12
    word |= 0 << 10  # 44100
    frame_length = (12 * bitrate_kbps * 1000 // sample_rate) * 4
    frame = word.to_bytes(4, "big") + b"\0" * (frame_length - 4)
    target = tmp_path / "layer1.mp3"
    target.write_bytes(frame * 10)

    info = inspect_media(target)

    assert info.audio_bitrate == bitrate_kbps
    assert info.length_seconds == round(target.stat().st_size * 8 / (bitrate_kbps * 1000))


def test_inspect_media_mp3_scans_past_a_false_sync_before_a_real_frame(tmp_path: Path):
    """A byte sequence that starts a valid 11-bit sync but decodes to a
    reserved/invalid header (bitrate index 15, "bad") must be skipped rather
    than rejecting the whole file, as long as a real frame follows."""
    invalid = bytes([0xFF, 0xFB, 0xF0, 0x00])  # sync + reserved bitrate index 15
    frame = _mp3_frame(bitrate_kbps=128, sample_rate=44100)
    target = tmp_path / "false-sync.mp3"
    target.write_bytes(invalid + frame * 5)

    info = inspect_media(target)

    assert info.audio_format == "MP3"
    assert info.audio_bitrate == 128


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


def test_cli_import_media_progress_reports_to_stderr(
    tmp_path: Path, capsys: pytest.CaptureFixture[str]
):
    catalog = tmp_path / "catalog.json"
    first = tmp_path / "first.mkv"
    first.write_bytes(b"one")
    second = tmp_path / "second.mkv"
    second.write_bytes(b"two")

    assert main([
        "-c", str(catalog), "import-media", str(first), str(second), "--progress",
    ]) == 0

    captured = capsys.readouterr()
    assert captured.err.splitlines() == [
        "Inspected 1/2 file(s)", "Inspected 2/2 file(s)",
    ]
    assert captured.out.strip() == "Imported 2 media file(s)"
    assert load(catalog).get(1).title == "first"
    assert load(catalog).get(2).title == "second"


def test_cli_import_media_without_progress_flag_is_silent_on_stderr(
    tmp_path: Path, capsys: pytest.CaptureFixture[str]
):
    catalog = tmp_path / "catalog.json"
    media = tmp_path / "movie.mkv"
    media.write_bytes(b"data")

    assert main(["-c", str(catalog), "import-media", str(media)]) == 0

    assert capsys.readouterr().err == ""


def test_cli_import_media_interrupted_during_inspection_leaves_catalog_untouched(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    """An import-media scan is only committed after every file is inspected,
    so interrupting the scan (Ctrl+C, or any exception) never partially
    writes the catalog — the same atomic-or-nothing guarantee as every other
    CatalogService bulk mutation."""
    catalog = tmp_path / "catalog.json"
    first = tmp_path / "first.mkv"
    first.write_bytes(b"one")
    second = tmp_path / "second.mkv"
    second.write_bytes(b"two")
    inspected = []

    def interrupt_on_second_file(path):
        inspected.append(path)
        if len(inspected) == 2:
            raise KeyboardInterrupt
        return movie_from_media(path)

    monkeypatch.setattr("amc.cli.movie_from_media", interrupt_on_second_file)

    with pytest.raises(KeyboardInterrupt):
        main(["-c", str(catalog), "import-media", str(first), str(second)])

    assert inspected == [first, second]
    assert not catalog.exists()


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
