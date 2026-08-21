import os
import stat
from pathlib import Path

import pytest

from amc.scripts import (
    configure_script,
    discover_scripts,
    inspect_script,
    load_script_configuration,
    preview_script_merge,
    save_script_configuration,
)
from amc.model import Movie
from amc.cli import main
import json

REAL_SCRIPT_FIXTURES = Path(__file__).parent.parent / "fixtures" / "scripts"


def test_inspect_script_reads_upstream_style_metadata_without_execution(tmp_path: Path):
    target = tmp_path / "example.ifs"
    target.write_text("""(*
[Infos]
Authors=Example Author
Title=Example Provider
Description=Metadata only
Language=English
Version=1.2
Requires=4.2
License=GPL
GetInfo=0
RequiresMovies=1
[Options]
Mode=1|0|0=Fast|1=Complete
[Parameters]
Query=Alien|Default title|Title to search
[Fields]
Excluded=Comments,URL
Picture=0
[ExtraFields]
AddExtras=0
DeleteExtras=1
ModifyExtras=0
Excluded=Trailer;Fan Art
Picture=0
[Static]
SessionToken=secret-value
Page=3
*)
begin
  raise_if_executed;
end.
""", encoding="utf-8")
    info = inspect_script(target)
    assert (info.title, info.authors, info.version) == (
        "Example Provider", "Example Author", "1.2"
    )
    assert info.get_info is False and info.requires_movies is True
    assert info.options[0].name == "Mode"
    assert info.options[0].values == ((0, "Fast"), (1, "Complete"))
    assert info.parameters[0].description == "Title to search"
    assert info.excluded_fields == ("Comments", "URL")
    assert info.picture is False
    assert (info.add_extras, info.delete_extras, info.modify_extras) == (
        False, True, False
    )
    assert info.excluded_extra_fields == ("Trailer", "Fan Art")
    assert info.extra_picture is False
    assert info.static_names == ("SessionToken", "Page")
    assert "secret-value" not in str(info.to_dict())


def test_inspect_script_marks_old_format_and_bounds_header(tmp_path: Path):
    old = tmp_path / "old.ifs"
    old.write_text("begin end.", encoding="utf-8")
    assert inspect_script(old).legacy_format is True
    large = tmp_path / "large.ifs"
    large.write_bytes(b"x" * (1024 * 1024 + 1))
    with pytest.raises(ValueError, match="size limit"):
        inspect_script(large)


def test_inspect_script_skips_malformed_option_with_diagnostic(tmp_path: Path):
    target = tmp_path / "malformed.ifs"
    target.write_text(
        "(*\n[Infos]\nTitle=Provider\n[Options]\nBroken=not-an-int|0\n"
        "Valid=1|0|0=No|1=Yes\n[Parameters]\nMissingEquals\n*)",
        encoding="utf-8",
    )
    info = inspect_script(target)
    assert [option.name for option in info.options] == ["Valid"]
    assert info.metadata_warnings == ("invalid option entry 1",)


def test_inspect_script_tolerates_bytes_undefined_in_cp1252(tmp_path: Path):
    """Real scripts in other single-byte code pages (found via a genuine
    Polish script contributed for local debugging, not committed to the
    repository) can contain byte values cp1252 leaves undefined -- 0x81,
    0x8D, 0x8F, 0x90, 0x9D -- which Python's cp1252 codec previously raised
    UnicodeDecodeError on instead of degrading gracefully like every other
    malformed-input path in this module."""
    target = tmp_path / "other-codepage.ifs"
    target.write_bytes(
        b"(*\n[Infos]\nTitle=Pol\x9dski\n[Options]\n*)\nbegin end."
    )
    info = inspect_script(target)
    assert info.title == "Pol�ski"
    assert info.legacy_format is False


