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
from amc.gui import _EDIT_FIELD_GROUPS, CatalogWindow, open_crop_dialog
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


def _labeled_widget(container: tk.Misc, label_text: str) -> tk.Widget:
    """Find the field widget paired with a Label with this exact text,
    matching the edit dialog's one-Label-one-field layout without
    depending on field order, count, or which group frame the pair lives
    in. The dialog groups fields into several LabelFrames (each with its
    own independent row numbering) and, in landscape mode, packs more than
    one label/field pair on the same row at different columns — so a pair
    is identified by (immediate parent, row), matching the label to the
    nearest field at a greater column in that same row. A field widget can
    be a plain Entry, a multi-line Text, or (for Picture) a composite
    Frame wrapping an Entry and its buttons — anything grid-managed in
    that row that is not itself a Label is a candidate."""
    labels_by_row: dict[tuple[int, int], list[tuple[int, str]]] = {}
    widgets_by_row: dict[tuple[int, int], list[tuple[int, tk.Widget]]] = {}

    def walk(widget: tk.Misc) -> None:
        for child in widget.winfo_children():
            info = child.grid_info()
            if info:
                key = (id(widget), info["row"])
                if isinstance(child, ttk.Label):
                    labels_by_row.setdefault(key, []).append((info["column"], child.cget("text")))
                else:
                    widgets_by_row.setdefault(key, []).append((info["column"], child))
            walk(child)

    walk(container)
    for key, labels in labels_by_row.items():
        for column, text in labels:
            if text != label_text:
                continue
            candidates = sorted(
                (c for c in widgets_by_row.get(key, []) if c[0] > column), key=lambda c: c[0]
            )
            if candidates:
                return candidates[0][1]
    raise LookupError(f"no field found for label {label_text!r}")


def _labeled_entry(container: tk.Misc, label_text: str) -> ttk.Entry:
    widget = _labeled_widget(container, label_text)
    assert isinstance(widget, ttk.Entry)
    return widget


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
    window = CatalogWindow(real_root, catalog_path, preferences_path=tmp_path / "prefs.json")
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
        "Add",
        "Edit",
        "Remove",
        "Set Pictures",
        "Assign Pictures",
        "Clear Pictures",
        "Undo",
        "Redo",
    }


def test_main_window_displays_linked_poster_from_amc_named_subfolder(
    real_root: tk.Tk, tmp_path: Path
):
    catalog_path = tmp_path / "RPlex_Mov.amc"
    # JSON is used only to construct the window cheaply; picture resolution is
    # driven by the catalog path and stored Movie value exactly as for native AMC.
    catalog_path.write_text(
        '{"version":1,"movies":[{"number":10,"title":"Life Itself",'
        '"picture":"RPlex_Mov.amc_pics\\\\RPlex_Mov_10.jpg"}]}',
        encoding="utf-8",
    )
    poster = tmp_path / "RPlex_Mov.amc_pics" / "RPlex_Mov_10.jpg"
    poster.parent.mkdir()
    Image.new("RGB", (40, 60), "red").save(poster)

    window = CatalogWindow(real_root, catalog_path, preferences_path=tmp_path / "prefs.json")
    window.table.selection_set("10")
    window.selection_changed()
    real_root.update_idletasks()

    assert window.poster_image is not None
    assert window.poster.cget("text") == ""


def test_html_layout_maps_a_real_tkinterweb_widget_and_renders_the_selection(
    real_root: tk.Tk, tmp_path: Path
):
    """Proves the real reason for adopting tkinterweb (ADR-0009): a genuine
    HtmlFrame constructs and packs correctly inside this app's own real
    widget tree under Xvfb, and switching to the HTML layout renders the
    selected movie through the chosen Individual template end to end. Only
    the final `load_html` browser-render call is spied, so the rendering
    pipeline in between (`amc.html_template.render_individual_template`)
    still runs for real."""
    template = tmp_path / "individual.html"
    template.write_text(
        "<html><body><h1>$$ITEM_FORMATTEDTITLE</h1></body></html>", encoding="utf-8"
    )
    window = _open_window(real_root, tmp_path)
    window.table.selection_set(window.table.get_children()[0])
    window.html_preview_template = str(template)

    with patch.object(window.html_view, "load_html") as load_html:
        window.layout.set("HTML")
        window._layout_changed()
        real_root.update()

    assert window.html_view.winfo_ismapped()
    rendered = load_html.call_args.args[0]
    assert "Alien" in rendered


def test_main_window_toolbar_only_shows_the_tightest_edit_loop(real_root: tk.Tk, tmp_path: Path):
    """Every action still exists (test_main_window_renders_with_expected_controls,
    and the menu bar below), but the visible toolbar row is limited to the
    add/edit/remove/toggle/undo/redo loop, not all 16 actions at once."""
    window = _open_window(real_root, tmp_path)

    visible = [
        button.cget("text") for button in window.action_buttons.values() if button.winfo_ismapped()
    ]
    assert set(visible) == {"Add", "Edit", "Remove", "Toggle Checked", "Undo", "Redo"}


