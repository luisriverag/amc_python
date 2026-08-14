from pathlib import Path

import pytest

from amc.application import CatalogService
from amc.catalog import Catalog
from amc.model import Movie
from amc.storage import load, save


def test_service_opens_missing_catalog_and_persists_crud(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)

    added = service.add(Movie(title="Alien"))
    assert (added.number, service.dirty) == (1, False)
    service.replace(1, Movie(title="Aliens"))
    assert service.catalog.get(1).title == "Aliens"
    removed = service.remove(1)
    assert removed.title == "Aliens"
    assert list(load(path)) == []


def test_native_catalog_is_read_only_until_saved_as_json(tmp_path: Path):
    from amc.native import write_native_catalog

    native_path = tmp_path / "catalog.amc"
    json_path = tmp_path / "catalog.json"
    write_native_catalog(Catalog([Movie(original_title="Alien")]), native_path)
    original_bytes = native_path.read_bytes()
    service = CatalogService(native_path)

    with pytest.raises(ValueError, match="read-only.*save as"):
        service.replace(1, Movie(original_title="Aliens"))
    with pytest.raises(ValueError, match="read-only.*save as"):
        service.save()
    with pytest.raises(ValueError, match="read-only.*save as"):
        service.save_as(tmp_path / "copy.amc")

    assert native_path.read_bytes() == original_bytes
    assert service.catalog.get(1).original_title == "Alien"

    service.save_as(json_path)
    service.replace(1, Movie(original_title="Aliens"))
    assert load(json_path).get(1).original_title == "Aliens"
    assert native_path.read_bytes() == original_bytes