def test_discover_scripts_reads_the_real_fixture_set_without_error():
    """Genuine AMC "Get Info" scripts, contributed by a user for local
    debugging (see tests/fixtures/scripts/PROVENANCE.md for source and
    per-file license/attribution) -- validates inspect_script/
    discover_scripts against real-world script syntax (multi-line license
    blocks, 30+ option entries, non-ASCII text in several code pages)
    instead of only synthetic headers."""
    infos = discover_scripts(REAL_SCRIPT_FIXTURES)
    names = {Path(info.path).name for info in infos}
    assert names == {
        "Allocine (FR).ifs", "Amazon (FR).ifs", "Filmweb (PL).ifs",
        "IMDB (Actor images).ifs", "IMDB.ifs", "IMDB_ALT.ifs",
        "IMDB_ALT_ES.ifs", "ItalianMultisite (IT).ifs", "MyMovies (IT).ifs",
        "OFDb-mobi-IMDb.ifs", "csfd.cz.ifs",
    }
    for info in infos:
        assert info.legacy_format is False
        assert info.metadata_warnings == ()
        assert info.title
        assert info.license


def test_inspect_script_reads_a_real_cp1250_encoded_script():
    """The real regression case for the cp1252-undefined-byte fix: this
    genuine Polish script previously crashed inspect_script() outright."""
    info = inspect_script(REAL_SCRIPT_FIXTURES / "Filmweb (PL).ifs")
    assert info.title == "filmweb.pl"
    assert info.language == "PL"
    assert info.get_info is True
    assert info.metadata_warnings == ()


def test_inspect_script_reads_a_real_mit_licensed_script():
    info = inspect_script(REAL_SCRIPT_FIXTURES / "IMDB_ALT.ifs")
    assert info.title == "IMDB ( via API )"
    assert info.site == "https://github.com/Purfview/IMDB_ALT"
    assert "MIT License" in info.license
    assert len(info.options) > 20


def test_inspect_script_reads_real_shared_pascal_units():
    """`.pas` shared units aren't discovered by discover_scripts() (it only
    globs *.ifs), but inspect_script() reads any file directly; these three
    are genuine real-world units with their own [Infos] header."""
    for name in ("JsonUtils.pas", "cp1250.pas", "en2pl.pas"):
        info = inspect_script(REAL_SCRIPT_FIXTURES / name)
        assert info.legacy_format is False
        assert info.metadata_warnings == ()
        assert "GPL" in info.license or "General Public License" in info.license


def test_discover_scripts_is_filtered_and_sorted(tmp_path: Path):
    (tmp_path / "b.ifs").write_text("begin end.", encoding="utf-8")
    (tmp_path / "a.ifs").write_text("begin end.", encoding="utf-8")
    (tmp_path / "ignored.txt").write_text("ignored", encoding="utf-8")
    assert [Path(item.path).name for item in discover_scripts(tmp_path)] == ["a.ifs", "b.ifs"]


def test_cli_lists_script_metadata_as_json(tmp_path: Path, capsys):
    (tmp_path / "provider.ifs").write_text("(*\n[Infos]\nTitle=Provider\n*)", encoding="utf-8")
    assert main(["list-scripts", str(tmp_path)]) == 0
    assert json.loads(capsys.readouterr().out)[0]["title"] == "Provider"


def test_configure_script_applies_validated_case_insensitive_inputs(tmp_path: Path):
    target = tmp_path / "provider.ifs"
    target.write_text(
        "(*\n[Infos]\nTitle=Provider\n[Options]\nMode=0|0|0=Fast|1=Complete\n"
        "[Parameters]\nQuery=Alien|Alien|Search title\n"
        "[Fields]\nExcluded=Comments|URL\n*)",
        encoding="utf-8",
    )
    script = inspect_script(target)

    configured = configure_script(
        script, options={"mode": 1}, parameters={"QUERY": "Arrival"}
    )

    assert configured.options[0].value == 1
    assert configured.parameters[0].value == "Arrival"
    assert configured.excluded_fields == ("Comments", "URL")
    assert script.options[0].value == 0


