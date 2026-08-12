"""Portable movie-catalog library."""

from .catalog import Catalog
from .errors import CatalogError
from .inspection import CatalogInfo, inspect_catalog, validate_catalog
from .model import Movie

__all__ = ["Catalog", "CatalogError", "CatalogInfo", "Movie", "inspect_catalog", "validate_catalog"]
__version__ = "0.1.0"
