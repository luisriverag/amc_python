"""Hand-written, provider-scoped IMDb metadata lookup via the OMDb API.

This is not a port of AMC's IFPS-scripted "Get Info"/"Update" workflow.
`docs/PORT_AUDIT.md` findings 29-31 decided against porting IFPS script
*execution* (a bytecode compiler plus a sandboxed VM, with real security
exposure from running arbitrary third-party scripts sourced from the web)
in favor of a small number of hand-written, auditable Python providers for
the specific cases named as most used: IMDb lookups and refreshing already-
catalogued movies ("update scripts"). This module is exactly that for IMDb,
via the OMDb API (https://www.omdbapi.com/) — a REST API that legally
re-serves a curated subset of IMDb's own data as JSON under its own terms.
Scraping imdb.com directly was considered and rejected: it is against
IMDb's Terms of Service and fragile to markup changes.

Every network call requires an explicit, caller-supplied API key (never
hardcoded, never persisted by this module — obtain one at
https://www.omdbapi.com/apikey.aspx) and a bounded timeout. Nothing here
runs a real HTTP request during the normal test suite: `fetch_omdb_record`
takes an injectable `opener`, and `tests/test_omdb.py` always supplies a
fake one instead of reaching the network, matching this project's existing
"live network tests must be opt-in" rule for any future provider.
"""

from __future__ import annotations

import json
import re
import urllib.error
import urllib.request
from collections.abc import Callable
from urllib.parse import urlencode

from .model import Movie
from .scripts import ScriptFieldChange, ScriptMergePreview

DEFAULT_OMDB_URL = "https://www.omdbapi.com/"
DEFAULT_TIMEOUT = 10.0
_IMDB_ID_RE = re.compile(r"tt\d{7,}")
_LEADING_INT_RE = re.compile(r"\d+")

Opener = Callable[[str, float], bytes]


class OmdbLookupError(ValueError):
    """The OMDb API responded, but with an error or an unusable payload."""


def imdb_id_from_url(url: str) -> str:
    """Extract an IMDb title ID (``ttNNNNNNN``) from a URL, or "" if none."""
    match = _IMDB_ID_RE.search(url)
    return match.group(0) if match else ""


def _default_opener(url: str, timeout: float) -> bytes:
    with urllib.request.urlopen(url, timeout=timeout) as response:  # noqa: S310
        return response.read()


def fetch_omdb_record(
    *,
    api_key: str,
    imdb_id: str = "",
    title: str = "",
    year: int | None = None,
    base_url: str = DEFAULT_OMDB_URL,
    timeout: float = DEFAULT_TIMEOUT,
    opener: Opener | None = None,
) -> dict[str, object]:
    """Fetch one movie's raw OMDb JSON record by IMDb ID or title/year.

    Exactly one of *imdb_id* or *title* is the lookup key, matching OMDb's
    own `i=`/`t=` query parameters; *year* narrows a title search the way
    OMDb's own `y=` parameter does and is ignored for an ID lookup.
    """
    if not api_key:
        raise ValueError("an OMDb API key is required")
    if not imdb_id and not title:
        raise ValueError("either imdb_id or title is required")
    if timeout <= 0:
        raise ValueError("timeout must be positive")
    params: dict[str, str] = {"apikey": api_key, "type": "movie", "plot": "full"}
    if imdb_id:
        params["i"] = imdb_id
    else:
        params["t"] = title
        if year is not None:
            params["y"] = str(year)
    url = f"{base_url}?{urlencode(params)}"
    fetch = opener or _default_opener
    try:
        body = fetch(url, timeout)
    except (urllib.error.URLError, TimeoutError, OSError) as error:
        raise OSError(f"OMDb request failed: {error}") from error
    try:
        data = json.loads(body)
    except json.JSONDecodeError as error:
        raise OmdbLookupError(f"OMDb returned invalid JSON: {error}") from error
    if not isinstance(data, dict):
        raise OmdbLookupError("OMDb response was not a JSON object")
    if data.get("Response") != "True":
        raise OmdbLookupError(str(data.get("Error", "OMDb lookup failed")))
    return data


def _text(record: dict[str, object], key: str) -> str:
    value = record.get(key, "")
    if not isinstance(value, str) or value == "N/A":
        return ""
    return value


def _leading_int(value: str) -> int | None:
    match = _LEADING_INT_RE.search(value)
    return int(match.group(0)) if match else None


def _rating(value: str) -> float | None:
    try:
        return float(value)
    except ValueError:
        return None


def movie_fields_from_omdb(record: dict[str, object]) -> dict[str, object]:
    """Map an OMDb JSON record onto AMC Python `Movie` fields.

    Only fields with a matching `Movie` field and a usable (non-"N/A")
    OMDb value are included. Deliberately excluded, and not silently
    dropped without a reason: `Poster` (image download is a separate,
    unimplemented capability — see `IMPLEMENTATION_PLAN.md` Milestone 6),
    and `Ratings`/`Metascore`/`BoxOffice`/`Awards`/`Production`/`Website`/
    `DVD` (no matching `Movie` field to receive them).
    """
    fields: dict[str, object] = {}
    for omdb_key, movie_field in (
        ("Title", "title"),
        ("Director", "director"),
        ("Writer", "writer"),
        ("Actors", "actors"),
        ("Plot", "description"),
        ("Genre", "category"),
        ("Country", "country"),
        ("Language", "languages"),
        ("Rated", "certification"),
    ):
        value = _text(record, omdb_key)
        if value:
            fields[movie_field] = value
    year = _leading_int(_text(record, "Year"))
    if year is not None:
        fields["year"] = year
    length = _leading_int(_text(record, "Runtime"))
    if length is not None:
        fields["length"] = length
    rating = _rating(_text(record, "imdbRating"))
    if rating is not None:
        fields["rating"] = rating
    imdb_id = _text(record, "imdbID")
    if imdb_id:
        fields["url"] = f"https://www.imdb.com/title/{imdb_id}/"
    return fields


def preview_omdb_update(movie: Movie, record: dict[str, object]) -> ScriptMergePreview:
    """Build an isolated, unmutated preview of what an OMDb record would
    change on *movie*.

    Reuses `amc.scripts`' `ScriptFieldChange`/`ScriptMergePreview` shape —
    an OMDb lookup is a second, differently-sourced provider of the exact
    same "isolated candidate, then apply only if the caller accepts it"
    contract those already give legacy-script results, not a reason to
    invent a second shape for the same idea. Unlike `preview_script_merge`,
    there is no untrusted-script permission model to enforce here: the
    field mapping is first-party code (`movie_fields_from_omdb`), not a
    declared-permissions external script result.
    """
    fields = movie_fields_from_omdb(record)
    candidate = movie.to_dict()
    changes: list[ScriptFieldChange] = []
    for name, value in fields.items():
        before = candidate[name]
        if before != value:
            candidate[name] = value
            changes.append(ScriptFieldChange(name, before, value))
    return ScriptMergePreview(Movie.from_dict(candidate), tuple(changes))
