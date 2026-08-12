"""Portable movie-catalog library."""

from .catalog import Catalog
from .errors import CatalogError
from .inspection import CatalogInfo, inspect_catalog, validate_catalog
from .model import Movie
from .native import (
    NativeCatalog,
    NativeCatalogProperties,
    NativeCustomField,
    NativeExtra,
    NativeReadLimits,
    read_native_catalog,
    read_native_properties,
)

__all__ = [
    "Catalog",
    "CatalogError",
    "CatalogInfo",
    "Movie",
    "NativeCatalog",
    "NativeCatalogProperties",
    "NativeCustomField",
    "NativeExtra",
    "NativeReadLimits",
    "inspect_catalog",
    "read_native_catalog",
    "read_native_properties",
    "validate_catalog",
]
__version__ = "0.1.0"
