from pathlib import Path
from unittest.mock import Mock, patch

import base64
import io
import pytest
from PIL import Image, UnidentifiedImageError

from amc.gui import (
    _EDIT_FLOAT_FIELDS,
    _EDIT_INTEGER_FIELDS,
    _EDIT_TEXT_FIELDS,
    CatalogWindow,
    crop_box_from_canvas,
    crop_image_bytes,
    filter_movies,
    main,
    make_modal,
    movie_from_form,
    movie_row,
    loan_event_row,
    movie_with_picture,
    movie_web_url,
    open_crop_dialog,
    parse_history_limit,
    poster_size,
    poster_source,
    run,
)
from amc.errors import CorruptCatalogError
from amc.catalog import Catalog
from amc.model import Movie
from amc.loans import LoanEvent
from amc.preferences import GuiPreferences


def test_window_sort_delegates_to_application_service():
    window = object.__new__(CatalogWindow)
    window.service = Mock()
    window.refresh = Mock()
    window.table = Mock()
    window.sort_field = None
    window.sort_reverse = False

    window.sort("director")

    window.service.sort.assert_called_once_with("director", reverse=False)
    window.refresh.assert_called_once_with()


def test_window_repeated_column_sort_toggles_direction():
    window = object.__new__(CatalogWindow)
    window.service = Mock()
    window.refresh = Mock()
    window.table = Mock()
    window.sort_field = "year"
    window.sort_reverse = False

    window.sort("year")

    window.service.sort.assert_called_once_with("year", reverse=True)
    assert window.sort_reverse is True
    assert window.table.heading.call_args_list[2].kwargs["text"] == "Year ▼"


def test_window_view_filter_change_refreshes_and_saves_preferences():
    window = object.__new__(CatalogWindow)
    window.refresh = Mock()
    window._save_preferences = Mock()

    window._view_filter_changed()

    window.refresh.assert_called_once_with()
    window._save_preferences.assert_called_once_with()


def test_window_layout_change_applies_layout_and_saves_preferences():
    window = object.__new__(CatalogWindow)
    window.apply_layout = Mock()
    window._save_preferences = Mock()

    window._layout_changed()

    window.apply_layout.assert_called_once_with()
    window._save_preferences.assert_called_once_with()


def test_window_saves_current_view_layout_and_window_size():
    window = object.__new__(CatalogWindow)
    window.view_filter = Mock(get=Mock(return_value="Checked"))
    window.layout = Mock(get=Mock(return_value="Poster"))
    window.preferences_path = Path("prefs.json")
    window._preferences = GuiPreferences()
    window.service = Mock(history_limit=100)
    window.winfo_toplevel = Mock(return_value=Mock())
    window.winfo_toplevel.return_value.winfo_width.return_value = 1280
    window.winfo_toplevel.return_value.winfo_height.return_value = 800

    with patch("amc.gui.save_preferences") as save:
        window._save_preferences()

    save.assert_called_once_with(
        GuiPreferences(
            view_filter="Checked", layout="Poster",
            window_width=1280, window_height=800, history_limit=100,
        ),
        Path("prefs.json"),
    )
    assert (window._preferences.window_width, window._preferences.window_height) == (
        1280, 800,
    )


def test_window_save_preferences_keeps_previous_size_when_window_not_yet_drawn():
    window = object.__new__(CatalogWindow)
    window.view_filter = Mock(get=Mock(return_value="All"))
    window.layout = Mock(get=Mock(return_value="Details"))
    window.preferences_path = Path("prefs.json")
    window._preferences = GuiPreferences(window_width=999, window_height=555)
    window.service = Mock(history_limit=100)
    window.winfo_toplevel = Mock(return_value=Mock())
    window.winfo_toplevel.return_value.winfo_width.return_value = 1
    window.winfo_toplevel.return_value.winfo_height.return_value = 1

    with patch("amc.gui.save_preferences") as save:
        window._save_preferences()

    saved = save.call_args.args[0]
    assert (saved.window_width, saved.window_height) == (999, 555)


def test_window_save_preferences_includes_the_current_history_limit():
    window = object.__new__(CatalogWindow)
    window.view_filter = Mock(get=Mock(return_value="All"))
    window.layout = Mock(get=Mock(return_value="Details"))
    window.preferences_path = Path("prefs.json")
    window._preferences = GuiPreferences()
    window.service = Mock(history_limit=250)
    window.winfo_toplevel = Mock(return_value=Mock())
    window.winfo_toplevel.return_value.winfo_width.return_value = 1100
    window.winfo_toplevel.return_value.winfo_height.return_value = 720

    with patch("amc.gui.save_preferences") as save:
        window._save_preferences()

    assert save.call_args.args[0].history_limit == 250
    assert window._preferences.history_limit == 250


def test_window_save_preferences_ignores_write_failures():
    window = object.__new__(CatalogWindow)
    window.view_filter = Mock(get=Mock(return_value="All"))
    window.layout = Mock(get=Mock(return_value="Details"))
    window.preferences_path = Path("prefs.json")
    window._preferences = GuiPreferences()
    window.service = Mock(history_limit=100)
    window.winfo_toplevel = Mock(return_value=Mock())
    window.winfo_toplevel.return_value.winfo_width.return_value = 1100
    window.winfo_toplevel.return_value.winfo_height.return_value = 720

    with patch("amc.gui.save_preferences", side_effect=OSError("disk full")):
        window._save_preferences()


