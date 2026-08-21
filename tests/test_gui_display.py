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


def _entries(widget: tk.Misc) -> list[ttk.Entry]:
    """Recursively collect every ttk.Entry under *widget*, in creation order."""
    found: list[ttk.Entry] = []
    for child in widget.winfo_children():
        if isinstance(child, ttk.Entry):
            found.append(child)
        found.extend(_entries(child))
    return found


def _comboboxes(widget: tk.Misc) -> list[ttk.Combobox]:
    """Recursively collect every ttk.Combobox under *widget*."""
    found: list[ttk.Combobox] = []
    for child in widget.winfo_children():
        if isinstance(child, ttk.Combobox):
            found.append(child)
        found.extend(_comboboxes(child))
    return found


def _treeviews(widget: tk.Misc) -> list[ttk.Treeview]:
    """Recursively collect every ttk.Treeview under *widget*."""
    found: list[ttk.Treeview] = []
    for child in widget.winfo_children():
        if isinstance(child, ttk.Treeview):
            found.append(child)
        found.extend(_treeviews(child))
    return found


def _labeled_entry(container: tk.Misc, label_text: str) -> ttk.Entry:
    """Find the Entry widget on the same grid row as a Label with this
    exact text, matching the edit dialog's one-Label-one-Entry-per-field
    layout without depending on field order or count."""
    rows_by_label: dict[int, str] = {}
    rows_by_entry: dict[int, ttk.Entry] = {}

    def walk(widget: tk.Misc) -> None:
        for child in widget.winfo_children():
            info = child.grid_info()
            if isinstance(child, ttk.Label) and info:
                rows_by_label[info["row"]] = child.cget("text")
            elif isinstance(child, ttk.Entry) and info:
                rows_by_entry[info["row"]] = child
            walk(child)

    walk(container)
    row = next(row for row, text in rows_by_label.items() if text == label_text)
    return rows_by_entry[row]


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


def _menu_labels(menu: tk.Menu) -> list[str]:
    end = menu.index("end")
    if end is None:
        return []
    return [
        "---" if menu.type(index) == "separator" else menu.entrycget(index, "label")
        for index in range(end + 1)
    ]


def test_main_window_renders_with_expected_controls(real_root: tk.Tk, tmp_path: Path):
    window = _open_window(real_root, tmp_path)

    assert window.winfo_viewable()
    assert len(window.table.get_children()) == 1
    assert set(window.action_buttons) >= {
        "Add", "Edit", "Remove", "Set Pictures", "Assign Pictures",
        "Clear Pictures", "Undo", "Redo",
    }


def test_main_window_toolbar_only_shows_the_tightest_edit_loop(real_root: tk.Tk, tmp_path: Path):
    """Every action still exists (test_main_window_renders_with_expected_controls,
    and the menu bar below), but the visible toolbar row is limited to the
    add/edit/remove/toggle/undo/redo loop, not all 16 actions at once."""
    window = _open_window(real_root, tmp_path)

    visible = [
        button.cget("text")
        for button in window.action_buttons.values()
        if button.winfo_ismapped()
    ]
    assert set(visible) == {"Add", "Edit", "Remove", "Toggle Checked", "Undo", "Redo"}


def test_main_window_has_a_grouped_menu_bar(real_root: tk.Tk, tmp_path: Path):
    window = _open_window(real_root, tmp_path)

    menubar = window.menubar
    top_level = [menubar.entrycget(i, "label") for i in range(menubar.index("end") + 1)]
    assert top_level == ["File", "Edit", "Movie", "Tools"]

    file_menu = real_root.nametowidget(menubar.entrycget(0, "menu"))
    assert "Open Catalog..." in _menu_labels(file_menu)
    assert "Exit" in _menu_labels(file_menu)

    movie_menu = real_root.nametowidget(menubar.entrycget(2, "menu"))
    assert {"Loan Out...", "Set Pictures...", "Renumber"} <= set(_menu_labels(movie_menu))

    tools_menu = real_root.nametowidget(menubar.entrycget(3, "menu"))
    assert _menu_labels(tools_menu) == ["Statistics...", "Duplicates..."]


