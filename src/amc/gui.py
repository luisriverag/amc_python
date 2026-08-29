"""Small standard-library desktop interface for AMC Python."""

from __future__ import annotations

import argparse
import base64
from collections.abc import Callable
import functools
import io
import os
import tkinter as tk
import webbrowser
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlparse
from tkinter import filedialog, messagebox, simpledialog, ttk
from tkinter import font as tkfont

from PIL import Image, ImageTk, UnidentifiedImageError
from tkinterweb import HtmlFrame

from . import __version__
from .application import CatalogService
from .errors import CatalogError
from .html_template import _read_template, render_individual_template
from .loans import LoanEvent
from .media import (
    DEFAULT_MEDIA_EXTENSIONS,
    attach_media_pictures,
    discover_media,
    merge_media_parts,
    movie_from_media,
)
from .model import Movie
from .omdb import (
    DEFAULT_TIMEOUT as DEFAULT_OMDB_TIMEOUT,
    fetch_omdb_record,
    imdb_id_from_url,
    preview_omdb_update,
)
from .preferences import (
    MAX_HISTORY_LIMIT,
    MIN_HISTORY_LIMIT,
    GuiPreferences,
    default_preferences_path,
    load_preferences,
    save_preferences,
)
from .presentation import filter_movies, poster_source
from .scripts import ScriptMergePreview

_EDIT_TEXT_FIELDS = (
    "title",
    "original_title",
    "translated_title",
    "director",
    "producer",
    "writer",
    "composer",
    "country",
    "category",
    "certification",
    "date",
    "media_label",
    "media_type",
    "source",
    "file_path",
    "languages",
    "subtitles",
    "video_format",
    "audio_format",
    "resolution",
    "url",
    "actors",
    "description",
    "comments",
    "picture",
)
_EDIT_MULTILINE_FIELDS = {"description", "comments"}
_EDIT_INTEGER_FIELDS = (
    "color_tag",
    "year",
    "length",
    "media_count",
    "video_bitrate",
    "audio_bitrate",
    "file_size",
)
_EDIT_FLOAT_FIELDS = ("rating", "user_rating", "framerate")
_SEARCH_FIELDS: tuple[tuple[str, str | None], ...] = (
    ("All fields", None),
    ("Title", "title"),
    ("Original title", "original_title"),
    ("Translated title", "translated_title"),
    ("Director", "director"),
    ("Producer", "producer"),
    ("Actors", "actors"),
    ("Category", "category"),
    ("Country", "country"),
    ("Year", "year"),
    ("Description", "description"),
    ("Comments", "comments"),
    ("Borrower", "borrower"),
    ("URL", "url"),
    ("File Path", "file_path"),
)
_SEARCH_FIELD_BY_LABEL = dict(_SEARCH_FIELDS)
_EXPORT_SORT_FIELDS = (
    "title",
    "original_title",
    "year",
    "director",
    "category",
    "rating",
    "length",
)
_IMAGE_FILETYPES = (
    ("Images", "*.jpg *.jpeg *.png *.gif *.bmp *.tif *.tiff *.webp"),
    ("All files", "*"),
)
# Every catalog-mutating CatalogService call the desktop makes is wrapped in
# this exact tuple. CatalogError/OSError/TypeError/ValueError are the
# documented service-layer failures; KeyError is Catalog.get()'s (and hence
# replace/remove/check-out/check-in/set-checked/picture) documented signal
# for a movie number that no longer exists, e.g. a stale selection racing
# another mutation. It belongs in every one of these boundaries, not just
# the ones a past edit happened to add it to — an uncaught KeyError here
# would surface as an unhandled Tk callback traceback instead of the same
# graceful error dialog every other expected failure gets.
_SERVICE_ERRORS = (CatalogError, OSError, TypeError, ValueError, KeyError)


def movie_from_form(movie: Movie, values: dict[str, str], *, checked: bool) -> Movie:
    """Build a validated replacement from GUI text values."""
    data = movie.to_dict()
    for name in _EDIT_TEXT_FIELDS:
        data[name] = values[name].strip()
    for name in _EDIT_INTEGER_FIELDS:
        raw = values[name].strip()
        try:
            data[name] = int(raw) if raw else None
        except ValueError as error:
            raise ValueError(f"{name.replace('_', ' ')} must be an integer") from error
    for name in _EDIT_FLOAT_FIELDS:
        raw = values[name].strip()
        try:
            data[name] = float(raw) if raw else None
        except ValueError as error:
            raise ValueError(f"{name.replace('_', ' ')} must be a number") from error
    data["checked"] = checked
    return Movie.from_dict(data)


def movie_with_picture(movie: Movie, picture: str, *, embedded: bytes | None) -> Movie:
    """Return a movie with linked and embedded picture state kept consistent."""
    data = movie.to_dict()
    data["picture"] = picture.strip()
    extras = data["extras"]
    extras.pop("native_picture_base64", None)
    if embedded is not None:
        if not embedded:
            raise ValueError("embedded poster data cannot be empty")
        extras["native_picture_base64"] = base64.b64encode(embedded).decode("ascii")
    return Movie.from_dict(data)


def movie_row(movie: Movie) -> tuple[object, ...]:
    """Return the stable table values for one movie."""
    return (
        movie.number,
        movie.display_title(),
        movie.year or "",
        movie.director,
        "Yes" if movie.checked else "",
        movie.borrower,
    )


def loan_event_row(event: LoanEvent) -> tuple[object, ...]:
    """Return concise display values for a retained loan event."""
    action = "Checked out" if event.action == "out" else "Checked in"
    return (
        event.timestamp.replace("T", " ", 1),
        action,
        event.movie_number,
        event.title,
        event.borrower,
    )


def poster_size(
    width: int, height: int, *, maximum: tuple[int, int] = (320, 420)
) -> tuple[int, int]:
    """Fit an image within the poster pane without changing its aspect ratio."""
    if width < 1 or height < 1:
        raise ValueError("poster dimensions must be positive")
    scale = min(maximum[0] / width, maximum[1] / height, 1.0)
    return max(1, round(width * scale)), max(1, round(height * scale))


def parse_history_limit(value: int) -> int:
    """Validate a Preferences dialog undo/redo history-limit entry."""
    if isinstance(value, bool) or not isinstance(value, int):
        raise ValueError("history limit must be a whole number")
    if not MIN_HISTORY_LIMIT <= value <= MAX_HISTORY_LIMIT:
        raise ValueError(
            f"history limit must be between {MIN_HISTORY_LIMIT} and {MAX_HISTORY_LIMIT}"
        )
    return value


def parse_extensions(text: str) -> set[str] | None:
    """Parse a comma-separated extension list the same way the CLI's
    ``import-media --extensions`` does: blank input means no filter."""
    if text.strip().casefold() == "default":
        return set(DEFAULT_MEDIA_EXTENSIONS)
    extensions = {item.strip() for item in text.split(",") if item.strip()}
    return extensions or None


def make_modal(dialog: tk.Toplevel, *, focus: tk.Widget | None = None) -> None:
    """Wait for a child window to become viewable before taking the Tk grab."""
    dialog.update_idletasks()
    dialog.wait_visibility()
    if focus is not None:
        focus.focus_set()
    dialog.grab_set()


def crop_box_from_canvas(
    rectangle: tuple[float, float, float, float],
    display_size: tuple[int, int],
    image_size: tuple[int, int],
) -> tuple[int, int, int, int]:
    """Map a dragged canvas rectangle to a clamped, ordered image-pixel crop box.

    *rectangle* is a possibly unordered, possibly out-of-bounds ``(x1, y1, x2,
    y2)`` in canvas coordinates, as produced while dragging a selection over a
    scaled preview of *display_size* showing an image of *image_size*.
    """
    display_width, display_height = display_size
    image_width, image_height = image_size
    if display_width < 1 or display_height < 1:
        raise ValueError("display dimensions must be positive")
    if image_width < 1 or image_height < 1:
        raise ValueError("image dimensions must be positive")
    x1, y1, x2, y2 = rectangle
    left, right = sorted((x1, x2))
    top, bottom = sorted((y1, y2))
    left = min(max(left, 0.0), display_width)
    right = min(max(right, 0.0), display_width)
    top = min(max(top, 0.0), display_height)
    bottom = min(max(bottom, 0.0), display_height)
    scale_x = image_width / display_width
    scale_y = image_height / display_height
    box = (
        max(0, min(image_width, round(left * scale_x))),
        max(0, min(image_height, round(top * scale_y))),
        max(0, min(image_width, round(right * scale_x))),
        max(0, min(image_height, round(bottom * scale_y))),
    )
    if box[2] <= box[0] or box[3] <= box[1]:
        raise ValueError("the crop selection is empty")
    return box


def crop_image_bytes(image_bytes: bytes, box: tuple[int, int, int, int]) -> bytes:
    """Crop encoded image bytes to *box*, re-encoding in the source format."""
    with Image.open(io.BytesIO(image_bytes)) as source:
        image_format = source.format or "PNG"
        cropped = source.crop(box)
        output = io.BytesIO()
        cropped.save(output, format=image_format)
        return output.getvalue()


@dataclass
class _CropSelection:
    """Mutable drag-to-select state for `open_crop_dialog`'s canvas
    callbacks, plus a reference to the displayed `PhotoImage` so it isn't
    garbage-collected while the dialog is still showing it."""

    photo: ImageTk.PhotoImage
    start: tuple[float, float] = (0.0, 0.0)
    rect: int | None = None


def open_crop_dialog(
    parent: tk.Misc,
    image_bytes: bytes,
    *,
    on_apply: Callable[[tuple[int, int, int, int]], None],
) -> None:
    """Show a draggable-rectangle crop editor over *image_bytes*.

    Calls *on_apply* with the selected crop box, in the source image's own
    pixel coordinates, only when the user drags a selection and accepts it.
    The caller decides what to do with the box — e.g. crop bytes immediately
    with `crop_image_bytes`, or keep it to pass into a later batch operation.
    """
    with Image.open(io.BytesIO(image_bytes)) as source:
        source.load()
        image_size = source.size
        display_size = poster_size(*image_size, maximum=(480, 480))
        preview = source.copy()
        preview.thumbnail(display_size, Image.Resampling.LANCZOS)
        photo = ImageTk.PhotoImage(preview)

    dialog = tk.Toplevel(parent)
    dialog.title("Crop picture")
    dialog.transient(parent.winfo_toplevel())
    ttk.Label(
        dialog,
        text="Drag a rectangle over the picture, then Apply Crop.",
        padding=(8, 8, 8, 0),
    ).pack()
    canvas = tk.Canvas(
        dialog,
        width=display_size[0],
        height=display_size[1],
        highlightthickness=0,
        cursor="crosshair",
    )
    canvas.pack(padx=8, pady=8)
    canvas.create_image(0, 0, anchor="nw", image=photo)
    selection = _CropSelection(photo)

    def begin(event: tk.Event) -> None:
        selection.start = (event.x, event.y)
        if selection.rect is not None:
            canvas.delete(selection.rect)
        selection.rect = canvas.create_rectangle(
            event.x, event.y, event.x, event.y, outline="red", width=2
        )

    def drag(event: tk.Event) -> None:
        if selection.rect is not None:
            start_x, start_y = selection.start
            canvas.coords(selection.rect, start_x, start_y, event.x, event.y)

    canvas.bind("<ButtonPress-1>", begin)
    canvas.bind("<B1-Motion>", drag)

    def accept() -> None:
        if selection.rect is None:
            messagebox.showerror(
                "Crop picture",
                "Drag a rectangle to select a crop area.",
                parent=dialog,
            )
            return
        rect_x1, rect_y1, rect_x2, rect_y2 = canvas.coords(selection.rect)
        try:
            box = crop_box_from_canvas(
                (rect_x1, rect_y1, rect_x2, rect_y2), display_size, image_size
            )
        except ValueError as error:
            messagebox.showerror("Crop picture", str(error), parent=dialog)
            return
        dialog.destroy()
        on_apply(box)

    buttons = ttk.Frame(dialog)
    buttons.pack(fill="x", padx=8, pady=(0, 8))
    cancel_button = ttk.Button(buttons, text="Cancel", command=dialog.destroy)
    cancel_button.pack(side="right")
    ttk.Button(buttons, text="Apply Crop", command=accept).pack(side="right", padx=(0, 4))
    make_modal(dialog, focus=cancel_button)