def test_window_close_saves_preferences_then_destroys():
    window = object.__new__(CatalogWindow)
    window._save_preferences = Mock()
    window.winfo_toplevel = Mock(return_value=Mock())

    window._on_close()

    window._save_preferences.assert_called_once_with()
    window.winfo_toplevel.return_value.destroy.assert_called_once_with()


def _window() -> CatalogWindow:
    window = object.__new__(CatalogWindow)
    window.service = Mock()
    window.service.path = Path("opened.json")
    window.refresh = Mock()
    window._path_changed = Mock()
    window.winfo_toplevel = Mock(return_value=Mock())
    window.status = Mock()
    window.details = Mock()
    window.poster = Mock()
    window.table = Mock()
    window.sort_field = None
    window.sort_reverse = False
    return window


def test_window_opens_selected_catalog():
    window = _window()
    with patch("amc.gui.filedialog.askopenfilename", return_value="movies.json"):
        window.open_catalog()
    window.service.open.assert_called_once_with("movies.json")
    window._path_changed.assert_called_once_with()


def test_movie_web_url_accepts_only_absolute_http_urls():
    assert movie_web_url(Movie(url=" https://example.com/movie?id=7 ")) == (
        "https://example.com/movie?id=7"
    )
    with pytest.raises(ValueError, match="has no URL"):
        movie_web_url(Movie())
    for unsafe in ("file:///tmp/movie", "javascript:alert(1)", "example.com/movie"):
        with pytest.raises(ValueError, match="absolute HTTP or HTTPS"):
            movie_web_url(Movie(url=unsafe))


def test_window_opens_selected_movie_url_in_browser():
    window = _window()
    window.selected = Mock(return_value=Movie(url="https://example.com/movie"))
    with patch("amc.gui.webbrowser.open", return_value=True) as open_browser:
        window.open_url()

    open_browser.assert_called_once_with("https://example.com/movie")


def test_window_reports_rejected_or_unhandled_movie_url():
    window = _window()
    window.selected = Mock(return_value=Movie(url="file:///tmp/movie"))
    with (
        patch("amc.gui.webbrowser.open") as open_browser,
        patch("amc.gui.messagebox.showerror") as showerror,
    ):
        window.open_url()
    open_browser.assert_not_called()
    showerror.assert_called_once()


def test_window_removes_all_selected_movies_atomically():
    window = _window()
    movies = [Movie(number=2, title="Two"), Movie(number=4, title="Four")]
    window.selected_movies = Mock(return_value=movies)
    with patch("amc.gui.messagebox.askyesno", return_value=True) as confirm:
        window.remove()

    window.service.remove_many.assert_called_once()
    assert list(window.service.remove_many.call_args.args[0]) == [2, 4]
    assert "2 selected movies" in confirm.call_args.args[1]
    window.refresh.assert_called_once_with()


def test_window_sets_the_same_picture_for_all_selected_movies_atomically():
    window = _window()
    movies = [Movie(number=2, title="Two"), Movie(number=4, title="Four")]
    window.selected_movies = Mock(return_value=movies)
    with (
        patch("amc.gui.filedialog.askopenfilename", return_value="cover.jpg"),
        patch("amc.gui.messagebox.askyesno", return_value=True) as confirm,
    ):
        window.set_pictures()

    window.service.set_picture_many.assert_called_once_with(
        {2: "cover.jpg", 4: "cover.jpg"}, embed=True
    )
    assert "2 selected movies" in confirm.call_args.args[1]
    window.refresh.assert_called_once_with()


def test_window_set_pictures_ignores_missing_selection_and_cancelled_dialog():
    window = _window()
    window.selected_movies = Mock(return_value=[])
    window.set_pictures()
    window.service.set_picture_many.assert_not_called()

    window.selected_movies = Mock(return_value=[Movie(number=2, title="Two")])
    with patch("amc.gui.filedialog.askopenfilename", return_value=""):
        window.set_pictures()
    window.service.set_picture_many.assert_not_called()


def test_window_set_pictures_links_instead_of_embedding_when_declined():
    window = _window()
    window.selected_movies = Mock(return_value=[Movie(number=2, title="Two")])
    with (
        patch("amc.gui.filedialog.askopenfilename", return_value="cover.jpg"),
        patch("amc.gui.messagebox.askyesno", return_value=False),
    ):
        window.set_pictures()

    window.service.set_picture_many.assert_called_once_with(
        {2: "cover.jpg"}, embed=False
    )


def test_window_assign_pictures_ignores_missing_selection():
    window = _window()
    window.selected_movies = Mock(return_value=[])
    with patch("amc.gui.tk.Toplevel") as toplevel:
        window.assign_pictures()
    toplevel.assert_not_called()
    window.service.set_picture_many.assert_not_called()


def test_window_clears_pictures_for_all_selected_movies_atomically():
    window = _window()
    movies = [Movie(number=2, title="Two"), Movie(number=4, title="Four")]
    window.selected_movies = Mock(return_value=movies)
    with patch("amc.gui.messagebox.askyesno", return_value=True) as confirm:
        window.clear_pictures()

    window.service.clear_picture_many.assert_called_once()
    assert list(window.service.clear_picture_many.call_args.args[0]) == [2, 4]
    assert "2 selected movies" in confirm.call_args.args[1]
    window.refresh.assert_called_once_with()


