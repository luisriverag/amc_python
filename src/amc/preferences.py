"""Python-owned desktop GUI preferences, stored separately from catalog data.

These preferences (last-used view filter, layout, and window geometry) are
an AMC Python convenience with no upstream counterpart. They are
deliberately kept out of the catalog JSON so they are never confused with
retained Ant Movie Catalog properties, and a missing or corrupt preferences
file is treated as "use the defaults" rather than an error: unlike catalog
data, losing a saved window size is not data loss worth blocking the
desktop interface over.
"""

from __future__ import annotations

import json
import os
import sys
from dataclasses import dataclass
from pathlib import Path

_FORMAT = "amc-python-gui-preferences"
_VERSION = 1
VALID_VIEW_FILTERS = ("All", "Loaned", "Available", "Checked", "Unchecked")
VALID_LAYOUTS = ("Table", "Details", "Poster")
MIN_WINDOW_SIZE = (760, 480)


@dataclass(frozen=True, slots=True)
class GuiPreferences:
    """Last-used desktop GUI state, independent of any specific catalog."""

    view_filter: str = "All"
    layout: str = "Details"
    window_width: int = 1100
    window_height: int = 720


def default_preferences_path() -> Path:
    """Return the platform-appropriate per-user preferences file path.

    ``AMC_PYTHON_CONFIG_DIR`` overrides the location entirely (primarily for
    tests and portable installs). Otherwise this follows each platform's
    usual per-user settings location: ``%APPDATA%`` on Windows, Application
    Support on macOS, and ``XDG_CONFIG_HOME`` (or ``~/.config``) elsewhere.
    """
    override = os.environ.get("AMC_PYTHON_CONFIG_DIR")
    if override:
        return Path(override) / "gui-preferences.json"
    if os.name == "nt":
        base = os.environ.get("APPDATA")
        root = Path(base) if base else Path.home() / "AppData" / "Roaming"
    elif sys.platform == "darwin":
        root = Path.home() / "Library" / "Application Support"
    else:
        base = os.environ.get("XDG_CONFIG_HOME")
        root = Path(base) if base else Path.home() / ".config"
    return root / "amc-python" / "gui-preferences.json"


def load_preferences(path: str | Path) -> GuiPreferences:
    """Load saved preferences, falling back to defaults for any problem.

    A missing file, unreadable file, corrupt JSON, unrecognized envelope, or
    an individual field with an invalid value all fall back to that field's
    default rather than raising. This file is a non-critical convenience,
    and the desktop interface must still start normally without it.
    """
    defaults = GuiPreferences()
    path = Path(path)
    try:
        with path.open(encoding="utf-8") as stream:
            document = json.load(stream)
    except (OSError, ValueError):
        return defaults
    if (
        not isinstance(document, dict)
        or document.get("format") != _FORMAT
        or document.get("version") != _VERSION
    ):
        return defaults
    view_filter = document.get("view_filter")
    layout = document.get("layout")
    width = document.get("window_width")
    height = document.get("window_height")
    return GuiPreferences(
        view_filter=(
            view_filter if view_filter in VALID_VIEW_FILTERS else defaults.view_filter
        ),
        layout=layout if layout in VALID_LAYOUTS else defaults.layout,
        window_width=(
            width
            if isinstance(width, int)
            and not isinstance(width, bool)
            and width >= MIN_WINDOW_SIZE[0]
            else defaults.window_width
        ),
        window_height=(
            height
            if isinstance(height, int)
            and not isinstance(height, bool)
            and height >= MIN_WINDOW_SIZE[1]
            else defaults.window_height
        ),
    )


def save_preferences(preferences: GuiPreferences, path: str | Path) -> None:
    """Atomically persist preferences, creating parent directories as needed."""
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    document = {
        "format": _FORMAT,
        "version": _VERSION,
        "view_filter": preferences.view_filter,
        "layout": preferences.layout,
        "window_width": preferences.window_width,
        "window_height": preferences.window_height,
    }
    temporary = path.with_name(f".{path.name}.tmp")
    try:
        with temporary.open("w", encoding="utf-8") as stream:
            json.dump(document, stream, ensure_ascii=False, indent=2)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        temporary.replace(path)
    finally:
        temporary.unlink(missing_ok=True)