def test_service_does_not_publish_failed_persistence(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    path = tmp_path / "catalog.json"
    save(Catalog([Movie(title="Original")]), path)
    service = CatalogService(path)

    def fail(_catalog: Catalog, _path: Path) -> None:
        raise OSError("disk full")

    monkeypatch.setattr("amc.application.save", fail)
    with pytest.raises(OSError, match="disk full"):
        service.replace(1, Movie(title="Changed"))

    assert service.dirty is False
    assert service.catalog.get(1).title == "Original"
    assert load(path).get(1).title == "Original"


def test_service_removes_many_in_one_persisted_mutation(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add_many([Movie(title="One"), Movie(title="Two"), Movie(title="Three")])

    removed = service.remove_many([1, 3])

    assert [movie.title for movie in removed] == ["One", "Three"]
    assert [movie.title for movie in service.catalog] == ["Two"]
    assert [movie.title for movie in load(path)] == ["Two"]


def test_service_remove_many_is_atomic_for_missing_or_duplicate_numbers(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add_many([Movie(title="One"), Movie(title="Two")])

    with pytest.raises(KeyError, match="movie 9"):
        service.remove_many([1, 9])
    with pytest.raises(ValueError, match="must be unique"):
        service.remove_many([1, 1])

    assert [movie.title for movie in service.catalog] == ["One", "Two"]
    assert [movie.title for movie in load(path)] == ["One", "Two"]


def test_service_sets_checked_state_for_many_movies_atomically(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add_many([
        Movie(title="One"),
        Movie(title="Two", checked=True),
        Movie(title="Three"),
    ])

    updated = service.set_checked_many([1, 3], True)

    assert [movie.number for movie in updated] == [1, 3]
    assert [movie.checked for movie in load(path)] == [True, True, True]


def test_service_set_checked_many_failure_does_not_publish_partial_state(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add_many([Movie(title="One"), Movie(title="Two")])

    with pytest.raises(KeyError, match="movie 9"):
        service.set_checked_many([1, 9], True)

    assert [movie.checked for movie in service.catalog] == [False, False]
    assert [movie.checked for movie in load(path)] == [False, False]


def test_service_undo_and_redo_persist_catalog_history(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add(Movie(title="Alien"))
    service.replace(1, Movie(title="Aliens"))

    service.undo()
    assert service.catalog.get(1).title == "Alien"
    assert load(path).get(1).title == "Alien"
    assert service.can_redo

    service.redo()
    assert service.catalog.get(1).title == "Aliens"
    assert load(path).get(1).title == "Aliens"


def test_service_failed_undo_preserves_state_and_history(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    service = CatalogService(tmp_path / "catalog.json")
    service.add(Movie(title="Alien"))

    def fail(*_args: object) -> None:
        raise OSError("full")

    monkeypatch.setattr("amc.application.save", fail)

    with pytest.raises(OSError, match="full"):
        service.undo()

    assert service.catalog.get(1).title == "Alien"
    assert service.can_undo


def test_service_new_mutation_clears_redo_history(tmp_path: Path):
    service = CatalogService(tmp_path / "catalog.json")
    service.add(Movie(title="Alien"))
    service.undo()
    assert service.can_redo

    service.add(Movie(title="Arrival"))

    assert not service.can_redo
    with pytest.raises(ValueError, match="nothing to redo"):
        service.redo()


def test_service_isolates_callers_and_can_reload(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    incoming = Movie(title="Alien", extras={"nested": [1]})

    service.add(incoming)
    incoming.title = "Changed by caller"
    incoming.extras["nested"].append(2)
    assert service.catalog.get(1).to_dict() == Movie(
        number=1, title="Alien", extras={"nested": [1]}
    ).to_dict()

    save(Catalog([Movie(title="External change")]), path)
    service.dirty = True
    service.reload()
    assert service.dirty is False
    assert service.catalog.get(1).title == "External change"


def test_service_persists_batch_merge_and_renumber(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)

    added = service.add_many([Movie(number=8, title="Alien"), Movie(title="Aliens")])
    assert [movie.number for movie in added] == [1, 2]
    count = service.merge(
        Catalog([Movie(number=2, title="Arrival")], metadata={"owner": "Amy"}),
        collision="renumber",
    )
    assert count == 1
    service.renumber(start=4)

    reopened = load(path)
    assert [(movie.number, movie.title) for movie in reopened] == [
        (4, "Alien"),
        (5, "Aliens"),
        (6, "Arrival"),
    ]
    assert reopened.metadata == {"owner": "Amy"}


def test_service_batch_failure_does_not_publish_partial_state(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add(Movie(title="Original"))

    def fail(_catalog: Catalog, _path: Path) -> None:
        raise OSError("disk full")

    monkeypatch.setattr("amc.application.save", fail)
    with pytest.raises(OSError, match="disk full"):
        service.add_many([Movie(title="One"), Movie(title="Two")])

    assert [movie.title for movie in service.catalog] == ["Original"]
    assert [movie.title for movie in load(path)] == ["Original"]


def test_service_backup_restore_and_exports(tmp_path: Path):
    path = tmp_path / "catalog.json"
    backup = tmp_path / "backup.json"
    service = CatalogService(path)
    service.add(Movie(title="Original", original_title="Original"))
    service.backup(backup)

    service.replace(1, Movie(title="Changed"))
    service.restore(backup)
    assert service.catalog.get(1).title == "Original"

    destinations = {
        "xml": tmp_path / "catalog.xml",
        "csv": tmp_path / "catalog.csv",
        "amc": tmp_path / "catalog.amc",
    }
    for format, destination in destinations.items():
        service.export(destination, format=format)
        exported = load(destination).get(1)
        assert exported.title == "Original" or exported.original_title == "Original"

    html = tmp_path / "catalog.html"
    service.export(html, format="html")
    assert "Original" in html.read_text(encoding="utf-8")


def test_service_rejects_invalid_export_options(tmp_path: Path):
    service = CatalogService(tmp_path / "missing.json")

    with pytest.raises(ValueError, match="unsupported export format"):
        service.export(tmp_path / "out", format="pdf")
    with pytest.raises(ValueError, match="only supported for HTML"):
        service.export(tmp_path / "out.xml", format="xml", template="template")
    with pytest.raises(ValueError, match="only supported for AMC"):
        service.export(tmp_path / "out.xml", format="xml", native_encoding="utf-8")


def test_service_passes_native_export_encoding_and_limits(tmp_path: Path):
    from amc.native import NativeWriteLimits

    service = CatalogService(tmp_path / "catalog.json")
    service.add(Movie(title="Amélie"))
    target = tmp_path / "catalog.amc"

    service.export(
        target,
        format="amc",
        native_encoding="utf-8",
        native_limits=NativeWriteLimits(max_file_bytes=4096),
    )

    assert target.exists()


def test_service_native_export_budget_preserves_destination(tmp_path: Path):
    from amc.native import NativeWriteLimits

    service = CatalogService(tmp_path / "catalog.json")
    service.add(Movie(title="Alien"))
    target = tmp_path / "catalog.amc"
    target.write_bytes(b"trusted")

    with pytest.raises(ValueError, match="output-size limit"):
        service.export(
            target,
            format="amc",
            native_limits=NativeWriteLimits(max_file_bytes=64),
        )

    assert target.read_bytes() == b"trusted"


def test_service_can_restore_over_an_unreadable_catalog(tmp_path: Path):
    source = tmp_path / "backup.json"
    destination = tmp_path / "broken.json"
    save(Catalog([Movie(title="Recovered")]), source)
    destination.write_text("not json", encoding="utf-8")

    restored = CatalogService.restore_to(source, destination)

    assert restored.catalog.get(1).title == "Recovered"
    assert load(destination).get(1).title == "Recovered"


def test_service_converts_interchange_over_unreadable_destination(tmp_path: Path):
    source = tmp_path / "source.xml"
    destination = tmp_path / "broken.json"
    source.write_text(
        '<AntMovieCatalog Format="4.2"><Catalog><Properties/>'
        '<Contents><Movie Number="7" FormattedTitle="Moon"/>'
        "</Contents></Catalog></AntMovieCatalog>",
        encoding="utf-8",
    )
    destination.write_text("not json", encoding="utf-8")

    converted = CatalogService.convert_to(source, destination)

    assert converted.catalog.get(7).title == "Moon"
    assert load(destination).get(7).title == "Moon"


def test_service_conversion_preserves_destination_when_source_is_invalid(
    tmp_path: Path,
):
    source = tmp_path / "broken.xml"
    destination = tmp_path / "catalog.json"
    source.write_text("<broken>", encoding="utf-8")
    save(Catalog([Movie(title="Original")]), destination)

    with pytest.raises(ValueError):
        CatalogService.convert_to(source, destination)

    assert load(destination).get(1).title == "Original"


def test_service_sort_persists_order(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add_many([Movie(title="Zulu"), Movie(title="Alien")])

    service.sort("title")

    assert [movie.title for movie in service.catalog] == ["Alien", "Zulu"]
    assert [movie.title for movie in load(path)] == ["Alien", "Zulu"]


def test_service_sort_failure_does_not_publish_order(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add_many([Movie(title="Zulu"), Movie(title="Alien")])

    def fail(_catalog: Catalog, _path: Path) -> None:
        raise OSError("disk full")

    monkeypatch.setattr("amc.application.save", fail)
    with pytest.raises(OSError, match="disk full"):
        service.sort("title")

    assert [movie.title for movie in service.catalog] == ["Zulu", "Alien"]
    assert [movie.title for movie in load(path)] == ["Zulu", "Alien"]


def test_service_checks_movie_out_and_in(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add(Movie(title="Alien"))

    loaned = service.check_out(1, "  Ripley  ")
    assert loaned.borrower == "Ripley"
    assert load(path).get(1).borrower == "Ripley"

    returned = service.check_in(1)
    assert returned.borrower == ""
    assert load(path).get(1).borrower == ""


def test_service_records_persisted_check_out_and_check_in_history(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add(Movie(title="Alien", media_label="DISC-1"))

    service.check_out(1, "Ripley")
    service.check_out(1, "Ripley")
    service.check_in(1)

    events = CatalogService(path).loan_history()
    assert [(event.action, event.borrower, event.title) for event in events] == [
        ("out", "Ripley", "Alien"),
        ("in", "Ripley", "Alien"),
    ]


def test_malformed_history_makes_loan_mutation_atomic(tmp_path: Path):
    path = tmp_path / "catalog.json"
    save(Catalog(
        [Movie(title="Alien")], metadata={"amc_python_loan_history": [{}]}
    ), path)
    service = CatalogService(path)

    with pytest.raises(ValueError, match="missing or unknown"):
        service.check_out(1, "Ripley")

    assert service.catalog.get(1).borrower == ""
    assert load(path).get(1).borrower == ""


def test_service_manages_borrower_names_atomically(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add_borrower("Ripley")
    service.add(Movie(title="Alien", borrower="Hicks"))

    assert CatalogService(path).borrowers() == ["Ripley", "Hicks"]
    assert service.remove_borrower("Ripley") == "Ripley"
    with pytest.raises(KeyError, match="does not exist"):
        service.remove_borrower("Ripley")
    assert service.borrowers() == ["Hicks"]


def test_service_exports_loan_history_with_catalog_filename(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add(Movie(title="Alien"))
    service.check_out(1, "Ripley")

    destination = tmp_path / "history.csv"
    service.export_loan_history(destination)

    assert "\tcatalog.json\tOut\t1\t\tAlien\tRipley" in destination.read_text()


def test_service_rejects_invalid_or_conflicting_loans(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add(Movie(title="Alien", borrower="Ripley"))

    with pytest.raises(ValueError, match="must not be empty"):
        service.check_out(1, "  ")
    with pytest.raises(ValueError, match="already checked out to Ripley"):
        service.check_out(1, "Dallas")
    assert load(path).get(1).borrower == "Ripley"

    service.check_in(1)
    with pytest.raises(ValueError, match="not checked out"):
        service.check_in(1)


def test_service_checks_multiple_movies_out_and_in_atomically(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add_many([Movie(title="Alien"), Movie(title="Aliens")])

    loaned = service.check_out_many([1, 2], "  Ripley  ")
    assert [movie.borrower for movie in loaned] == ["Ripley", "Ripley"]
    assert [movie.borrower for movie in load(path)] == ["Ripley", "Ripley"]

    returned = service.check_in_many([1, 2])
    assert [movie.borrower for movie in returned] == ["", ""]
    assert [movie.borrower for movie in load(path)] == ["", ""]


def test_service_bulk_loan_conflict_preserves_every_movie(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add_many([
        Movie(title="Alien"),
        Movie(title="Aliens", borrower="Hicks"),
    ])

    with pytest.raises(ValueError, match="already checked out to Hicks"):
        service.check_out_many([1, 2], "Ripley")

    assert [movie.borrower for movie in service.catalog] == ["", "Hicks"]
    assert [movie.borrower for movie in load(path)] == ["", "Hicks"]


def test_service_expands_loans_by_nonempty_media_label(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add_many([
        Movie(title="Disc two", media_label="BOX-1"),
        Movie(title="Unlabeled"),
        Movie(title="Disc one", media_label="box-1"),
        Movie(title="Other", media_label="BOX-2"),
    ])

    selected = service.check_out(3, "Ripley", include_media_label=True)
    assert selected.number == 3
    assert [movie.borrower for movie in load(path)] == ["Ripley", "", "Ripley", ""]
    assert [event.movie_number for event in service.loan_history()] == [1, 3]

    service.check_in(3, include_media_label=True)
    assert [movie.borrower for movie in load(path)] == ["", "", "", ""]


def test_grouped_loan_conflict_is_atomic(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add_many([
        Movie(title="One", media_label="BOX", borrower="Hicks"),
        Movie(title="Two", media_label="BOX"),
    ])

    with pytest.raises(ValueError, match="already checked out to Hicks"):
        service.check_out(2, "Ripley", include_media_label=True)

    assert [movie.borrower for movie in load(path)] == ["Hicks", ""]


def test_empty_media_labels_are_not_grouped(tmp_path: Path):
    service = CatalogService(tmp_path / "catalog.json")
    service.add_many([Movie(title="One"), Movie(title="Two")])

    service.check_out(2, "Ripley", include_media_label=True)

    assert [movie.borrower for movie in service.catalog] == ["", "Ripley"]


def test_service_expands_loans_by_retained_native_number(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add_many([
        Movie(title="Disc one", extras={"native_movie_number": 7}),
        Movie(title="Other", extras={"native_movie_number": 8}),
        Movie(title="Disc two", extras={"native_movie_number": 7}),
    ])

    service.check_out(3, "Ripley", include_native_number=True)
    assert [movie.borrower for movie in load(path)] == ["Ripley", "", "Ripley"]
    service.check_in(1, include_native_number=True)
    assert [movie.borrower for movie in load(path)] == ["", "", ""]


def test_native_number_and_media_label_groups_form_union(tmp_path: Path):
    service = CatalogService(tmp_path / "catalog.json")
    service.add_many([
        Movie(title="Selected", media_label="BOX", extras={"native_movie_number": 7}),
        Movie(title="Same number", extras={"native_movie_number": 7}),
        Movie(title="Same label", media_label="box", extras={"native_movie_number": 8}),
    ])

    service.check_out(
        1, "Ripley", include_media_label=True, include_native_number=True
    )

    assert [movie.borrower for movie in service.catalog] == ["Ripley"] * 3


def test_service_open_and_save_as_publish_paths_only_after_success(tmp_path: Path):
    original = tmp_path / "original.json"
    other = tmp_path / "other.json"
    saved_as = tmp_path / "saved.json"
    save(Catalog([Movie(title="Original")]), original)
    save(Catalog([Movie(title="Other")]), other)
    service = CatalogService(original)

    service.open(other)
    assert (service.path, service.catalog.get(1).title) == (other, "Other")
    service.save_as(saved_as)
    assert service.path == saved_as
    assert load(saved_as).get(1).title == "Other"

    broken = tmp_path / "broken.json"
    broken.write_text("not json", encoding="utf-8")
    with pytest.raises(ValueError):
        service.open(broken)
    assert (service.path, service.catalog.get(1).title) == (saved_as, "Other")


def test_service_import_from_loads_then_atomically_merges(tmp_path: Path):
    path = tmp_path / "catalog.json"
    source = tmp_path / "incoming.json"
    service = CatalogService(path)
    service.add(Movie(number=1, title="Existing"))
    save(Catalog([Movie(number=1, title="Incoming")]), source)

    assert service.import_from(source, collision="renumber") == 1
    assert [(movie.number, movie.title) for movie in load(path)] == [
        (1, "Existing"),
        (2, "Incoming"),
    ]


def test_service_exposes_statistics_and_duplicates_without_mutation(tmp_path: Path):
    service = CatalogService(tmp_path / "missing.json")
    service.add_many(
        [Movie(title="Moon", year=2009, rating=8), Movie(title="moon", year=2009)]
    )

    assert service.statistics() == {
        "movies": 2,
        "checked": 0,
        "total_length": 0,
        "average_rating": 8,
        "earliest_year": 2009,
        "latest_year": 2009,
    }
    assert [[movie.number for movie in group] for group in service.duplicates()] == [[1, 2]]


def test_service_sets_checked_state_atomically(tmp_path: Path):
    path = tmp_path / "catalog.json"
    service = CatalogService(path)
    service.add(Movie(title="Moon"))

    checked = service.set_checked(1, True)

    assert checked.checked is True
    assert load(path).get(1).checked is True
    with pytest.raises(TypeError, match="checked must be a boolean"):
        service.set_checked(1, 1)  # type: ignore[arg-type]