def test_window_clear_pictures_ignores_missing_selection_and_declined_confirmation():
    window = _window()
    window.selected_movies = Mock(return_value=[])
    window.clear_pictures()
    window.service.clear_picture_many.assert_not_called()

    window.selected_movies = Mock(return_value=[Movie(number=2, title="Two")])
    with patch("amc.gui.messagebox.askyesno", return_value=False):
        window.clear_pictures()
    window.service.clear_picture_many.assert_not_called()


def test_window_save_as_ignores_cancel_and_saves_selection():
    window = _window()
    with patch("amc.gui.filedialog.asksaveasfilename", return_value=""):
        window.save_as()
    window.service.save_as.assert_not_called()

    with patch("amc.gui.filedialog.asksaveasfilename", return_value="copy.json"):
        window.save_as()
    window.service.save_as.assert_called_once_with("copy.json")


def test_window_warns_that_opened_interchange_catalog_is_read_only():
    window = _window()
    with (
        patch("amc.gui.filedialog.askopenfilename", return_value="movies.amc"),
        patch("amc.gui.messagebox.showinfo") as showinfo,
    ):
        window.open_catalog()

    window.service.open.assert_called_once_with("movies.amc")
    assert "Save As" in showinfo.call_args.args[1]


def test_window_imports_and_refreshes():
    window = _window()
    window.service.import_from.return_value = 2
    with (
        patch("amc.gui.filedialog.askopenfilename", return_value="incoming.xml"),
        patch("amc.gui.messagebox.showinfo") as showinfo,
    ):
        window.import_catalog()
    window.service.import_from.assert_called_once_with("incoming.xml")
    window.refresh.assert_called_once_with()
    showinfo.assert_called_once()


def test_window_import_media_ignores_cancelled_file_dialog():
    window = _window()

    with (
        patch("amc.gui.filedialog.askopenfilenames", return_value=()),
        patch("amc.gui.tk.Toplevel") as toplevel,
    ):
        window.import_media()

    toplevel.assert_not_called()
    window.service.add_many.assert_not_called()


def test_window_import_media_inspects_selected_files_and_adds_them():
    window = _window()
    dialog = Mock()
    movies = [Movie(title="One"), Movie(title="Two")]

    with (
        patch(
            "amc.gui.filedialog.askopenfilenames",
            return_value=["one.mkv", "two.mkv"],
        ),
        patch("amc.gui.tk.Toplevel", return_value=dialog),
        patch("amc.gui.ttk.Label", return_value=Mock()),
        patch("amc.gui.ttk.Button", return_value=Mock()),
        patch("amc.gui.make_modal"),
        patch("amc.gui.movie_from_media", side_effect=movies),
        patch("amc.gui.messagebox.showinfo") as showinfo,
    ):
        window.import_media()

    window.service.add_many.assert_called_once_with(movies)
    window.refresh.assert_called_once_with()
    dialog.destroy.assert_called_once_with()
    showinfo.assert_called_once()


def test_window_import_media_can_be_cancelled_mid_scan():
    window = _window()
    dialog = Mock()
    paths = [Path("a.mkv"), Path("b.mkv"), Path("c.mkv")]
    inspected = []

    def fake_movie_from_media(path):
        inspected.append(path)
        if path == paths[0]:
            button.call_args_list[0].kwargs["command"]()
        return Movie(title=path.name)

    with (
        patch(
            "amc.gui.filedialog.askopenfilenames",
            return_value=[str(item) for item in paths],
        ),
        patch("amc.gui.tk.Toplevel", return_value=dialog),
        patch("amc.gui.ttk.Label", return_value=Mock()),
        patch("amc.gui.ttk.Button") as button,
        patch("amc.gui.make_modal"),
        patch("amc.gui.movie_from_media", side_effect=fake_movie_from_media),
    ):
        window.import_media()

    assert inspected == [paths[0]]
    window.service.add_many.assert_not_called()
    window.refresh.assert_not_called()
    dialog.destroy.assert_called_once_with()


def test_window_import_media_reports_invalid_media_without_mutating_catalog():
    window = _window()
    dialog = Mock()

    with (
        patch(
            "amc.gui.filedialog.askopenfilenames", return_value=["broken.mkv"],
        ),
        patch("amc.gui.tk.Toplevel", return_value=dialog),
        patch("amc.gui.ttk.Label", return_value=Mock()),
        patch("amc.gui.ttk.Button", return_value=Mock()),
        patch("amc.gui.make_modal"),
        patch("amc.gui.movie_from_media", side_effect=ValueError("bad media")),
        patch("amc.gui.messagebox.showerror") as showerror,
    ):
        window.import_media()

    window.service.add_many.assert_not_called()
    window.refresh.assert_not_called()
    dialog.destroy.assert_called_once_with()
    showerror.assert_called_once()


def test_window_exports_using_destination_extension():
    window = _window()
    with (
        patch("amc.gui.filedialog.asksaveasfilename", return_value="movies.csv"),
        patch("amc.gui.messagebox.showinfo"),
    ):
        window.export_catalog()
    window.service.export.assert_called_once_with("movies.csv", format="csv")