def test_main_window_has_a_grouped_menu_bar(real_root: tk.Tk, tmp_path: Path):
    window = _open_window(real_root, tmp_path)

    menubar = window.menubar
    top_level = [menubar.entrycget(i, "label") for i in range(menubar.index("end") + 1)]
    assert top_level == ["File", "Edit", "Movie", "Tools", "Help"]

    file_menu = real_root.nametowidget(menubar.entrycget(0, "menu"))
    assert "Open Catalog..." in _menu_labels(file_menu)
    assert "Export HTML Template..." in _menu_labels(file_menu)
    assert "Exit" in _menu_labels(file_menu)

    movie_menu = real_root.nametowidget(menubar.entrycget(2, "menu"))
    assert {"Loan Out...", "Set Pictures...", "Renumber"} <= set(_menu_labels(movie_menu))

    tools_menu = real_root.nametowidget(menubar.entrycget(3, "menu"))
    assert _menu_labels(tools_menu) == [
        "Statistics...",
        "Duplicates...",
        "---",
        "Choose HTML Preview Template...",
    ]


def test_menu_bar_disabled_state_tracks_selection_like_the_toolbar(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    edit_menu = real_root.nametowidget(window.menubar.entrycget(1, "menu"))
    remove_index = next(
        i
        for i in range(edit_menu.index("end") + 1)
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
        i
        for i in range(edit_menu.index("end") + 1)
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
            i
            for i in range(menu.index("end") + 1)
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


def test_right_click_selects_the_row_and_opens_the_edit_dialog(real_root: tk.Tk, tmp_path: Path):
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
            i
            for i in range(menu.index("end") + 1)
            if menu.type(i) != "separator" and menu.entrycget(i, "label") == label
        )

    window.context_menu.invoke(_index(window.context_menu, "Edit Movie"))
    real_root.update_idletasks()
    real_root.update()

    dialogs = [item for item in _toplevels(real_root) if item.title() == "Edit movie"]
    assert len(dialogs) == 1
    dialogs[0].destroy()


def test_right_click_on_empty_space_does_not_change_the_selection(real_root: tk.Tk, tmp_path: Path):
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


def test_about_dialog_opens_over_a_real_window(real_root: tk.Tk, tmp_path: Path):
    window = _open_window(real_root, tmp_path)

    window.show_about()
    real_root.update_idletasks()
    real_root.update()
    dialogs = [item for item in _toplevels(real_root) if item.title() == "About AMC Python"]

    assert len(dialogs) == 1
    assert dialogs[0].winfo_viewable()
    dialogs[0].destroy()


def test_assign_pictures_dialog_renders_a_row_per_selected_movie(real_root: tk.Tk, tmp_path: Path):
    window = _open_window(real_root, tmp_path)
    window.selected_movies = lambda: [
        Movie(number=1, title="Alien"),
        Movie(number=2, title="Aliens"),
    ]

    window.assign_pictures()
    real_root.update_idletasks()
    real_root.update()
    dialogs = [item for item in _toplevels(real_root) if item.title() == "Assign pictures"]

    assert len(dialogs) == 1
    assert dialogs[0].winfo_viewable()
    dialogs[0].destroy()


def test_import_media_dialog_inspects_and_adds_a_real_file(real_root: tk.Tk, tmp_path: Path):
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
    dialog = [item for item in _toplevels(real_root) if item.title() == "Crop picture"][0]
    canvas = next(child for child in dialog.winfo_children() if isinstance(child, tk.Canvas))

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
    dialog = [item for item in _toplevels(real_root) if item.title() == "Crop picture"][0]

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
    dialog = [item for item in _toplevels(real_root) if item.title() == "Check out movie"][0]
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


def test_update_from_imdb_dialog_previews_then_applies_a_real_change(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    movie = next(iter(window.service.catalog))
    window.table.selection_set(str(movie.number))
    real_root.update_idletasks()
    real_root.update()

    with patch(
        "amc.gui.fetch_omdb_record",
        return_value={
            "Response": "True",
            "Title": "Alien",
            "Director": "Ridley Scott",
            "imdbID": "tt0078748",
        },
    ) as fetch:
        window.update_from_imdb()
        real_root.update_idletasks()
        real_root.update()
        dialog = [item for item in _toplevels(real_root) if item.title() == "Update from IMDb"][0]
        _labeled_entry(dialog, "IMDb ID (optional)").insert(0, "tt0078748")
        _buttons(dialog)["Fetch Preview"].invoke()
        real_root.update()
        fetch.assert_called_once()
        assert fetch.call_args.kwargs["imdb_id"] == "tt0078748"

        _buttons(dialog)["Apply"].invoke()
        real_root.update()

    assert not dialog.winfo_exists()
    updated = window.service.catalog.get(movie.number)
    assert updated.director == "Ridley Scott"
    assert updated.url == "https://www.imdb.com/title/tt0078748/"


def test_update_from_imdb_dialog_reports_a_lookup_failure_without_closing(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    movie = next(iter(window.service.catalog))
    window.table.selection_set(str(movie.number))
    real_root.update_idletasks()
    real_root.update()

    with (
        patch("amc.gui.fetch_omdb_record", side_effect=OSError("OMDb request failed")),
        patch("amc.gui.messagebox.showerror") as showerror,
    ):
        window.update_from_imdb()
        real_root.update_idletasks()
        real_root.update()
        dialog = [item for item in _toplevels(real_root) if item.title() == "Update from IMDb"][0]
        _buttons(dialog)["Fetch Preview"].invoke()
        real_root.update()

    showerror.assert_called_once()
    assert dialog.winfo_exists()
    assert str(_buttons(dialog)["Apply"].cget("state")) == "disabled"
    dialog.destroy()


def test_set_pictures_embeds_a_real_image_for_selected_movies(real_root: tk.Tk, tmp_path: Path):
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


def test_clear_pictures_removes_a_real_picture_after_confirmation(real_root: tk.Tk, tmp_path: Path):
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


def test_duplicates_dialog_lists_matching_title_year_groups(real_root: tk.Tk, tmp_path: Path):
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


def test_loan_history_dialog_shows_a_real_checkout_event(real_root: tk.Tk, tmp_path: Path):
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


def test_search_bar_field_scope_whole_field_and_reverse_filter_the_real_table(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    window.service.add(Movie(number=2, title="Aliens", director="Scott"))
    window.refresh()
    real_root.update()
    assert len(window.table.get_children()) == 2

    window.search_field.set("Director")
    window.search_text.set("scott")
    real_root.update()
    assert {window.table.item(iid)["values"][0] for iid in window.table.get_children()} == {1, 2}

    window.search_field.set("Title")
    real_root.update()
    assert len(window.table.get_children()) == 0

    window.search_whole_field.set(True)
    window.search_text.set("Aliens")
    real_root.update()
    assert [window.table.item(iid)["values"][0] for iid in window.table.get_children()] == [2]

    window.search_reverse.set(True)
    real_root.update()
    assert [window.table.item(iid)["values"][0] for iid in window.table.get_children()] == [1]


def test_table_sort_click_reorders_rows_and_marks_the_heading(real_root: tk.Tk, tmp_path: Path):
    window = _open_window(real_root, tmp_path)
    window.service.add(Movie(number=2, title="Before Alien", year=1975))
    window.refresh()

    window.sort("title")
    real_root.update_idletasks()
    real_root.update()

    ascending = [window.table.item(iid)["values"][1] for iid in window.table.get_children()]
    assert ascending == sorted(ascending)
    assert window.table.heading("title")["text"].endswith("▲")

    window.sort("title")
    real_root.update()

    descending = [window.table.item(iid)["values"][1] for iid in window.table.get_children()]
    assert descending == list(reversed(ascending))
    assert window.table.heading("title")["text"].endswith("▼")


def test_previous_next_movie_navigation_steps_the_real_table_selection(
    real_root: tk.Tk, tmp_path: Path
):
    window = _open_window(real_root, tmp_path)
    window.service.add(Movie(number=2, title="Before Alien", year=1975))
    window.refresh()
    real_root.update()
    rows = window.table.get_children()
    assert len(rows) == 2

    window.select_next()
    real_root.update()
    assert window.table.selection() == (rows[0],)

    window.select_next()
    real_root.update()
    assert window.table.selection() == (rows[1],)

    window.select_next()
    real_root.update()
    assert window.table.selection() == ()

    window.select_previous()
    real_root.update()
    assert window.table.selection() == (rows[-1],)


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


def test_edit_dialog_rejects_a_non_integer_year_without_closing(real_root: tk.Tk, tmp_path: Path):
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


def test_edit_dialog_rejects_a_missing_title_without_closing(real_root: tk.Tk, tmp_path: Path):
    window = _open_window(real_root, tmp_path)
    movie = next(iter(window.service.catalog))

    window._dialog(movie, is_new=False)
    real_root.update_idletasks()
    real_root.update()
    dialog = [item for item in _toplevels(real_root) if item.title() == "Edit movie"][0]
    title_entry = _labeled_entry(dialog, "Title")
    title_entry.delete(0, tk.END)

    with patch("amc.gui.messagebox.showerror") as showerror:
        _buttons(dialog)["Save"].invoke()
    real_root.update()

    showerror.assert_called_once()
    assert "title is required" in showerror.call_args.args[1]
    assert dialog.winfo_exists()
    assert window.service.catalog.get(movie.number).title == movie.title
    dialog.destroy()


def _label_frames(widget: tk.Misc) -> dict[str, ttk.LabelFrame]:
    """Recursively collect every ttk.LabelFrame under *widget*, keyed by its title."""
    found: dict[str, ttk.LabelFrame] = {}
    for child in widget.winfo_children():
        if isinstance(child, ttk.LabelFrame):
            found[child.cget("text")] = child
        found.update(_label_frames(child))
    return found


def test_edit_dialog_groups_fields_into_named_sections(real_root: tk.Tk, tmp_path: Path):
    """The edit dialog groups its ~30 fields into named LabelFrame
    sections (Identification, Classification, ...) instead of one flat
    list, matching upstream AMC's own grouped layout. Every field must be
    reachable within its declared group, regardless of row-pairing mode."""
    window = _open_window(real_root, tmp_path)
    movie = next(iter(window.service.catalog))

    window._dialog(movie, is_new=False)
    real_root.update_idletasks()
    real_root.update()
    dialog = [item for item in _toplevels(real_root) if item.title() == "Edit movie"][0]

    frames = _label_frames(dialog)
    assert set(frames) == {title for title, _rows in _EDIT_FIELD_GROUPS}
    for group_title, group_rows in _EDIT_FIELD_GROUPS:
        frame = frames[group_title]
        for row_fields in group_rows:
            for name in row_fields:
                label_text = name.replace("_", " ").title()
                assert _labeled_widget(frame, label_text) is not None

    dialog.destroy()


def test_edit_dialog_packs_paired_fields_side_by_side_when_wide(real_root: tk.Tk, tmp_path: Path):
    """In a wide (landscape) window, a multi-field row like Year/Length
    packs its fields side by side: same grid row, increasing column."""
    window = _open_window(real_root, tmp_path)
    movie = next(iter(window.service.catalog))

    window._dialog(movie, is_new=False)
    real_root.update_idletasks()
    real_root.update()
    dialog = [item for item in _toplevels(real_root) if item.title() == "Edit movie"][0]
    dialog.geometry("900x700")
    real_root.update_idletasks()
    real_root.update()

    frames = _label_frames(dialog)
    classification = frames["Classification"]
    year_entry = _labeled_entry(classification, "Year")
    length_entry = _labeled_entry(classification, "Length")

    assert year_entry.grid_info()["row"] == length_entry.grid_info()["row"]
    assert year_entry.grid_info()["column"] < length_entry.grid_info()["column"]

    dialog.destroy()


def test_edit_dialog_stacks_every_field_on_its_own_row_when_narrow(
    real_root: tk.Tk, tmp_path: Path
):
    """In a narrow (portrait) window, fields that would otherwise be
    paired instead each get their own row, one field per line, so nothing
    is clipped or squeezed."""
    window = _open_window(real_root, tmp_path)
    movie = next(iter(window.service.catalog))

    window._dialog(movie, is_new=False)
    real_root.update_idletasks()
    real_root.update()
    dialog = [item for item in _toplevels(real_root) if item.title() == "Edit movie"][0]
    dialog.geometry("380x700")
    real_root.update_idletasks()
    real_root.update()

    frames = _label_frames(dialog)
    classification = frames["Classification"]
    year_entry = _labeled_entry(classification, "Year")
    length_entry = _labeled_entry(classification, "Length")

    assert year_entry.grid_info()["column"] == length_entry.grid_info()["column"]
    assert year_entry.grid_info()["row"] != length_entry.grid_info()["row"]

    dialog.destroy()


def test_edit_dialog_scrollbar_has_no_gap_from_its_canvas(real_root: tk.Tk, tmp_path: Path):
    """The scrollbar shares its grid column with the wider Save button
    (a different row), so it must stick to the canvas's edge explicitly —
    without that, it centers in the wider column and floats away from the
    content it scrolls."""
    window = _open_window(real_root, tmp_path)
    movie = next(iter(window.service.catalog))

    window._dialog(movie, is_new=False)
    real_root.update_idletasks()
    real_root.update()
    dialog = [item for item in _toplevels(real_root) if item.title() == "Edit movie"][0]
    dialog.geometry("900x700")
    real_root.update_idletasks()
    real_root.update()

    canvas = next(c for c in dialog.winfo_children() if isinstance(c, tk.Canvas))
    scrollbar = next(c for c in dialog.winfo_children() if isinstance(c, ttk.Scrollbar))

    assert scrollbar.winfo_x() == canvas.winfo_x() + canvas.winfo_width()

    dialog.destroy()
