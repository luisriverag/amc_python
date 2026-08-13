import wave
from pathlib import Path

import pytest

from amc.media import discover_media, inspect_media, movie_from_media
from amc.cli import main
from amc.storage import load


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