def test_window_requires_confirmation_for_unverified_native_export():
    window = _window()
    with (
        patch("amc.gui.filedialog.asksaveasfilename", return_value="movies.amc"),
        patch("amc.gui.messagebox.askyesno", return_value=False) as confirm,
    ):
        window.export_catalog()

    window.service.export.assert_not_called()
    assert "not been verified" in confirm.call_args.args[1]


def test_window_native_export_explains_existing_backup(tmp_path: Path):
    window = _window()
    destination = tmp_path / "movies.amc"
    destination.write_bytes(b"old catalog")
    with (
        patch(
            "amc.gui.filedialog.asksaveasfilename", return_value=str(destination)
        ),
        patch("amc.gui.messagebox.askyesno", return_value=True) as confirm,
        patch("amc.gui.messagebox.showinfo") as showinfo,
    ):
        window.export_catalog()

    window.service.export.assert_called_once_with(str(destination), format="amc")
    assert str(destination.with_suffix(".bak")) in confirm.call_args.args[1]
    assert str(destination.with_suffix(".bak")) in showinfo.call_args.args[1]


def test_window_rejects_unknown_export_extension():
    window = _window()
    with (
        patch("amc.gui.filedialog.asksaveasfilename", return_value="movies.pdf"),
        patch("amc.gui.messagebox.showerror") as showerror,
    ):
        window.export_catalog()
    window.service.export.assert_not_called()
    showerror.assert_called_once()


def test_window_checks_selected_movie_in():
    window = _window()
    window.selected_movies = Mock(return_value=[
        Movie(number=7, title="Moon", borrower="Sam"),
        Movie(number=8, title="Alien", borrower="Sam"),
    ])

    window.loan_in()

    window.service.check_in_many.assert_called_once()
    assert list(window.service.check_in_many.call_args.args[0]) == [7, 8]
    window.refresh.assert_called_once_with()


def test_window_loan_in_ignores_missing_selection():
    window = _window()
    window.selected_movies = Mock(return_value=[])

    window.loan_in()

    window.service.check_in_many.assert_not_called()


def test_window_shows_service_statistics_and_duplicate_count():
    window = _window()
    window.service.statistics.return_value = {
        "movies": 3,
        "checked": 1,
        "total_length": 120,
        "average_rating": None,
        "earliest_year": 1985,
        "latest_year": 2009,
    }
    window.service.duplicates.return_value = [[Movie(), Movie()]]

    with patch("amc.gui.messagebox.showinfo") as showinfo:
        window.show_statistics()

    message = showinfo.call_args.args[1]
    assert "Movies: 3" in message
    assert "Average rating: —" in message
    assert "Duplicate groups: 1" in message


def test_window_reports_invalid_loan_history_without_opening_dialog():
    window = _window()
    window.service.loan_history.side_effect = ValueError("invalid history")
    with (
        patch("amc.gui.tk.Toplevel") as toplevel,
        patch("amc.gui.messagebox.showerror") as showerror,
    ):
        window.show_loan_history()

    toplevel.assert_not_called()
    showerror.assert_called_once_with(
        "Could not read loan history", "invalid history", parent=window
    )


def test_window_exports_loan_history_to_selected_destination():
    window = _window()
    window.service.path = Path("movies.json")
    with (
        patch(
            "amc.gui.filedialog.asksaveasfilename",
            return_value="movies loan history.csv",
        ) as save_dialog,
        patch("amc.gui.messagebox.showinfo") as showinfo,
    ):
        window.export_loan_history()

    assert save_dialog.call_args.kwargs["initialfile"] == "movies loan history.csv"
    window.service.export_loan_history.assert_called_once_with(
        "movies loan history.csv"
    )
    showinfo.assert_called_once()


def test_window_loan_history_export_cancel_and_failure_are_safe():
    window = _window()
    with patch("amc.gui.filedialog.asksaveasfilename", return_value=""):
        window.export_loan_history()
    window.service.export_loan_history.assert_not_called()

    window.service.export_loan_history.side_effect = OSError("disk full")
    with (
        patch("amc.gui.filedialog.asksaveasfilename", return_value="history.csv"),
        patch("amc.gui.messagebox.showerror") as showerror,
    ):
        window.export_loan_history()
    showerror.assert_called_once()


def test_window_shows_duplicate_movie_groups():
    window = _window()
    window.service.duplicates.return_value = [[
        Movie(number=1, title="Moon", year=2009),
        Movie(number=8, title="moon", year=2009),
    ]]

    with patch("amc.gui.messagebox.showinfo") as showinfo:
        window.show_duplicates()

    assert showinfo.call_args.args == (
        "Duplicate movies",
        "#1 Moon (2009), #8 moon (2009)",
    )


def test_window_renumbers_after_confirmation():
    window = _window()
    window.service.catalog = [Movie(), Movie()]
    with patch("amc.gui.messagebox.askyesno", return_value=True):
        window.renumber()

    window.service.renumber.assert_called_once_with()
    window.refresh.assert_called_once_with()


def test_window_does_not_renumber_after_rejection():
    window = _window()
    window.service.catalog = [Movie(), Movie()]
    with patch("amc.gui.messagebox.askyesno", return_value=False):
        window.renumber()

    window.service.renumber.assert_not_called()


def test_window_backs_up_selected_destination():
    window = _window()
    window.path = Path("movies.json")
    with (
        patch("amc.gui.filedialog.asksaveasfilename", return_value="safe.json"),
        patch("amc.gui.messagebox.showinfo") as showinfo,
    ):
        window.backup_catalog()

    window.service.backup.assert_called_once_with("safe.json")
    showinfo.assert_called_once()