def test_configure_script_rejects_unknown_and_invalid_options(tmp_path: Path):
    target = tmp_path / "provider.ifs"
    target.write_text(
        "(*\n[Options]\nMode=0|0|0=Fast|1=Complete\n*)", encoding="utf-8"
    )
    script = inspect_script(target)

    with pytest.raises(ValueError, match="unknown script option"):
        configure_script(script, options={"Missing": 1})
    with pytest.raises(ValueError, match="invalid value 2"):
        configure_script(script, options={"Mode": 2})


def test_configure_script_rejects_ambiguous_duplicate_declarations(tmp_path: Path):
    target = tmp_path / "provider.ifs"
    target.write_text(
        "(*\n[Options]\nMode=0|0\nmode=1|1\n*)", encoding="utf-8"
    )

    with pytest.raises(ValueError, match="duplicate script option declaration"):
        configure_script(inspect_script(target))


def test_cli_configures_script_without_executing_it(tmp_path: Path, capsys):
    target = tmp_path / "provider.ifs"
    target.write_text(
        "(*\n[Infos]\nTitle=Provider\n[Options]\nMode=0|0|0=Fast|1=Complete\n"
        "[Parameters]\nQuery=Alien|Alien|Search title\n*)\nraise_if_executed;",
        encoding="utf-8",
    )

    assert main([
        "configure-script", str(target), "--option", "Mode=1",
        "--parameter", "Query=Moon",
    ]) == 0

    output = json.loads(capsys.readouterr().out)
    assert output["options"][0]["value"] == 1
    assert output["parameters"][0]["value"] == "Moon"


def test_script_configuration_roundtrip_excludes_static_values(tmp_path: Path):
    target = tmp_path / "provider.ifs"
    settings = tmp_path / "provider.json"
    target.write_text(
        "(*\n[Options]\nMode=0|0|0=Fast|1=Complete\n"
        "[Parameters]\nQuery=Alien|Alien|Search title\n"
        "[Static]\nSecret=do-not-save\n*)",
        encoding="utf-8",
    )
    configured = configure_script(
        inspect_script(target), options={"Mode": 1}, parameters={"Query": "Moon"}
    )

    save_script_configuration(configured, settings)
    restored = load_script_configuration(inspect_script(target), settings)

    assert restored.options[0].value == 1
    assert restored.parameters[0].value == "Moon"
    assert "do-not-save" not in settings.read_text(encoding="utf-8")
    assert not settings.with_name(f".{settings.name}.tmp").exists()


