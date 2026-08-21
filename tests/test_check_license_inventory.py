import importlib.util
import json
from pathlib import Path


SPEC = importlib.util.spec_from_file_location(
    "check_license_inventory", Path("tools/check_license_inventory.py")
)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(MODULE)


def test_checked_in_license_inventory_is_complete(capsys):
    assert MODULE.validate() == []
    assert MODULE.main() == 0
    assert "all retained" in capsys.readouterr().out


def test_license_inventory_reports_invalid_and_stale_entries(tmp_path, monkeypatch):
    tree = tmp_path / "tree"
    tree.mkdir()
    (tree / "new.pas").write_text("unit new;", encoding="utf-8")
    manifest = tmp_path / "inventory.json"
    manifest.write_text(
        json.dumps(
            {
                "files": [
                    {"path": "z", "status": "unknown", "basis": ""},
                    {"path": "z", "status": "notice", "basis": "reviewed"},
                ]
            }
        ),
        encoding="utf-8",
    )
    monkeypatch.setattr(MODULE, "ROOT", tmp_path)
    monkeypatch.setattr(MODULE, "MANIFEST", manifest)
    monkeypatch.setattr(MODULE, "TREES", (tree,))

    errors = MODULE.validate()
    assert "files must be sorted by path" not in errors
    assert any("invalid status" in error for error in errors)
    assert any("basis" in error for error in errors)
    assert any("duplicate paths" in error for error in errors)
    assert any("unrecorded files" in error for error in errors)
    assert any("missing files" in error for error in errors)
    assert MODULE.main() == 1