def test_window_restores_confirmed_backup_and_refreshes():
    window = _window()
    with (
        patch("amc.gui.filedialog.askopenfilename", return_value="safe.json"),
        patch("amc.gui.messagebox.askyesno", return_value=True),
        patch("amc.gui.messagebox.showinfo"),
    ):
        window.restore_catalog()

    window.service.restore.assert_called_once_with("safe.json")
    window.refresh.assert_called_once_with()


def test_window_does_not_restore_without_confirmation():
    window = _window()
    with (
        patch("amc.gui.filedialog.askopenfilename", return_value="safe.json"),
        patch("amc.gui.messagebox.askyesno", return_value=False),
    ):
        window.restore_catalog()

    window.service.restore.assert_not_called()


def test_window_open_failure_keeps_active_view():
    window = _window()
    window.service.open.side_effect = CorruptCatalogError("broken catalog")
    with (
        patch("amc.gui.filedialog.askopenfilename", return_value="broken.amc"),
        patch("amc.gui.messagebox.showerror") as showerror,
    ):
        window.open_catalog()

    window._path_changed.assert_not_called()
    showerror.assert_called_once()


def test_window_restore_failure_does_not_refresh():
    window = _window()
    window.service.restore.side_effect = OSError("disk full")
    with (
        patch("amc.gui.filedialog.askopenfilename", return_value="safe.json"),
        patch("amc.gui.messagebox.askyesno", return_value=True),
        patch("amc.gui.messagebox.showerror") as showerror,
    ):
        window.restore_catalog()

    window.refresh.assert_not_called()
    showerror.assert_called_once()


def test_window_sort_failure_does_not_refresh():
    window = _window()
    window.service.sort.side_effect = OSError("disk full")
    with patch("amc.gui.messagebox.showerror") as showerror:
        window.sort("title")

    window.refresh.assert_not_called()
    showerror.assert_called_once()


def test_window_reloads_and_refreshes():
    window = _window()

    window.reload_catalog()

    window.service.reload.assert_called_once_with()
    window.refresh.assert_called_once_with()


def test_window_reload_failure_does_not_refresh():
    window = _window()
    window.service.reload.side_effect = CorruptCatalogError("broken catalog")
    with patch("amc.gui.messagebox.showerror") as showerror:
        window.reload_catalog()

    window.refresh.assert_not_called()
    showerror.assert_called_once()


def test_gui_entry_point_accepts_catalog_path():
    with patch("amc.gui.run") as run:
        main(["movies.json"])

    run.assert_called_once_with(Path("movies.json"))


def test_gui_entry_point_defaults_to_catalog_json():
    with patch("amc.gui.run") as run:
        main([])

    run.assert_called_once_with(Path("catalog.json"))


def test_run_sets_title_and_resizable_minimum_size():
    root = Mock()
    with (
        patch("amc.gui.tk.Tk", return_value=root),
        patch("amc.gui.CatalogWindow") as window,
    ):
        run(Path("movies.amc"))

    root.title.assert_called_once_with("AMC Python — movies.amc")
    root.minsize.assert_called_once_with(760, 480)
    window.assert_called_once_with(root, Path("movies.amc"))
    root.mainloop.assert_called_once_with()


def test_window_focuses_and_selects_search_text():
    window = _window()
    window.search_entry = Mock()

    window.focus_search()

    window.search_entry.focus_set.assert_called_once_with()
    window.search_entry.selection_range.assert_called_once_with(0, "end")


def test_window_escape_clears_search_and_focuses_table():
    window = _window()
    window.search_text = Mock()

    window.clear_search()

    window.search_text.set.assert_called_once_with("")
    window.table.focus_set.assert_called_once_with()


def test_window_keyboard_action_uses_button_state():
    window = _window()
    window.action_buttons = {"Remove": Mock()}

    result = window.invoke_action("Remove")

    window.action_buttons["Remove"].invoke.assert_called_once_with()
    assert result == "break"


def test_window_action_states_follow_selection_history_and_format():
    window = _window()
    names = (
        "Add", "Edit", "Remove", "Loan Out", "Loan In", "Toggle Checked",
        "Set Pictures", "Assign Pictures", "Clear Pictures", "Undo", "Redo",
        "Open URL", "Renumber",
    )
    window.action_buttons = {name: Mock() for name in names}
    window.import_button = Mock()
    window.import_media_button = Mock()
    window.restore_button = Mock()
    window.table.selection.return_value = ("7", "8")
    window.service.is_writable = True
    window.service.can_undo = True
    window.service.can_redo = False
    window.service.catalog = Catalog([
        Movie(number=7, borrower="Sam"), Movie(number=8, borrower="Sam"),
    ])

    window.update_action_states()

    assert window.action_buttons["Edit"].configure.call_args.kwargs["state"] == "disabled"
    assert window.action_buttons["Remove"].configure.call_args.kwargs["state"] == "normal"
    assert window.action_buttons["Open URL"].configure.call_args.kwargs["state"] == "disabled"
    assert window.action_buttons["Undo"].configure.call_args.kwargs["state"] == "normal"
    assert window.action_buttons["Redo"].configure.call_args.kwargs["state"] == "disabled"
    assert window.import_button.configure.call_args.kwargs["state"] == "normal"
    assert window.restore_button.configure.call_args.kwargs["state"] == "normal"


