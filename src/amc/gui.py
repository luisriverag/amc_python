"""Small standard-library desktop interface for AMC Python."""

from __future__ import annotations

import tkinter as tk
from pathlib import Path
from tkinter import messagebox, ttk

from .catalog import Catalog
from .model import Movie
from .storage import load, save


class CatalogWindow(ttk.Frame):
    """Browse and edit a catalog without third-party GUI dependencies."""

    def __init__(self, master: tk.Tk, path: Path) -> None:
        super().__init__(master, padding=10)
        self.path = path
        self.catalog = load(path) if path.exists() else Catalog()
        self.search_text = tk.StringVar()
        self.pack(fill="both", expand=True)

        bar = ttk.Frame(self)
        bar.pack(fill="x", pady=(0, 8))
        ttk.Label(bar, text="Search:").pack(side="left")
        search = ttk.Entry(bar, textvariable=self.search_text)
        search.pack(side="left", fill="x", expand=True, padx=6)
        self.search_text.trace_add("write", lambda *_: self.refresh())
        ttk.Button(bar, text="Add", command=self.add).pack(side="left")
        ttk.Button(bar, text="Edit", command=self.edit).pack(side="left", padx=4)
        ttk.Button(bar, text="Remove", command=self.remove).pack(side="left")

        self.table = ttk.Treeview(self, columns=("number", "title", "year", "director"), show="headings")
        for key, label, width in (("number", "#", 55), ("title", "Title", 300), ("year", "Year", 70), ("director", "Director", 180)):
            self.table.heading(key, text=label, command=lambda name=key: self.sort(name))
            self.table.column(key, width=width, anchor="e" if key in {"number", "year"} else "w")
        self.table.pack(fill="both", expand=True)
        self.table.bind("<Double-1>", lambda _event: self.edit())
        self.refresh()

    def refresh(self) -> None:
        self.table.delete(*self.table.get_children())
        query = self.search_text.get().strip()
        movies = self.catalog.search(query) if query else list(self.catalog)
        for movie in movies:
            self.table.insert("", "end", iid=str(movie.number), values=(movie.number, movie.display_title(), movie.year or "", movie.director))

    def selected(self) -> Movie | None:
        selection = self.table.selection()
        return self.catalog.get(int(selection[0])) if selection else None

    def add(self) -> None:
        self._dialog(Movie(), is_new=True)

    def edit(self) -> None:
        movie = self.selected()
        if movie:
            self._dialog(movie, is_new=False)

    def remove(self) -> None:
        movie = self.selected()
        if movie and messagebox.askyesno("Remove movie", f"Remove {movie.display_title()}?"):
            self.catalog.remove(movie.number)
            self.persist()

    def sort(self, field: str) -> None:
        self.catalog.sort(field)
        self.refresh()

    def persist(self) -> None:
        save(self.catalog, self.path)
        self.refresh()

    def _dialog(self, movie: Movie, *, is_new: bool) -> None:
        dialog = tk.Toplevel(self)
        dialog.title("Add movie" if is_new else "Edit movie")
        dialog.transient(self.winfo_toplevel())
        values = {name: tk.StringVar(value="" if getattr(movie, name) is None else str(getattr(movie, name))) for name in ("title", "year", "director", "category", "actors", "url")}
        for row, (name, value) in enumerate(values.items()):
            ttk.Label(dialog, text=name.replace("_", " ").title()).grid(row=row, column=0, sticky="w", padx=8, pady=4)
            ttk.Entry(dialog, textvariable=value, width=48).grid(row=row, column=1, padx=8, pady=4)

        def accept() -> None:
            if not values["title"].get().strip():
                messagebox.showerror("Invalid movie", "A title is required.", parent=dialog)
                return
            year = values["year"].get().strip()
            if year and not year.isdigit():
                messagebox.showerror("Invalid year", "Year must be a number.", parent=dialog)
                return
            for name, value in values.items():
                setattr(movie, name, int(year) if name == "year" and year else (None if name == "year" else value.get().strip()))
            if is_new:
                self.catalog.add(movie)
            self.persist()
            dialog.destroy()

        ttk.Button(dialog, text="Save", command=accept).grid(row=len(values), column=1, sticky="e", padx=8, pady=10)
        dialog.bind("<Return>", lambda _event: accept())
        dialog.grab_set()


def run(path: Path) -> None:
    root = tk.Tk()
    root.title(f"AMC Python — {path.name}")
    root.geometry("760x480")
    CatalogWindow(root, path)
    root.mainloop()
