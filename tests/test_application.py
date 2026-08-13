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
