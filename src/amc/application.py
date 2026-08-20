"""Shared catalog application services for user-interface adapters."""

from __future__ import annotations

import base64
from collections.abc import Callable, Iterable
import io
import os
from pathlib import Path
from typing import TypeVar

from PIL import Image, UnidentifiedImageError

from .catalog import Catalog
from .loans import (
    LoanEvent,
    add_borrower,
    append_event,
    borrowers,
    export_legacy_history,
    history,
    remove_borrower,
)
from .model import Movie
from .native import NativeReadLimits, NativeWriteLimits
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
_MAX_PICTURE_BYTES = 64 * 1024 * 1024
_MAX_PICTURE_PIXELS = 40_000_000
_READ_ONLY_INTERCHANGE_SUFFIXES = {".amc", ".xml", ".csv"}


class CatalogService:
    """Own a catalog and persist mutations without exposing partial changes."""

    def __init__(self, path: str | Path, *, history_limit: int = _HISTORY_LIMIT) -> None:
        if (
            isinstance(history_limit, bool)
            or not isinstance(history_limit, int)
            or history_limit < 1
        ):
            raise ValueError("history_limit must be a positive integer")
        self.path = Path(path)
        self.catalog = load(self.path) if self.path.exists() else Catalog()
        self.dirty = False
        self.history_limit = history_limit
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
        self._require_working_format(candidate_path)
        save(self.catalog, candidate_path)
        self.path = candidate_path
        self.dirty = False

    def save(self) -> None:
        self._require_working_format(self.path)
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
        native_encoding: str = "cp1252",
        native_limits: NativeReadLimits | None = None,
    ) -> int:
        """Load and atomically merge an interchange catalog."""
        return self.merge(
            load(
                source,
                native_encoding=native_encoding,
                native_limits=native_limits,
            ),
            collision=collision,
            metadata=metadata,
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

    def check_out(
        self,
        number: int,
        borrower: str,
        *,
        include_media_label: bool = False,
        include_native_number: bool = False,
    ) -> Movie:
        """Assign a borrower unless the movie is already loaned elsewhere."""
        updated = self.check_out_many(
            [number], borrower, include_media_label=include_media_label,
            include_native_number=include_native_number,
        )
        return next(movie for movie in updated if movie.number == number)

    def check_out_many(
        self,
        numbers: Iterable[int],
        borrower: str,
        *,
        include_media_label: bool = False,
        include_native_number: bool = False,
    ) -> list[Movie]:
        """Assign one borrower to distinct movies in one atomic write."""
        borrower = borrower.strip()
        if not borrower:
            raise ValueError("borrower must not be empty")
        requested = self._movie_numbers(numbers)
        if not requested:
            return []

        def assign_all(catalog: Catalog) -> list[Movie]:
            expanded = self._expand_loan_groups(
                catalog,
                requested,
                include_media_label=include_media_label,
                include_native_number=include_native_number,
            )
            updated = []
            for number in expanded:
                movie = catalog.get(number)
                if movie.borrower and movie.borrower != borrower:
                    raise ValueError(
                        f"movie {number} is already checked out to {movie.borrower}"
                    )
                values = movie.to_dict()
                values["borrower"] = borrower
                replacement = catalog.replace(number, Movie.from_dict(values))
                if not movie.borrower:
                    append_event(
                        catalog, replacement, action="out", borrower=borrower
                    )
                updated.append(replacement)
            return updated

        return self._persist(assign_all)

    def check_in(
        self,
        number: int,
        *,
        include_media_label: bool = False,
        include_native_number: bool = False,
    ) -> Movie:
        """Clear the current borrower for a loaned movie."""
        updated = self.check_in_many(
            [number], include_media_label=include_media_label,
            include_native_number=include_native_number,
        )
        return next(movie for movie in updated if movie.number == number)

    def check_in_many(
        self,
        numbers: Iterable[int],
        *,
        include_media_label: bool = False,
        include_native_number: bool = False,
    ) -> list[Movie]:
        """Clear borrowers from distinct loaned movies in one atomic write."""
        requested = self._movie_numbers(numbers)
        if not requested:
            return []

        def clear_all(catalog: Catalog) -> list[Movie]:
            expanded = self._expand_loan_groups(
                catalog,
                requested,
                include_media_label=include_media_label,
                include_native_number=include_native_number,
            )
            updated = []
            for number in expanded:
                movie = catalog.get(number)
                if not movie.borrower:
                    raise ValueError(f"movie {number} is not checked out")
                values = movie.to_dict()
                values["borrower"] = ""
                replacement = catalog.replace(number, Movie.from_dict(values))
                append_event(
                    catalog, replacement, action="in", borrower=movie.borrower
                )
                updated.append(replacement)
            return updated

        return self._persist(clear_all)

    def loan_history(self) -> list[LoanEvent]:
        """Return validated loan events in chronological insertion order."""
        return history(self.catalog)

    def borrowers(self) -> list[str]:
        """Return managed borrowers plus names referenced by active loans."""
        return borrowers(self.catalog)

    def add_borrower(self, name: str) -> str:
        """Persist a managed borrower name."""
        return self._persist(lambda catalog: add_borrower(catalog, name))

    def remove_borrower(self, name: str) -> str:
        """Remove an unused managed borrower name."""
        return self._persist(lambda catalog: remove_borrower(catalog, name))

    def export_loan_history(
        self, destination: str | Path, *, catalog_name: str | None = None
    ) -> None:
        """Export retained events using the upstream tab-separated column layout."""
        export_legacy_history(
            self.catalog,
            destination,
            catalog_name=self.path.name if catalog_name is None else catalog_name,
        )

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

    def set_picture(
        self,
        number: int,
        source: str | Path,
        *,
        embed: bool = False,
        max_bytes: int = _MAX_PICTURE_BYTES,
        max_pixels: int = _MAX_PICTURE_PIXELS,
        crop: tuple[int, int, int, int] | None = None,
    ) -> Movie:
        """Link or embed a movie picture in one atomic catalog mutation."""
        updated = self.set_picture_many(
            {number: source},
            embed=embed,
            max_bytes=max_bytes,
            max_pixels=max_pixels,
            crop=crop,
        )
        return updated[0]

    def set_picture_many(
        self,
        assignments: dict[int, str | Path] | Iterable[tuple[int, str | Path]],
        *,
        embed: bool = False,
        max_bytes: int = _MAX_PICTURE_BYTES,
        max_pixels: int = _MAX_PICTURE_PIXELS,
        crop: tuple[int, int, int, int] | None = None,
        crops: dict[int, tuple[int, int, int, int]] | None = None,
    ) -> list[Movie]:
        """Link or embed pictures for distinct movies in one atomic write.

        Every movie shares the same *embed*, *max_bytes*, and *max_pixels*
        settings; each movie number has its own picture source. *crop* is
        applied to every embedded picture unless a movie number has its own
        entry in *crops*, which takes precedence for that movie only.
        """
        pairs = list(assignments.items() if isinstance(assignments, dict) else assignments)
        requested = self._movie_numbers(number for number, _ in pairs)
        if isinstance(max_bytes, bool) or not isinstance(max_bytes, int) or max_bytes < 0:
            raise ValueError("max_bytes must be a non-negative integer")
        if isinstance(max_pixels, bool) or not isinstance(max_pixels, int) or max_pixels < 1:
            raise ValueError("max_pixels must be a positive integer")
        crops = dict(crops) if crops else {}
        unknown_crop_numbers = sorted(set(crops) - set(requested))
        if unknown_crop_numbers:
            raise ValueError(
                f"crops references movie numbers not in assignments: "
                f"{unknown_crop_numbers}"
            )
        if not embed and (crop is not None or crops):
            raise ValueError("crop is only supported for embedded pictures")
        if not requested:
            return []

        prepared: dict[int, tuple[Path, str]] = {}
        for number, source in pairs:
            source_path = Path(source)
            encoded = ""
            if embed:
                movie_crop = crops.get(number, crop)
                size = source_path.stat().st_size
                if size > max_bytes:
                    raise ValueError(
                        f"picture exceeds size limit for movie {number}: "
                        f"{size} > {max_bytes}"
                    )
                data = source_path.read_bytes()
                if len(data) > max_bytes:
                    raise ValueError(
                        f"picture exceeds size limit for movie {number}: "
                        f"{len(data)} > {max_bytes}"
                    )
                data = self._prepare_picture(data, max_pixels=max_pixels, crop=movie_crop)
                if len(data) > max_bytes:
                    raise ValueError(
                        f"cropped picture exceeds size limit for movie {number}: "
                        f"{len(data)} > {max_bytes}"
                    )
                encoded = base64.b64encode(data).decode("ascii")
            prepared[number] = (source_path, encoded)

        def update_all(catalog: Catalog) -> list[Movie]:
            updated = []
            for number in requested:
                source_path, encoded = prepared[number]
                movie = catalog.get(number)
                values = movie.to_dict()
                values["picture"] = source_path.name if embed else str(source_path)
                extras = dict(values["extras"])
                if embed:
                    extras["native_picture_base64"] = encoded
                else:
                    extras.pop("native_picture_base64", None)
                values["extras"] = extras
                updated.append(catalog.replace(number, Movie.from_dict(values)))
            return updated

        return self._persist(update_all)

    def clear_picture(self, number: int) -> Movie:
        """Remove both linked and embedded picture state atomically."""
        updated = self.clear_picture_many([number])
        return updated[0]

    def clear_picture_many(self, numbers: Iterable[int]) -> list[Movie]:
        """Remove linked and embedded picture state from distinct movies
        in one atomic write."""
        requested = self._movie_numbers(numbers)
        if not requested:
            return []

        def clear_all(catalog: Catalog) -> list[Movie]:
            updated = []
            for number in requested:
                movie = catalog.get(number)
                values = movie.to_dict()
                values["picture"] = ""
                extras = dict(values["extras"])
                extras.pop("native_picture_base64", None)
                values["extras"] = extras
                updated.append(catalog.replace(number, Movie.from_dict(values)))
            return updated

        return self._persist(clear_all)

    def export_picture(self, number: int, destination: str | Path) -> None:
        """Atomically copy an embedded or linked picture to *destination*."""
        movie = self.catalog.get(number)
        encoded = movie.extras.get("native_picture_base64", "")
        if encoded:
            if not isinstance(encoded, str):
                raise TypeError("embedded picture must be a base64 string")
            try:
                data = base64.b64decode(encoded, validate=True)
            except ValueError as error:
                raise ValueError("embedded picture is not valid base64") from error
        else:
            if not movie.picture:
                raise ValueError(f"movie {number} has no picture")
            source = Path(movie.picture)
            if not source.is_absolute():
                source = self.path.parent / source
            data = source.read_bytes()
        destination = Path(destination)
        destination.parent.mkdir(parents=True, exist_ok=True)
        temporary = destination.with_name(f".{destination.name}.tmp")
        try:
            with temporary.open("wb") as stream:
                stream.write(data)
                stream.flush()
                os.fsync(stream.fileno())
            temporary.replace(destination)
        finally:
            temporary.unlink(missing_ok=True)

    @staticmethod
    def _prepare_picture(
        data: bytes,
        *,
        max_pixels: int,
        crop: tuple[int, int, int, int] | None,
    ) -> bytes:
        """Validate an image and optionally return a safely cropped encoding."""
        try:
            with Image.open(io.BytesIO(data)) as image:
                width, height = image.size
                if width < 1 or height < 1 or width * height > max_pixels:
                    raise ValueError(
                        f"picture exceeds pixel limit: {width}x{height} > {max_pixels}"
                    )
                if crop is not None:
                    if (
                        len(crop) != 4
                        or any(isinstance(value, bool) or not isinstance(value, int) for value in crop)
                    ):
                        raise TypeError("crop must contain four integers")
                    left, top, crop_width, crop_height = crop
                    if left < 0 or top < 0 or crop_width < 1 or crop_height < 1:
                        raise ValueError("crop coordinates must define a positive rectangle")
                    if left + crop_width > width or top + crop_height > height:
                        raise ValueError("crop rectangle exceeds picture bounds")
                    output = io.BytesIO()
                    cropped = image.crop(
                        (left, top, left + crop_width, top + crop_height)
                    )
                    cropped.save(output, format=image.format or "PNG")
                    return output.getvalue()
                image.verify()
                return data
        except (OSError, UnidentifiedImageError, Image.DecompressionBombError) as error:
            raise ValueError(f"picture is not a supported image: {error}") from error

    @property
    def can_undo(self) -> bool:
        return bool(self._undo)

    @property
    def can_redo(self) -> bool:
        return bool(self._redo)

    @property
    def is_writable(self) -> bool:
        """Return whether the active path is an internal, mutable catalog."""
        return self.path.suffix.casefold() not in _READ_ONLY_INTERCHANGE_SUFFIXES

    def undo(self) -> None:
        """Atomically restore the catalog state before the last mutation."""
        if not self._undo:
            raise ValueError("nothing to undo")
        self._require_working_format(self.path)
        previous = self._clone(self._undo[-1])
        save(previous, self.path)
        self._undo.pop()
        self._redo.append(self._clone(self.catalog))
        del self._redo[:-self.history_limit]
        self.catalog = previous

    def redo(self) -> None:
        """Atomically reapply the most recently undone mutation."""
        if not self._redo:
            raise ValueError("nothing to redo")
        self._require_working_format(self.path)
        following = self._clone(self._redo[-1])
        save(following, self.path)
        self._redo.pop()
        self._undo.append(self._clone(self.catalog))
        del self._undo[:-self.history_limit]
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
        native_encoding: str = "cp1252",
        native_limits: NativeWriteLimits | None = None,
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
        if format == "amc":
            if template is not None or row_template is not None:
                raise ValueError("templates are only supported for HTML export")
            save_native(
                self.catalog,
                destination,
                encoding=native_encoding,
                limits=native_limits,
            )
            return
        if native_encoding != "cp1252" or native_limits is not None:
            raise ValueError("native export options are only supported for AMC export")
        if template is not None or row_template is not None:
            raise ValueError("templates are only supported for HTML export")
        try:
            exporter = exporters[format]
        except KeyError as error:
            raise ValueError(f"unsupported export format: {format}") from error
        exporter(self.catalog, destination)

    def _persist(self, mutation: Callable[[Catalog], _Result]) -> _Result:
        """Save a mutation before publishing it as current application state."""
        self._require_working_format(self.path)
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
        del self._undo[:-self.history_limit]
        self._redo.clear()
        self.dirty = False
        return result

    @staticmethod
    def _require_working_format(path: Path) -> None:
        """Prevent JSON persistence from overwriting an interchange-format file."""
        if path.suffix.casefold() in _READ_ONLY_INTERCHANGE_SUFFIXES:
            raise ValueError(
                f"{path.suffix or 'interchange'} catalogs are read-only; save as an "
                "AMC Python JSON catalog before editing"
            )

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

    @staticmethod
    def _expand_loan_groups(
        catalog: Catalog,
        numbers: list[int],
        *,
        include_media_label: bool,
        include_native_number: bool,
    ) -> list[int]:
        """Expand selected movies to requested source-derived loan groups."""
        if not isinstance(include_media_label, bool):
            raise TypeError("include_media_label must be a boolean")
        if not isinstance(include_native_number, bool):
            raise TypeError("include_native_number must be a boolean")
        selected = [catalog.get(number) for number in numbers]
        if not include_media_label and not include_native_number:
            return numbers
        labels = {movie.media_label.casefold() for movie in selected if movie.media_label}
        native_numbers = {
            movie.extras.get("native_movie_number", movie.number)
            for movie in selected
        }
        expanded = set(numbers)
        expanded.update(
            movie.number
            for movie in catalog
            if (
                include_media_label
                and movie.media_label
                and movie.media_label.casefold() in labels
            ) or (
                include_native_number
                and movie.extras.get("native_movie_number", movie.number)
                in native_numbers
            )
        )
        return [movie.number for movie in catalog if movie.number in expanded]
