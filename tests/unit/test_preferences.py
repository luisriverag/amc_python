import json
import os
import stat
from pathlib import Path

import pytest

from amc.preferences import (
    GuiPreferences,
    default_preferences_path,
    load_preferences,
    save_preferences,
)


def test_load_preferences_returns_defaults_for_missing_file(tmp_path: Path):
    assert load_preferences(tmp_path / "missing.json") == GuiPreferences()


def test_save_and_load_preferences_round_trip(tmp_path: Path):
    path = tmp_path / "gui-preferences.json"
    preferences = GuiPreferences(
        view_filter="Checked",
        layout="Poster",
        window_width=1280,
        window_height=800,
        history_limit=250,
    )

    save_preferences(preferences, path)

    assert load_preferences(path) == preferences


def test_save_preferences_creates_parent_directories(tmp_path: Path):
    path = tmp_path / "nested" / "config" / "gui-preferences.json"

    save_preferences(GuiPreferences(), path)

    assert path.exists()


@pytest.mark.skipif(os.name == "nt", reason="Windows cannot fsync directory handles")
def test_save_preferences_fsyncs_destination_directory_entry(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    path = tmp_path / "gui-preferences.json"
    original_fsync = os.fsync
    directory_syncs = 0

    def count_directory_syncs(descriptor: int) -> None:
        nonlocal directory_syncs
        if stat.S_ISDIR(os.fstat(descriptor).st_mode):
            directory_syncs += 1
        original_fsync(descriptor)

    monkeypatch.setattr("amc.native.os.fsync", count_directory_syncs)
    save_preferences(GuiPreferences(), path)

    assert directory_syncs == 1


def test_load_preferences_falls_back_to_defaults_for_corrupt_or_unreadable_file(
    tmp_path: Path,
):
    corrupt = tmp_path / "corrupt.json"
    corrupt.write_text("not json", encoding="utf-8")
    assert load_preferences(corrupt) == GuiPreferences()

    not_an_object = tmp_path / "not-object.json"
    not_an_object.write_text("[1, 2, 3]", encoding="utf-8")
    assert load_preferences(not_an_object) == GuiPreferences()

    wrong_format = tmp_path / "wrong-format.json"
    wrong_format.write_text(
        json.dumps({"format": "something-else", "version": 1}), encoding="utf-8"
    )
    assert load_preferences(wrong_format) == GuiPreferences()

    wrong_version = tmp_path / "wrong-version.json"
    wrong_version.write_text(
        json.dumps({"format": "amc-python-gui-preferences", "version": 99}),
        encoding="utf-8",
    )
    assert load_preferences(wrong_version) == GuiPreferences()


def test_load_preferences_falls_back_field_by_field_for_invalid_values(
    tmp_path: Path,
):
    path = tmp_path / "gui-preferences.json"
    path.write_text(
        json.dumps(
            {
                "format": "amc-python-gui-preferences",
                "version": 1,
                "view_filter": "Not a real view",
                "layout": 12345,
                "window_width": "wide",
                "window_height": 10,
            }
        ),
        encoding="utf-8",
    )

    assert load_preferences(path) == GuiPreferences()


def test_load_preferences_rejects_out_of_range_or_boolean_history_limit(
    tmp_path: Path,
):
    too_low = tmp_path / "too-low.json"
    too_low.write_text(
        json.dumps(
            {
                "format": "amc-python-gui-preferences",
                "version": 1,
                "history_limit": 0,
            }
        ),
        encoding="utf-8",
    )
    assert load_preferences(too_low).history_limit == GuiPreferences().history_limit

    too_high = tmp_path / "too-high.json"
    too_high.write_text(
        json.dumps(
            {
                "format": "amc-python-gui-preferences",
                "version": 1,
                "history_limit": 1001,
            }
        ),
        encoding="utf-8",
    )
    assert load_preferences(too_high).history_limit == GuiPreferences().history_limit

    boolean = tmp_path / "boolean.json"
    boolean.write_text(
        json.dumps(
            {
                "format": "amc-python-gui-preferences",
                "version": 1,
                "history_limit": True,
            }
        ),
        encoding="utf-8",
    )
    assert load_preferences(boolean).history_limit == GuiPreferences().history_limit


def test_load_preferences_rejects_boolean_window_dimensions(tmp_path: Path):
    path = tmp_path / "gui-preferences.json"
    path.write_text(
        json.dumps(
            {
                "format": "amc-python-gui-preferences",
                "version": 1,
                "window_width": True,
                "window_height": True,
            }
        ),
        encoding="utf-8",
    )

    preferences = load_preferences(path)

    assert preferences.window_width == GuiPreferences().window_width
    assert preferences.window_height == GuiPreferences().window_height


def test_save_and_load_preferences_round_trips_html_preview_template(tmp_path: Path):
    path = tmp_path / "gui-preferences.json"
    preferences = GuiPreferences(html_preview_template="/templates/individual.html")

    save_preferences(preferences, path)

    assert load_preferences(path) == preferences


def test_load_preferences_falls_back_to_default_for_non_string_html_preview_template(
    tmp_path: Path,
):
    path = tmp_path / "gui-preferences.json"
    path.write_text(
        json.dumps(
            {
                "format": "amc-python-gui-preferences",
                "version": 1,
                "html_preview_template": 12345,
            }
        ),
        encoding="utf-8",
    )

    assert load_preferences(path).html_preview_template == GuiPreferences().html_preview_template


def test_default_preferences_path_honors_config_dir_override(tmp_path: Path, monkeypatch):
    monkeypatch.setenv("AMC_PYTHON_CONFIG_DIR", str(tmp_path))

    assert default_preferences_path() == tmp_path / "gui-preferences.json"


def test_default_preferences_path_is_stable_and_under_amc_python(monkeypatch):
    monkeypatch.delenv("AMC_PYTHON_CONFIG_DIR", raising=False)

    path = default_preferences_path()

    assert path.name == "gui-preferences.json"
    assert path.parent.name == "amc-python"
    assert default_preferences_path() == path