def test_window_disables_mutations_for_interchange_catalog():
    window = _window()
    names = (
        "Add", "Edit", "Remove", "Loan Out", "Loan In", "Toggle Checked",
        "Set Pictures", "Assign Pictures", "Clear Pictures", "Undo", "Redo",
        "Open URL", "Renumber",
    )
    window.action_buttons = {name: Mock() for name in names}
    window.import_button = Mock()
    window.import_media_button = Mock()
    window.restore_button = Mock()
    window.table.selection.return_value = ("7",)
    window.service.is_writable = False
    window.service.catalog = Catalog([
        Movie(number=7, url="https://example.com"),
    ])

    window.update_action_states()

    for name in names:
        expected = "normal" if name == "Open URL" else "disabled"
        assert window.action_buttons[name].configure.call_args.kwargs["state"] == expected
    assert window.import_button.configure.call_args.kwargs["state"] == "disabled"
    assert window.restore_button.configure.call_args.kwargs["state"] == "disabled"


def test_window_disables_actions_when_selection_lacks_required_data():
    window = _window()
    names = (
        "Add", "Edit", "Remove", "Loan Out", "Loan In", "Toggle Checked",
        "Set Pictures", "Assign Pictures", "Clear Pictures", "Undo", "Redo",
        "Open URL", "Renumber",
    )
    window.action_buttons = {name: Mock() for name in names}
    window.import_button = Mock()
    window.import_media_button = Mock()
    window.restore_button = Mock()
    window.table.selection.return_value = ("7",)
    window.service.is_writable = True
    window.service.can_undo = False
    window.service.can_redo = False
    window.service.catalog = Catalog([Movie(number=7)])

    window.update_action_states()

    assert window.action_buttons["Loan In"].configure.call_args.kwargs["state"] == "disabled"
    assert window.action_buttons["Open URL"].configure.call_args.kwargs["state"] == "disabled"


def test_window_renders_selected_movie_details_read_only():
    window = _window()
    window.selected = Mock(return_value=Movie(
        number=7,
        title="Moon",
        director="Duncan Jones",
        borrower="Sam Bell",
        description="A lunar mystery.",
    ))

    window.show_selected()

    inserted = window.details.insert.call_args.args[1]
    assert "Title: Moon" in inserted
    assert "Director: Duncan Jones" in inserted
    assert "Borrower: Sam Bell" in inserted
    assert "Description: A lunar mystery." in inserted
    assert window.details.configure.call_args_list[-1].kwargs == {"state": "disabled"}


def test_window_clears_details_without_selection():
    window = _window()
    window.selected = Mock(return_value=None)

    window.show_selected()

    window.details.insert.assert_called_once_with("1.0", "")


def _form_values(**overrides: str) -> dict[str, str]:
    values = {
        name: "" for name in _EDIT_TEXT_FIELDS + _EDIT_INTEGER_FIELDS + _EDIT_FLOAT_FIELDS
    }
    values.update(overrides)
    return values


def test_movie_form_parses_all_scalar_field_kinds():
    movie = movie_from_form(
        Movie(number=7, extras={"kept": True}),
        _form_values(
            title=" Moon ", year="2009", length="97", rating="8.5",
            user_rating="9", color_tag="2", framerate="23.976",
            director=" Duncan Jones ",
            writer=" Nathan Parker ", composer=" Clint Mansell ",
            certification=" R ", file_path=" Media/Moon.mkv ",
            description="  A lunar mystery.\nSecond paragraph.  ",
            comments="  Restored edition.  ",
        ),
        checked=True,
    )

    assert (movie.number, movie.title, movie.year, movie.length) == (7, "Moon", 2009, 97)
    assert (movie.rating, movie.framerate, movie.director, movie.checked) == (
        8.5, 23.976, "Duncan Jones", True
    )
    assert (movie.user_rating, movie.color_tag) == (9, 2)
    assert (movie.writer, movie.composer, movie.certification, movie.file_path) == (
        "Nathan Parker", "Clint Mansell", "R", "Media/Moon.mkv"
    )
    assert movie.extras == {"kept": True}
    assert movie.description == "A lunar mystery.\nSecond paragraph."
    assert movie.comments == "Restored edition."


def test_movie_form_reports_field_specific_number_errors():
    with pytest.raises(ValueError, match="video bitrate must be an integer"):
        movie_from_form(Movie(), _form_values(video_bitrate="fast"), checked=False)
    with pytest.raises(ValueError, match="rating must be a number"):
        movie_from_form(Movie(), _form_values(rating="great"), checked=False)


def test_movie_view_filters_cover_loan_and_checked_states():
    movies = [
        Movie(number=1, title="Available"),
        Movie(number=2, title="Loaned", borrower="Sam"),
        Movie(number=3, title="Checked", checked=True),
    ]

    assert [movie.number for movie in filter_movies(movies, "All")] == [1, 2, 3]
    assert [movie.number for movie in filter_movies(movies, "Loaned")] == [2]
    assert [movie.number for movie in filter_movies(movies, "Available")] == [1, 3]
    assert [movie.number for movie in filter_movies(movies, "Checked")] == [3]
    assert [movie.number for movie in filter_movies(movies, "Unchecked")] == [1, 2]


