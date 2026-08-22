import os
import stat
from datetime import datetime, timezone

import pytest

from amc.catalog import Catalog
from amc.loans import (
    BORROWERS_KEY,
    METADATA_KEY,
    LoanEvent,
    add_borrower,
    append_event,
    borrowers,
    export_legacy_history,
    history,
    remove_borrower,
)
from amc.model import Movie


def test_append_and_decode_loan_event():
    catalog = Catalog()
    movie = Movie(number=7, title="Alien", media_label="DISC-1")
    event = append_event(
        catalog,
        movie,
        action="out",
        borrower="Ripley",
        timestamp=datetime(2026, 8, 13, 12, 30, tzinfo=timezone.utc),
    )
    assert event == LoanEvent(
        timestamp="2026-08-13T12:30:00+00:00",
        action="out",
        movie_number=7,
        media_label="DISC-1",
        title="Alien",
        borrower="Ripley",
    )
    assert history(catalog) == [event]


@pytest.mark.parametrize(
    ("value", "error"),
    [
        ({}, "missing or unknown"),
        (
            {
                "timestamp": "not a date",
                "action": "out",
                "movie_number": 1,
                "media_label": "",
                "title": "Alien",
                "borrower": "Ripley",
            },
            "ISO 8601",
        ),
        (
            {
                "timestamp": "2026-08-13T12:30:00",
                "action": "out",
                "movie_number": 1,
                "media_label": "",
                "title": "Alien",
                "borrower": "Ripley",
            },
            "timezone",
        ),
        (
            {
                "timestamp": "2026-08-13T12:30:00+00:00",
                "action": "lost",
                "movie_number": 1,
                "media_label": "",
                "title": "Alien",
                "borrower": "Ripley",
            },
            "action",
        ),
    ],
)
def test_history_rejects_malformed_metadata(value: object, error: str):
    catalog = Catalog(metadata={METADATA_KEY: [value]})
    with pytest.raises((TypeError, ValueError), match=error):
        history(catalog)


def test_history_rejects_non_array_metadata():
    catalog = Catalog(metadata={METADATA_KEY: {}})
    with pytest.raises(TypeError, match="must be an array"):
        history(catalog)


def test_borrowers_combine_managed_and_active_names_case_insensitively():
    catalog = Catalog(
        [Movie(borrower="ripley"), Movie(borrower="Hicks")],
        metadata={BORROWERS_KEY: ["Ripley", "Dallas"]},
    )

    assert borrowers(catalog) == ["Ripley", "Dallas", "Hicks"]


def test_add_and_remove_managed_borrower():
    catalog = Catalog()
    assert add_borrower(catalog, "  Ripley  ") == "Ripley"
    assert borrowers(catalog) == ["Ripley"]
    with pytest.raises(ValueError, match="already exists"):
        add_borrower(catalog, "RIPLEY")
    assert remove_borrower(catalog, "ripley") == "Ripley"
    assert borrowers(catalog) == []


def test_remove_borrower_rejects_active_or_unmanaged_name():
    catalog = Catalog([Movie(borrower="Ripley")], metadata={BORROWERS_KEY: ["Ripley"]})
    with pytest.raises(ValueError, match="checked-out movies"):
        remove_borrower(catalog, "Ripley")
    with pytest.raises(KeyError, match="does not exist"):
        remove_borrower(Catalog(), "Ripley")


@pytest.mark.parametrize("value", [{}, [""], [7]])
def test_borrowers_reject_malformed_metadata(value: object):
    catalog = Catalog(metadata={BORROWERS_KEY: value})
    with pytest.raises((TypeError, ValueError)):
        borrowers(catalog)


def test_export_legacy_history_uses_upstream_columns_and_crlf(tmp_path):
    catalog = Catalog()
    append_event(
        catalog,
        Movie(number=7, title="Alien", media_label="DISC-1"),
        action="out",
        borrower="Ripley",
        timestamp=datetime(2026, 8, 13, 12, 30, tzinfo=timezone.utc),
    )
    destination = tmp_path / "Loans history.csv"

    export_legacy_history(catalog, destination, catalog_name="movies.amc")

    assert destination.read_bytes() == (
        b"Date & Time\tCatalog\tIn/Out\tMovie Number\tMovieLabel\tMovie Title\t"
        b"Borrower Name\r\n"
        b"2026/08/13 12:30:00\tmovies.amc\tOut\t7\tDISC-1\tAlien\tRipley\r\n"
    )


@pytest.mark.skipif(os.name == "nt", reason="Windows cannot fsync directory handles")
def test_export_legacy_history_fsyncs_destination_directory_entry(
    tmp_path, monkeypatch: pytest.MonkeyPatch
):
    catalog = Catalog()
    append_event(
        catalog,
        Movie(number=7, title="Alien", media_label="DISC-1"),
        action="out",
        borrower="Ripley",
        timestamp=datetime(2026, 8, 13, 12, 30, tzinfo=timezone.utc),
    )
    destination = tmp_path / "Loans history.csv"
    original_fsync = os.fsync
    directory_syncs = 0

    def count_directory_syncs(descriptor: int) -> None:
        nonlocal directory_syncs
        if stat.S_ISDIR(os.fstat(descriptor).st_mode):
            directory_syncs += 1
        original_fsync(descriptor)

    monkeypatch.setattr("amc.native.os.fsync", count_directory_syncs)
    export_legacy_history(catalog, destination, catalog_name="movies.amc")

    assert directory_syncs == 1


def test_export_legacy_history_rejects_ambiguous_cells_without_replacing(tmp_path):
    catalog = Catalog()
    append_event(catalog, Movie(number=1, title="bad\ttitle"), action="in", borrower="Ripley")
    destination = tmp_path / "history.csv"
    destination.write_text("trusted", encoding="utf-8")

    with pytest.raises(ValueError, match="tabs or line breaks"):
        export_legacy_history(catalog, destination, catalog_name="movies.amc")

    assert destination.read_text(encoding="utf-8") == "trusted"
