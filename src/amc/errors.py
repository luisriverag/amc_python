"""Stable public exceptions and diagnostics for catalog operations."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class Diagnostic:
    """A machine-readable validation or inspection result."""

    code: str
    message: str
    severity: str = "error"
    offset: int | None = None


class CatalogError(Exception):
    """Base class for expected, user-actionable failures."""

    code = "catalog_error"

    def __init__(self, message: str, *, offset: int | None = None) -> None:
        super().__init__(message)
        self.offset = offset


class UnsupportedFormatError(CatalogError):
    code = "unsupported_format"


class UnsupportedVersionError(CatalogError):
    code = "unsupported_version"


class CorruptCatalogError(CatalogError):
    code = "corrupt_catalog"


class ValidationError(CatalogError):
    code = "validation_error"


class ConflictError(CatalogError):
    code = "conflict"