def test_movie_view_filter_rejects_unknown_mode():
    with pytest.raises(ValueError, match="unknown movie view filter"):
        filter_movies([], "Missing")


def test_movie_row_includes_checked_and_borrower_status():
    assert movie_row(Movie(
        number=7, title="Moon", year=2009, director="Duncan Jones",
        checked=True, borrower="Sam Bell",
    )) == (7, "Moon", 2009, "Duncan Jones", "Yes", "Sam Bell")


def test_loan_event_row_uses_readable_action_and_timestamp():
    event = LoanEvent(
        timestamp="2026-08-14T12:30:00+00:00",
        action="out",
        movie_number=7,
        media_label="DVD 4",
        title="Moon",
        borrower="Sam Bell",
    )

    assert loan_event_row(event) == (
        "2026-08-14 12:30:00+00:00", "Checked out", 7, "Moon", "Sam Bell",
    )


def test_window_toggles_selected_checked_state():
    window = _window()
    window.selected_movies = Mock(
        return_value=[Movie(number=7, title="Moon", checked=False)]
    )

    window.toggle_checked()

    window.service.set_checked_many.assert_called_once()
    assert list(window.service.set_checked_many.call_args.args[0]) == [7]
    assert window.service.set_checked_many.call_args.args[1] is True
    window.refresh.assert_called_once_with()


def test_window_bulk_checked_toggle_checks_mixed_selection_then_clears_all():
    window = _window()
    window.selected_movies = Mock(return_value=[
        Movie(number=2, checked=True),
        Movie(number=4, checked=False),
    ])

    window.toggle_checked()
    first = window.service.set_checked_many.call_args
    assert list(first.args[0]) == [2, 4]
    assert first.args[1] is True

    window.selected_movies.return_value = [
        Movie(number=2, checked=True),
        Movie(number=4, checked=True),
    ]
    window.toggle_checked()
    second = window.service.set_checked_many.call_args
    assert list(second.args[0]) == [2, 4]
    assert second.args[1] is False


def test_window_checked_failure_does_not_refresh():
    window = _window()
    window.selected_movies = Mock(
        return_value=[Movie(number=7, title="Moon", checked=True)]
    )
    window.service.set_checked_many.side_effect = OSError("disk full")
    with patch("amc.gui.messagebox.showerror") as showerror:
        window.toggle_checked()

    window.refresh.assert_not_called()
    showerror.assert_called_once()


def test_window_undo_and_redo_delegate_and_refresh():
    window = _window()

    window.undo()
    window.redo()

    window.service.undo.assert_called_once_with()
    window.service.redo.assert_called_once_with()
    assert window.refresh.call_count == 2


def test_window_failed_undo_does_not_refresh():
    window = _window()
    window.service.undo.side_effect = OSError("disk full")
    with patch("amc.gui.messagebox.showerror") as showerror:
        window.undo()

    window.refresh.assert_not_called()
    showerror.assert_called_once()


def test_poster_source_prefers_valid_embedded_picture(tmp_path: Path):
    encoded = base64.b64encode(b"GIF89a").decode("ascii")
    movie = Movie(picture="missing.gif", extras={"native_picture_base64": encoded})

    assert poster_source(movie, tmp_path / "movies.amc") == ("data", encoded)


def test_movie_with_picture_adds_and_removes_embedded_data():
    original = Movie(
        number=4,
        title="Moon",
        extras={"custom": "kept", "native_picture_base64": "old"},
    )

    embedded = movie_with_picture(original, " covers/moon.jpg ", embedded=b"image")
    linked = movie_with_picture(embedded, "covers/moon.jpg", embedded=None)

    assert embedded.picture == "covers/moon.jpg"
    assert base64.b64decode(embedded.extras["native_picture_base64"]) == b"image"
    assert embedded.extras["custom"] == "kept"
    assert linked.extras == {"custom": "kept"}
    assert original.extras["native_picture_base64"] == "old"


def test_movie_with_picture_rejects_empty_embedded_data():
    with pytest.raises(ValueError, match="cannot be empty"):
        movie_with_picture(Movie(), "poster.jpg", embedded=b"")


def test_poster_source_resolves_relative_link(tmp_path: Path):
    poster = tmp_path / "covers" / "moon.gif"
    poster.parent.mkdir()
    poster.write_bytes(b"GIF89a")

    assert poster_source(Movie(picture="covers/moon.gif"), tmp_path / "movies.json") == (
        "file", str(poster)
    )


def test_poster_source_rejects_invalid_or_missing_sources(tmp_path: Path):
    assert poster_source(Movie(extras={"native_picture_base64": "not base64"}), tmp_path / "x.amc") is None
    assert poster_source(Movie(picture="missing.jpg"), tmp_path / "x.json") is None


def test_poster_source_falls_back_from_invalid_embedded_to_linked(tmp_path: Path):
    poster = tmp_path / "cover.jpg"
    poster.write_bytes(b"poster")
    movie = Movie(
        picture="cover.jpg", extras={"native_picture_base64": "not base64"}
    )

    assert poster_source(movie, tmp_path / "movies.amc") == ("file", str(poster))


def test_poster_source_recovers_windows_path_beside_catalog(tmp_path: Path):
    poster = tmp_path / "cover.jpg"
    poster.write_bytes(b"poster")

    assert poster_source(
        Movie(picture=r"C:\Movies\Posters\cover.jpg"), tmp_path / "movies.amc"
    ) == ("file", str(poster))


