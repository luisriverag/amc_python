"""Shared catalog application services for user-interface adapters."""

from __future__ import annotations

from collections.abc import Callable, Iterable
from pathlib import Path
from typing import TypeVar

from .catalog import Catalog
from .model import Movie
from .storage import (
    copy_catalog,
    load,
    save,
    save_csv,
    save_html,
    save_native,
    save_xml,
)

_Result = TypeVar("_Result")
_HISTORY_LIMIT = 100


class CatalogService:
    """Own a catalog and persist mutations without exposing partial changes."""

    def __init__(self, path: str | Path) -> None:
        self.path = Path(path)
        self.catalog = load(self.path) if self.path.exists() else Catalog()
        self.dirty = False
        self._undo: list[Catalog] = []
        self._redo: list[Catalog] = []

    def reload(self) -> None:
        """Discard in-memory changes and reopen the configured catalog."""
        self.catalog = load(self.path) if self.path.exists() else Catalog()
        self.dirty = False
        self._clear_history()

    def open(self, path: str | Path) -> None:
        """Open another catalog only after it has loaded successfully."""
        candidate_path = Path(path)
        candidate = load(candidate_path)
        self.path = candidate_path
        self.catalog = candidate
        self.dirty = False
        self._clear_history()

    def save_as(self, path: str | Path) -> None:
        """Save to a new path and adopt it only after persistence succeeds."""
        candidate_path = Path(path)
        save(self.catalog, candidate_path)
        self.path = candidate_path
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

    def remove_many(self, numbers: Iterable[int]) -> list[Movie]:
        """Remove distinct movie numbers in one failure-atomic operation."""
        requested = list(numbers)
        if any(
            isinstance(number, bool) or not isinstance(number, int)
            for number in requested
        ):
            raise TypeError("movie numbers must be integers")
        if len(set(requested)) != len(requested):
            raise ValueError("movie numbers must be unique")
        if not requested:
            return []

        def remove_all(catalog: Catalog) -> list[Movie]:
            return [catalog.remove(number) for number in requested]

        return self._persist(remove_all)

    def add_many(self, movies: Iterable[Movie]) -> list[Movie]:
        """Add a batch in one failure-atomic persistence operation."""
        isolated = [Movie.from_dict(movie.to_dict()) for movie in movies]

        def add_all(catalog: Catalog) -> list[Movie]:
            return [catalog.add(movie) for movie in isolated]

        return self._persist(add_all)

    def merge(
        self,
        incoming: Catalog,
        *,
        collision: str = "renumber",
        metadata: str = "error",
    ) -> int:
        """Merge a catalog and persist only the complete successful result."""
        isolated = Catalog(
            (Movie.from_dict(movie.to_dict()) for movie in incoming),
            metadata=incoming.metadata,
        )
        return self._persist(
            lambda catalog: catalog.merge(
                isolated, collision=collision, metadata=metadata
            )
        )

    def import_from(
        self,
        source: str | Path,
        *,
        collision: str = "renumber",
        metadata: str = "error",
    ) -> int:
        """Load and atomically merge an interchange catalog."""
        return self.merge(
            load(source), collision=collision, metadata=metadata
        )

    def renumber(self, start: int = 1) -> None:
        """Renumber all movies and persist the complete result."""
        self._persist(lambda catalog: catalog.renumber(start))

    def sort(self, field: str = "title", *, reverse: bool = False) -> None:
        """Sort movies and persist the new order as one operation."""
        self._persist(lambda catalog: catalog.sort(field, reverse=reverse))

    def statistics(self) -> dict[str, int | float | None]:
        """Return catalog aggregates without exposing mutation to an adapter."""
        return self.catalog.statistics()

    def duplicates(self) -> list[list[Movie]]:
        """Return normalized title/year duplicate groups."""
        return self.catalog.duplicates()

    def check_out(self, number: int, borrower: str) -> Movie:
        """Assign a borrower unless the movie is already loaned elsewhere."""
        borrower = borrower.strip()
        if not borrower:
            raise ValueError("borrower must not be empty")

        def assign(catalog: Catalog) -> Movie:
            movie = catalog.get(number)
            if movie.borrower and movie.borrower != borrower:
                raise ValueError(
                    f"movie {number} is already checked out to {movie.borrower}"
                )
            values = movie.to_dict()
            values["borrower"] = borrower
            return catalog.replace(number, Movie.from_dict(values))

        return self._persist(assign)

    def check_out_many(self, numbers: Iterable[int], borrower: str) -> list[Movie]:
        """Assign one borrower to distinct movies in one atomic write."""
        borrower = borrower.strip()
        if not borrower:
            raise ValueError("borrower must not be empty")
        requested = self._movie_numbers(numbers)
        if not requested:
            return []

        def assign_all(catalog: Catalog) -> list[Movie]:
            updated = []
            for number in requested:
                movie = catalog.get(number)
                if movie.borrower and movie.borrower != borrower:
                    raise ValueError(
                        f"movie {number} is already checked out to {movie.borrower}"
                    )
                values = movie.to_dict()
                values["borrower"] = borrower
                updated.append(catalog.replace(number, Movie.from_dict(values)))
            return updated

        return self._persist(assign_all)

    def check_in(self, number: int) -> Movie:
        """Clear the current borrower for a loaned movie."""
        def clear(catalog: Catalog) -> Movie:
            movie = catalog.get(number)
            if not movie.borrower:
                raise ValueError(f"movie {number} is not checked out")
            values = movie.to_dict()
            values["borrower"] = ""
            return catalog.replace(number, Movie.from_dict(values))

        return self._persist(clear)

    def check_in_many(self, numbers: Iterable[int]) -> list[Movie]:
        """Clear borrowers from distinct loaned movies in one atomic write."""
        requested = self._movie_numbers(numbers)
        if not requested:
            return []

        def clear_all(catalog: Catalog) -> list[Movie]:
            updated = []
            for number in requested:
                movie = catalog.get(number)
                if not movie.borrower:
                    raise ValueError(f"movie {number} is not checked out")
                values = movie.to_dict()
                values["borrower"] = ""
                updated.append(catalog.replace(number, Movie.from_dict(values)))
            return updated

        return self._persist(clear_all)

    def set_checked(self, number: int, checked: bool) -> Movie:
        """Set the catalog-review flag for one movie atomically."""
        if not isinstance(checked, bool):
            raise TypeError("checked must be a boolean")

        def update(catalog: Catalog) -> Movie:
            movie = catalog.get(number)
            values = movie.to_dict()
            values["checked"] = checked
            return catalog.replace(number, Movie.from_dict(values))

        return self._persist(update)

    def set_checked_many(self, numbers: Iterable[int], checked: bool) -> list[Movie]:
        """Set the review flag for distinct movie numbers in one atomic write."""
        if not isinstance(checked, bool):
            raise TypeError("checked must be a boolean")
        requested = list(numbers)
        if any(
            isinstance(number, bool) or not isinstance(number, int)
            for number in requested
        ):
            raise TypeError("movie numbers must be integers")
        if len(set(requested)) != len(requested):
            raise ValueError("movie numbers must be unique")
        if not requested:
            return []

        def update_all(catalog: Catalog) -> list[Movie]:
            updated = []
            for number in requested:
                movie = catalog.get(number)
                values = movie.to_dict()
                values["checked"] = checked
                updated.append(catalog.replace(number, Movie.from_dict(values)))
            return updated

        return self._persist(update_all)

    @property
    def can_undo(self) -> bool:
        return bool(self._undo)

    @property
    def can_redo(self) -> bool:
        return bool(self._redo)

    def undo(self) -> None:
        """Atomically restore the catalog state before the last mutation."""
        if not self._undo:
            raise ValueError("nothing to undo")
        previous = self._clone(self._undo[-1])
        save(previous, self.path)
        self._undo.pop()
        self._redo.append(self._clone(self.catalog))
        del self._redo[:-_HISTORY_LIMIT]
        self.catalog = previous

    def redo(self) -> None:
        """Atomically reapply the most recently undone mutation."""
        if not self._redo:
            raise ValueError("nothing to redo")
        following = self._clone(self._redo[-1])
        save(following, self.path)
        self._redo.pop()
        self._undo.append(self._clone(self.catalog))
        del self._undo[:-_HISTORY_LIMIT]
        self.catalog = following

    def backup(self, destination: str | Path) -> None:
        """Copy the persisted catalog bytes to a validated backup."""
        copy_catalog(self.path, destination)

    def restore(self, source: str | Path) -> None:
        """Atomically restore persisted bytes, then publish the restored catalog."""
        copy_catalog(source, self.path)
        self.reload()

    @classmethod
    def restore_to(
        cls, source: str | Path, destination: str | Path
    ) -> CatalogService:
        """Restore a path that may currently be missing or unreadable."""
        copy_catalog(source, destination)
        return cls(destination)

    @classmethod
    def convert_to(
        cls, source: str | Path, destination: str | Path
    ) -> CatalogService:
        """Load an interchange catalog and atomically write internal JSON output."""
        catalog = load(source)
        save(catalog, destination)
        return cls(destination)

    def export(
        self,
        destination: str | Path,
        *,
        format: str,
        template: str | Path | None = None,
        row_template: str | Path | None = None,
    ) -> None:
        """Export the current catalog through an explicitly selected adapter."""
        exporters = {
            "xml": save_xml,
            "csv": save_csv,
            "amc": save_native,
        }
        if format == "html":
            save_html(
                self.catalog,
                destination,
                template=template,
                row_template=row_template,
            )
            return
        if template is not None or row_template is not None:
            raise ValueError("templates are only supported for HTML export")
        try:
            exporter = exporters[format]
        except KeyError as error:
            raise ValueError(f"unsupported export format: {format}") from error
        exporter(self.catalog, destination)

    def _persist(self, mutation: Callable[[Catalog], _Result]) -> _Result:
        """Save a mutation before publishing it as current application state."""
        previous = self._clone(self.catalog)
        candidate = self._clone(self.catalog)
        result = mutation(candidate)
        self.dirty = True
        try:
            save(candidate, self.path)
        except Exception:
            self.dirty = False
            raise
        self.catalog = candidate
        self._undo.append(previous)
        del self._undo[:-_HISTORY_LIMIT]
        self._redo.clear()
        self.dirty = False
        return result

    @staticmethod
    def _clone(catalog: Catalog) -> Catalog:
        return Catalog(
            (Movie.from_dict(movie.to_dict()) for movie in catalog),
            metadata=catalog.metadata,
        )

    def _clear_history(self) -> None:
        self._undo.clear()
        self._redo.clear()

    @staticmethod
    def _movie_numbers(numbers: Iterable[int]) -> list[int]:
        requested = list(numbers)
        if any(
            isinstance(number, bool) or not isinstance(number, int)
            for number in requested
        ):
            raise TypeError("movie numbers must be integers")
        if len(set(requested)) != len(requested):
            raise ValueError("movie numbers must be unique")
        return requested
