"""Real-display smoke tests for the desktop GUI.

Unlike the rest of `test_gui.py`, which uses `object.__new__` to bypass
`CatalogWindow.__init__` entirely and mocks every widget, these tests
construct actual Tk widget trees against a real (possibly virtual) X
display. This is the "real-display smoke run" `compatibility.md` and
`PORT_AUDIT.md` previously listed as unavailable in this project's
environment; a virtual framebuffer server (Xvfb) turned out to already be
installed, which makes it possible after all. Run under one, e.g.::

    xvfb-run -a python -m pytest tests/test_gui_display.py

These still cannot verify screen-reader behavior: Tk has no meaningful
AT-SPI bridge on X11 to exercise, and no screen reader is installed here,
so the accessibility-pass gap tracked elsewhere is unaffected by this file.

Every test skips automatically wherever no working Tk display exists (no
`DISPLAY`, no Xvfb, a Windows CI runner without a desktop session): the
`real_root` fixture attempts to create a genuine `tk.Tk()` and calls
`pytest.skip` on failure instead of erroring, so this file is safe to
collect and run anywhere the rest of the suite runs.
"""

from __future__ import annotations

import io
import tkinter as tk
from pathlib import Path
from tkinter import ttk
from unittest.mock import patch

import pytest
from PIL import Image

from amc.catalog import Catalog
from amc.gui import CatalogWindow, open_crop_dialog
from amc.model import Movie
from amc.storage import save


@pytest.fixture
def real_root():
    try:
        root = tk.Tk()
    except tk.TclError as error:
        pytest.skip(f"no Tk display available: {error}")
    root.geometry("900x600")
    yield root
    root.destroy()


def _toplevels(widget: tk.Misc) -> list[tk.Toplevel]:
    """Recursively collect every live Toplevel under *widget* in the widget tree."""
    found = []
    for child in widget.winfo_children():
        if isinstance(child, tk.Toplevel):
            found.append(child)
        found.extend(_toplevels(child))
    return found


def _buttons(widget: tk.Misc) -> dict[str, ttk.Button]:
    """Recursively collect every ttk.Button under *widget*, keyed by its label."""
    found: dict[str, ttk.Button] = {}
    for child in widget.winfo_children():
        if isinstance(child, ttk.Button):
            found[child.cget("text")] = child
        found.update(_buttons(child))
    return found


def _png_bytes(size: tuple[int, int] = (40, 30)) -> bytes:
    buffer = io.BytesIO()
    Image.new("RGB", size, "red").save(buffer, format="PNG")
    return buffer.getvalue()


def _open_window(real_root: tk.Tk, tmp_path: Path) -> CatalogWindow:
    catalog_path = tmp_path / "catalog.json"
    save(
        Catalog([Movie(number=1, title="Alien", year=1979, director="Scott")]),
        catalog_path,
    )
    window = CatalogWindow(
        real_root, catalog_path, preferences_path=tmp_path / "prefs.json"
    )
    real_root.update_idletasks()
    real_root.update()
    return window


def test_main_window_renders_with_expected_controls(real_root: tk.Tk, tmp_path: Path):
    window = _open_window(real_root, tmp_path)

    assert window.winfo_viewable()
    assert len(window.table.get_children()) == 1
    assert set(window.action_buttons) >= {
        "Add", "Edit", "Remove", "Set Pictures", "Assign Pictures",
        "Clear Pictures", "Undo", "Redo",
    }


def test_preferences_dialog_opens_over_a_real_window(real_root: tk.Tk, tmp_path: Path):
    window = _open_window(real_root, tmp_path)

    window.open_preferences()
    real_root.update_idletasks()
    real_root.update()
    dialogs = [item for item in _toplevels(real_root) if item.title() == "Preferences"]

    assert len(dialogs) == 1
    assert dialogs[0].winfo_viewable()
    dialogs[0].destroy()


def test_assign_pictures_dialog_renders_a_row_per_selected_movie(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    window.selected_movies = lambda: [
        Movie(number=1, title="Alien"), Movie(number=2, title="Aliens"),
    ]

    window.assign_pictures()
    real_root.update_idletasks()
    real_root.update()
    dialogs = [
        item for item in _toplevels(real_root) if item.title() == "Assign pictures"
    ]

    assert len(dialogs) == 1
    assert dialogs[0].winfo_viewable()
    dialogs[0].destroy()


def test_import_media_dialog_inspects_and_adds_a_real_file(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    media = tmp_path / "clip.mkv"
    media.write_bytes(b"fake media bytes")

    with patch("amc.gui.messagebox.showinfo") as showinfo:
        window._import_media_paths([media])
    real_root.update_idletasks()
    real_root.update()

    assert len(window.table.get_children()) == 2
    showinfo.assert_called_once()


def test_edit_dialog_renders_every_field_group(real_root: tk.Tk, tmp_path: Path):
    window = _open_window(real_root, tmp_path)
    movie = next(iter(window.service.catalog))

    window._dialog(movie, is_new=False)
    real_root.update_idletasks()
    real_root.update()
    dialogs = [item for item in _toplevels(real_root) if item.title() == "Edit movie"]

    assert len(dialogs) == 1
    buttons = _buttons(dialogs[0])
    assert {"Save", "Browse", "Crop", "Clear"} <= set(buttons)
    dialogs[0].destroy()


def test_crop_dialog_drag_select_and_apply_reports_the_selected_box(
    real_root: tk.Tk,
):
    """End-to-end interactive smoke test: drag a selection over a real decoded
    image and click Apply Crop, the same gesture a user performs, then check
    the callback receives the box the drag actually produced."""
    applied: list[tuple[int, int, int, int]] = []

    open_crop_dialog(real_root, _png_bytes(), on_apply=applied.append)
    real_root.update_idletasks()
    real_root.update()
    dialog = [
        item for item in _toplevels(real_root) if item.title() == "Crop picture"
    ][0]
    canvas = next(
        child for child in dialog.winfo_children() if isinstance(child, tk.Canvas)
    )

    canvas.event_generate("<ButtonPress-1>", x=2, y=2)
    canvas.event_generate("<B1-Motion>", x=20, y=15)
    real_root.update()
    _buttons(dialog)["Apply Crop"].invoke()
    real_root.update()

    assert applied == [(2, 2, 20, 15)]
    assert not dialog.winfo_exists()


def test_crop_dialog_cancel_closes_without_applying(real_root: tk.Tk):
    applied: list[tuple[int, int, int, int]] = []

    open_crop_dialog(real_root, _png_bytes(), on_apply=applied.append)
    real_root.update_idletasks()
    real_root.update()
    dialog = [
        item for item in _toplevels(real_root) if item.title() == "Crop picture"
    ][0]

    _buttons(dialog)["Cancel"].invoke()
    real_root.update()

    assert applied == []
    assert not dialog.winfo_exists()
