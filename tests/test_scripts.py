from pathlib import Path

import pytest

from amc.scripts import discover_scripts, inspect_script
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
