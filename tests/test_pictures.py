from pathlib import Path

import pytest
from PIL import Image

from amc.application import CatalogService
from amc.catalog import Catalog
from amc.model import Movie
from amc.storage import load, save


def test_service_links_and_exports_picture_relative_to_catalog(tmp_path: Path):
    catalog_path = tmp_path / "catalog.json"
    picture = tmp_path / "cover.jpg"
    picture.write_bytes(b"image")
    save(Catalog([Movie(title="Alien")]), catalog_path)
    service = CatalogService(catalog_path)

    service.set_picture(1, "cover.jpg")
    destination = tmp_path / "copy.jpg"
    service.export_picture(1, destination)

    assert destination.read_bytes() == b"image"
    assert load(catalog_path).get(1).picture == "cover.jpg"


def test_service_embeds_exports_and_clears_picture(tmp_path: Path):
    catalog_path = tmp_path / "catalog.json"
    picture = tmp_path / "cover.png"
    Image.new("RGB", (2, 3), "red").save(picture)
    expected = picture.read_bytes()
    save(Catalog([Movie(title="Alien")]), catalog_path)
    service = CatalogService(catalog_path)

    updated = service.set_picture(1, picture, embed=True)
    picture.unlink()
    destination = tmp_path / "exported.png"
    service.export_picture(1, destination)

    assert updated.picture == "cover.png"
    assert destination.read_bytes() == expected
    cleared = service.clear_picture(1)
    assert cleared.picture == ""
    assert "native_picture_base64" not in cleared.extras


def test_picture_size_limit_does_not_mutate_catalog(tmp_path: Path):
    catalog_path = tmp_path / "catalog.json"
    picture = tmp_path / "large.jpg"
    picture.write_bytes(b"1234")
    save(Catalog([Movie(title="Alien")]), catalog_path)
    service = CatalogService(catalog_path)

    with pytest.raises(ValueError, match="size limit"):
        service.set_picture(1, picture, embed=True, max_bytes=3)

    assert load(catalog_path).get(1).picture == ""


def test_picture_pixel_limit_and_invalid_image_do_not_mutate_catalog(tmp_path: Path):
    catalog_path = tmp_path / "catalog.json"
    picture = tmp_path / "cover.png"
    Image.new("RGB", (3, 2), "blue").save(picture)
    save(Catalog([Movie(title="Alien")]), catalog_path)
    service = CatalogService(catalog_path)

    with pytest.raises(ValueError, match="pixel limit"):
        service.set_picture(1, picture, embed=True, max_pixels=5)
    picture.write_bytes(b"not an image")
    with pytest.raises(ValueError, match="not a supported image"):
        service.set_picture(1, picture, embed=True)

    assert load(catalog_path).get(1).picture == ""


def test_service_crops_embedded_picture(tmp_path: Path):
    catalog_path = tmp_path / "catalog.json"
    picture = tmp_path / "cover.png"
    image = Image.new("RGB", (4, 3), "red")
    image.putpixel((2, 1), (0, 0, 255))
    image.save(picture)
    save(Catalog([Movie(title="Alien")]), catalog_path)

    service = CatalogService(catalog_path)
    service.set_picture(1, picture, embed=True, crop=(2, 1, 1, 1))
    exported = tmp_path / "crop.png"
    service.export_picture(1, exported)

    with Image.open(exported) as cropped:
        assert cropped.size == (1, 1)
        assert cropped.getpixel((0, 0)) == (0, 0, 255)


@pytest.mark.parametrize("crop", [(-1, 0, 1, 1), (0, 0, 0, 1), (3, 2, 2, 2)])
def test_invalid_crop_does_not_mutate_catalog(
    tmp_path: Path, crop: tuple[int, int, int, int]
):
    catalog_path = tmp_path / "catalog.json"
    picture = tmp_path / "cover.png"
    Image.new("RGB", (4, 3), "red").save(picture)
    save(Catalog([Movie(title="Alien")]), catalog_path)

    with pytest.raises(ValueError, match="crop"):
        CatalogService(catalog_path).set_picture(1, picture, embed=True, crop=crop)

    assert load(catalog_path).get(1).picture == ""


def test_picture_export_failure_preserves_destination(tmp_path: Path):
    catalog_path = tmp_path / "catalog.json"
    save(Catalog([Movie(
        title="Alien", picture="cover.jpg",
        extras={"native_picture_base64": "not base64"},
    )]), catalog_path)
    destination = tmp_path / "cover.jpg"
    destination.write_bytes(b"trusted")

    with pytest.raises(ValueError, match="not valid base64"):
        CatalogService(catalog_path).export_picture(1, destination)

    assert destination.read_bytes() == b"trusted"
