"""Small standard-library desktop interface for AMC Python."""

from __future__ import annotations

import argparse
import base64
import io
import tkinter as tk
import webbrowser
from pathlib import Path
from urllib.parse import urlparse
from tkinter import filedialog, messagebox, ttk
from tkinter import font as tkfont

from PIL import Image, ImageTk, UnidentifiedImageError

from .application import CatalogService
from .errors import CatalogError
from .loans import LoanEvent
from .model import Movie
from .presentation import filter_movies, poster_source

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


def movie_with_picture(
    movie: Movie, picture: str, *, embedded: bytes | None
) -> Movie:
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


def poster_size(width: int, height: int, *, maximum: tuple[int, int] = (320, 420)) -> tuple[int, int]:
    """Fit an image within the poster pane without changing its aspect ratio."""
    if width < 1 or height < 1:
        raise ValueError("poster dimensions must be positive")
    scale = min(maximum[0] / width, maximum[1] / height, 1.0)
    return max(1, round(width * scale)), max(1, round(height * scale))


def make_modal(dialog: tk.Toplevel, *, focus: tk.Widget | None = None) -> None:
    """Wait for a child window to become viewable before taking the Tk grab."""
    dialog.update_idletasks()
    dialog.wait_visibility()
    if focus is not None:
        focus.focus_set()
    dialog.grab_set()


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

    def __init__(self, master: tk.Tk, path: Path) -> None:
        super().__init__(master, padding=10)
        self.path = path
        self.service = CatalogService(path)
        self.search_text = tk.StringVar()
        self.view_filter = tk.StringVar(value="All")
        self.layout = tk.StringVar(value="Details")
        self.sort_field: str | None = None
        self.sort_reverse = False
        self.pack(fill="both", expand=True)
        self._configure_style()

        files = ttk.Frame(self)
        files.pack(fill="x", pady=(0, 8))
        ttk.Button(files, text="Open", command=self.open_catalog).pack(side="left")
        ttk.Button(files, text="Save As", command=self.save_as).pack(side="left", padx=4)
        self.import_button = ttk.Button(files, text="Import", command=self.import_catalog)
        self.import_button.pack(side="left")
        ttk.Button(files, text="Export", command=self.export_catalog).pack(side="left", padx=4)
        ttk.Button(files, text="Backup", command=self.backup_catalog).pack(side="left")
        self.restore_button = ttk.Button(files, text="Restore", command=self.restore_catalog)
        self.restore_button.pack(side="left", padx=4)
        self.location = ttk.Label(files, text=str(path))
        self.location.pack(side="left", fill="x", expand=True, padx=8)

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
        view.bind("<<ComboboxSelected>>", lambda _event: self.refresh())
        ttk.Label(bar, text="Layout:").pack(side="left")
        layout = ttk.Combobox(
            bar,
            textvariable=self.layout,
            values=("Table", "Details", "Poster"),
            state="readonly",
            width=8,
        )
        layout.pack(side="left", padx=(0, 6))
        layout.bind("<<ComboboxSelected>>", lambda _event: self.apply_layout())

        # Keep catalog actions on their own row. Putting every action beside the
        # search field clipped the right-most controls on common 760px displays.
        actions = ttk.Frame(self)
        actions.pack(fill="x", pady=(0, 8))
        self.action_buttons: dict[str, ttk.Button] = {}
        for text, command, padding in (
            ("Add", self.add, 0),
            ("Edit", self.edit, 4),
            ("Remove", self.remove, 0),
            ("Loan Out", self.loan_out, 12),
            ("Loan In", self.loan_in, 4),
            ("Toggle Checked", self.toggle_checked, 12),
            ("Undo", self.undo, 12),
            ("Redo", self.redo, 4),
            ("Open URL", self.open_url, 12),
            ("Stats", self.show_statistics, 12),
            ("Loan History", self.show_loan_history, 4),
            ("Duplicates", self.show_duplicates, 4),
            ("Renumber", self.renumber, 0),
        ):
            button = ttk.Button(actions, text=text, command=command)
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
            self.table.heading(key, text=label, command=lambda name=key: self.sort(name))
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
        self.status = ttk.Label(self, anchor="w")
        self.status.pack(fill="x", pady=(6, 0))
        self._bind_shortcuts()
        self.refresh()
        self.apply_layout()

    def _configure_style(self) -> None:
        """Use a readable Treeview row height derived from the active Tk font."""
        font = tkfont.nametofont("TkDefaultFont")
        ttk.Style(self).configure("Treeview", rowheight=max(24, font.metrics("linespace") + 8))

    def apply_layout(self) -> None:
        """Switch among compact table, textual details, and poster-focused views."""
        mode = self.layout.get()
        self.details.pack_forget()
        self.poster.pack_forget()
        if mode == "Table":
            self.details_frame.pack_forget()
        else:
            self.details_frame.pack(fill="x", pady=(8, 0))
            if mode == "Poster":
                self.poster.pack(fill="both", expand=True)
            else:
                self.poster.pack(side="left", fill="y", padx=(0, 8))
                self.details.pack(side="left", fill="both", expand=True)
        self.show_selected()

    def _bind_shortcuts(self) -> None:
        root = self.winfo_toplevel()
        root.bind("<Control-o>", lambda _event: self.open_catalog())
        root.bind("<Control-Shift-S>", lambda _event: self.save_as())
        root.bind("<Control-f>", lambda _event: self.focus_search())
        root.bind("<Escape>", lambda _event: self.clear_search())
        root.bind("<Control-n>", lambda _event: self.invoke_action("Add"))
        root.bind("<Delete>", lambda _event: self.invoke_action("Remove"))
        root.bind("<space>", lambda _event: self.invoke_action("Toggle Checked"))
        root.bind("<F5>", lambda _event: self.reload_catalog())
        root.bind("<Control-z>", lambda _event: self.invoke_action("Undo"))
        root.bind("<Control-y>", lambda _event: self.invoke_action("Redo"))
        root.bind("<Control-u>", lambda _event: self.invoke_action("Open URL"))

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
            "Open URL": can_open_url,
        }
        for name, enabled in selection_actions.items():
            self.action_buttons[name].configure(state="normal" if enabled else "disabled")
        self.action_buttons["Add"].configure(state="normal" if writable else "disabled")
        self.import_button.configure(state="normal" if writable else "disabled")
        self.restore_button.configure(state="normal" if writable else "disabled")
        self.action_buttons["Renumber"].configure(
            state="normal" if writable and len(self.service.catalog) else "disabled"
        )
        self.action_buttons["Undo"].configure(
            state="normal" if writable and self.service.can_undo else "disabled"
        )
        self.action_buttons["Redo"].configure(
            state="normal" if writable and self.service.can_redo else "disabled"
        )

    def refresh(self) -> None:
        selection = self.table.selection()
        self.table.delete(*self.table.get_children())
        query = self.search_text.get().strip()
        movies = self.service.catalog.search(query) if query else list(self.service.catalog)
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
        self.poster.configure(
            image=image or "", text="" if image is not None else status
        )

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
        except (CatalogError, OSError, TypeError, ValueError) as error:
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
        except (CatalogError, OSError, TypeError, ValueError) as error:
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
        except (CatalogError, OSError, TypeError, ValueError) as error:
            messagebox.showerror("Could not save catalog", str(error), parent=self)
            return
        self._path_changed()

    def _path_changed(self) -> None:
        self.path = self.service.path
        self.location.configure(text=str(self.path))
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
        except (CatalogError, OSError, TypeError, ValueError) as error:
            messagebox.showerror("Could not import catalog", str(error), parent=self)
            return
        self.refresh()
        messagebox.showinfo(
            "Import complete", f"Imported {count} movie(s).", parent=self
        )

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
        if format_name == "amc":
            backup_note = (
                f"\n\nThe existing file will be preserved as "
                f"{Path(selected).with_suffix('.bak')}."
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
        try:
            self.service.export(selected, format=format_name)
        except (CatalogError, OSError, TypeError, ValueError) as error:
            messagebox.showerror("Could not export catalog", str(error), parent=self)
            return
        completion = f"Exported to {selected}."
        if format_name == "amc" and destination_exists:
            completion += f"\nPrevious file: {Path(selected).with_suffix('.bak')}"
        messagebox.showinfo("Export complete", completion, parent=self)

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
        except (CatalogError, OSError, TypeError, ValueError) as error:
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
        except (CatalogError, OSError, TypeError, ValueError) as error:
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
            except (CatalogError, OSError, TypeError, ValueError, KeyError) as error:
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
                self.service.check_out_many(
                    (movie.number for movie in movies), borrower.get()
                )
            except (CatalogError, OSError, TypeError, ValueError) as error:
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
        except (CatalogError, OSError, TypeError, ValueError) as error:
            messagebox.showerror("Could not check in movie", str(error), parent=self)
            return
        self.refresh()

    def toggle_checked(self) -> None:
        movies = self.selected_movies()
        if not movies:
            return
        checked = not all(movie.checked for movie in movies)
        try:
            self.service.set_checked_many(
                (movie.number for movie in movies), checked
            )
        except (CatalogError, OSError, TypeError, ValueError, KeyError) as error:
            messagebox.showerror(
                "Could not update checked state", str(error), parent=self
            )
            return
        self.refresh()

    def undo(self) -> None:
        try:
            self.service.undo()
        except (CatalogError, OSError, TypeError, ValueError) as error:
            messagebox.showerror("Could not undo change", str(error), parent=self)
            return
        self.refresh()

    def redo(self) -> None:
        try:
            self.service.redo()
        except (CatalogError, OSError, TypeError, ValueError) as error:
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
        ttk.Button(
            footer, text="Export History", command=self.export_loan_history
        ).pack(side="left")
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
            messagebox.showerror(
                "Could not export loan history", str(error), parent=self
            )
            return
        messagebox.showinfo(
            "Loan history exported", f"Exported to {selected}.", parent=self
        )

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
        except (CatalogError, OSError, TypeError, ValueError) as error:
            messagebox.showerror("Could not renumber movies", str(error), parent=self)
            return
        self.refresh()

    def sort(self, field: str) -> None:
        reverse = self.sort_field == field and not self.sort_reverse
        try:
            self.service.sort(field, reverse=reverse)
        except (CatalogError, OSError, TypeError, ValueError) as error:
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
        for row, (name, value) in enumerate(values.items()):
            ttk.Label(fields_frame, text=name.replace("_", " ").title()).grid(row=row, column=0, sticky="w", padx=8, pady=4)
            if name in _EDIT_MULTILINE_FIELDS:
                text = tk.Text(fields_frame, width=48, height=5, wrap="word")
                text.insert("1.0", value.get())
                text.grid(row=row, column=1, sticky="ew", padx=8, pady=4)
                multiline_widgets[name] = text
            else:
                entry = ttk.Entry(fields_frame, textvariable=value, width=48)
                entry.grid(row=row, column=1, padx=8, pady=4)
            if name == "picture":
                picture_value = value

                def choose_picture() -> None:
                    nonlocal picture_bytes
                    selected = filedialog.askopenfilename(
                        parent=dialog,
                        title="Choose poster",
                        filetypes=(
                            (
                                "Images",
                                "*.jpg *.jpeg *.png *.gif *.bmp *.tif *.tiff *.webp",
                            ),
                            ("All files", "*"),
                        ),
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

                controls = ttk.Frame(fields_frame)
                controls.grid(row=row, column=2, sticky="w", padx=(0, 8))
                ttk.Button(
                    controls, text="Browse", command=choose_picture
                ).pack(side="left")
                ttk.Button(
                    controls, text="Clear", command=clear_picture
                ).pack(side="left", padx=4)
                ttk.Checkbutton(
                    controls, text="Embed", variable=embed_picture
                ).pack(side="left")
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
            except (CatalogError, OSError, TypeError, ValueError) as error:
                messagebox.showerror("Could not save movie", str(error), parent=dialog)
                return
            self.refresh()
            dialog.destroy()

        ttk.Button(dialog, text="Save", command=accept).grid(row=1, column=1, sticky="e", padx=8, pady=10)
        dialog.bind("<Return>", lambda _event: accept())
        make_modal(dialog)


def run(path: Path) -> None:
    root = tk.Tk()
    root.title(f"AMC Python — {path.name}")
    root.geometry("1100x720")
    root.minsize(760, 480)
    CatalogWindow(root, path)
    root.mainloop()


def main(argv: list[str] | None = None) -> None:
    """Launch the installed desktop entry point."""
    parser = argparse.ArgumentParser(prog="amc-gui", description="AMC Python desktop")
    parser.add_argument("catalog", nargs="?", type=Path, default=Path("catalog.json"))
    args = parser.parse_args(argv)
    run(args.catalog)
