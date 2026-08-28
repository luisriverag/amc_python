import base64
import math
import wave
from pathlib import Path

import pytest
from PIL import Image

from amc.media import (
    attach_media_pictures,
    discover_media,
    inspect_media,
    merge_media_parts,
    movie_from_media,
)
from amc.model import Movie
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
    return bytes(
        [
            (expon >> 8) & 0xFF,
            expon & 0xFF,
            (himant >> 24) & 0xFF,
            (himant >> 16) & 0xFF,
            (himant >> 8) & 0xFF,
            himant & 0xFF,
            (lomant >> 24) & 0xFF,
            (lomant >> 16) & 0xFF,
            (lomant >> 8) & 0xFF,
            lomant & 0xFF,
        ]
    )


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
        "Movie",
        "Movie.mkv",
        "MKV",
        5,
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


def test_movie_from_media_converts_length_seconds_to_minutes(tmp_path: Path):
    """`Movie.length` is minutes (upstream's documented unit for its own
    "Length" field), not the seconds `MediaInfo.length_seconds` reports."""
    target = tmp_path / "audio.wav"
    with wave.open(str(target), "wb") as stream:
        stream.setnchannels(1)
        stream.setsampwidth(2)
        stream.setframerate(1)
        stream.writeframes(b"\0" * 240)  # 240 frames at 1 Hz = 120 seconds

    info = inspect_media(target)
    movie = movie_from_media(target)

    assert info.length_seconds == 120
    assert movie.length == 2


def test_movie_from_media_leaves_length_unset_when_duration_is_unknown(tmp_path: Path):
    target = tmp_path / "unknown.mkv"
    target.write_bytes(b"media")

    movie = movie_from_media(target)

    assert movie.length is None


def test_movie_from_media_supports_deferred_and_skipped_extraction(tmp_path: Path):
    target = tmp_path / "Movie.mkv"
    target.write_bytes(b"media")

    deferred = movie_from_media(target, extraction="defer")
    skipped = movie_from_media(target, extraction="skip")

    assert deferred.file_size == 5
    assert deferred.extras == {"media_path": str(target), "media_analysis": "pending"}
    assert skipped.file_size is None
    assert skipped.extras == {"media_path": str(target), "media_analysis": "skipped"}
    with pytest.raises(ValueError, match="extraction mode"):
        movie_from_media(target, extraction="later")


def test_movie_from_media_can_clean_filename_derived_title(tmp_path: Path):
    target = tmp_path / "Movie.2024.1080p.mkv"
    target.write_bytes(b"media")

    movie = movie_from_media(target, title_filter_pattern=r"[._]|\b(?:2024|1080p)\b")

    assert movie.title == "Movie"
    with pytest.raises(ValueError, match="invalid title filter"):
        movie_from_media(target, title_filter_pattern="[")
    with pytest.raises(ValueError, match="1 to 256"):
        movie_from_media(target, title_filter_pattern="")


def test_merge_media_parts_preserves_first_fields_and_combines_numeric_facts(tmp_path: Path):
    first_path = tmp_path / "Movie CD1.avi"
    second_path = tmp_path / "Movie cd2.avi"
    first = Movie(
        title="Movie CD1",
        media_label="Movie CD1.avi",
        length=60,
        file_size=100,
        video_bitrate=1000,
        audio_bitrate=100,
        extras={"media_path": str(first_path)},
    )
    second = Movie(
        title="Movie cd2",
        media_label="Movie cd2.avi",
        length=30,
        file_size=50,
        video_bitrate=1400,
        audio_bitrate=200,
        extras={"media_path": str(second_path)},
    )

    movies = merge_media_parts([(first_path, first), (second_path, second)])

    assert len(movies) == 1
    assert movies[0].title == "Movie CD1"
    assert movies[0].media_label == "Movie CD1.avi"
    assert (movies[0].length, movies[0].file_size, movies[0].media_count) == (90, 150, 2)
    assert (movies[0].video_bitrate, movies[0].audio_bitrate) == (1200, 150)
    assert movies[0].extras == {
        "media_path": str(first_path),
        "media_parts": [str(first_path), str(second_path)],
    }


