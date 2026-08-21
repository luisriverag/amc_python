import json

import pytest

from amc.model import Movie
from amc.omdb import (
    OmdbLookupError,
    fetch_omdb_record,
    imdb_id_from_url,
    movie_fields_from_omdb,
    preview_omdb_update,
)

_RECORD = {
    "Title": "Alien",
    "Year": "1979",
    "Rated": "R",
    "Released": "25 Jun 1979",
    "Runtime": "117 min",
    "Genre": "Horror, Sci-Fi",
    "Director": "Ridley Scott",
    "Writer": "Dan O'Bannon",
    "Actors": "Sigourney Weaver, Tom Skerritt",
    "Plot": "The crew of a spaceship encounter a deadly lifeform.",
    "Language": "English",
    "Country": "United States, United Kingdom",
    "Awards": "Won 1 Oscar",
    "Poster": "https://example.com/poster.jpg",
    "Metascore": "89",
    "imdbRating": "8.5",
    "imdbVotes": "900,000",
    "imdbID": "tt0078748",
    "Type": "movie",
    "DVD": "N/A",
    "BoxOffice": "$78,900,000",
    "Production": "N/A",
    "Website": "N/A",
    "Response": "True",
}


def _opener(body: bytes, *, error: Exception | None = None):
    def opener(url: str, timeout: float) -> bytes:
        if error is not None:
            raise error
        return body

    return opener


def test_fetch_omdb_record_returns_the_parsed_json_on_success():
    record = fetch_omdb_record(
        api_key="key", imdb_id="tt0078748",
        opener=_opener(json.dumps(_RECORD).encode()),
    )
    assert record["imdbID"] == "tt0078748"


def test_fetch_omdb_record_requires_an_api_key():
    with pytest.raises(ValueError, match="API key is required"):
        fetch_omdb_record(api_key="", title="Alien", opener=_opener(b"{}"))


def test_fetch_omdb_record_requires_an_imdb_id_or_title():
    with pytest.raises(ValueError, match="imdb_id or title is required"):
        fetch_omdb_record(api_key="key", opener=_opener(b"{}"))


def test_fetch_omdb_record_rejects_a_non_positive_timeout():
    with pytest.raises(ValueError, match="timeout must be positive"):
        fetch_omdb_record(
            api_key="key", title="Alien", timeout=0, opener=_opener(b"{}")
        )


def test_fetch_omdb_record_wraps_a_transport_failure_as_oserror():
    def failing_opener(url: str, timeout: float) -> bytes:
        raise TimeoutError("timed out")

    with pytest.raises(OSError, match="OMDb request failed"):
        fetch_omdb_record(api_key="key", title="Alien", opener=failing_opener)


def test_fetch_omdb_record_rejects_invalid_json():
    with pytest.raises(OmdbLookupError, match="invalid JSON"):
        fetch_omdb_record(api_key="key", title="Alien", opener=_opener(b"not json"))


def test_fetch_omdb_record_rejects_a_non_object_response():
    with pytest.raises(OmdbLookupError, match="not a JSON object"):
        fetch_omdb_record(
            api_key="key", title="Alien", opener=_opener(json.dumps([1, 2]).encode())
        )


def test_fetch_omdb_record_surfaces_the_omdb_error_message():
    body = json.dumps({"Response": "False", "Error": "Movie not found!"}).encode()
    with pytest.raises(OmdbLookupError, match="Movie not found!"):
        fetch_omdb_record(api_key="key", title="Not A Real Movie", opener=_opener(body))


def test_imdb_id_from_url_extracts_the_title_id():
    assert imdb_id_from_url("https://www.imdb.com/title/tt0078748/") == "tt0078748"
    assert imdb_id_from_url("https://example.com/no-id-here") == ""


def test_movie_fields_from_omdb_maps_every_matching_field():
    fields = movie_fields_from_omdb(_RECORD)
    assert fields == {
        "title": "Alien",
        "director": "Ridley Scott",
        "writer": "Dan O'Bannon",
        "actors": "Sigourney Weaver, Tom Skerritt",
        "description": "The crew of a spaceship encounter a deadly lifeform.",
        "category": "Horror, Sci-Fi",
        "country": "United States, United Kingdom",
        "languages": "English",
        "certification": "R",
        "year": 1979,
        "length": 117,
        "rating": 8.5,
        "url": "https://www.imdb.com/title/tt0078748/",
    }


def test_movie_fields_from_omdb_excludes_na_and_unmapped_values():
    fields = movie_fields_from_omdb({"Response": "True", "DVD": "N/A", "Metascore": "89"})
    assert fields == {}


def test_preview_omdb_update_only_reports_actual_changes():
    movie = Movie(
        number=1, title="Alien", director="", year=None, rating=None,
    )

    preview = preview_omdb_update(movie, _RECORD)

    changed_fields = {change.field for change in preview.changes}
    assert "title" not in changed_fields  # already "Alien", no diff
    assert "director" in changed_fields
    assert "year" in changed_fields
    assert "rating" in changed_fields
    assert preview.movie.director == "Ridley Scott"
    assert preview.movie.year == 1979
    assert preview.movie.rating == 8.5
    assert preview.movie.number == 1  # untouched, not an OMDb field
    assert movie.director == ""  # the original movie is never mutated


def test_preview_omdb_update_reports_no_changes_for_an_already_matching_movie():
    movie = Movie.from_dict({**Movie().to_dict(), **movie_fields_from_omdb(_RECORD)})

    preview = preview_omdb_update(movie, _RECORD)

    assert preview.changes == ()
    assert preview.movie == movie