def movie_web_url(movie: Movie) -> str:
    """Return a browser-safe HTTP(S) URL from a movie record."""
    url = movie.url.strip()
    if not url:
        raise ValueError("the selected movie has no URL")
    parsed = urlparse(url)
    if parsed.scheme.casefold() not in {"http", "https"} or not parsed.netloc:
        raise ValueError("movie URL must be an absolute HTTP or HTTPS URL")
    return url


class CatalogWindow(ttk.Frame):
    """Browse and edit a catalog without third-party GUI dependencies."""

    def __init__(self, master: tk.Tk, path: Path, *, preferences_path: Path | None = None) -> None:
        super().__init__(master, padding=10)
        self.path = path
        self.preferences_path = (
            default_preferences_path() if preferences_path is None else preferences_path
        )
        self._preferences = load_preferences(self.preferences_path)
        self.service = CatalogService(path, history_limit=self._preferences.history_limit)
        self.search_text = tk.StringVar()
        self.view_filter = tk.StringVar(value=self._preferences.view_filter)
        self.layout = tk.StringVar(value=self._preferences.layout)
        self.html_preview_template = self._preferences.html_preview_template
        self.sort_field: str | None = None
        self.sort_reverse = False
        master.geometry(f"{self._preferences.window_width}x{self._preferences.window_height}")
        self.pack(fill="both", expand=True)
        self._configure_style()

        files = ttk.Frame(self)
        files.pack(fill="x", pady=(0, 8))
        ttk.Button(files, text="Open", command=self.open_catalog).pack(side="left")
        ttk.Button(files, text="Save As", command=self.save_as).pack(side="left", padx=4)
        self.import_button = ttk.Button(files, text="Import", command=self.import_catalog)
        self.import_button.pack(side="left")
        self.import_media_button = ttk.Button(files, text="Import Media", command=self.import_media)
        self.import_media_button.pack(side="left", padx=4)
        ttk.Button(files, text="Export", command=self.export_catalog).pack(side="left", padx=4)
        ttk.Button(files, text="Backup", command=self.backup_catalog).pack(side="left")
        self.restore_button = ttk.Button(files, text="Restore", command=self.restore_catalog)
        self.restore_button.pack(side="left", padx=4)
        ttk.Button(files, text="Preferences", command=self.open_preferences).pack(side="right")
        self.location_label = ttk.Label(files, text=str(path))
        self.location_label.pack(side="left", fill="x", expand=True, padx=8)

        bar = ttk.Frame(self)
        bar.pack(fill="x", pady=(0, 8))
        ttk.Label(bar, text="Search:").pack(side="left")
        self.search_entry = ttk.Entry(bar, textvariable=self.search_text)
        self.search_entry.pack(side="left", fill="x", expand=True, padx=6)
        self.search_text.trace_add("write", lambda *_: self.refresh())
        ttk.Label(bar, text="View:").pack(side="left")
        view = ttk.Combobox(
            bar,
            textvariable=self.view_filter,
            values=("All", "Loaned", "Available", "Checked", "Unchecked"),
            state="readonly",
            width=10,
        )
        view.pack(side="left", padx=(0, 6))
        view.bind("<<ComboboxSelected>>", lambda _event: self._view_filter_changed())
        ttk.Label(bar, text="Layout:").pack(side="left")
        layout = ttk.Combobox(
            bar,
            textvariable=self.layout,
            values=("Table", "Details", "Poster", "HTML"),
            state="readonly",
            width=8,
        )
        layout.pack(side="left", padx=(0, 6))
        layout.bind("<<ComboboxSelected>>", lambda _event: self._layout_changed())

        search_options = ttk.Frame(self)
        search_options.pack(fill="x", pady=(0, 8))
        ttk.Label(search_options, text="Search in field:").pack(side="left")
        self.search_field = tk.StringVar(value=_SEARCH_FIELDS[0][0])
        field_combo = ttk.Combobox(
            search_options,
            textvariable=self.search_field,
            values=[label for label, _ in _SEARCH_FIELDS],
            state="readonly",
            width=16,
        )
        field_combo.pack(side="left", padx=(0, 12))
        self.search_field.trace_add("write", lambda *_: self.refresh())
        self.search_whole_field = tk.BooleanVar(value=False)
        ttk.Checkbutton(
            search_options,
            text="Whole field only",
            variable=self.search_whole_field,
        ).pack(side="left", padx=(0, 12))
        self.search_whole_field.trace_add("write", lambda *_: self.refresh())
        self.search_reverse = tk.BooleanVar(value=False)
        ttk.Checkbutton(
            search_options,
            text="Reverse results",
            variable=self.search_reverse,
        ).pack(side="left")
        self.search_reverse.trace_add("write", lambda *_: self.refresh())

        # Keep catalog actions on their own row. Putting every action beside the
        # search field clipped the right-most controls on common 760px displays.
        # Every action below also has a menu entry (_build_menu_bar, grouped by
        # File/Edit/Movie/Tools) now that there is a menu bar; only the tightest
        # add/edit/remove/undo-redo loop — the buttons clicked over and over
        # while browsing — stays as a one-click toolbar button too. The rest are
        # still created (just not packed) so action_buttons/invoke_action/
        # update_action_states keep working unchanged for their keyboard
        # shortcuts and menu entries.
        actions = ttk.Frame(self)
        actions.pack(fill="x", pady=(0, 8))
        self.action_buttons: dict[str, ttk.Button] = {}
        toolbar_actions = {"Add", "Edit", "Remove", "Toggle Checked", "Undo", "Redo"}
        for text, command, padding in (
            ("Add", self.add, 0),
            ("Edit", self.edit, 4),
            ("Remove", self.remove, 0),
            ("Loan Out", self.loan_out, 12),
            ("Loan In", self.loan_in, 4),
            ("Toggle Checked", self.toggle_checked, 12),
            ("Set Pictures", self.set_pictures, 12),
            ("Assign Pictures", self.assign_pictures, 4),
            ("Clear Pictures", self.clear_pictures, 4),
            ("Undo", self.undo, 12),
            ("Redo", self.redo, 4),
            ("Open URL", self.open_url, 12),
            ("Update from IMDb", self.update_from_imdb, 4),
            ("Stats", self.show_statistics, 12),
            ("Loan History", self.show_loan_history, 4),
            ("Duplicates", self.show_duplicates, 4),
            ("Renumber", self.renumber, 0),
        ):
            button = ttk.Button(actions, text=text, command=command)
            if text in toolbar_actions:
                button.pack(side="left", padx=(padding, 0))
            self.action_buttons[text] = button

        self.table = ttk.Treeview(
            self,
            columns=("number", "title", "year", "director", "checked", "borrower"),
            show="headings",
            selectmode="extended",
        )
        for key, label, width in (
            ("number", "#", 55),
            ("title", "Title", 300),
            ("year", "Year", 70),
            ("director", "Director", 180),
            ("checked", "Checked", 70),
            ("borrower", "Borrower", 150),
        ):
            self.table.heading(key, text=label, command=functools.partial(self.sort, key))
            self.table.column(key, width=width, anchor="e" if key in {"number", "year"} else "w")
        self.table.pack(fill="both", expand=True)
        self.table.bind("<Double-1>", lambda _event: self.edit())
        self.table.bind("<<TreeviewSelect>>", lambda _event: self.selection_changed())
        details_frame = ttk.LabelFrame(self, text="Movie details", padding=6)
        self.details_frame = details_frame
        details_frame.pack(fill="x", pady=(8, 0))
        self.poster = ttk.Label(details_frame, text="No poster", anchor="center")
        self.details = tk.Text(
            details_frame, height=6, wrap="word", state="disabled", takefocus=False
        )
        self.details.pack(fill="x")
        self.html_view = HtmlFrame(details_frame, messages_enabled=False)
        self.status = ttk.Label(self, anchor="w")
        self.status.pack(fill="x", pady=(6, 0))
        self._bind_shortcuts()
        self._build_menu_bar(master)
        self._build_context_menu()
        self.refresh()
        self.apply_layout()
        master.protocol("WM_DELETE_WINDOW", self._on_close)

    def _configure_style(self) -> None:
        """Use a readable Treeview row height derived from the active Tk font."""
        font = tkfont.nametofont("TkDefaultFont")
        ttk.Style(self).configure("Treeview", rowheight=max(24, font.metrics("linespace") + 8))

    def apply_layout(self) -> None:
        """Switch among compact table, textual details, poster, and HTML views."""
        mode = self.layout.get()
        self.details.pack_forget()
        self.poster.pack_forget()
        self.html_view.pack_forget()
        if mode == "Table":
            self.details_frame.pack_forget()
        elif mode == "HTML":
            self.details_frame.pack(fill="both", expand=True, pady=(8, 0))
            self.html_view.pack(fill="both", expand=True)
        else:
            self.details_frame.pack(fill="x", pady=(8, 0))
            if mode == "Poster":
                self.poster.pack(fill="both", expand=True)
            else:
                self.poster.pack(side="left", fill="y", padx=(0, 8))
                self.details.pack(side="left", fill="both", expand=True)
        self.show_selected()

    def _view_filter_changed(self) -> None:
        self.refresh()
        self._save_preferences()

    def _layout_changed(self) -> None:
        self.apply_layout()
        self._save_preferences()

    def _save_preferences(self) -> None:
        """Persist the current view/layout and window size, best-effort.

        A write failure here must not block using or closing the window, so
        it is deliberately swallowed rather than shown to the user; the
        catalog itself is unaffected either way.
        """
        toplevel = self.winfo_toplevel()
        width = toplevel.winfo_width()
        height = toplevel.winfo_height()
        preferences = GuiPreferences(
            view_filter=self.view_filter.get(),
            layout=self.layout.get(),
            window_width=width if width > 1 else self._preferences.window_width,
            window_height=height if height > 1 else self._preferences.window_height,
            history_limit=self.service.history_limit,
            html_preview_template=self.html_preview_template,
        )
        self._preferences = preferences
        try:
            save_preferences(preferences, self.preferences_path)
        except OSError:
            pass

    def _on_close(self) -> None:
        self._save_preferences()
        self.winfo_toplevel().destroy()

    def open_preferences(self) -> None:
        """Edit Python-owned desktop preferences (currently: undo/redo depth)."""
        dialog = tk.Toplevel(self)
        dialog.title("Preferences")
        dialog.transient(self.winfo_toplevel())
        ttk.Label(dialog, text="Undo/redo history limit").grid(
            row=0, column=0, sticky="w", padx=8, pady=8
        )
        limit = tk.IntVar(value=self.service.history_limit)
        spinbox = ttk.Spinbox(
            dialog,
            from_=MIN_HISTORY_LIMIT,
            to=MAX_HISTORY_LIMIT,
            textvariable=limit,
            width=8,
        )
        spinbox.grid(row=0, column=1, padx=8, pady=8)

        def accept() -> None:
            try:
                value = parse_history_limit(limit.get())
            except (ValueError, tk.TclError) as error:
                messagebox.showerror("Preferences", str(error), parent=dialog)
                return
            self.service.history_limit = value
            self._save_preferences()
            dialog.destroy()

        buttons = ttk.Frame(dialog)
        buttons.grid(row=1, column=0, columnspan=2, sticky="e", padx=8, pady=(0, 8))
        ttk.Button(buttons, text="Cancel", command=dialog.destroy).pack(side="left", padx=(0, 4))
        ttk.Button(buttons, text="Save", command=accept).pack(side="left")
        dialog.bind("<Return>", lambda _event: accept())
        make_modal(dialog, focus=spinbox)

    def _bind_shortcuts(self) -> None:
        root = self.winfo_toplevel()
        root.bind("<Control-o>", lambda _event: self.open_catalog())
        root.bind("<Control-Shift-S>", lambda _event: self.save_as())
        root.bind("<Control-f>", lambda _event: self.focus_search())
        root.bind("<Escape>", lambda _event: self.clear_search())
        root.bind("<Control-n>", lambda _event: self.invoke_action("Add"))
        root.bind("<Control-m>", lambda _event: self.import_media_button.invoke())
        root.bind("<Delete>", lambda _event: self.invoke_action("Remove"))
        root.bind("<space>", lambda _event: self.invoke_action("Toggle Checked"))
        root.bind("<F5>", lambda _event: self.reload_catalog())
        root.bind("<Control-z>", lambda _event: self.invoke_action("Undo"))
        root.bind("<Control-y>", lambda _event: self.invoke_action("Redo"))
        root.bind("<Control-u>", lambda _event: self.invoke_action("Open URL"))
        root.bind("<Control-Prior>", lambda _event: self.select_previous())
        root.bind("<Control-Next>", lambda _event: self.select_next())

    def _build_menu_bar(self, master: tk.Tk) -> None:
        """Group every action into a standard File/Edit/Movie/Tools menu bar.

        Before this, every action (24 of them) was a flat, ungrouped toolbar
        button row with no menu bar at all. Every entry here calls the same
        method the toolbar buttons and keyboard shortcuts already use — for
        actions backed by `action_buttons`, through `invoke_action` so a
        menu click respects the same disabled state a toolbar click would.
        `_menu_entries` records each such entry's `(menu, index)` pairs —
        a name can back more than one entry now that the right-click
        context menu (`_build_context_menu`) tracks some of the same
        action names — so `update_action_states` can gray them all out
        the same way it already grays out `action_buttons`.
        """
        self._menu_entries: dict[str, list[tuple[tk.Menu, int]]] = {}
        add_action = self._add_menu_action
        add_tracked = self._add_tracked_menu_command

        menubar = tk.Menu(master, tearoff=False)

        file_menu = tk.Menu(menubar, tearoff=False)
        file_menu.add_command(
            label="Open Catalog...", command=self.open_catalog, accelerator="Ctrl+O"
        )
        file_menu.add_command(label="Reload", command=self.reload_catalog, accelerator="F5")
        file_menu.add_command(label="Save As...", command=self.save_as, accelerator="Ctrl+Shift+S")
        file_menu.add_separator()
        add_tracked(file_menu, "Import Catalog...", "Import", self.import_catalog)
        add_tracked(file_menu, "Import Media...", "Import Media", self.import_media, "Ctrl+M")
        file_menu.add_separator()
        file_menu.add_command(label="Export...", command=self.export_catalog)
        file_menu.add_command(
            label="Export HTML Template...", command=self.export_html_template_dialog
        )
        file_menu.add_separator()
        file_menu.add_command(label="Backup...", command=self.backup_catalog)
        add_tracked(file_menu, "Restore...", "Restore", self.restore_catalog)
        file_menu.add_separator()
        file_menu.add_command(label="Preferences...", command=self.open_preferences)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self._on_close)
        menubar.add_cascade(label="File", menu=file_menu)

        edit_menu = tk.Menu(menubar, tearoff=False)
        add_action(edit_menu, "Add Movie", "Add", "Ctrl+N")
        add_action(edit_menu, "Edit Movie", "Edit")
        add_action(edit_menu, "Remove Movie", "Remove", "Delete")
        edit_menu.add_separator()
        add_action(edit_menu, "Undo", "Undo", "Ctrl+Z")
        add_action(edit_menu, "Redo", "Redo", "Ctrl+Y")
        edit_menu.add_separator()
        add_action(edit_menu, "Toggle Checked", "Toggle Checked", "Space")
        edit_menu.add_separator()
        edit_menu.add_command(label="Find", command=self.focus_search, accelerator="Ctrl+F")
        edit_menu.add_command(label="Clear Search", command=self.clear_search, accelerator="Esc")
        menubar.add_cascade(label="Edit", menu=edit_menu)

        movie_menu = tk.Menu(menubar, tearoff=False)
        movie_menu.add_command(
            label="Previous Movie", command=self.select_previous, accelerator="Ctrl+PageUp"
        )
        movie_menu.add_command(
            label="Next Movie", command=self.select_next, accelerator="Ctrl+PageDown"
        )
        movie_menu.add_separator()
        add_action(movie_menu, "Loan Out...", "Loan Out")
        add_action(movie_menu, "Loan In", "Loan In")
        movie_menu.add_command(label="Loan History...", command=self.show_loan_history)
        movie_menu.add_separator()
        add_action(movie_menu, "Set Pictures...", "Set Pictures")
        add_action(movie_menu, "Assign Pictures...", "Assign Pictures")
        add_action(movie_menu, "Clear Pictures", "Clear Pictures")
        movie_menu.add_separator()
        add_action(movie_menu, "Open URL", "Open URL", "Ctrl+U")
        movie_menu.add_separator()
        add_action(movie_menu, "Update from IMDb...", "Update from IMDb")
        movie_menu.add_separator()
        add_action(movie_menu, "Renumber", "Renumber")
        menubar.add_cascade(label="Movie", menu=movie_menu)

        tools_menu = tk.Menu(menubar, tearoff=False)
        tools_menu.add_command(label="Statistics...", command=self.show_statistics)
        tools_menu.add_command(label="Duplicates...", command=self.show_duplicates)
        tools_menu.add_separator()
        tools_menu.add_command(
            label="Choose HTML Preview Template...", command=self.choose_html_preview_template
        )
        menubar.add_cascade(label="Tools", menu=tools_menu)

        help_menu = tk.Menu(menubar, tearoff=False)
        help_menu.add_command(label="About AMC Python...", command=self.show_about)
        menubar.add_cascade(label="Help", menu=help_menu)

        master.config(menu=menubar)
        self.menubar = menubar

    def _add_menu_action(self, menu: tk.Menu, label: str, name: str, accelerator: str = "") -> None:
        """Add a menu entry that invokes an `action_buttons` action, tracked
        for `update_action_states` under `name` alongside any other menu
        (menu bar, context menu) that already tracks the same name."""
        menu.add_command(
            label=label,
            accelerator=accelerator,
            command=lambda: self.invoke_action(name),
        )
        end_index = menu.index("end")
        assert end_index is not None  # add_command above always adds an entry
        self._menu_entries.setdefault(name, []).append((menu, end_index))

    def _add_tracked_menu_command(
        self,
        menu: tk.Menu,
        label: str,
        name: str,
        command: Callable[[], None],
        accelerator: str = "",
    ) -> None:
        """Like `_add_menu_action`, but for a command not in `action_buttons`
        (e.g. Import/Import Media/Restore, which have no toolbar button)."""
        menu.add_command(label=label, accelerator=accelerator, command=command)
        end_index = menu.index("end")
        assert end_index is not None  # add_command above always adds an entry
        self._menu_entries.setdefault(name, []).append((menu, end_index))

    def _build_context_menu(self) -> None:
        """Right-click the movie table for a selection-aware context menu.

        Mirrors the most commonly needed Edit/Movie menu entries rather than
        duplicating all of them, and shares their `_menu_entries` tracking —
        so e.g. Remove Movie is grayed out here in lockstep with the toolbar
        button and the Edit menu entry, not just one of them.
        """
        menu = tk.Menu(self, tearoff=False)
        self._add_menu_action(menu, "Add Movie", "Add")
        self._add_menu_action(menu, "Edit Movie", "Edit")
        self._add_menu_action(menu, "Remove Movie", "Remove")
        menu.add_separator()
        self._add_menu_action(menu, "Toggle Checked", "Toggle Checked")
        menu.add_separator()
        self._add_menu_action(menu, "Loan Out...", "Loan Out")
        self._add_menu_action(menu, "Loan In", "Loan In")
        menu.add_separator()
        self._add_menu_action(menu, "Open URL", "Open URL")
        self.context_menu = menu
        self.table.bind("<Button-3>", self._show_context_menu)

    def _show_context_menu(self, event: tk.Event) -> None:
        """Select the right-clicked row (if it isn't already selected) and
        pop up the context menu there, matching common file-manager UX."""
        row = self.table.identify_row(event.y)
        if row and row not in self.table.selection():
            self.table.selection_set(row)
            self.table.focus(row)
            self.selection_changed()
        try:
            self.context_menu.tk_popup(event.x_root, event.y_root)
        finally:
            self.context_menu.grab_release()

    def invoke_action(self, name: str) -> str:
        """Invoke a toolbar action while respecting its disabled state."""
        self.action_buttons[name].invoke()
        return "break"

    def focus_search(self) -> None:
        """Focus and select the search text for keyboard-driven filtering."""
        self.search_entry.focus_set()
        self.search_entry.selection_range(0, tk.END)

    def clear_search(self) -> None:
        """Clear filtering and return keyboard focus to the movie table."""
        self.search_text.set("")
        self.table.focus_set()

    def selection_changed(self) -> None:
        """Refresh selection-dependent details and action availability."""
        self.show_selected()
        self.update_action_states()

    def update_action_states(self) -> None:
        """Disable actions that cannot succeed in the current GUI state."""
        movies = self.selected_movies()
        selected = len(movies)
        writable = self.service.is_writable
        can_open_url = False
        if selected == 1:
            try:
                movie_web_url(movies[0])
            except ValueError:
                pass
            else:
                can_open_url = True
        selection_actions = {
            "Edit": selected == 1 and writable,
            "Remove": selected > 0 and writable,
            "Loan Out": selected > 0 and writable,
            "Loan In": selected > 0 and all(movie.borrower for movie in movies) and writable,
            "Toggle Checked": selected > 0 and writable,
            "Set Pictures": selected > 0 and writable,
            "Assign Pictures": selected > 0 and writable,
            "Clear Pictures": selected > 0 and writable,
            "Open URL": can_open_url,
            "Update from IMDb": selected == 1 and writable,
        }
        for name, enabled in selection_actions.items():
            self._set_action_state(name, enabled)
        self._set_action_state("Add", writable)
        self._set_menu_state("Import", writable)
        self._set_menu_state("Import Media", writable)
        self._set_menu_state("Restore", writable)
        self.import_button.configure(state="normal" if writable else "disabled")
        self.import_media_button.configure(state="normal" if writable else "disabled")
        self.restore_button.configure(state="normal" if writable else "disabled")
        self._set_action_state("Renumber", writable and len(self.service.catalog) > 0)
        self._set_action_state("Undo", writable and self.service.can_undo)
        self._set_action_state("Redo", writable and self.service.can_redo)

    def _set_action_state(self, name: str, enabled: bool) -> None:
        """Enable/disable a toolbar button and its matching menu entry together."""
        self.action_buttons[name].configure(state="normal" if enabled else "disabled")
        self._set_menu_state(name, enabled)

    def _set_menu_state(self, name: str, enabled: bool) -> None:
        # getattr, not self._menu_entries directly: headless tests build a
        # CatalogWindow via object.__new__ and never run __init__/
        # _build_menu_bar, so there is no menu bar (or _menu_entries) to sync.
        for menu, index in getattr(self, "_menu_entries", {}).get(name, []):
            menu.entryconfigure(index, state="normal" if enabled else "disabled")

    def refresh(self) -> None:
        selection = self.table.selection()
        self.table.delete(*self.table.get_children())
        movies = self.service.catalog.search(
            self.search_text.get(),
            field=_SEARCH_FIELD_BY_LABEL.get(self.search_field.get()),
            whole_field=self.search_whole_field.get(),
            reverse=self.search_reverse.get(),
        )
        movies = filter_movies(movies, self.view_filter.get())
        for movie in movies:
            self.table.insert("", "end", iid=str(movie.number), values=movie_row(movie))
        visible = {str(movie.number) for movie in movies}
        retained = [item for item in selection if item in visible]
        if retained:
            self.table.selection_set(retained)
            self.table.focus(retained[0])
        total = len(self.service.catalog)
        mode = self.view_filter.get().lower()
        self.status.configure(
            text=f"Showing {len(movies)} of {total} movie(s) — {mode} view"
            + (" — read-only; use Save As to edit" if not self.service.is_writable else "")
        )
        self.update_action_states()

    def selected(self) -> Movie | None:
        selection = self.table.selection()
        return self.service.catalog.get(int(selection[0])) if selection else None

    def selected_movies(self) -> list[Movie]:
        """Return every selected table movie in selection order."""
        return [self.service.catalog.get(int(item)) for item in self.table.selection()]

    def select_next(self) -> None:
        """Select the next row, matching upstream's ActionMovieNext."""
        self._step_selection(1)

    def select_previous(self) -> None:
        """Select the previous row, matching upstream's ActionMoviePrevious."""
        self._step_selection(-1)

    def _step_selection(self, delta: int) -> None:
        """Move the current row selection by one, matching upstream
        (`main.pas`'s `ActionMovieNext`/`ActionMoviePreviousExecute`): with
        nothing selected, Next starts at the first row and Previous at the
        last; otherwise each steps by exactly one row with no wraparound —
        stepping past either end clears the selection instead of wrapping.
        """
        children = self.table.get_children()
        if not children:
            return
        current = self.table.selection()
        if current:
            try:
                index = children.index(current[0]) + delta
            except ValueError:
                index = 0 if delta > 0 else len(children) - 1
        else:
            index = 0 if delta > 0 else len(children) - 1
        if 0 <= index < len(children):
            target = children[index]
            self.table.selection_set(target)
            self.table.focus(target)
            self.table.see(target)
        else:
            self.table.selection_set()

    def show_selected(self) -> None:
        """Render the selected movie's useful summary fields read-only."""
        movie = self.selected()
        lines: list[str] = []
        if movie is not None:
            values = (
                ("Title", movie.display_title()),
                ("Original title", movie.original_title),
                ("Director", movie.director),
                ("Category", movie.category),
                ("Actors", movie.actors),
                ("Borrower", movie.borrower),
                ("URL", movie.url),
                ("Description", movie.description),
                ("Comments", movie.comments),
            )
            lines = [f"{label}: {value}" for label, value in values if value]
        self.details.configure(state="normal")
        self.details.delete("1.0", tk.END)
        self.details.insert("1.0", "\n".join(lines))
        self.details.configure(state="disabled")
        self._show_poster(movie)
        if self.layout.get() == "HTML":
            self._show_html_preview(movie)

    def _show_poster(self, movie: Movie | None) -> None:
        source = poster_source(movie, self.service.path) if movie is not None else None
        image = None
        status = "No poster assigned"
        if source is not None:
            try:
                raw = (
                    io.BytesIO(base64.b64decode(source[1], validate=True))
                    if source[0] == "data"
                    else source[1]
                )
                with Image.open(raw) as opened:
                    opened.thumbnail((320, 420), Image.Resampling.LANCZOS)
                    image = ImageTk.PhotoImage(opened.copy())
            except (OSError, ValueError, UnidentifiedImageError, tk.TclError) as error:
                image = None
                status = f"Poster could not be displayed: {error}"
        elif movie is not None and movie.picture:
            status = f"Poster file not found: {movie.picture}"
        self.poster_image = image
        self.poster.configure(image=image or "", text="" if image is not None else status)

    def _show_html_preview(self, movie: Movie | None) -> None:
        """Render the selected movie through the chosen Individual template.

        Matches upstream's own main window, which shows the selected movie's
        page live in a pane next to the list. `base_url` is set to the
        template's own directory so its relative CSS/image references
        resolve the same way they would in a real HTML export.
        """
        if not self.html_preview_template:
            self.html_view.load_html(
                "<p>Choose a template via <b>Tools → Choose HTML Preview Template...</b></p>"
            )
            return
        if movie is None:
            self.html_view.load_html("<p>No movie selected.</p>")
            return
        template_path = Path(self.html_preview_template)
        try:
            source = _read_template(template_path, 1024 * 1024)
        except (OSError, ValueError, UnicodeDecodeError) as error:
            self.html_view.load_html(f"<p>Could not read template: {error}</p>")
            return
        record_number = next(
            (
                index
                for index, candidate in enumerate(self.service.catalog, start=1)
                if candidate.number == movie.number
            ),
            1,
        )
        rendered = render_individual_template(
            movie,
            self.service.catalog,
            source,
            source_name=self.service.path.name,
            record_number=record_number,
        )
        directory = template_path.resolve().parent.as_posix()
        if not directory.startswith("/"):
            directory = f"/{directory}"
        self.html_view.load_html(rendered, base_url=f"file://{directory}/")

    def choose_html_preview_template(self) -> None:
        """Pick the Individual-template file the HTML layout renders live."""
        chosen = filedialog.askopenfilename(
            parent=self.winfo_toplevel(),
            title="Choose an individual-movie template for the HTML preview",
            filetypes=(("HTML template", "*.html *.htm"), ("All files", "*")),
        )
        if not chosen:
            return
        self.html_preview_template = chosen
        self._save_preferences()
        if self.layout.get() == "HTML":
            self.show_selected()

    def open_catalog(self) -> None:
        selected = filedialog.askopenfilename(
            parent=self.winfo_toplevel(),
            title="Open catalog",
            filetypes=(("Catalogs", "*.json *.xml *.csv *.amc"), ("All files", "*")),
        )
        if not selected:
            return
        try:
            self.service.open(selected)
        except _SERVICE_ERRORS as error:
            messagebox.showerror("Could not open catalog", str(error), parent=self)
            return
        self._path_changed()
        if Path(selected).suffix.casefold() in {".amc", ".xml", ".csv"}:
            messagebox.showinfo(
                "Catalog opened read-only",
                "Interchange catalogs are protected from in-place editing. Use "
                "Save As to create an AMC Python JSON working catalog before "
                "making changes.",
                parent=self,
            )

    def reload_catalog(self) -> None:
        try:
            self.service.reload()
        except _SERVICE_ERRORS as error:
            messagebox.showerror("Could not reload catalog", str(error), parent=self)
            return
        self.refresh()

    def save_as(self) -> None:
        selected = filedialog.asksaveasfilename(
            parent=self.winfo_toplevel(),
            title="Save catalog as",
            defaultextension=".json",
            filetypes=(("AMC Python JSON", "*.json"), ("All files", "*")),
        )
        if not selected:
            return
        try:
            self.service.save_as(selected)
        except _SERVICE_ERRORS as error:
            messagebox.showerror("Could not save catalog", str(error), parent=self)
            return
        self._path_changed()

    def _path_changed(self) -> None:
        self.path = self.service.path
        self.location_label.configure(text=str(self.path))
        self.winfo_toplevel().title(f"AMC Python — {self.path.name}")
        self.refresh()

    def import_catalog(self) -> None:
        selected = filedialog.askopenfilename(
            parent=self.winfo_toplevel(),
            title="Import catalog",
            filetypes=(("Catalogs", "*.json *.xml *.csv *.amc"), ("All files", "*")),
        )
        if not selected:
            return
        try:
            count = self.service.import_from(selected)
        except _SERVICE_ERRORS as error:
            messagebox.showerror("Could not import catalog", str(error), parent=self)
            return
        self.refresh()
        messagebox.showinfo("Import complete", f"Imported {count} movie(s).", parent=self)

    def import_media(self) -> None:
        """Batch-add movies from chosen media files or a folder.

        Mirrors the CLI's ``import-media``/``--recursive``, including its
        folder-expansion bound (see `amc.media.discover_media`).
        """
        from_folder = messagebox.askyesnocancel(
            "Import media",
            "Import from a folder (Yes) or choose individual files (No)?",
            parent=self.winfo_toplevel(),
        )
        if from_folder is None:
            return
        if from_folder:
            selected_folder = filedialog.askdirectory(
                parent=self.winfo_toplevel(),
                title="Choose a media folder",
            )
            if not selected_folder:
                return
            recursive = messagebox.askyesno(
                "Import media",
                "Include files in subfolders?",
                parent=self.winfo_toplevel(),
            )
            max_depth = None
            if recursive:
                depth_text = simpledialog.askstring(
                    "Import media",
                    "Maximum subfolder depth (0 = this folder only)?\nLeave blank for unlimited.",
                    parent=self.winfo_toplevel(),
                )
                if depth_text and depth_text.strip():
                    try:
                        max_depth = int(depth_text)
                    except ValueError:
                        messagebox.showerror(
                            "Could not import media",
                            "Maximum depth must be a non-negative integer.",
                            parent=self,
                        )
                        return
            extensions_text = simpledialog.askstring(
                "Import media",
                "Limit to these extensions (comma-separated, e.g. mkv,mp4,wav)?\n"
                "Enter 'default' for common video types; leave blank for every file.",
                parent=self.winfo_toplevel(),
            )
            extensions = parse_extensions(extensions_text) if extensions_text else None
            title_filter_pattern = simpledialog.askstring(
                "Import media",
                "Filename cleanup regex (matching text is removed)?\n"
                "Leave blank to keep the original filename-derived title.",
                parent=self.winfo_toplevel(),
            )
            title_filter_pattern = title_filter_pattern or None
            merge_parts = messagebox.askyesno(
                "Import media",
                "Merge adjacent CD1/CD2-style files into one movie?",
                parent=self.winfo_toplevel(),
            )
            import_pictures = messagebox.askyesno(
                "Import media",
                "Attach same-name or folder poster images?",
                parent=self.winfo_toplevel(),
            )
            embed_pictures = import_pictures and messagebox.askyesno(
                "Import media",
                "Embed found poster images in the catalog?\n"
                "Choose No to keep links to the image files.",
                parent=self.winfo_toplevel(),
            )
            extraction = simpledialog.askstring(
                "Import media",
                "Metadata extraction mode: full, defer, or skip?",
                initialvalue="full",
                parent=self.winfo_toplevel(),
            )
            if extraction is None:
                return
            extraction = extraction.strip().casefold()
            if extraction not in {"full", "defer", "skip"}:
                messagebox.showerror(
                    "Could not import media",
                    "Extraction mode must be full, defer, or skip.",
                    parent=self,
                )
                return
            try:
                paths = discover_media(
                    [Path(selected_folder)],
                    recursive=recursive,
                    max_depth=max_depth,
                    extensions=extensions,
                )
            except ValueError as error:
                messagebox.showerror("Could not import media", str(error), parent=self)
                return
            if not paths:
                messagebox.showinfo("Import media", "No media files were found.", parent=self)
                return
        else:
            selected = filedialog.askopenfilenames(
                parent=self.winfo_toplevel(),
                title="Choose media files",
            )
            if not selected:
                return
            paths = [Path(item) for item in selected]
            merge_parts = False
            import_pictures = False
            embed_pictures = False
            extraction = "full"
            title_filter_pattern = None
        self._import_media_paths(
            paths,
            merge_parts=merge_parts,
            import_pictures=import_pictures,
            embed_pictures=embed_pictures,
            extraction=extraction,
            title_filter_pattern=title_filter_pattern,
        )

    def _import_media_paths(
        self,
        paths: list[Path],
        *,
        merge_parts: bool = False,
        import_pictures: bool = False,
        embed_pictures: bool = False,
        extraction: str = "full",
        title_filter_pattern: str | None = None,
    ) -> None:
        """Inspect resolved media paths with progress/cancel, then add atomically."""
        total = len(paths)
        dialog = tk.Toplevel(self)
        dialog.title("Import media")
        dialog.transient(self.winfo_toplevel())
        status = ttk.Label(
            dialog,
            text=f"Ready to inspect {total} file(s).",
            width=48,
            anchor="w",
        )
        status.grid(row=0, column=0, padx=8, pady=8)
        cancelled = {"value": False}
        cancel_button = ttk.Button(
            dialog, text="Cancel", command=lambda: cancelled.__setitem__("value", True)
        )
        cancel_button.grid(row=1, column=0, sticky="e", padx=8, pady=(0, 8))
        make_modal(dialog, focus=cancel_button)

        movies: list[Movie] = []
        for index, path in enumerate(paths, start=1):
            if cancelled["value"]:
                break
            status.configure(text=f"Inspecting {index}/{total}: {path.name}")
            dialog.update()
            try:
                movies.append(
                    movie_from_media(
                        path,
                        extraction=extraction,
                        title_filter_pattern=title_filter_pattern,
                    )
                )
            except ValueError as error:
                messagebox.showerror("Could not import media", str(error), parent=dialog)
                dialog.destroy()
                return
        if cancelled["value"]:
            dialog.destroy()
            return
        source_count = len(movies)
        if import_pictures:
            try:
                movies = attach_media_pictures(list(zip(paths, movies)), embed=embed_pictures)
            except (OSError, ValueError) as error:
                messagebox.showerror("Could not import media", str(error), parent=dialog)
                dialog.destroy()
                return
        if merge_parts:
            movies = merge_media_parts(list(zip(paths, movies)))
        try:
            self.service.add_many(movies)
        except _SERVICE_ERRORS as error:
            messagebox.showerror("Could not import media", str(error), parent=dialog)
            dialog.destroy()
            return
        dialog.destroy()
        self.refresh()
        summary = (
            f"Imported {len(movies)} movie(s) from {source_count} media file(s)."
            if merge_parts
            else f"Imported {len(movies)} media file(s)."
        )
        messagebox.showinfo("Import complete", summary, parent=self)

    def export_catalog(self) -> None:
        selected = filedialog.asksaveasfilename(
            parent=self.winfo_toplevel(),
            title="Export catalog",
            defaultextension=".xml",
            filetypes=(
                ("AMC XML", "*.xml"),
                ("CSV", "*.csv"),
                ("HTML", "*.html"),
                ("AMC native", "*.amc"),
            ),
        )
        if not selected:
            return
        suffix = Path(selected).suffix.casefold()
        formats = {".xml": "xml", ".csv": "csv", ".html": "html", ".htm": "html", ".amc": "amc"}
        try:
            format_name = formats[suffix]
        except KeyError:
            messagebox.showerror(
                "Could not export catalog",
                "Choose an .xml, .csv, .html, or .amc destination.",
                parent=self,
            )
            return
        destination_exists = Path(selected).exists()
        if format_name == "html" and messagebox.askyesno(
            "Export HTML",
            "Use an Ant Movie Catalog template — a real .html file with "
            "$$TAG_NAME placeholders from AMC's own HTML export? Choose No "
            "for AMC Python's own default table export.",
            parent=self,
        ):
            self._export_html_template(selected)
            return
        if format_name == "amc":
            backup_note = (
                f"\n\nThe existing file will be preserved as {Path(selected).with_suffix('.bak')}."
                if destination_exists
                else ""
            )
            if not messagebox.askyesno(
                "Export experimental native catalog?",
                "Native AMC 4.2 export is source-derived but has not been verified "
                "with the upstream application. Keep your AMC Python JSON catalog "
                f"and test the exported file before relying on it.{backup_note}\n\n"
                "Continue?",
                parent=self,
            ):
                return
        self._export_with_scope(selected, format_name, destination_exists=destination_exists)

    def export_html_template_dialog(self) -> None:
        """Open the two-template HTML exporter through a discoverable direct action."""
        destination = filedialog.asksaveasfilename(
            parent=self.winfo_toplevel(),
            title="Export HTML template — choose full catalog page",
            defaultextension=".html",
            filetypes=(("HTML", "*.html *.htm"),),
        )
        if destination:
            self._export_html_template(destination)

    def _movies_by_scope(self, scope: str) -> list[Movie] | None:
        """Resolve a "Movies to include" choice to an explicit list, or
        None for the whole catalog, matching upstream's Export dialog."""
        if scope == "all":
            return None
        if scope == "selected":
            return self.selected_movies()
        if scope == "checked":
            return [movie for movie in self.service.catalog if movie.checked]
        if scope == "visible":
            return [self.service.catalog.get(int(iid)) for iid in self.table.get_children()]
        raise ValueError(f"unknown export scope: {scope!r}")

    def _build_export_scope_controls(
        self, dialog: tk.Toplevel, start_row: int
    ) -> tuple[tk.StringVar, tk.StringVar, tk.BooleanVar, int]:
        """Build the "Movies to include"/"Sort by" controls shared by both
        export dialogs, matching upstream's own Export screen (All/Selected/
        Checked/Visible, each with a live count, plus an export-time sort
        order independent of the catalog's current order). Returns the
        scope/sort-by/reverse variables and the next unused grid row."""
        counts = {
            "all": len(self.service.catalog),
            "selected": len(self.selected_movies()),
            "checked": sum(1 for movie in self.service.catalog if movie.checked),
            "visible": len(self.table.get_children()),
        }
        scope = tk.StringVar(value="all")
        row = start_row
        ttk.Label(dialog, text="Movies to include:").grid(
            row=row, column=0, columnspan=3, sticky="w", padx=8, pady=(8, 0)
        )
        row += 1
        for key in ("all", "selected", "checked", "visible"):
            ttk.Radiobutton(
                dialog, text=f"{key.capitalize()} ({counts[key]})", variable=scope, value=key
            ).grid(row=row, column=0, columnspan=3, sticky="w", padx=24)
            row += 1
        sort_by = tk.StringVar(value="")
        ttk.Label(dialog, text="Sort by:").grid(row=row, column=0, sticky="w", padx=8, pady=(8, 0))
        sort_combo = ttk.Combobox(
            dialog,
            textvariable=sort_by,
            values=("", *_EXPORT_SORT_FIELDS),
            state="readonly",
            width=14,
        )
        sort_combo.grid(row=row, column=1, sticky="w", pady=(8, 0))
        reverse = tk.BooleanVar(value=False)
        ttk.Checkbutton(dialog, text="Reverse", variable=reverse).grid(
            row=row, column=2, sticky="w", pady=(8, 0)
        )
        return scope, sort_by, reverse, row + 1

    def _export_with_scope(
        self, destination: str, format_name: str, *, destination_exists: bool
    ) -> None:
        """Ask "Movies to include" and an export sort order, then export."""
        dialog = tk.Toplevel(self)
        dialog.title("Export options")
        dialog.transient(self.winfo_toplevel())
        scope, sort_by, reverse, next_row = self._build_export_scope_controls(dialog, 0)

        def accept() -> None:
            movies = self._movies_by_scope(scope.get())
            if movies is not None and not movies:
                messagebox.showerror("Export options", "No movies match that scope.", parent=dialog)
                return
            try:
                self.service.export(
                    destination,
                    format=format_name,
                    movies=movies,
                    sort_by=sort_by.get() or None,
                    sort_reverse=reverse.get(),
                )
            except _SERVICE_ERRORS as error:
                messagebox.showerror("Could not export catalog", str(error), parent=dialog)
                return
            dialog.destroy()
            completion = f"Exported to {destination}."
            if format_name == "amc" and destination_exists:
                completion += f"\nPrevious file: {Path(destination).with_suffix('.bak')}"
            messagebox.showinfo("Export complete", completion, parent=self)

        buttons = ttk.Frame(dialog)
        buttons.grid(row=next_row, column=0, columnspan=3, sticky="e", padx=8, pady=8)
        ttk.Button(buttons, text="Cancel", command=dialog.destroy).pack(side="left", padx=(0, 4))
        ttk.Button(buttons, text="Export...", command=accept).pack(side="left")
        make_modal(dialog)

    def _export_html_template(self, destination: str) -> None:
        """Render Ant Movie Catalog's own $$TAG_NAME HTML templates.

        Distinct from AMC Python's own {{MOVIES}}-template export: this asks
        for a real AMC template file, so a template the user already has
        keeps working. Mirrors upstream's own Export dialog, which treats
        the full-catalog page and the individual-movie page as two
        independently selected templates (its "Full" and "Individual" tabs);
        this dialog offers the same two-template choice without upstream's
        in-place template editor, since selecting a template file is all
        this port's renderer needs. See amc.html_template for exact tag
        coverage and scope.
        """
        dialog = tk.Toplevel(self)
        dialog.title("Export HTML template")
        dialog.transient(self.winfo_toplevel())

        full_enabled = tk.BooleanVar(value=True)
        full_template = tk.StringVar()
        individual_enabled = tk.BooleanVar(value=False)
        individual_template = tk.StringVar()
        individual_dir = tk.StringVar()
        individual_filename = tk.StringVar(value="{number}.html")
        copy_pictures = tk.BooleanVar(value=False)
        picture_directory = tk.StringVar(value="pictures")
        pictures_only_if_missing = tk.BooleanVar(value=False)

        def browse_template(target: tk.StringVar, title: str) -> None:
            chosen = filedialog.askopenfilename(
                parent=dialog,
                title=title,
                filetypes=(("HTML template", "*.html *.htm"), ("All files", "*")),
            )
            if chosen:
                target.set(chosen)

        def browse_dir(target: tk.StringVar) -> None:
            chosen = filedialog.askdirectory(
                parent=dialog, title="Choose a folder for individual movie pages"
            )
            if chosen:
                target.set(chosen)

        def set_row_state(widgets: list[ttk.Widget], enabled: bool) -> None:
            flag = "!disabled" if enabled else "disabled"
            for widget in widgets:
                widget.state([flag])

        full_check = ttk.Checkbutton(dialog, text="Full catalog page", variable=full_enabled)
        full_check.grid(row=0, column=0, columnspan=3, sticky="w", padx=8, pady=(8, 0))
        ttk.Label(dialog, text="Template:").grid(row=1, column=0, sticky="w", padx=(24, 8))
        full_entry = ttk.Entry(dialog, textvariable=full_template, width=40)
        full_entry.grid(row=1, column=1, sticky="we", pady=(0, 8))
        full_browse = ttk.Button(
            dialog,
            text="Browse...",
            command=lambda: browse_template(full_template, "Choose a full-catalog template"),
        )
        full_browse.grid(row=1, column=2, padx=8, pady=(0, 8))

        individual_check = ttk.Checkbutton(
            dialog, text="Individual movie pages", variable=individual_enabled
        )
        individual_check.grid(row=2, column=0, columnspan=3, sticky="w", padx=8)
        ttk.Label(dialog, text="Template:").grid(row=3, column=0, sticky="w", padx=(24, 8))
        individual_entry = ttk.Entry(dialog, textvariable=individual_template, width=40)
        individual_entry.grid(row=3, column=1, sticky="we")
        individual_browse = ttk.Button(
            dialog,
            text="Browse...",
            command=lambda: browse_template(
                individual_template, "Choose an individual-movie template"
            ),
        )
        individual_browse.grid(row=3, column=2, padx=8)
        ttk.Label(dialog, text="Folder:").grid(
            row=4, column=0, sticky="w", padx=(24, 8), pady=(4, 0)
        )
        dir_entry = ttk.Entry(dialog, textvariable=individual_dir, width=40)
        dir_entry.grid(row=4, column=1, sticky="we", pady=(4, 0))
        dir_browse = ttk.Button(
            dialog, text="Browse...", command=lambda: browse_dir(individual_dir)
        )
        dir_browse.grid(row=4, column=2, padx=8, pady=(4, 0))
        ttk.Label(dialog, text="Filename pattern:").grid(
            row=5, column=0, sticky="w", padx=(24, 8), pady=(4, 8)
        )
        filename_entry = ttk.Entry(dialog, textvariable=individual_filename, width=40)
        filename_entry.grid(row=5, column=1, sticky="we", pady=(4, 8))

        individual_widgets = [
            individual_entry,
            individual_browse,
            dir_entry,
            dir_browse,
            filename_entry,
        ]
        set_row_state(individual_widgets, individual_enabled.get())
        individual_enabled.trace_add(
            "write", lambda *_args: set_row_state(individual_widgets, individual_enabled.get())
        )
        full_widgets = [full_entry, full_browse]
        set_row_state(full_widgets, full_enabled.get())
        full_enabled.trace_add(
            "write", lambda *_args: set_row_state(full_widgets, full_enabled.get())
        )

        copy_check = ttk.Checkbutton(dialog, text="Copy pictures", variable=copy_pictures)
        copy_check.grid(row=6, column=0, columnspan=3, sticky="w", padx=8)
        ttk.Label(dialog, text="Picture folder:").grid(
            row=7, column=0, sticky="w", padx=(24, 8), pady=(4, 8)
        )
        picture_dir_entry = ttk.Entry(dialog, textvariable=picture_directory, width=40)
        picture_dir_entry.grid(row=7, column=1, sticky="we", pady=(4, 8))
        missing_check = ttk.Checkbutton(
            dialog,
            text="Only if missing",
            variable=pictures_only_if_missing,
        )
        missing_check.grid(row=7, column=2, sticky="w", padx=8, pady=(4, 8))
        picture_widgets = [picture_dir_entry, missing_check]
        set_row_state(picture_widgets, copy_pictures.get())
        copy_pictures.trace_add(
            "write", lambda *_args: set_row_state(picture_widgets, copy_pictures.get())
        )

        scope, sort_by, reverse, next_row = self._build_export_scope_controls(dialog, 8)

        def accept() -> None:
            if not full_enabled.get() and not individual_enabled.get():
                messagebox.showerror(
                    "Export HTML template",
                    "Choose at least one of Full catalog page or Individual movie pages.",
                    parent=dialog,
                )
                return
            if full_enabled.get() and not full_template.get():
                messagebox.showerror(
                    "Export HTML template",
                    "Choose a template file for the full catalog page.",
                    parent=dialog,
                )
                return
            if individual_enabled.get() and not individual_template.get():
                messagebox.showerror(
                    "Export HTML template",
                    "Choose a template file for individual movie pages.",
                    parent=dialog,
                )
                return
            movies = self._movies_by_scope(scope.get())
            if movies is not None and not movies:
                messagebox.showerror(
                    "Export HTML template", "No movies match that scope.", parent=dialog
                )
                return
            try:
                written = self.service.export_html_template(
                    destination,
                    full_template=full_template.get() if full_enabled.get() else None,
                    individual_template=(
                        individual_template.get() if individual_enabled.get() else None
                    ),
                    individual_dir=individual_dir.get() or None,
                    individual_filename=individual_filename.get() or "{number}.html",
                    movies=movies,
                    sort_by=sort_by.get() or None,
                    sort_reverse=reverse.get(),
                    copy_pictures=copy_pictures.get(),
                    picture_directory=picture_directory.get() or "pictures",
                    pictures_only_if_missing=pictures_only_if_missing.get(),
                )
            except _SERVICE_ERRORS as error:
                messagebox.showerror("Could not export catalog", str(error), parent=dialog)
                return
            dialog.destroy()
            messagebox.showinfo("Export complete", f"Wrote {len(written)} file(s).", parent=self)

        buttons = ttk.Frame(dialog)
        buttons.grid(row=next_row, column=0, columnspan=3, sticky="e", padx=8, pady=(0, 8))
        ttk.Button(buttons, text="Cancel", command=dialog.destroy).pack(side="left", padx=(0, 4))
        ttk.Button(buttons, text="Export...", command=accept).pack(side="left")
        dialog.columnconfigure(1, weight=1)
        make_modal(dialog, focus=full_entry)

    def backup_catalog(self) -> None:
        selected = filedialog.asksaveasfilename(
            parent=self.winfo_toplevel(),
            title="Back up catalog",
            defaultextension=".json",
            initialfile=f"{self.path.stem}.backup{self.path.suffix or '.json'}",
            filetypes=(("Catalog backup", "*.*"),),
        )
        if not selected:
            return

        try:
            self.service.backup(selected)
        except _SERVICE_ERRORS as error:
            messagebox.showerror("Could not back up catalog", str(error), parent=self)
            return
        messagebox.showinfo("Backup complete", f"Backed up to {selected}.", parent=self)

    def restore_catalog(self) -> None:
        selected = filedialog.askopenfilename(
            parent=self.winfo_toplevel(),
            title="Restore catalog",
            filetypes=(("Catalogs", "*.json *.xml *.csv *.amc"), ("All files", "*")),
        )
        if not selected:
            return
        if not messagebox.askyesno(
            "Restore catalog",
            "Replace the current catalog with this validated backup?",
            parent=self,
        ):
            return
        try:
            self.service.restore(selected)
        except _SERVICE_ERRORS as error:
            messagebox.showerror("Could not restore catalog", str(error), parent=self)
            return
        self.refresh()
        messagebox.showinfo("Restore complete", "The catalog was restored.", parent=self)

    def add(self) -> None:
        self._dialog(Movie(), is_new=True)

    def edit(self) -> None:
        movie = self.selected()
        if movie:
            self._dialog(movie, is_new=False)

    def remove(self) -> None:
        movies = self.selected_movies()
        if not movies:
            return
        description = (
            movies[0].display_title()
            if len(movies) == 1
            else f"these {len(movies)} selected movies"
        )
        if messagebox.askyesno("Remove movie", f"Remove {description}?"):
            try:
                self.service.remove_many(movie.number for movie in movies)
            except _SERVICE_ERRORS as error:
                messagebox.showerror("Could not remove movie", str(error), parent=self)
                return
            self.refresh()

    def loan_out(self) -> None:
        movies = self.selected_movies()
        if not movies:
            return
        dialog = tk.Toplevel(self)
        dialog.title("Check out movie")
        dialog.transient(self.winfo_toplevel())
        existing = {movie.borrower for movie in movies if movie.borrower}
        borrower = tk.StringVar(value=existing.pop() if len(existing) == 1 else "")
        ttk.Label(dialog, text="Borrower").grid(row=0, column=0, padx=8, pady=8)
        entry = ttk.Combobox(
            dialog,
            textvariable=borrower,
            values=tuple(self.service.borrowers()),
            width=34,
        )
        entry.grid(row=0, column=1, padx=8, pady=8)

        def accept() -> None:
            try:
                self.service.check_out_many((movie.number for movie in movies), borrower.get())
            except _SERVICE_ERRORS as error:
                messagebox.showerror("Could not check out movie", str(error), parent=dialog)
                return
            dialog.destroy()
            self.refresh()

        ttk.Button(dialog, text="Check Out", command=accept).grid(
            row=1, column=1, sticky="e", padx=8, pady=(0, 8)
        )
        dialog.bind("<Return>", lambda _event: accept())
        make_modal(dialog, focus=entry)

    def loan_in(self) -> None:
        movies = self.selected_movies()
        if not movies:
            return
        try:
            self.service.check_in_many(movie.number for movie in movies)
        except _SERVICE_ERRORS as error:
            messagebox.showerror("Could not check in movie", str(error), parent=self)
            return
        self.refresh()

    def toggle_checked(self) -> None:
        movies = self.selected_movies()
        if not movies:
            return
        checked = not all(movie.checked for movie in movies)
        try:
            self.service.set_checked_many((movie.number for movie in movies), checked)
        except _SERVICE_ERRORS as error:
            messagebox.showerror("Could not update checked state", str(error), parent=self)
            return
        self.refresh()

    def set_pictures(self) -> None:
        """Link or embed one chosen picture for every selected movie."""
        movies = self.selected_movies()
        if not movies:
            return
        selected = filedialog.askopenfilename(
            parent=self.winfo_toplevel(),
            title="Choose poster",
            filetypes=_IMAGE_FILETYPES,
        )
        if not selected:
            return
        description = (
            movies[0].display_title()
            if len(movies) == 1
            else f"these {len(movies)} selected movies"
        )
        embed = messagebox.askyesno(
            "Set pictures",
            f"Embed this picture in the catalog for {description}? Choose "
            "No to store a linked path instead.",
            parent=self,
        )
        try:
            self.service.set_picture_many(
                [(movie.number, selected) for movie in movies], embed=embed
            )
        except _SERVICE_ERRORS as error:
            messagebox.showerror("Could not set pictures", str(error), parent=self)
            return
        self.refresh()

    def assign_pictures(self) -> None:
        """Assign a distinct picture file to each selected movie in one write."""
        movies = self.selected_movies()
        if not movies:
            return
        dialog = tk.Toplevel(self)
        dialog.title("Assign pictures")
        dialog.transient(self.winfo_toplevel())
        ttk.Label(
            dialog,
            text="Browse a picture for each movie below, then Apply. Movies "
            "left unassigned keep their current picture. Crop is optional and "
            "only applies to embedded pictures.",
            wraplength=520,
            justify="left",
        ).grid(row=0, column=0, sticky="w", padx=8, pady=(8, 4))

        canvas = tk.Canvas(
            dialog, highlightthickness=0, width=520, height=min(320, 32 * len(movies) + 8)
        )
        scrollbar = ttk.Scrollbar(dialog, orient="vertical", command=canvas.yview)
        rows_frame = ttk.Frame(canvas)
        rows_frame.bind(
            "<Configure>",
            lambda _event: canvas.configure(scrollregion=canvas.bbox("all")),
        )
        canvas.create_window((0, 0), window=rows_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)
        canvas.grid(row=1, column=0, sticky="nsew", padx=(8, 0), pady=4)
        scrollbar.grid(row=1, column=1, sticky="ns", pady=4)
        dialog.rowconfigure(1, weight=1)
        dialog.columnconfigure(0, weight=1)

        assignments: dict[int, str] = {}
        crops: dict[int, tuple[int, int, int, int]] = {}
        first_browse_button: ttk.Button | None = None
        for row, movie in enumerate(movies):
            ttk.Label(rows_frame, text=movie.display_title(), width=30, anchor="w").grid(
                row=row, column=0, sticky="w", pady=2
            )
            status = ttk.Label(rows_frame, text="(unassigned)", width=24, anchor="w")
            status.grid(row=row, column=1, sticky="w", padx=(4, 4))

            def describe(number: int, status: ttk.Label = status) -> None:
                name = Path(assignments[number]).name
                status.configure(text=f"{name} (cropped)" if number in crops else name)

            def choose(number: int = movie.number, status: ttk.Label = status) -> None:
                selected = filedialog.askopenfilename(
                    parent=dialog,
                    title="Choose poster",
                    filetypes=_IMAGE_FILETYPES,
                )
                if not selected:
                    return
                assignments[number] = selected
                crops.pop(number, None)
                describe(number, status)

            def crop(number: int = movie.number, status: ttk.Label = status) -> None:
                if number not in assignments:
                    messagebox.showerror(
                        "Crop picture",
                        "Choose a picture for this movie before cropping.",
                        parent=dialog,
                    )
                    return

                def apply_crop(box: tuple[int, int, int, int]) -> None:
                    crops[number] = box
                    describe(number, status)

                try:
                    image_bytes = Path(assignments[number]).read_bytes()
                    open_crop_dialog(dialog, image_bytes, on_apply=apply_crop)
                except (OSError, UnidentifiedImageError) as error:
                    messagebox.showerror("Crop picture", str(error), parent=dialog)

            browse_button = ttk.Button(rows_frame, text="Browse", command=choose)
            browse_button.grid(row=row, column=2, padx=(0, 4))
            if first_browse_button is None:
                first_browse_button = browse_button
            ttk.Button(rows_frame, text="Crop", command=crop).grid(row=row, column=3, padx=(0, 8))

        embed = tk.BooleanVar(value=False)
        ttk.Checkbutton(dialog, text="Embed", variable=embed).grid(
            row=2, column=0, sticky="w", padx=8, pady=(4, 0)
        )

        def accept() -> None:
            if not assignments:
                messagebox.showerror(
                    "Assign pictures",
                    "Choose a picture for at least one movie.",
                    parent=dialog,
                )
                return
            try:
                self.service.set_picture_many(assignments.items(), embed=embed.get(), crops=crops)
            except _SERVICE_ERRORS as error:
                messagebox.showerror("Could not assign pictures", str(error), parent=dialog)
                return
            dialog.destroy()
            self.refresh()

        buttons = ttk.Frame(dialog)
        buttons.grid(row=3, column=0, sticky="e", padx=8, pady=8)
        ttk.Button(buttons, text="Cancel", command=dialog.destroy).pack(side="left", padx=(0, 4))
        ttk.Button(buttons, text="Apply", command=accept).pack(side="left")
        make_modal(dialog, focus=first_browse_button)

    def clear_pictures(self) -> None:
        """Remove linked and embedded pictures from every selected movie."""
        movies = self.selected_movies()
        if not movies:
            return
        description = (
            movies[0].display_title()
            if len(movies) == 1
            else f"these {len(movies)} selected movies"
        )
        if not messagebox.askyesno("Clear pictures", f"Remove the picture for {description}?"):
            return
        try:
            self.service.clear_picture_many(movie.number for movie in movies)
        except _SERVICE_ERRORS as error:
            messagebox.showerror("Could not clear pictures", str(error), parent=self)
            return
        self.refresh()

    def update_from_imdb(self) -> None:
        """Preview, then optionally apply, an OMDb-sourced IMDb metadata
        update for the selected movie.

        Reuses `amc.omdb.preview_omdb_update`'s isolated candidate-preview
        contract exactly as `amc cli imdb-lookup` does: nothing is written
        to the catalog until the user reviews the field changes and clicks
        Apply. The API key defaults to the `OMDB_API_KEY` environment
        variable (matching the CLI's `--api-key` default) and is never
        persisted by this dialog or written to GUI preferences.
        """
        movie = self.selected()
        if movie is None:
            return
        dialog = tk.Toplevel(self)
        dialog.title("Update from IMDb")
        dialog.transient(self.winfo_toplevel())
        api_key = tk.StringVar(value=os.environ.get("OMDB_API_KEY", ""))
        imdb_id = tk.StringVar(value=imdb_id_from_url(movie.url))
        ttk.Label(dialog, text="OMDb API key").grid(
            row=0, column=0, sticky="w", padx=8, pady=(8, 4)
        )
        ttk.Entry(dialog, textvariable=api_key, width=42, show="*").grid(
            row=0, column=1, padx=8, pady=(8, 4)
        )
        ttk.Label(dialog, text="IMDb ID (optional)").grid(
            row=1, column=0, sticky="w", padx=8, pady=4
        )
        id_entry = ttk.Entry(dialog, textvariable=imdb_id, width=42)
        id_entry.grid(row=1, column=1, padx=8, pady=4)
        ttk.Label(
            dialog,
            text=f'Falls back to a title/year search for "{movie.display_title()}" '
            "when no IMDb ID is given.",
            wraplength=420,
            justify="left",
            foreground="gray",
        ).grid(row=2, column=0, columnspan=2, sticky="w", padx=8)
        results = tk.Text(dialog, height=8, width=56, state="disabled", wrap="word")
        results.grid(row=3, column=0, columnspan=2, padx=8, pady=8)

        current_preview: ScriptMergePreview | None = None

        def show_lines(lines: list[str]) -> None:
            results.configure(state="normal")
            results.delete("1.0", "end")
            results.insert("1.0", "\n".join(lines) if lines else "No changes.")
            results.configure(state="disabled")

        def fetch() -> None:
            nonlocal current_preview
            current_preview = None
            apply_button.configure(state="disabled")
            candidate_id = imdb_id.get().strip()
            try:
                record = fetch_omdb_record(
                    api_key=api_key.get().strip(),
                    imdb_id=candidate_id,
                    title="" if candidate_id else movie.display_title(),
                    year=None if candidate_id else movie.year,
                    timeout=DEFAULT_OMDB_TIMEOUT,
                )
                preview = preview_omdb_update(movie, record)
            except (OSError, ValueError) as error:
                messagebox.showerror("Could not fetch IMDb metadata", str(error), parent=dialog)
                show_lines([])
                return
            current_preview = preview
            show_lines(
                [
                    f"{change.field}: {change.before!r} -> {change.after!r}"
                    for change in preview.changes
                ]
            )
            apply_button.configure(state="normal" if preview.changes else "disabled")

        def accept() -> None:
            preview = current_preview
            if preview is None:
                return
            try:
                self.service.replace(movie.number, preview.movie)
            except _SERVICE_ERRORS as error:
                messagebox.showerror("Could not apply IMDb update", str(error), parent=dialog)
                return
            dialog.destroy()
            self.refresh()

        buttons = ttk.Frame(dialog)
        buttons.grid(row=4, column=0, columnspan=2, sticky="e", padx=8, pady=(0, 8))
        ttk.Button(buttons, text="Fetch Preview", command=fetch).pack(side="left", padx=(0, 4))
        apply_button = ttk.Button(buttons, text="Apply", command=accept, state="disabled")
        apply_button.pack(side="left")
        make_modal(dialog, focus=id_entry)

    def undo(self) -> None:
        try:
            self.service.undo()
        except _SERVICE_ERRORS as error:
            messagebox.showerror("Could not undo change", str(error), parent=self)
            return
        self.refresh()

    def redo(self) -> None:
        try:
            self.service.redo()
        except _SERVICE_ERRORS as error:
            messagebox.showerror("Could not redo change", str(error), parent=self)
            return
        self.refresh()

    def open_url(self) -> None:
        movie = self.selected()
        if movie is None:
            return
        try:
            url = movie_web_url(movie)
            opened = webbrowser.open(url)
            if not opened:
                raise OSError("no web browser accepted the movie URL")
        except (OSError, ValueError) as error:
            messagebox.showerror("Could not open movie URL", str(error), parent=self)

    def show_statistics(self) -> None:
        statistics = self.service.statistics()
        duplicates = self.service.duplicates()
        labels = {
            "movies": "Movies",
            "checked": "Checked",
            "total_length": "Total length (minutes)",
            "average_rating": "Average rating",
            "earliest_year": "Earliest year",
            "latest_year": "Latest year",
        }
        lines = [
            f"{labels[name]}: {value if value is not None else '—'}"
            for name, value in statistics.items()
        ]
        lines.append(f"Duplicate groups: {len(duplicates)}")
        messagebox.showinfo("Catalog statistics", "\n".join(lines), parent=self)

    def show_loan_history(self) -> None:
        """Show retained check-out and check-in events in a scrollable table."""
        try:
            events = self.service.loan_history()
        except (TypeError, ValueError) as error:
            messagebox.showerror("Could not read loan history", str(error), parent=self)
            return
        dialog = tk.Toplevel(self)
        dialog.title("Loan history")
        dialog.transient(self.winfo_toplevel())
        dialog.geometry("900x420")
        frame = ttk.Frame(dialog, padding=10)
        frame.pack(fill="both", expand=True)
        footer = ttk.Frame(dialog, padding=(10, 0, 10, 10))
        footer.pack(fill="x")
        ttk.Button(footer, text="Export History", command=self.export_loan_history).pack(
            side="left"
        )
        ttk.Button(footer, text="Close", command=dialog.destroy).pack(side="right")
        table = ttk.Treeview(
            frame,
            columns=("timestamp", "action", "number", "title", "borrower"),
            show="headings",
        )
        for name, label, width in (
            ("timestamp", "Date and time", 190),
            ("action", "Action", 100),
            ("number", "#", 55),
            ("title", "Movie", 300),
            ("borrower", "Borrower", 180),
        ):
            table.heading(name, text=label)
            table.column(name, width=width, anchor="e" if name == "number" else "w")
        for event in reversed(events):
            table.insert("", "end", values=loan_event_row(event))
        scrollbar = ttk.Scrollbar(frame, orient="vertical", command=table.yview)
        table.configure(yscrollcommand=scrollbar.set)
        table.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")
        if not events:
            self.status.configure(text="No loan history has been recorded.")
        dialog.bind("<Escape>", lambda _event: dialog.destroy())
        table.focus_set()

    def export_loan_history(self) -> None:
        """Export retained loan events using the upstream-compatible TSV shape."""
        selected = filedialog.asksaveasfilename(
            parent=self.winfo_toplevel(),
            title="Export loan history",
            defaultextension=".csv",
            initialfile=f"{self.service.path.stem} loan history.csv",
            filetypes=(("Tab-separated history", "*.csv"), ("All files", "*")),
        )
        if not selected:
            return
        try:
            self.service.export_loan_history(selected)
        except (OSError, TypeError, ValueError) as error:
            messagebox.showerror("Could not export loan history", str(error), parent=self)
            return
        messagebox.showinfo("Loan history exported", f"Exported to {selected}.", parent=self)

    def show_duplicates(self) -> None:
        groups = self.service.duplicates()
        if not groups:
            messagebox.showinfo(
                "Duplicate movies", "No duplicate title/year groups found.", parent=self
            )
            return
        lines = []
        for group in groups:
            lines.append(
                ", ".join(
                    f"#{movie.number} {movie.display_title()}"
                    + (f" ({movie.year})" if movie.year else "")
                    for movie in group
                )
            )
        messagebox.showinfo("Duplicate movies", "\n".join(lines), parent=self)

    def show_about(self) -> None:
        """Version, license, and a project link, matching upstream's own
        Help menu (`main.dfm`) — this port previously had neither a Help
        menu nor an About dialog anywhere in the desktop GUI."""
        dialog = tk.Toplevel(self)
        dialog.title("About AMC Python")
        dialog.transient(self.winfo_toplevel())
        ttk.Label(dialog, text="AMC Python", font=("TkDefaultFont", 12, "bold")).grid(
            row=0, column=0, sticky="w", padx=12, pady=(12, 0)
        )
        ttk.Label(dialog, text=f"Version {__version__}").grid(row=1, column=0, sticky="w", padx=12)
        ttk.Label(
            dialog,
            text="A portable Python port of Ant Movie Catalog.",
            wraplength=320,
        ).grid(row=2, column=0, sticky="w", padx=12, pady=(4, 0))
        ttk.Label(dialog, text="License: GPL-2.0-or-later").grid(
            row=3, column=0, sticky="w", padx=12, pady=(8, 0)
        )
        link = ttk.Label(
            dialog,
            text="github.com/luisriverag/amc_python",
            foreground="blue",
            cursor="hand2",
        )
        link.grid(row=4, column=0, sticky="w", padx=12, pady=(0, 12))
        link.bind(
            "<Button-1>",
            lambda _event: webbrowser.open("https://github.com/luisriverag/amc_python"),
        )
        ttk.Button(dialog, text="Close", command=dialog.destroy).grid(
            row=5, column=0, sticky="e", padx=12, pady=(0, 12)
        )
        make_modal(dialog, focus=link)

    def renumber(self) -> None:
        if not len(self.service.catalog):
            return
        if not messagebox.askyesno(
            "Renumber movies",
            "Assign consecutive numbers in the current catalog order?",
            parent=self,
        ):
            return
        try:
            self.service.renumber()
        except _SERVICE_ERRORS as error:
            messagebox.showerror("Could not renumber movies", str(error), parent=self)
            return
        self.refresh()

    def sort(self, field: str) -> None:
        reverse = self.sort_field == field and not self.sort_reverse
        try:
            self.service.sort(field, reverse=reverse)
        except _SERVICE_ERRORS as error:
            messagebox.showerror("Could not sort movies", str(error), parent=self)
            return
        self.sort_field = field
        self.sort_reverse = reverse
        labels = {
            "number": "#",
            "title": "Title",
            "year": "Year",
            "director": "Director",
            "checked": "Checked",
            "borrower": "Borrower",
        }
        for name, label in labels.items():
            marker = " ▼" if reverse else " ▲"
            self.table.heading(name, text=label + (marker if name == field else ""))
        self.refresh()

    def _dialog(self, movie: Movie, *, is_new: bool) -> None:
        dialog = tk.Toplevel(self)
        dialog.title("Add movie" if is_new else "Edit movie")
        dialog.transient(self.winfo_toplevel())
        field_names = _EDIT_TEXT_FIELDS + _EDIT_INTEGER_FIELDS + _EDIT_FLOAT_FIELDS
        values = {
            name: tk.StringVar(
                value="" if getattr(movie, name) is None else str(getattr(movie, name))
            )
            for name in field_names
        }
        checked = tk.BooleanVar(value=movie.checked)
        multiline_widgets: dict[str, tk.Text] = {}
        raw_embedded = movie.extras.get("native_picture_base64")
        try:
            picture_bytes = (
                base64.b64decode(raw_embedded, validate=True)
                if isinstance(raw_embedded, str) and raw_embedded
                else None
            )
        except ValueError:
            picture_bytes = None
        embed_picture = tk.BooleanVar(value=picture_bytes is not None)
        canvas = tk.Canvas(dialog, highlightthickness=0, width=570, height=520)
        scrollbar = ttk.Scrollbar(dialog, orient="vertical", command=canvas.yview)
        fields_frame = ttk.Frame(canvas)
        fields_frame.bind(
            "<Configure>",
            lambda _event: canvas.configure(scrollregion=canvas.bbox("all")),
        )
        canvas.create_window((0, 0), window=fields_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)
        canvas.grid(row=0, column=0, columnspan=2, sticky="nsew")
        scrollbar.grid(row=0, column=2, sticky="ns")
        dialog.rowconfigure(0, weight=1)
        dialog.columnconfigure(0, weight=1)
        title_entry: ttk.Entry | None = None
        for row, (name, value) in enumerate(values.items()):
            ttk.Label(fields_frame, text=name.replace("_", " ").title()).grid(
                row=row, column=0, sticky="w", padx=8, pady=4
            )
            if name in _EDIT_MULTILINE_FIELDS:
                text = tk.Text(fields_frame, width=48, height=5, wrap="word")
                text.insert("1.0", value.get())
                text.grid(row=row, column=1, sticky="ew", padx=8, pady=4)
                multiline_widgets[name] = text
            else:
                entry = ttk.Entry(fields_frame, textvariable=value, width=48)
                entry.grid(row=row, column=1, padx=8, pady=4)
                if name == "title":
                    title_entry = entry
            if name == "picture":
                picture_value = value

                def choose_picture() -> None:
                    nonlocal picture_bytes
                    selected = filedialog.askopenfilename(
                        parent=dialog,
                        title="Choose poster",
                        filetypes=_IMAGE_FILETYPES,
                    )
                    if not selected:
                        return
                    try:
                        with Image.open(selected) as image:
                            image.verify()
                        picture_bytes = Path(selected).read_bytes()
                    except (OSError, UnidentifiedImageError) as error:
                        messagebox.showerror("Invalid poster", str(error), parent=dialog)
                        return
                    selected_path = Path(selected)
                    try:
                        display_path = selected_path.resolve().relative_to(
                            self.service.path.parent.resolve()
                        )
                    except ValueError:
                        display_path = selected_path
                    picture_value.set(str(display_path))

                def clear_picture() -> None:
                    nonlocal picture_bytes
                    picture_bytes = None
                    embed_picture.set(False)
                    picture_value.set("")

                def crop_picture() -> None:
                    if picture_bytes is None:
                        messagebox.showerror(
                            "Crop picture",
                            "Choose a poster before cropping.",
                            parent=dialog,
                        )
                        return

                    def apply_crop(box: tuple[int, int, int, int]) -> None:
                        nonlocal picture_bytes
                        if picture_bytes is not None:
                            picture_bytes = crop_image_bytes(picture_bytes, box)

                    try:
                        open_crop_dialog(dialog, picture_bytes, on_apply=apply_crop)
                    except (OSError, UnidentifiedImageError) as error:
                        messagebox.showerror("Crop picture", str(error), parent=dialog)

                controls = ttk.Frame(fields_frame)
                controls.grid(row=row, column=2, sticky="w", padx=(0, 8))
                ttk.Button(controls, text="Browse", command=choose_picture).pack(side="left")
                ttk.Button(controls, text="Crop", command=crop_picture).pack(side="left", padx=4)
                ttk.Button(controls, text="Clear", command=clear_picture).pack(side="left", padx=4)
                ttk.Checkbutton(controls, text="Embed", variable=embed_picture).pack(side="left")
        ttk.Checkbutton(fields_frame, text="Checked", variable=checked).grid(
            row=len(values), column=1, sticky="w", padx=8, pady=4
        )

        def accept() -> None:
            for name, widget in multiline_widgets.items():
                values[name].set(widget.get("1.0", "end-1c"))
            if not any(
                values[name].get().strip()
                for name in ("title", "translated_title", "original_title")
            ):
                messagebox.showerror("Invalid movie", "A title is required.", parent=dialog)
                return
            try:
                replacement = movie_from_form(
                    movie,
                    {name: value.get() for name, value in values.items()},
                    checked=checked.get(),
                )
                if embed_picture.get() and picture_bytes is None:
                    raise ValueError("choose a poster before enabling Embed")
                replacement = movie_with_picture(
                    replacement,
                    values["picture"].get(),
                    embedded=picture_bytes if embed_picture.get() else None,
                )
            except (TypeError, ValueError) as error:
                messagebox.showerror("Invalid movie", str(error), parent=dialog)
                return
            try:
                if is_new:
                    self.service.add(replacement)
                else:
                    self.service.replace(movie.number, replacement)
            except _SERVICE_ERRORS as error:
                messagebox.showerror("Could not save movie", str(error), parent=dialog)
                return
            self.refresh()
            dialog.destroy()

        ttk.Button(dialog, text="Save", command=accept).grid(
            row=1, column=1, sticky="e", padx=8, pady=10
        )
        dialog.bind("<Return>", lambda _event: accept())
        make_modal(dialog, focus=title_entry)


def run(path: Path) -> None:
    root = tk.Tk()
    root.title(f"AMC Python — {path.name}")
    root.minsize(760, 480)
    CatalogWindow(root, path)
    root.mainloop()


def main(argv: list[str] | None = None) -> None:
    """Launch the installed desktop entry point."""
    parser = argparse.ArgumentParser(prog="amc-gui", description="AMC Python desktop")
    parser.add_argument("catalog", nargs="?", type=Path, default=Path("catalog.json"))
    args = parser.parse_args(argv)
    run(args.catalog)
