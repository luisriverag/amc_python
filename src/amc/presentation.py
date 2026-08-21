"""Interface-neutral catalog filtering and poster-source resolution."""

from __future__ import annotations

import base64
from pathlib import Path

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
    path = Path(movie.picture.replace("\\", "/"))
    candidates = [path] if path.is_absolute() else [catalog_path.parent / path]
    candidates.append(catalog_path.parent / path.name)
    for candidate in candidates:
        if candidate.is_file():
            return ("file", str(candidate))
    return None
