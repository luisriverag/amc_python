"""Format-neutral loan history retained in catalog metadata."""

from __future__ import annotations

from dataclasses import asdict, dataclass
from datetime import datetime, timezone
import os
from pathlib import Path
from typing import Literal

from .catalog import Catalog
from .model import Movie
from .native import replace_and_sync_directory

METADATA_KEY = "amc_python_loan_history"
BORROWERS_KEY = "amc_python_borrowers"
LEGACY_HEADER = "Date & Time\tCatalog\tIn/Out\tMovie Number\tMovieLabel\tMovie Title\tBorrower Name"


@dataclass(frozen=True, slots=True)
class LoanEvent:
    """One immutable check-out or check-in event."""

    timestamp: str
    action: Literal["out", "in"]
    movie_number: int
    media_label: str
    title: str
    borrower: str

    def to_dict(self) -> dict[str, str | int]:
        return asdict(self)

    @classmethod
    def from_dict(cls, value: object) -> "LoanEvent":
        if not isinstance(value, dict):
            raise TypeError("loan history entries must be objects")
        expected = {"timestamp", "action", "movie_number", "media_label", "title", "borrower"}
        if set(value) != expected:
            raise ValueError("loan history entry has missing or unknown fields")
        event = cls(
            timestamp=value["timestamp"],
            action=value["action"],
            movie_number=value["movie_number"],
            media_label=value["media_label"],
            title=value["title"],
            borrower=value["borrower"],
        )
        event.validate()
        return event

    def validate(self) -> None:
        if not isinstance(self.timestamp, str):
            raise TypeError("loan history timestamp must be a string")
        try:
            parsed = datetime.fromisoformat(self.timestamp)
        except ValueError as error:
            raise ValueError("loan history timestamp must be ISO 8601") from error
        if parsed.tzinfo is None:
            raise ValueError("loan history timestamp must include a timezone")
        if self.action not in {"out", "in"}:
            raise ValueError("loan history action must be 'out' or 'in'")
        if isinstance(self.movie_number, bool) or not isinstance(self.movie_number, int):
            raise TypeError("loan history movie number must be an integer")
        if self.movie_number < 0:
            raise ValueError("loan history movie number cannot be negative")
        for name in ("media_label", "title", "borrower"):
            if not isinstance(getattr(self, name), str):
                raise TypeError(f"loan history {name.replace('_', ' ')} must be a string")
        if not self.borrower:
            raise ValueError("loan history borrower must not be empty")


def history(catalog: Catalog) -> list[LoanEvent]:
    """Decode and validate the catalog's chronological loan history."""
    values = catalog.metadata.get(METADATA_KEY, [])
    if not isinstance(values, list):
        raise TypeError("catalog loan history must be an array")
    return [LoanEvent.from_dict(value) for value in values]


def borrowers(catalog: Catalog) -> list[str]:
    """Return managed and currently active borrowers, case-insensitively unique."""
    managed = catalog.metadata.get(BORROWERS_KEY, [])
    if not isinstance(managed, list):
        raise TypeError("catalog borrowers must be an array")
    result: list[str] = []
    seen: set[str] = set()
    for value in [*managed, *(movie.borrower for movie in catalog if movie.borrower)]:
        if not isinstance(value, str):
            raise TypeError("catalog borrower names must be strings")
        name = value.strip()
        if not name:
            raise ValueError("catalog borrower names must not be empty")
        folded = name.casefold()
        if folded not in seen:
            seen.add(folded)
            result.append(name)
    return result


def add_borrower(catalog: Catalog, name: str) -> str:
    """Add a persistent borrower name, rejecting case-insensitive duplicates."""
    if not isinstance(name, str):
        raise TypeError("borrower must be a string")
    name = name.strip()
    if not name:
        raise ValueError("borrower must not be empty")
    existing = borrowers(catalog)
    if any(item.casefold() == name.casefold() for item in existing):
        raise ValueError(f"borrower already exists: {name}")
    managed = catalog.metadata.get(BORROWERS_KEY, [])
    if not isinstance(managed, list):
        raise TypeError("catalog borrowers must be an array")
    catalog.metadata[BORROWERS_KEY] = [*managed, name]
    return name


def remove_borrower(catalog: Catalog, name: str) -> str:
    """Remove a managed borrower name when it has no active loans."""
    if not isinstance(name, str):
        raise TypeError("borrower must be a string")
    name = name.strip()
    if not name:
        raise ValueError("borrower must not be empty")
    managed = catalog.metadata.get(BORROWERS_KEY, [])
    borrowers(catalog)  # validate metadata before changing it
    if not isinstance(managed, list):
        raise TypeError("catalog borrowers must be an array")
    match = next((item for item in managed if item.casefold() == name.casefold()), None)
    if match is None:
        raise KeyError(f"borrower does not exist: {name}")
    if any(movie.borrower.casefold() == name.casefold() for movie in catalog):
        raise ValueError(f"borrower still has checked-out movies: {match}")
    catalog.metadata[BORROWERS_KEY] = [item for item in managed if item != match]
    return match


def export_legacy_history(catalog: Catalog, destination: str | Path, *, catalog_name: str) -> None:
    """Atomically export the tab-separated layout written by upstream AMC."""
    if not isinstance(catalog_name, str):
        raise TypeError("catalog name must be a string")
    _validate_legacy_cell(catalog_name, "catalog name")
    rows = [LEGACY_HEADER]
    for event in history(catalog):
        timestamp = datetime.fromisoformat(event.timestamp).astimezone()
        values = (
            timestamp.strftime("%Y/%m/%d %H:%M:%S"),
            catalog_name,
            "Out" if event.action == "out" else "In",
            str(event.movie_number),
            event.media_label,
            event.title,
            event.borrower,
        )
        for value in values:
            _validate_legacy_cell(value, "loan history value")
        rows.append("\t".join(values))
    path = Path(destination)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    try:
        with temporary.open("w", encoding="utf-8", newline="") as stream:
            stream.write("\r\n".join(rows) + "\r\n")
            stream.flush()
            os.fsync(stream.fileno())
        replace_and_sync_directory(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)


def _validate_legacy_cell(value: str, label: str) -> None:
    if any(character in value for character in "\t\r\n"):
        raise ValueError(f"{label} cannot contain tabs or line breaks")


def append_event(
    catalog: Catalog,
    movie: Movie,
    *,
    action: Literal["out", "in"],
    borrower: str,
    timestamp: datetime | None = None,
) -> LoanEvent:
    """Append an event after validating all existing history entries."""
    moment = timestamp or datetime.now(timezone.utc)
    if not isinstance(moment, datetime):
        raise TypeError("loan history timestamp must be a datetime")
    if moment.tzinfo is None:
        raise ValueError("loan history timestamp must include a timezone")
    event = LoanEvent(
        timestamp=moment.isoformat(),
        action=action,
        movie_number=movie.number,
        media_label=movie.media_label,
        title=movie.display_title(),
        borrower=borrower,
    )
    event.validate()
    events = history(catalog)
    events.append(event)
    catalog.metadata[METADATA_KEY] = [item.to_dict() for item in events]
    return event
