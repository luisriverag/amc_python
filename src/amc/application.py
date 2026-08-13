"""Shared catalog application services for user-interface adapters."""

from __future__ import annotations

from collections.abc import Callable
from pathlib import Path
from typing import TypeVar

from .catalog import Catalog
from .model import Movie
from .storage import load, save

_Result = TypeVar("_Result")


class CatalogService:
    """Own a catalog and persist mutations without exposing partial changes."""

    def __init__(self, path: str | Path) -> None:
        self.path = Path(path)
        self.catalog = load(self.path) if self.path.exists() else Catalog()
        self.dirty = False

    def reload(self) -> None:
        """Discard in-memory changes and reopen the configured catalog."""
        self.catalog = load(self.path) if self.path.exists() else Catalog()
        self.dirty = False

    def save(self) -> None:
        save(self.catalog, self.path)
        self.dirty = False

    def add(self, movie: Movie) -> Movie:
        isolated = Movie.from_dict(movie.to_dict())
        return self._persist(lambda catalog: catalog.add(isolated))

    def replace(self, number: int, movie: Movie) -> Movie:
        return self._persist(lambda catalog: catalog.replace(number, movie))

    def remove(self, number: int) -> Movie:
        return self._persist(lambda catalog: catalog.remove(number))

    def _persist(self, mutation: Callable[[Catalog], _Result]) -> _Result:
        """Save a mutation before publishing it as current application state."""
        candidate = Catalog(
            (Movie.from_dict(movie.to_dict()) for movie in self.catalog),
            metadata=self.catalog.metadata,
        )
        result = mutation(candidate)
        self.dirty = True
        try:
            save(candidate, self.path)
        except Exception:
            self.dirty = False
            raise
        self.catalog = candidate
        self.dirty = False
        return result
