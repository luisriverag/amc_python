from pathlib import Path

import pytest

from amc.scripts import (
    configure_script,
    discover_scripts,
    inspect_script,
    load_script_configuration,
    save_script_configuration,
)
from amc.cli import main
import json


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
