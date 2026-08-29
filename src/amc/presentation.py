"""Interface-neutral catalog filtering and poster-source resolution."""

from __future__ import annotations

import base64
import os
from pathlib import Path, PureWindowsPath
import unicodedata

from .model import Movie

VIEW_FILTERS = ("All", "Loaned", "Available", "Checked", "Unchecked")


def filter_movies(movies: list[Movie], mode: str) -> list[Movie]:
    filters = {
        "All": lambda movie: True,
        "Loaned": lambda movie: bool(movie.borrower),
        "Available": lambda movie: not movie.borrower,
        "Checked": lambda movie: movie.checked,
        "Unchecked": lambda movie: not movie.checked,
    }
    try:
        predicate = filters[mode]
    except KeyError as error:
        raise ValueError(f"unknown movie view filter: {mode}") from error
    return [movie for movie in movies if predicate(movie)]


def poster_source(movie: Movie, catalog_path: Path) -> tuple[str, str] | None:
    embedded = movie.extras.get("native_picture_base64")
    if isinstance(embedded, str) and embedded:
        try:
            base64.b64decode(embedded, validate=True)
        except ValueError:
            pass
        else:
            return ("data", embedded)
    if not movie.picture:
        return None
    resolved = linked_picture_path(movie.picture, catalog_path)
    return ("file", str(resolved)) if resolved is not None else None


def linked_picture_path(picture: str, catalog_path: Path) -> Path | None:
    """Resolve an AMC picture link relative to its catalog, including Windows case.

    Native AMC catalogs commonly contain backslash-separated links created on
    case-insensitive Windows filesystems. Preserve their subdirectory instead
    of falling straight back to the basename, and recover component casing
    when the catalog and picture folder are opened on Linux.
    """
    picture = picture.strip().strip('"')
    if not picture:
        return None
    windows_path = PureWindowsPath(picture)
    normalized = Path(picture.replace("\\", "/"))
    path = Path(*windows_path.parts[1:]) if windows_path.drive else normalized
    catalog_roots = list(dict.fromkeys((catalog_path.parent, catalog_path.resolve().parent)))
    candidates = [path] if path.is_absolute() else [root / path for root in catalog_roots]
    if windows_path.is_absolute():
        for root in catalog_roots:
            parent_name = _fold(root.name)
            for index, part in enumerate(windows_path.parts):
                if _fold(part) == parent_name and index + 1 < len(windows_path.parts):
                    candidates.append(root.joinpath(*windows_path.parts[index + 1 :]))
                    break
    candidates.extend(root / windows_path.name for root in catalog_roots)
    for candidate in candidates:
        if candidate.is_file():
            return candidate
        for root in catalog_roots:
            try:
                relative = candidate.relative_to(root)
            except ValueError:
                continue
            recovered = _case_insensitive_path(root, relative)
            if recovered is not None and recovered.is_file():
                return recovered
    # Some AMC catalogs retain a stale relative folder after the catalog and
    # its picture directory are moved together. As a final bounded fallback,
    # locate the stored basename below the catalog directory. Never guess when
    # more than one matching file exists.
    for root in catalog_roots:
        recovered = _find_unique_descendant(root, windows_path.name)
        if recovered is not None:
            return recovered
    return None


def _case_insensitive_path(root: Path, relative: Path) -> Path | None:
    current = root
    for part in relative.parts:
        if part in ("", "."):
            continue
        if part == ".." or not current.is_dir():
            return None
        try:
            matches = [child for child in current.iterdir() if _fold(child.name) == _fold(part)]
        except OSError:
            return None
        if len(matches) != 1:
            return None
        current = matches[0]
    return current


def _find_unique_descendant(
    root: Path, basename: str, *, max_depth: int = 4, max_entries: int = 10_000
) -> Path | None:
    """Find one case/Unicode-insensitive basename under *root*, within bounds."""
    wanted = _fold(basename)
    match: Path | None = None
    entries = 0
    try:
        for directory, subdirectories, filenames in os.walk(root, followlinks=False):
            relative = Path(directory).relative_to(root)
            if len(relative.parts) >= max_depth:
                subdirectories.clear()
            entries += len(subdirectories) + len(filenames)
            if entries > max_entries:
                return None
            for filename in filenames:
                if _fold(filename) != wanted:
                    continue
                candidate = Path(directory) / filename
                if match is not None and candidate != match:
                    return None
                match = candidate
    except OSError:
        return None
    return match


def _fold(value: str) -> str:
    return unicodedata.normalize("NFC", value).casefold()