def test_merge_media_parts_requires_adjacent_same_directory_matches_and_valid_regex(
    tmp_path: Path,
):
    paths = [tmp_path / "Film CD1.mkv", tmp_path / "Other.mkv", tmp_path / "Film CD2.mkv"]
    movies = [Movie(title=path.stem) for path in paths]
    assert len(merge_media_parts(list(zip(paths, movies)))) == 3
    other_directory = tmp_path / "other" / "Film CD2.mkv"
    assert len(merge_media_parts([(paths[0], movies[0]), (other_directory, movies[2])])) == 2
    custom = merge_media_parts(
        [(tmp_path / "Film part-1.mkv", movies[0]), (tmp_path / "Film part-2.mkv", movies[2])],
        disk_tag_pattern=r"(?i)part-[0-9]+",
    )
    assert len(custom) == 1
    with pytest.raises(ValueError, match="invalid disk tag pattern"):
        merge_media_parts([], disk_tag_pattern="[")
    with pytest.raises(ValueError, match="1 to 256"):
        merge_media_parts([], disk_tag_pattern="")


def test_attach_media_pictures_prefers_same_stem_and_can_link_or_embed(tmp_path: Path):
    media = tmp_path / "Movie.mkv"
    media.write_bytes(b"movie")
    folder_picture = tmp_path / "folder.png"
    Image.new("RGB", (2, 2), "blue").save(folder_picture)
    same_stem = tmp_path / "Movie.JPG"
    Image.new("RGB", (2, 2), "red").save(same_stem)
    source = Movie(title="Movie")

    linked = attach_media_pictures([(media, source)])[0]
    embedded = attach_media_pictures([(media, source)], embed=True)[0]

    assert linked.picture == str(same_stem)
    assert "native_picture_base64" not in linked.extras
    assert embedded.picture == "Movie.JPG"
    assert base64.b64decode(embedded.extras["native_picture_base64"]) == same_stem.read_bytes()
    assert source.picture == ""


def test_attach_media_pictures_uses_configured_folder_name_and_validates_limits(
    tmp_path: Path,
):
    media = tmp_path / "Movie.mkv"
    media.write_bytes(b"movie")
    poster = tmp_path / "poster.png"
    Image.new("RGB", (3, 2), "green").save(poster)
    source = Movie(title="Movie")

    assert attach_media_pictures([(media, source)], folder_picture_name="poster")[0].picture == str(
        poster
    )
    with pytest.raises(ValueError, match="without a path"):
        attach_media_pictures([], folder_picture_name="../poster")
    with pytest.raises(ValueError, match="size limit"):
        attach_media_pictures(
            [(media, source)], embed=True, folder_picture_name="poster", max_bytes=1
        )
    with pytest.raises(ValueError, match="pixel limit"):
        attach_media_pictures(
            [(media, source)], embed=True, folder_picture_name="poster", max_pixels=5
        )


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
        target,
        sample_rate=44100,
        channels=2,
        bits_per_sample=16,
        total_samples=0,
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
        target,
        sample_rate=44100.0,
        channels=2,
        bits_per_sample=16,
        total_samples=44100 * 2,
    )

    info = inspect_media(target)

    assert info.length_seconds == 2
    assert info.audio_format == "AIFF"
    assert info.audio_bitrate == round(44100 * 16 * 2 / 1000)


def test_inspect_media_reads_aifc_pcm_variant_with_exact_bitrate(tmp_path: Path):
    target = tmp_path / "audio.aifc"
    _write_aiff(
        target,
        sample_rate=48000.0,
        channels=1,
        bits_per_sample=16,
        total_samples=48000,
        form_type=b"AIFC",
        compression_type=b"sowt",
    )

    info = inspect_media(target)

    assert info.length_seconds == 1
    assert info.audio_bitrate == round(48000 * 16 * 1 / 1000)