@pytest.mark.skipif(os.name == "nt", reason="Windows cannot fsync directory handles")
def test_save_script_configuration_fsyncs_destination_directory_entry(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    target = tmp_path / "provider.ifs"
    settings = tmp_path / "provider.json"
    target.write_text("(*\n[Options]\nMode=0|0|0=Fast\n*)", encoding="utf-8")
    original_fsync = os.fsync
    directory_syncs = 0

    def count_directory_syncs(descriptor: int) -> None:
        nonlocal directory_syncs
        if stat.S_ISDIR(os.fstat(descriptor).st_mode):
            directory_syncs += 1
        original_fsync(descriptor)

    monkeypatch.setattr("amc.native.os.fsync", count_directory_syncs)
    save_script_configuration(inspect_script(target), settings)

    assert directory_syncs == 1


def test_script_configuration_rejects_wrong_script_and_invalid_values(tmp_path: Path):
    first = tmp_path / "first.ifs"
    second = tmp_path / "second.ifs"
    first.write_text("(*\n[Options]\nMode=0|0|0=Fast|1=Complete\n*)", encoding="utf-8")
    second.write_text("(*\n[Options]\nMode=0|0|0=Fast|1=Complete\n*)", encoding="utf-8")
    settings = tmp_path / "settings.json"
    save_script_configuration(inspect_script(first), settings)

    with pytest.raises(ValueError, match="different script"):
        load_script_configuration(inspect_script(second), settings)

    document = json.loads(settings.read_text(encoding="utf-8"))
    document["options"] = {"Mode": True}
    settings.write_text(json.dumps(document), encoding="utf-8")
    with pytest.raises(ValueError, match="map names to integers"):
        load_script_configuration(inspect_script(first), settings)


def test_cli_loads_overrides_and_saves_script_configuration(tmp_path: Path, capsys):
    target = tmp_path / "provider.ifs"
    source = tmp_path / "source.json"
    destination = tmp_path / "saved.json"
    target.write_text(
        "(*\n[Options]\nMode=0|0|0=Fast|1=Complete\n"
        "[Parameters]\nQuery=Alien|Alien|Search title\n*)",
        encoding="utf-8",
    )
    save_script_configuration(
        configure_script(inspect_script(target), options={"Mode": 1}), source
    )

    assert main([
        "configure-script", str(target), "--load", str(source),
        "--parameter", "Query=Arrival", "--save", str(destination),
    ]) == 0

    output = json.loads(capsys.readouterr().out)
    saved = json.loads(destination.read_text(encoding="utf-8"))
    assert output["options"][0]["value"] == 1
    assert output["parameters"][0]["value"] == "Arrival"
    assert saved["parameters"] == {"Query": "Arrival"}


def test_script_merge_preview_is_validated_isolated_and_field_level(tmp_path: Path):
    target = tmp_path / "provider.ifs"
    target.write_text("(*\n[Infos]\nTitle=Provider\n*)", encoding="utf-8")
    original = Movie(number=4, title="Alien", year=1979, extras={"Source": "old"})

    preview = preview_script_merge(
        inspect_script(target), original,
        fields={"TITLE": "Aliens", "year": 1986},
        extras={"Source": "provider", "Score": 9},
    )

    assert (original.title, original.year, original.extras) == (
        "Alien", 1979, {"Source": "old"}
    )
    assert (preview.movie.title, preview.movie.year) == ("Aliens", 1986)
    assert preview.movie.extras == {"Source": "provider", "Score": 9}
    assert [change.field for change in preview.changes] == [
        "title", "year", "extras.Source", "extras.Score"
    ]


def test_script_merge_preview_enforces_declared_permissions(tmp_path: Path):
    target = tmp_path / "restricted.ifs"
    target.write_text(
        "(*\n[Fields]\nExcluded=Comments|URL\nPicture=0\n"
        "[ExtraFields]\nAddExtras=0\nDeleteExtras=0\nModifyExtras=0\n"
        "Excluded=Secret\n*)",
        encoding="utf-8",
    )
    script = inspect_script(target)
    movie = Movie(number=1, extras={"Existing": "old", "Secret": "kept"})

    for fields in ({"comments": "no"}, {"Url": "no"}, {"picture": "no.jpg"}):
        with pytest.raises(ValueError, match="not permitted"):
            preview_script_merge(script, movie, fields=fields)
    for extras in (
        {"New": "no"}, {"Existing": "no"}, {"Existing": None}, {"Secret": "no"}
    ):
        with pytest.raises(ValueError, match="not permitted"):
            preview_script_merge(script, movie, extras=extras)


def test_script_merge_preview_rejects_invalid_or_ambiguous_results(tmp_path: Path):
    target = tmp_path / "provider.ifs"
    target.write_text("(*\n*)", encoding="utf-8")
    script = inspect_script(target)
    movie = Movie(number=1)

    with pytest.raises(ValueError, match="unknown script field"):
        preview_script_merge(script, movie, fields={"missing": "value"})
    with pytest.raises(ValueError, match="duplicate script field"):
        preview_script_merge(script, movie, fields={"title": "A", "TITLE": "B"})
    with pytest.raises(TypeError, match="year must be"):
        preview_script_merge(script, movie, fields={"year": "invalid"})
    with pytest.raises(TypeError, match="extra names"):
        preview_script_merge(script, movie, extras={"": "invalid"})
