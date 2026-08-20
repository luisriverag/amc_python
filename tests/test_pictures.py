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


def test_service_links_pictures_for_many_movies_in_one_persisted_mutation(
    tmp_path: Path,
):
    catalog_path = tmp_path / "catalog.json"
    cover_one = tmp_path / "one.jpg"
    cover_one.write_bytes(b"image one")
    cover_two = tmp_path / "two.jpg"
    cover_two.write_bytes(b"image two")
    save(
        Catalog([Movie(number=1, title="One"), Movie(number=2, title="Two")]),
        catalog_path,
    )
    service = CatalogService(catalog_path)

    updated = service.set_picture_many({1: cover_one, 2: cover_two})

    assert [movie.picture for movie in updated] == [str(cover_one), str(cover_two)]
    assert load(catalog_path).get(1).picture == str(cover_one)
    assert load(catalog_path).get(2).picture == str(cover_two)


def test_service_embeds_the_same_picture_for_many_movies_atomically(
    tmp_path: Path,
):
    catalog_path = tmp_path / "catalog.json"
    picture = tmp_path / "cover.png"
    Image.new("RGB", (2, 3), "red").save(picture)
    save(
        Catalog([Movie(number=1, title="One"), Movie(number=2, title="Two")]),
        catalog_path,
    )
    service = CatalogService(catalog_path)

    updated = service.set_picture_many({1: picture, 2: picture}, embed=True)

    assert [movie.picture for movie in updated] == ["cover.png", "cover.png"]
    for number in (1, 2):
        assert "native_picture_base64" in load(catalog_path).get(number).extras


def test_service_applies_per_movie_crop_rectangles(tmp_path: Path):
    catalog_path = tmp_path / "catalog.json"
    cover_one = tmp_path / "one.png"
    image_one = Image.new("RGB", (4, 4), "red")
    image_one.putpixel((1, 1), (0, 255, 0))
    image_one.save(cover_one)
    cover_two = tmp_path / "two.png"
    image_two = Image.new("RGB", (4, 4), "blue")
    image_two.putpixel((2, 2), (255, 255, 0))
    image_two.save(cover_two)
    save(
        Catalog([Movie(number=1, title="One"), Movie(number=2, title="Two")]),
        catalog_path,
    )
    service = CatalogService(catalog_path)

    service.set_picture_many(
        {1: cover_one, 2: cover_two},
        embed=True,
        crops={1: (1, 1, 1, 1), 2: (2, 2, 1, 1)},
    )

    exported_one = tmp_path / "exported-one.png"
    service.export_picture(1, exported_one)
    with Image.open(exported_one) as cropped:
        assert cropped.size == (1, 1)
        assert cropped.getpixel((0, 0)) == (0, 255, 0)

    exported_two = tmp_path / "exported-two.png"
    service.export_picture(2, exported_two)
    with Image.open(exported_two) as cropped:
        assert cropped.size == (1, 1)
        assert cropped.getpixel((0, 0)) == (255, 255, 0)


def test_service_falls_back_to_shared_crop_for_movies_without_a_per_movie_entry(
    tmp_path: Path,
):
    catalog_path = tmp_path / "catalog.json"
    cover_one = tmp_path / "one.png"
    image_one = Image.new("RGB", (4, 4), "red")
    image_one.putpixel((3, 3), (0, 255, 0))
    image_one.save(cover_one)
    cover_two = tmp_path / "two.png"
    image_two = Image.new("RGB", (4, 4), "blue")
    image_two.putpixel((0, 0), (255, 255, 0))
    image_two.save(cover_two)
    save(
        Catalog([Movie(number=1, title="One"), Movie(number=2, title="Two")]),
        catalog_path,
    )
    service = CatalogService(catalog_path)

    service.set_picture_many(
        {1: cover_one, 2: cover_two},
        embed=True,
        crop=(0, 0, 1, 1),
        crops={1: (3, 3, 1, 1)},
    )

    exported_one = tmp_path / "exported-one.png"
    service.export_picture(1, exported_one)
    with Image.open(exported_one) as cropped:
        assert cropped.getpixel((0, 0)) == (0, 255, 0)

    exported_two = tmp_path / "exported-two.png"
    service.export_picture(2, exported_two)
    with Image.open(exported_two) as cropped:
        assert cropped.getpixel((0, 0)) == (255, 255, 0)


