"""Catalog operations independent from the user interface and file format."""

from __future__ import annotations

from collections.abc import Iterable, Iterator
import json

from .model import Movie


class Catalog:
    def __init__(
        self, movies: Iterable[Movie] = (), *, metadata: dict[str, object] | None = None
    ) -> None:
        self._movies: list[Movie] = []
        self.metadata = _copy_metadata(metadata)
        for movie in movies:
            self.add(movie, renumber=False)

    def __iter__(self) -> Iterator[Movie]:
        return iter(self._movies)

    def __len__(self) -> int:
        return len(self._movies)

    def add(self, movie: Movie, *, renumber: bool = True) -> Movie:
        used = {item.number for item in self._movies}
        if renumber or movie.number <= 0 or movie.number in used:
            movie.number = max(used, default=0) + 1
        self._movies.append(movie)
        return movie

    def remove(self, number: int) -> Movie:
        movie = self.get(number)
        self._movies.remove(movie)
        return movie

    def get(self, number: int) -> Movie:
        for movie in self._movies:
            if movie.number == number:
                return movie
        raise KeyError(f"movie {number} does not exist")

    def search(self, query: str) -> list[Movie]:
        needle = query.strip().casefold()
        if not needle:
            return list(self)
        searchable = (
            "title", "original_title", "translated_title", "director", "producer",
            "actors", "country", "category", "description", "comments", "languages",
        )
        return [movie for movie in self if any(needle in str(getattr(movie, key)).casefold() for key in searchable)]

    def sort(self, field: str = "title", *, reverse: bool = False) -> None:
        if field not in Movie.__dataclass_fields__ or field == "extras":
            raise ValueError(f"unknown movie field: {field}")
        def key(item: Movie):
            value = getattr(item, field)
            return (value is None, value.casefold() if isinstance(value, str) else value)

        self._movies.sort(key=key, reverse=reverse)

    def renumber(self, start: int = 1) -> None:
        """Assign consecutive numbers while preserving the current order."""
        if start < 1:
            raise ValueError("starting number must be positive")
        for number, movie in enumerate(self._movies, start=start):
            movie.number = number

    def statistics(self) -> dict[str, int | float | None]:
        """Return useful aggregate values for the catalog."""
        ratings = [movie.rating for movie in self if movie.rating is not None]
        years = [movie.year for movie in self if movie.year is not None]
        return {
            "movies": len(self),
            "checked": sum(movie.checked for movie in self),
            "total_length": sum(movie.length or 0 for movie in self),
            "average_rating": sum(ratings) / len(ratings) if ratings else None,
            "earliest_year": min(years) if years else None,
            "latest_year": max(years) if years else None,
        }

    def merge(self, movies: Iterable[Movie]) -> int:
        """Append movies and retain metadata when merging another catalog."""
        merged_metadata = self.metadata
        if isinstance(movies, Catalog):
            incoming = _copy_metadata(movies.metadata)
            conflicts = [
                key for key, value in incoming.items()
                if key in self.metadata and self.metadata[key] != value
            ]
            if conflicts:
                raise ValueError(f"conflicting catalog metadata: {conflicts[0]}")
            merged_metadata = {**self.metadata, **incoming}
        count = 0
        for movie in movies:
            self.add(movie, renumber=movie.number <= 0 or any(item.number == movie.number for item in self))
            count += 1
        self.metadata = merged_metadata
        return count


def _copy_metadata(metadata: dict[str, object] | None) -> dict[str, object]:
    """Validate JSON-compatible catalog metadata and return an isolated deep copy."""
    if metadata is None:
        return {}
    if not isinstance(metadata, dict):
        raise TypeError("catalog metadata must be an object")
    if any(not isinstance(key, str) for key in metadata):
        raise TypeError("catalog metadata keys must be strings")
    try:
        encoded = json.dumps(metadata, ensure_ascii=False, allow_nan=False)
    except (TypeError, ValueError) as error:
        raise TypeError(f"catalog metadata must be JSON-compatible: {error}") from error
    return json.loads(encoded)