def test_inspect_media_reads_aifc_compressed_variant_with_average_bitrate(
    tmp_path: Path,
):
    target = tmp_path / "audio.aifc"
    _write_aiff(
        target,
        sample_rate=44100.0,
        channels=2,
        bits_per_sample=16,
        total_samples=44100 * 3,
        form_type=b"AIFC",
        compression_type=b"ima4",
        audio_bytes=b"\0" * 5000,
    )

    info = inspect_media(target)

    assert info.length_seconds == 3
    assert info.audio_bitrate == round(target.stat().st_size * 8 / 3 / 1000)


def test_inspect_media_aiff_with_zero_sample_count_has_no_duration(tmp_path: Path):
    target = tmp_path / "streamed.aiff"
    _write_aiff(
        target,
        sample_rate=44100.0,
        channels=2,
        bits_per_sample=16,
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
        b"FORM"
        + (18).to_bytes(4, "big")
        + b"AIFF"
        + b"COMM"
        + (18).to_bytes(4, "big")
        + b"\x00" * 4
    )
    with pytest.raises(ValueError, match="truncated chunk"):
        inspect_media(truncated_chunk)

    missing_comm = tmp_path / "missing-comm.aiff"
    missing_comm.write_bytes(
        b"FORM" + (12).to_bytes(4, "big") + b"AIFF" + b"JUNK" + (0).to_bytes(4, "big")
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
    target: Path,
    *,
    frames: int,
    bitrate_kbps: int = 128,
    sample_rate: int = 44100,
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
    tag = (
        b"ID3"
        + bytes([4, 0, 0])
        + bytes(
            [
                (len(tag_body) >> 21) & 0x7F,
                (len(tag_body) >> 14) & 0x7F,
                (len(tag_body) >> 7) & 0x7F,
                len(tag_body) & 0x7F,
            ]
        )
        + tag_body
    )
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


def _ogg_page(
    *,
    payload: bytes,
    granule: int,
    serial: int = 42,
    sequence: int = 0,
    header_type: int = 0,
) -> bytes:
    """Build one Ogg page: a 27-byte fixed header, its lacing segment
    table, then the payload. The checksum field is left zero since
    `_inspect_ogg_vorbis` never validates it (Ogg's CRC uses a non-standard
    polynomial not worth reimplementing for a synthetic fixture)."""
    segments = []
    remaining = len(payload)
    while True:
        chunk = min(remaining, 255)
        segments.append(chunk)
        remaining -= chunk
        if chunk < 255:
            break
    header = (
        b"OggS"
        + bytes([0, header_type])
        + granule.to_bytes(8, "little", signed=True)
        + serial.to_bytes(4, "little")
        + sequence.to_bytes(4, "little")
        + b"\x00\x00\x00\x00"
        + bytes([len(segments)])
        + bytes(segments)
    )
    return header + payload


def _vorbis_identification_packet(
    *,
    sample_rate: int = 44100,
    bitrate_nominal: int = 128000,
    channels: int = 2,
) -> bytes:
    return (
        b"\x01vorbis"
        + (0).to_bytes(4, "little")
        + bytes([channels])
        + sample_rate.to_bytes(4, "little")
        + (0).to_bytes(4, "little", signed=True)
        + bitrate_nominal.to_bytes(4, "little", signed=True)
        + (0).to_bytes(4, "little", signed=True)
        + bytes([0, 1])
    )


def _write_ogg_vorbis(
    target: Path,
    *,
    sample_rate: int = 44100,
    bitrate_nominal: int = 128000,
    total_samples: int = 44100 * 5,
    serial: int = 42,
) -> None:
    identification = _vorbis_identification_packet(
        sample_rate=sample_rate, bitrate_nominal=bitrate_nominal
    )
    first_page = _ogg_page(
        payload=identification, granule=0, serial=serial, sequence=0, header_type=0x02
    )
    last_page = _ogg_page(
        payload=b"\x00" * 16,
        granule=total_samples,
        serial=serial,
        sequence=1,
        header_type=0x04,
    )
    target.write_bytes(first_page + last_page)


def test_inspect_media_reads_ogg_vorbis_duration_and_nominal_bitrate(tmp_path: Path):
    target = tmp_path / "audio.ogg"
    _write_ogg_vorbis(target, sample_rate=44100, bitrate_nominal=128000, total_samples=44100 * 5)

    info = inspect_media(target)

    assert info.audio_format == "OGG"
    assert info.audio_bitrate == 128
    assert info.length_seconds == 5


def test_inspect_media_ogg_vorbis_falls_back_to_average_bitrate_when_nominal_is_zero(
    tmp_path: Path,
):
    target = tmp_path / "vbr.ogg"
    _write_ogg_vorbis(target, sample_rate=44100, bitrate_nominal=0, total_samples=44100 * 4)

    info = inspect_media(target)

    assert info.length_seconds == 4
    expected_bitrate = round(target.stat().st_size * 8 / 4 / 1000)
    assert info.audio_bitrate == expected_bitrate


def test_inspect_media_rejects_ogg_without_a_marker(tmp_path: Path):
    target = tmp_path / "not-really.ogg"
    target.write_bytes(b"not an ogg file" * 10)
    with pytest.raises(ValueError, match="missing OggS marker"):
        inspect_media(target)


def test_inspect_media_rejects_ogg_with_a_non_vorbis_first_packet(tmp_path: Path):
    target = tmp_path / "opus.ogg"
    payload = b"OpusHead" + b"\x00" * 16
    target.write_bytes(_ogg_page(payload=payload, granule=0, header_type=0x02))
    with pytest.raises(ValueError, match="missing Vorbis identification header"):
        inspect_media(target)


def _mp4_box(box_type: bytes, payload: bytes) -> bytes:
    return (8 + len(payload)).to_bytes(4, "big") + box_type + payload


def _mvhd_box(*, timescale: int, duration: int, version: int = 0) -> bytes:
    if version == 1:
        payload = (
            bytes([1, 0, 0, 0])
            + b"\x00" * 8
            + b"\x00" * 8
            + timescale.to_bytes(4, "big")
            + duration.to_bytes(8, "big")
        )
    else:
        payload = (
            bytes([0, 0, 0, 0])
            + b"\x00" * 4
            + b"\x00" * 4
            + timescale.to_bytes(4, "big")
            + duration.to_bytes(4, "big")
        )
    payload += b"\x00" * (36 + 4 + 2 + 10 + 36 + 24 + 4)  # rest of mvhd, unused
    return _mp4_box(b"mvhd", payload)


def _write_mp4(
    target: Path,
    *,
    timescale: int = 600,
    duration: int = 3000,
    version: int = 0,
    padding: bytes = b"\x00" * 500,
) -> None:
    ftyp = _mp4_box(b"ftyp", b"isom" + (0).to_bytes(4, "big") + b"isomiso2mp41")
    moov = _mp4_box(b"moov", _mvhd_box(timescale=timescale, duration=duration, version=version))
    mdat = _mp4_box(b"mdat", padding)
    target.write_bytes(ftyp + moov + mdat)


def test_inspect_media_reads_mp4_duration_and_average_bitrate(tmp_path: Path):
    target = tmp_path / "movie.mp4"
    _write_mp4(target, timescale=600, duration=3000)

    info = inspect_media(target)

    assert info.video_format == "MP4"
    assert info.length_seconds == 5
    assert info.video_bitrate == round(target.stat().st_size * 8 / 5 / 1000)
    assert info.audio_format == ""
    assert info.audio_bitrate is None


def test_inspect_media_reads_mp4_mvhd_version_1_with_64_bit_fields(tmp_path: Path):
    target = tmp_path / "movie64.mp4"
    _write_mp4(target, timescale=1000, duration=8000, version=1)

    info = inspect_media(target)

    assert info.length_seconds == 8
    assert info.video_bitrate == round(target.stat().st_size * 8 / 8 / 1000)


def test_inspect_media_mp4_skips_a_large_preceding_box_via_seek(tmp_path: Path):
    """A box before `moov` must be skipped by seeking past its declared
    size, not by reading its payload into memory (`mdat` can be huge)."""
    target = tmp_path / "faststart.mp4"
    ftyp = _mp4_box(b"ftyp", b"isom" + (0).to_bytes(4, "big") + b"isomiso2mp41")
    free = _mp4_box(b"free", b"\x00" * 200_000)
    moov = _mp4_box(b"moov", _mvhd_box(timescale=600, duration=3000))
    target.write_bytes(ftyp + free + moov)

    info = inspect_media(target)

    assert info.length_seconds == 5


def test_inspect_media_m4a_uses_audio_fields_not_video(tmp_path: Path):
    target = tmp_path / "song.m4a"
    _write_mp4(target, timescale=600, duration=1200)

    info = inspect_media(target)

    assert info.audio_format == "M4A"
    assert info.length_seconds == 2
    assert info.audio_bitrate == round(target.stat().st_size * 8 / 2 / 1000)
    assert info.video_format == ""
    assert info.video_bitrate is None


def test_inspect_media_mov_suffix_reports_its_own_label(tmp_path: Path):
    target = tmp_path / "clip.mov"
    _write_mp4(target, timescale=600, duration=3000)

    info = inspect_media(target)

    assert info.video_format == "MOV"


def test_inspect_media_rejects_mp4_without_a_moov_box(tmp_path: Path):
    target = tmp_path / "no-moov.mp4"
    ftyp = _mp4_box(b"ftyp", b"isom" + (0).to_bytes(4, "big") + b"isomiso2mp41")
    mdat = _mp4_box(b"mdat", b"\x00" * 32)
    target.write_bytes(ftyp + mdat)
    with pytest.raises(ValueError, match="missing moov box"):
        inspect_media(target)


def test_inspect_media_rejects_mp4_moov_without_an_mvhd_box(tmp_path: Path):
    target = tmp_path / "no-mvhd.mp4"
    moov = _mp4_box(b"moov", _mp4_box(b"iods", b"\x00" * 8))
    target.write_bytes(moov)
    with pytest.raises(ValueError, match="missing mvhd box"):
        inspect_media(target)


def test_cli_import_media_is_atomic_before_save(tmp_path: Path):
    catalog = tmp_path / "catalog.json"
    good = tmp_path / "good.mkv"
    good.write_bytes(b"media")
    assert main(["-c", str(catalog), "import-media", str(good)]) == 0
    assert load(catalog).get(1).title == "good"
    previous = catalog.read_bytes()
    assert main(["-c", str(catalog), "import-media", str(good), str(tmp_path / "missing.mkv")]) == 2
    assert catalog.read_bytes() == previous


def test_cli_import_media_progress_reports_to_stderr(
    tmp_path: Path, capsys: pytest.CaptureFixture[str]
):
    catalog = tmp_path / "catalog.json"
    first = tmp_path / "first.mkv"
    first.write_bytes(b"one")
    second = tmp_path / "second.mkv"
    second.write_bytes(b"two")

    assert (
        main(
            [
                "-c",
                str(catalog),
                "import-media",
                str(first),
                str(second),
                "--progress",
            ]
        )
        == 0
    )

    captured = capsys.readouterr()
    assert captured.err.splitlines() == [
        "Inspected 1/2 file(s)",
        "Inspected 2/2 file(s)",
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

    def interrupt_on_second_file(path, **_kwargs):
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
        "a.mkv",
        "b.mkv",
        "c.mkv",
    ]
    deeper = nested / "deeper"
    deeper.mkdir()
    (deeper / "d.mkv").write_bytes(b"d")
    assert [path.name for path in discover_media([tmp_path], max_depth=0)] == [
        "a.mkv",
        "b.mkv",
    ]
    assert [path.name for path in discover_media([tmp_path], max_depth=1)] == [
        "a.mkv",
        "b.mkv",
        "c.mkv",
    ]
    with pytest.raises(ValueError, match="maximum depth"):
        discover_media([tmp_path], max_depth=-1)
    with pytest.raises(ValueError, match="file-count limit"):
        discover_media([tmp_path], recursive=True, max_files=2)
    assert [
        path.name for path in discover_media([tmp_path], recursive=True, extensions={"MKV"})
    ] == ["a.mkv", "b.mkv", "c.mkv", "d.mkv"]


def test_discover_media_depth_limit_prunes_traversal(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    nested = tmp_path / "nested"
    deeper = nested / "deeper"
    deeper.mkdir(parents=True)
    (deeper / "hidden.mkv").write_bytes(b"hidden")
    visited: list[Path] = []
    original_iterdir = Path.iterdir

    def recording_iterdir(path: Path):
        visited.append(path)
        return original_iterdir(path)

    monkeypatch.setattr(Path, "iterdir", recording_iterdir)

    assert discover_media([tmp_path], max_depth=1) == []
    assert visited == [tmp_path, nested]


def test_cli_import_media_directory_recursively(tmp_path: Path):
    media = tmp_path / "media"
    nested = media / "nested"
    nested.mkdir(parents=True)
    (media / "one.mkv").write_bytes(b"one")
    (nested / "two.mkv").write_bytes(b"two")
    (media / "ignored.txt").write_bytes(b"ignored")
    catalog = tmp_path / "catalog.json"
    assert (
        main(
            [
                "-c",
                str(catalog),
                "import-media",
                str(media),
                "--recursive",
                "--extensions",
                "mkv,mp4",
            ]
        )
        == 0
    )
    assert [movie.title for movie in load(catalog)] == ["two", "one"]


def test_cli_import_media_can_merge_adjacent_multi_part_files(tmp_path: Path):
    media = tmp_path / "media"
    media.mkdir()
    (media / "Movie CD1.mkv").write_bytes(b"one")
    (media / "Movie CD2.mkv").write_bytes(b"two")
    catalog = tmp_path / "catalog.json"

    assert main(["-c", str(catalog), "import-media", str(media), "--merge-parts"]) == 0

    movies = list(load(catalog))
    assert len(movies) == 1
    assert movies[0].title == "Movie CD1"
    assert movies[0].media_count == 2
    assert movies[0].file_size == 6


def test_cli_import_media_can_embed_discovered_picture(tmp_path: Path):
    media = tmp_path / "Movie.mkv"
    media.write_bytes(b"movie")
    picture = tmp_path / "Movie.png"
    Image.new("RGB", (2, 2), "red").save(picture)
    catalog = tmp_path / "catalog.json"

    assert (
        main(
            [
                "-c",
                str(catalog),
                "import-media",
                str(media),
                "--import-pictures",
                "embed",
            ]
        )
        == 0
    )

    movie = load(catalog).get(1)
    assert movie.picture == "Movie.png"
    assert base64.b64decode(movie.extras["native_picture_base64"]) == picture.read_bytes()


def test_cli_import_media_can_defer_metadata_extraction(tmp_path: Path):
    media = tmp_path / "Movie.mkv"
    media.write_bytes(b"movie")
    catalog = tmp_path / "catalog.json"

    assert main(["-c", str(catalog), "import-media", str(media), "--extract", "defer"]) == 0

    movie = load(catalog).get(1)
    assert movie.file_size == 5
    assert movie.extras["media_analysis"] == "pending"


def test_cli_import_media_supports_default_extensions_and_title_cleanup(tmp_path: Path):
    media = tmp_path / "media"
    media.mkdir()
    (media / "Movie.1080p.mkv").write_bytes(b"movie")
    (media / "notes.txt").write_bytes(b"notes")
    catalog = tmp_path / "catalog.json"

    assert (
        main(
            [
                "-c",
                str(catalog),
                "import-media",
                str(media),
                "--extensions",
                "default",
                "--title-filter-regex",
                r"[.]|1080p",
            ]
        )
        == 0
    )
    assert [movie.title for movie in load(catalog)] == ["Movie"]