def test_menu_bar_disabled_state_tracks_selection_like_the_toolbar(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    edit_menu = real_root.nametowidget(window.menubar.entrycget(1, "menu"))
    remove_index = next(
        i for i in range(edit_menu.index("end") + 1)
        if edit_menu.type(i) != "separator" and edit_menu.entrycget(i, "label") == "Remove Movie"
    )
    assert edit_menu.entrycget(remove_index, "state") == "disabled"

    window.selected_movies = lambda: [next(iter(window.service.catalog))]
    window.selection_changed()

    assert edit_menu.entrycget(remove_index, "state") == "normal"
    assert str(window.action_buttons["Remove"].cget("state")) == "normal"


def test_menu_command_opens_the_add_movie_dialog(real_root: tk.Tk, tmp_path: Path):
    window = _open_window(real_root, tmp_path)
    edit_menu = real_root.nametowidget(window.menubar.entrycget(1, "menu"))
    add_index = next(
        i for i in range(edit_menu.index("end") + 1)
        if edit_menu.type(i) != "separator" and edit_menu.entrycget(i, "label") == "Add Movie"
    )

    edit_menu.invoke(add_index)
    real_root.update_idletasks()
    real_root.update()

    dialogs = [item for item in _toplevels(real_root) if item.title() == "Add movie"]
    assert len(dialogs) == 1
    dialogs[0].destroy()


def test_context_menu_state_tracks_the_edit_menu_together(real_root: tk.Tk, tmp_path: Path):
    """The context menu and the Edit menu both track the "Remove" action
    name in `_menu_entries` now; selecting a movie must gray both out in
    lockstep, not just whichever menu happens to be open."""
    window = _open_window(real_root, tmp_path)
    edit_menu = real_root.nametowidget(window.menubar.entrycget(1, "menu"))

    def _index(menu: tk.Menu, label: str) -> int:
        return next(
            i for i in range(menu.index("end") + 1)
            if menu.type(i) != "separator" and menu.entrycget(i, "label") == label
        )

    edit_remove = _index(edit_menu, "Remove Movie")
    context_remove = _index(window.context_menu, "Remove Movie")
    assert edit_menu.entrycget(edit_remove, "state") == "disabled"
    assert window.context_menu.entrycget(context_remove, "state") == "disabled"

    window.selected_movies = lambda: [next(iter(window.service.catalog))]
    window.selection_changed()

    assert edit_menu.entrycget(edit_remove, "state") == "normal"
    assert window.context_menu.entrycget(context_remove, "state") == "normal"


def test_right_click_selects_the_row_and_opens_the_edit_dialog(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    assert window.table.selection() == ()

    bbox = window.table.bbox("1")
    assert bbox, "the single seeded row must be visible to click on"
    x, y = bbox[0] + bbox[2] // 2, bbox[1] + bbox[3] // 2
    window.table.event_generate("<Button-3>", x=x, y=y)
    real_root.update_idletasks()
    real_root.update()
    window.context_menu.unpost()

    assert window.table.selection() == ("1",)

    def _index(menu: tk.Menu, label: str) -> int:
        return next(
            i for i in range(menu.index("end") + 1)
            if menu.type(i) != "separator" and menu.entrycget(i, "label") == label
        )

    window.context_menu.invoke(_index(window.context_menu, "Edit Movie"))
    real_root.update_idletasks()
    real_root.update()

    dialogs = [item for item in _toplevels(real_root) if item.title() == "Edit movie"]
    assert len(dialogs) == 1
    dialogs[0].destroy()


def test_right_click_on_empty_space_does_not_change_the_selection(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    window.table.selection_set("1")
    real_root.update_idletasks()
    real_root.update()

    window.table.event_generate("<Button-3>", x=5, y=window.table.winfo_height() - 2)
    real_root.update_idletasks()
    real_root.update()

    assert window.table.selection() == ("1",)
    window.context_menu.unpost()


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


def test_loan_out_dialog_checks_out_a_real_movie(real_root: tk.Tk, tmp_path: Path):
    window = _open_window(real_root, tmp_path)
    movie = next(iter(window.service.catalog))
    window.selected_movies = lambda: [movie]

    window.loan_out()
    real_root.update_idletasks()
    real_root.update()
    dialog = [
        item for item in _toplevels(real_root) if item.title() == "Check out movie"
    ][0]
    _comboboxes(dialog)[0].set("Ripley")
    _buttons(dialog)["Check Out"].invoke()
    real_root.update()

    assert not dialog.winfo_exists()
    assert window.service.catalog.get(movie.number).borrower == "Ripley"


def test_loan_in_checks_in_a_real_loaned_movie(real_root: tk.Tk, tmp_path: Path):
    window = _open_window(real_root, tmp_path)
    movie = next(iter(window.service.catalog))
    window.service.check_out(movie.number, "Ripley")
    window.selected_movies = lambda: [window.service.catalog.get(movie.number)]

    window.loan_in()
    real_root.update_idletasks()
    real_root.update()

    assert window.service.catalog.get(movie.number).borrower == ""


def test_set_pictures_embeds_a_real_image_for_selected_movies(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    movie = next(iter(window.service.catalog))
    window.selected_movies = lambda: [movie]
    picture = tmp_path / "cover.png"
    picture.write_bytes(_png_bytes())

    with (
        patch("amc.gui.filedialog.askopenfilename", return_value=str(picture)),
        patch("amc.gui.messagebox.askyesno", return_value=True),
    ):
        window.set_pictures()
    real_root.update_idletasks()
    real_root.update()

    updated = window.service.catalog.get(movie.number)
    assert updated.extras.get("native_picture_base64")


def test_clear_pictures_removes_a_real_picture_after_confirmation(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    movie = next(iter(window.service.catalog))
    picture = tmp_path / "cover.png"
    picture.write_bytes(_png_bytes())
    window.service.set_picture(movie.number, picture, embed=True)
    window.selected_movies = lambda: [window.service.catalog.get(movie.number)]

    with patch("amc.gui.messagebox.askyesno", return_value=True):
        window.clear_pictures()
    real_root.update_idletasks()
    real_root.update()

    updated = window.service.catalog.get(movie.number)
    assert not updated.extras.get("native_picture_base64")
    assert updated.picture == ""


def test_statistics_dialog_shows_a_computed_summary(real_root: tk.Tk, tmp_path: Path):
    window = _open_window(real_root, tmp_path)

    with patch("amc.gui.messagebox.showinfo") as showinfo:
        window.show_statistics()

    showinfo.assert_called_once()
    title, message = showinfo.call_args.args
    assert title == "Catalog statistics"
    assert "Movies: 1" in message
    assert "Duplicate groups: 0" in message


def test_duplicates_dialog_lists_matching_title_year_groups(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    window.service.add(Movie(number=2, title="Alien", year=1979, director="Someone Else"))

    with patch("amc.gui.messagebox.showinfo") as showinfo:
        window.show_duplicates()

    showinfo.assert_called_once()
    title, message = showinfo.call_args.args
    assert title == "Duplicate movies"
    assert "#1 Alien (1979)" in message
    assert "#2 Alien (1979)" in message


def test_duplicates_dialog_reports_none_found_when_the_catalog_has_no_duplicates(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)

    with patch("amc.gui.messagebox.showinfo") as showinfo:
        window.show_duplicates()

    title, message = showinfo.call_args.args
    assert title == "Duplicate movies"
    assert "No duplicate" in message


def test_loan_history_dialog_shows_a_real_checkout_event(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    movie = next(iter(window.service.catalog))
    window.service.check_out(movie.number, "Ada")

    window.show_loan_history()
    real_root.update_idletasks()
    real_root.update()

    dialog = [item for item in _toplevels(real_root) if item.title() == "Loan history"][0]
    table = _treeviews(dialog)[0]
    rows = [table.item(iid)["values"] for iid in table.get_children()]

    assert len(rows) == 1
    assert rows[0][1] == "Checked out"
    assert rows[0][3] == movie.display_title()
    assert rows[0][4] == "Ada"
    dialog.destroy()


def test_loan_history_dialog_reports_none_recorded_in_the_status_bar(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)

    window.show_loan_history()
    real_root.update_idletasks()
    real_root.update()

    dialog = [item for item in _toplevels(real_root) if item.title() == "Loan history"][0]
    assert _treeviews(dialog)[0].get_children() == ()
    assert "No loan history" in window.status.cget("text")
    dialog.destroy()


def test_table_sort_click_reorders_rows_and_marks_the_heading(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    window.service.add(Movie(number=2, title="Before Alien", year=1975))
    window.refresh()

    window.sort("title")
    real_root.update_idletasks()
    real_root.update()

    ascending = [
        window.table.item(iid)["values"][1] for iid in window.table.get_children()
    ]
    assert ascending == sorted(ascending)
    assert window.table.heading("title")["text"].endswith("▲")

    window.sort("title")
    real_root.update()

    descending = [
        window.table.item(iid)["values"][1] for iid in window.table.get_children()
    ]
    assert descending == list(reversed(ascending))
    assert window.table.heading("title")["text"].endswith("▼")


def test_edit_dialog_rejects_an_out_of_range_rating_without_closing(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    movie = next(iter(window.service.catalog))

    window._dialog(movie, is_new=False)
    real_root.update_idletasks()
    real_root.update()
    dialog = [item for item in _toplevels(real_root) if item.title() == "Edit movie"][0]
    rating_entry = _labeled_entry(dialog, "Rating")
    rating_entry.delete(0, tk.END)
    rating_entry.insert(0, "15")

    with patch("amc.gui.messagebox.showerror") as showerror:
        _buttons(dialog)["Save"].invoke()
    real_root.update()

    showerror.assert_called_once()
    assert "rating must be between 0 and 10" in showerror.call_args.args[1]
    assert dialog.winfo_exists()
    assert window.service.catalog.get(movie.number).rating == movie.rating
    dialog.destroy()


def test_edit_dialog_rejects_a_non_integer_year_without_closing(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    movie = next(iter(window.service.catalog))

    window._dialog(movie, is_new=False)
    real_root.update_idletasks()
    real_root.update()
    dialog = [item for item in _toplevels(real_root) if item.title() == "Edit movie"][0]
    year_entry = _labeled_entry(dialog, "Year")
    year_entry.delete(0, tk.END)
    year_entry.insert(0, "not-a-year")

    with patch("amc.gui.messagebox.showerror") as showerror:
        _buttons(dialog)["Save"].invoke()
    real_root.update()

    showerror.assert_called_once()
    assert "year must be an integer" in showerror.call_args.args[1]
    assert dialog.winfo_exists()
    assert window.service.catalog.get(movie.number).year == movie.year
    dialog.destroy()


def test_edit_dialog_rejects_a_missing_title_without_closing(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    movie = next(iter(window.service.catalog))

    window._dialog(movie, is_new=False)
    real_root.update_idletasks()
    real_root.update()
    dialog = [item for item in _toplevels(real_root) if item.title() == "Edit movie"][0]
    title_entry = _entries(dialog)[0]
    title_entry.delete(0, tk.END)

    with patch("amc.gui.messagebox.showerror") as showerror:
        _buttons(dialog)["Save"].invoke()
    real_root.update()

    showerror.assert_called_once()
    assert "title is required" in showerror.call_args.args[1]
    assert dialog.winfo_exists()
    assert window.service.catalog.get(movie.number).title == movie.title
    dialog.destroy()
