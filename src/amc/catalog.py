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

    def replace(self, number: int, movie: Movie) -> Movie:
        """Replace one movie while preserving its catalog number."""
        current = self.get(number)
        replacement = Movie.from_dict(movie.to_dict())
        replacement.number = number
        self._movies[self._movies.index(current)] = replacement
        return replacement

    def search(self, query: str) -> list[Movie]:
        needle = query.strip().casefold()
        if not needle:
            return list(self)
        searchable = (
            "title",
            "original_title",
            "translated_title",
            "director",
            "producer",
            "actors",
            "country",
            "category",
            "description",
            "comments",
            "languages",
        )
        return [
            movie
            for movie in self
            if any(needle in str(getattr(movie, key)).casefold() for key in searchable)
        ]

    def sort(self, field: str = "title", *, reverse: bool = False) -> None:
        if field not in Movie.__dataclass_fields__ or field == "extras":
            raise ValueError(f"unknown movie field: {field}")

        def key(item: Movie):
            value = getattr(item, field)
            return value.casefold() if isinstance(value, str) else value

        present = [movie for movie in self._movies if getattr(movie, field) is not None]
        missing = [movie for movie in self._movies if getattr(movie, field) is None]
        present.sort(key=key, reverse=reverse)
        self._movies = present + missing

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

    def duplicates(self) -> list[list[Movie]]:
        """Group movies with the same normalized title and year."""
        groups: dict[tuple[str, int | None], list[Movie]] = {}
        for movie in self:
            title = movie.display_title().strip().casefold()
            if title == "(untitled)":
                continue
            groups.setdefault((title, movie.year), []).append(movie)
        return [group for group in groups.values() if len(group) > 1]

    def merge(
        self,
        movies: Iterable[Movie],
        *,
        collision: str = "renumber",
        metadata: str = "error",
    ) -> int:
        """Merge movies using explicit number-collision and metadata policies."""
        if collision not in {"error", "skip", "replace", "renumber"}:
            raise ValueError(f"unknown movie collision policy: {collision}")
        if metadata not in {"error", "keep", "replace", "namespace"}:
            raise ValueError(f"unknown metadata merge policy: {metadata}")
        merged_metadata = _copy_metadata(self.metadata)
        if isinstance(movies, Catalog):
            incoming = _copy_metadata(movies.metadata)
            conflicts = [
                key
                for key, value in incoming.items()
                if key in self.metadata and self.metadata[key] != value
            ]
            if conflicts and metadata == "error":
                raise ValueError(f"conflicting catalog metadata: {conflicts[0]}")
            if metadata == "namespace":
                namespaces = merged_metadata.get("amc_python_merge_namespaces", {})
                if not isinstance(namespaces, dict):
                    raise ValueError(
                        "catalog metadata amc_python_merge_namespaces must be an object"
                    )
                namespaces = _copy_metadata(namespaces)
                suffix = 1
                while f"import_{suffix}" in namespaces:
                    suffix += 1
                namespaces[f"import_{suffix}"] = incoming
                merged_metadata["amc_python_merge_namespaces"] = namespaces
            elif metadata == "replace":
                merged_metadata.update(incoming)
            else:
                merged_metadata = {**incoming, **merged_metadata}

        incoming_movies = [Movie.from_dict(movie.to_dict()) for movie in movies]
        result = list(self._movies)
        used = {movie.number for movie in result}
        count = 0
        for movie in incoming_movies:
            duplicate = movie.number > 0 and movie.number in used
            if duplicate and collision == "error":
                raise ValueError(f"duplicate movie number: {movie.number}")
            if duplicate and collision == "skip":
                continue
            if duplicate and collision == "replace":
                result = [item for item in result if item.number != movie.number]
            elif movie.number <= 0 or duplicate:
                movie.number = max(used, default=0) + 1
            result.append(movie)
            used.add(movie.number)
            count += 1
        self._movies = result
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