def test_parse_history_limit_accepts_in_range_values():
    assert parse_history_limit(1) == 1
    assert parse_history_limit(1000) == 1000
    assert parse_history_limit(250) == 250


def test_parse_history_limit_rejects_out_of_range_or_non_integer_values():
    with pytest.raises(ValueError, match="between 1 and 1000"):
        parse_history_limit(0)
    with pytest.raises(ValueError, match="between 1 and 1000"):
        parse_history_limit(1001)
    with pytest.raises(ValueError, match="whole number"):
        parse_history_limit(True)
    with pytest.raises(ValueError, match="whole number"):
        parse_history_limit(5.5)


def test_window_preferences_dialog_updates_service_history_limit():
    window = object.__new__(CatalogWindow)
    window.service = Mock(history_limit=100)
    window._save_preferences = Mock()
    dialog = Mock()
    limit = Mock(get=Mock(return_value=250))
    spinbox = Mock()

    with (
        patch("amc.gui.tk.Toplevel", return_value=dialog),
        patch("amc.gui.tk.IntVar", return_value=limit),
        patch("amc.gui.ttk.Spinbox", return_value=spinbox),
        patch("amc.gui.ttk.Label"),
        patch("amc.gui.ttk.Frame"),
        patch("amc.gui.ttk.Button") as button,
        patch("amc.gui.make_modal"),
        patch("amc.gui.messagebox.showerror") as showerror,
    ):
        window.winfo_toplevel = Mock(return_value=Mock())
        window.open_preferences()
        accept = button.call_args_list[1].kwargs["command"]
        accept()

    showerror.assert_not_called()
    assert window.service.history_limit == 250
    window._save_preferences.assert_called_once_with()
    dialog.destroy.assert_called_once_with()


def test_poster_size_preserves_aspect_ratio_without_upscaling():
    assert poster_size(640, 800) == (320, 400)
    assert poster_size(800, 400) == (320, 160)
    assert poster_size(100, 200) == (100, 200)
    with pytest.raises(ValueError, match="dimensions must be positive"):
        poster_size(0, 100)


def test_crop_box_from_canvas_scales_to_image_pixels():
    # A 200x100 preview of a 400x200 image scales by exactly 2x.
    assert crop_box_from_canvas((10, 20, 110, 70), (200, 100), (400, 200)) == (
        20, 40, 220, 140,
    )


def test_crop_box_from_canvas_normalizes_reversed_drag_direction():
    # Dragging from bottom-right to top-left still yields an ordered box.
    assert crop_box_from_canvas((110, 70, 10, 20), (200, 100), (400, 200)) == (
        20, 40, 220, 140,
    )


def test_crop_box_from_canvas_clamps_out_of_bounds_coordinates():
    assert crop_box_from_canvas((-50, -50, 250, 150), (200, 100), (200, 100)) == (
        0, 0, 200, 100,
    )


def test_crop_box_from_canvas_rejects_empty_selection():
    with pytest.raises(ValueError, match="crop selection is empty"):
        crop_box_from_canvas((10, 10, 10, 40), (200, 100), (200, 100))
    with pytest.raises(ValueError, match="crop selection is empty"):
        crop_box_from_canvas((-5, 10, 0, 40), (200, 100), (200, 100))


def test_crop_box_from_canvas_rejects_non_positive_dimensions():
    with pytest.raises(ValueError, match="display dimensions must be positive"):
        crop_box_from_canvas((0, 0, 10, 10), (0, 100), (200, 100))
    with pytest.raises(ValueError, match="image dimensions must be positive"):
        crop_box_from_canvas((0, 0, 10, 10), (200, 100), (200, 0))


def test_crop_image_bytes_crops_and_preserves_source_format():
    image = Image.new("RGB", (400, 200), "red")
    image.putpixel((300, 150), (0, 0, 255))
    buffer = io.BytesIO()
    image.save(buffer, format="PNG")

    cropped_bytes = crop_image_bytes(buffer.getvalue(), (150, 100, 350, 200))

    with Image.open(io.BytesIO(cropped_bytes)) as cropped:
        assert cropped.format == "PNG"
        assert cropped.size == (200, 100)
        assert cropped.getpixel((150, 50)) == (0, 0, 255)


def test_open_crop_dialog_rejects_invalid_image_bytes_before_opening_any_window():
    with pytest.raises(UnidentifiedImageError):
        open_crop_dialog(Mock(), b"not an image", on_apply=Mock())


def test_window_reports_missing_linked_poster():
    window = _window()

    window._show_poster(Movie(picture="covers/missing.jpg"))

    assert window.poster.configure.call_args.kwargs["text"] == (
        "Poster file not found: covers/missing.jpg"
    )


def test_modal_waits_until_viewable_before_grab_and_focus():
    calls: list[str] = []
    dialog = Mock()
    focus = Mock()
    dialog.update_idletasks.side_effect = lambda: calls.append("update")
    dialog.wait_visibility.side_effect = lambda: calls.append("visible")
    focus.focus_set.side_effect = lambda: calls.append("focus")
    dialog.grab_set.side_effect = lambda: calls.append("grab")

    make_modal(dialog, focus=focus)

    assert calls == ["update", "visible", "focus", "grab"]