def test_service_rejects_crops_for_unknown_movie_numbers(tmp_path: Path):
    catalog_path = tmp_path / "catalog.json"
    cover = tmp_path / "cover.png"
    Image.new("RGB", (4, 4), "red").save(cover)
    save(Catalog([Movie(number=1, title="One")]), catalog_path)
    service = CatalogService(catalog_path)

    with pytest.raises(ValueError, match="crops references movie numbers"):
        service.set_picture_many({1: cover}, embed=True, crops={9: (0, 0, 1, 1)})

    assert load(catalog_path).get(1).picture == ""


def test_service_rejects_per_movie_crops_without_embed(tmp_path: Path):
    catalog_path = tmp_path / "catalog.json"
    cover = tmp_path / "cover.png"
    Image.new("RGB", (4, 4), "red").save(cover)
    save(Catalog([Movie(number=1, title="One")]), catalog_path)
    service = CatalogService(catalog_path)

    with pytest.raises(ValueError, match="crop is only supported"):
        service.set_picture_many({1: cover}, crops={1: (0, 0, 1, 1)})

    assert load(catalog_path).get(1).picture == ""


def test_service_set_picture_many_is_atomic_for_missing_or_duplicate_numbers(
    tmp_path: Path,
):
    catalog_path = tmp_path / "catalog.json"
    cover = tmp_path / "cover.jpg"
    cover.write_bytes(b"image")
    save(Catalog([Movie(number=1, title="One")]), catalog_path)
    service = CatalogService(catalog_path)

    with pytest.raises(KeyError, match="movie 9"):
        service.set_picture_many({1: cover, 9: cover})
    with pytest.raises(ValueError, match="must be unique"):
        service.set_picture_many([(1, cover), (1, cover)])

    assert load(catalog_path).get(1).picture == ""


def test_service_set_picture_many_rejects_crop_without_embed(tmp_path: Path):
    catalog_path = tmp_path / "catalog.json"
    cover = tmp_path / "cover.jpg"
    cover.write_bytes(b"image")
    save(Catalog([Movie(number=1, title="One")]), catalog_path)
    service = CatalogService(catalog_path)

    with pytest.raises(ValueError, match="crop is only supported"):
        service.set_picture_many({1: cover}, crop=(0, 0, 1, 1))

    assert load(catalog_path).get(1).picture == ""


def test_service_clears_pictures_for_many_movies_in_one_persisted_mutation(
    tmp_path: Path,
):
    catalog_path = tmp_path / "catalog.json"
    save(
        Catalog([
            Movie(number=1, title="One", picture="one.jpg"),
            Movie(number=2, title="Two", picture="two.jpg"),
            Movie(number=3, title="Three", picture="three.jpg"),
        ]),
        catalog_path,
    )
    service = CatalogService(catalog_path)

    cleared = service.clear_picture_many([1, 3])

    assert [movie.picture for movie in cleared] == ["", ""]
    assert load(catalog_path).get(1).picture == ""
    assert load(catalog_path).get(2).picture == "two.jpg"
    assert load(catalog_path).get(3).picture == ""


def test_service_clear_picture_many_is_atomic_for_missing_or_duplicate_numbers(
    tmp_path: Path,
):
    catalog_path = tmp_path / "catalog.json"
    save(
        Catalog([Movie(number=1, title="One", picture="one.jpg")]),
        catalog_path,
    )
    service = CatalogService(catalog_path)

    with pytest.raises(KeyError, match="movie 9"):
        service.clear_picture_many([1, 9])
    with pytest.raises(ValueError, match="must be unique"):
        service.clear_picture_many([1, 1])

    assert load(catalog_path).get(1).picture == "one.jpg"


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
