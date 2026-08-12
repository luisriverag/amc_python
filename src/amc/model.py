"""Domain objects used by the catalog."""

from __future__ import annotations

import math
from dataclasses import asdict, dataclass, field, fields
from typing import Any


_STRING_FIELDS = {
    "title", "original_title", "translated_title", "director", "producer",
    "country", "category", "date", "borrower", "media_label", "media_type",
    "source", "languages", "subtitles", "video_format", "audio_format",
    "resolution", "url", "description", "comments", "actors", "picture",
}
_OPTIONAL_INTEGER_FIELDS = {
    "year", "length", "media_count", "video_bitrate", "audio_bitrate", "file_size",
}
_OPTIONAL_NUMBER_FIELDS = {"rating", "framerate"}


@dataclass(slots=True)
class Movie:
    """A movie and the most commonly used Ant Movie Catalog fields."""

    number: int = 0
    title: str = ""
    original_title: str = ""
    translated_title: str = ""
    director: str = ""
    producer: str = ""
    country: str = ""
    category: str = ""
    year: int | None = None
    length: int | None = None
    rating: float | None = None
    date: str = ""
    borrower: str = ""
    media_label: str = ""
    media_type: str = ""
    media_count: int | None = None
    source: str = ""
    languages: str = ""
    subtitles: str = ""
    video_format: str = ""
    video_bitrate: int | None = None
    audio_format: str = ""
    audio_bitrate: int | None = None
    resolution: str = ""
    framerate: float | None = None
    file_size: int | None = None
    url: str = ""
    description: str = ""
    comments: str = ""
    actors: str = ""
    checked: bool = False
    picture: str = ""
    extras: dict[str, Any] = field(default_factory=dict)

    def __post_init__(self) -> None:
        """Reject ambiguous values regardless of how the movie was constructed."""
        if isinstance(self.number, bool) or not isinstance(self.number, int):
            raise TypeError("movie number must be an integer")
        if self.number < 0:
            raise ValueError("movie number cannot be negative")
        for name in _STRING_FIELDS:
            if not isinstance(getattr(self, name), str):
                raise TypeError(f"{name} must be a string")
        for name in _OPTIONAL_INTEGER_FIELDS:
            value = getattr(self, name)
            if value is not None and (isinstance(value, bool) or not isinstance(value, int)):
                raise TypeError(f"{name} must be an integer or null")
        for name in _OPTIONAL_NUMBER_FIELDS:
            value = getattr(self, name)
            if value is not None and (
                isinstance(value, bool)
                or not isinstance(value, (int, float))
                or not math.isfinite(value)
            ):
                raise TypeError(f"{name} must be a finite number or null")
        if not isinstance(self.checked, bool):
            raise TypeError("checked must be a boolean")
        if not isinstance(self.extras, dict):
            raise TypeError("movie extras must be an object")
        self.extras = dict(self.extras)
        if self.rating is not None and not 0 <= self.rating <= 10:
            raise ValueError("rating must be between 0 and 10")

    def display_title(self) -> str:
        return self.title or self.translated_title or self.original_title or "(untitled)"

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)

    @classmethod
    def from_dict(cls, value: dict[str, Any]) -> "Movie":
        if not isinstance(value, dict):
            raise TypeError("movie data must be an object")
        known = {item.name for item in fields(cls)}
        data = {key: val for key, val in value.items() if key in known}
        raw_extras = data.get("extras")
        if raw_extras is not None and not isinstance(raw_extras, dict):
            raise TypeError("movie extras must be an object")
        extras = dict(raw_extras or {})
        extras.update({key: val for key, val in value.items() if key not in known})
        data["extras"] = extras
        return cls(**data)
