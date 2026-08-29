import base64
from pathlib import Path

import pytest

from amc.catalog import Catalog
from amc.cli import main
from amc.html_template import (
    export_html_template,
    render_full_template,
    render_individual_template,
)
from amc.model import Movie
from amc.storage import load


def test_render_full_template_expands_item_loop_and_general_tags():
    catalog = Catalog(
        [Movie(number=1, title="Alien", year=1979), Movie(number=2, title="Aliens", year=1986)],
        metadata={"amc_xml": {"owner": "Ripley"}},
    )
    template = (
        "<html>$$OWNER_NAME has $$TOTALMOVIES movies:"
        "$$ITEM_BEGIN<p>$$ITEM_NUMBER: $$ITEM_FORMATTEDTITLE ($$ITEM_YEAR)</p>$$ITEM_END"
        "</html>"
    )

    page = render_full_template(catalog, template)

    assert page == (
        "<html>Ripley has 2 movies:<p>1: Alien (1979)</p><p>2: Aliens (1986)</p></html>"
    )


def test_render_full_template_without_item_loop_still_replaces_general_tags():
    catalog = Catalog([Movie(number=1, title="Alien")])
    page = render_full_template(catalog, "<p>$$TOTALMOVIES movie(s)</p>")
    assert page == "<p>1 movie(s)</p>"


def test_render_individual_template_covers_common_movie_tags():
    catalog = Catalog()
    movie = Movie(
        number=7,
        title="Moon",
        original_title="Moon",
        year=2009,
        director="Duncan Jones",
        rating=8.4,
        user_rating=9.0,
        checked=True,
        actors="Sam Rockwell",
        description="Solitude.\nIsolation.",
        picture="posters/moon.jpg",
    )
    template = (
        "$$ITEM_NUMBER|$$ITEM_FORMATTEDTITLE|$$ITEM_YEAR|$$ITEM_DIRECTOR|"
        "$$ITEM_RATING|$$ITEM_RATING10|$$ITEM_APPR10|$$ITEM_USERRATING|"
        "$$ITEM_CHECKED|$$ITEM_ACTORS|$$ITEM_DESCRIPTION|$$ITEM_PICTUREFILENAME|"
        "$$ITEM_PICTURE"
    )

    page = render_individual_template(movie, catalog, template)

    assert page == (
        "7|Moon|2009|Duncan Jones|"
        '8.4|8|<img src="appr10_8.gif" alt="8/10" />|9.0|'
        "x|Sam Rockwell|Solitude.<br>Isolation.|moon.jpg|"
        '<img src="moon.jpg" alt="pic_movie_7" />'
    )


def test_render_individual_template_appreciation_bucket_matches_upstream_ranges():
    """Mirrors export.pas's exact 0..29/30..49/50..69/70..89/90..100 case
    statement on the 0-100 internal rating scale, not an approximation of it."""
    catalog = Catalog()
    cases = [
        (2.9, "0"),
        (3.0, "1"),
        (4.9, "1"),
        (5.0, "2"),
        (6.9, "2"),
        (7.0, "3"),
        (8.9, "3"),
        (9.0, "4"),
        (10.0, "4"),
    ]
    for rating, expected in cases:
        movie = Movie(number=1, title="X", rating=rating)
        page = render_individual_template(movie, catalog, "$$ITEM_RATING4")
        assert page == expected, (rating, page)


def test_render_individual_template_blank_rating_leaves_every_rating_tag_empty():
    movie = Movie(number=1, title="Unrated")
    page = render_individual_template(
        movie,
        Catalog(),
        "[$$ITEM_RATING][$$ITEM_RATING4][$$ITEM_RATING10][$$ITEM_APPR10][$$ITEM_APPRECIATION]",
    )
    assert page == "[][][][][]"


def test_render_movie_tags_strips_unimplemented_extra_record_blocks():
    movie = Movie(number=1, title="Alien")
    template = (
        "before$$ITEM_EXTRA_BEGIN(Trailers)stuff about $$ITEM_EXTRA_TITLE$$ITEM_EXTRA_ENDafter"
    )

    page = render_individual_template(movie, Catalog(), template)

    assert page == "beforeafter"


def test_render_movie_tags_reads_custom_field_values_from_extras():
    movie = Movie(number=1, title="Alien", extras={"Format": "Director's Cut"})
    page = render_individual_template(movie, Catalog(), "$$ITEM_CF_FORMAT|$$LABEL_CF_FORMAT")
    assert page == "Director's Cut|Format"


def test_export_html_template_requires_at_least_one_template(tmp_path: Path):
    with pytest.raises(ValueError, match="at least one"):
        export_html_template(Catalog(), tmp_path / "out.html")


def test_export_html_template_writes_full_and_individual_pages_atomically(tmp_path: Path):
    catalog = Catalog([Movie(number=1, title="Alien"), Movie(number=5, title="Aliens")])
    full = tmp_path / "full.html"
    full.write_text("$$ITEM_BEGIN$$ITEM_NUMBER;$$ITEM_END", encoding="utf-8")
    individual = tmp_path / "individual.html"
    individual.write_text("<h1>$$ITEM_FORMATTEDTITLE</h1>", encoding="utf-8")
    destination = tmp_path / "site" / "index.html"

    written = export_html_template(
        catalog,
        destination,
        full_template=full,
        individual_template=individual,
    )

    assert destination.read_text(encoding="utf-8") == "1;5;"
    individual_dir = tmp_path / "site"
    assert (individual_dir / "1.html").read_text(encoding="utf-8") == "<h1>Alien</h1>"
    assert (individual_dir / "5.html").read_text(encoding="utf-8") == "<h1>Aliens</h1>"
    assert set(written) == {
        destination,
        individual_dir / "1.html",
        individual_dir / "5.html",
    }


def test_export_html_template_uses_a_custom_individual_filename_pattern(tmp_path: Path):
    catalog = Catalog([Movie(number=3, title="Alien")])
    individual = tmp_path / "individual.html"
    individual.write_text("$$ITEM_FORMATTEDTITLE", encoding="utf-8")

    written = export_html_template(
        catalog,
        tmp_path / "out.html",
        individual_template=individual,
        individual_dir=tmp_path / "pages",
        individual_filename="movie-{number}.html",
    )

    assert written == [tmp_path / "pages" / "movie-3.html"]
    assert (tmp_path / "pages" / "movie-3.html").exists()


def test_export_html_template_rejects_an_oversized_template(tmp_path: Path):
    catalog = Catalog([Movie(number=1, title="Alien")])
    huge = tmp_path / "huge.html"
    huge.write_text("x" * 10, encoding="utf-8")

    with pytest.raises(ValueError, match="exceeds size limit"):
        export_html_template(
            catalog, tmp_path / "out.html", full_template=huge, max_template_bytes=1
        )


def test_export_html_template_copies_linked_pictures_into_subdirectory(tmp_path: Path):
    catalog_path = tmp_path / "catalog.json"
    source = tmp_path / "covers" / "alien.jpg"
    source.parent.mkdir()
    source.write_bytes(b"jpeg-data")
    catalog = Catalog([Movie(number=1, title="Alien", picture="covers/alien.jpg")])
    template = tmp_path / "template.html"
    template.write_text("$$ITEM_BEGIN$$ITEM_PICTURE$$ITEM_END", encoding="utf-8")

    written = export_html_template(
        catalog,
        tmp_path / "site" / "index.html",
        full_template=template,
        copy_pictures=True,
        picture_directory="images",
        catalog_path=catalog_path,
    )

    picture = tmp_path / "site" / "images" / "alien.jpg"
    assert picture.read_bytes() == b"jpeg-data"
    assert 'src="images/alien.jpg"' in (tmp_path / "site" / "index.html").read_text()
    assert picture in written


def test_export_html_template_only_if_missing_preserves_existing_picture(tmp_path: Path):
    source = tmp_path / "alien.jpg"
    source.write_bytes(b"new")
    target = tmp_path / "site" / "pictures" / "alien.jpg"
    target.parent.mkdir(parents=True)
    target.write_bytes(b"old")
    template = tmp_path / "template.html"
    template.write_text("x", encoding="utf-8")

    written = export_html_template(
        Catalog([Movie(number=1, picture="alien.jpg")]),
        tmp_path / "site" / "index.html",
        full_template=template,
        copy_pictures=True,
        pictures_only_if_missing=True,
        catalog_path=tmp_path / "catalog.json",
    )

    assert target.read_bytes() == b"old"
    assert target not in written


def test_export_html_template_names_embedded_picture_and_links_from_individual_dir(tmp_path: Path):
    png = b"\x89PNG\r\n\x1a\ncontent"
    catalog = Catalog(
        [Movie(number=7, extras={"native_picture_base64": base64.b64encode(png).decode()})]
    )
    template = tmp_path / "individual.html"
    template.write_text("$$ITEM_PICTUREFILENAME", encoding="utf-8")
    full_template = tmp_path / "full.html"
    full_template.write_text("$$ITEM_BEGIN$$ITEM_PICTUREFILENAME$$ITEM_END", encoding="utf-8")

    export_html_template(
        catalog,
        tmp_path / "site" / "index.html",
        full_template=full_template,
        individual_template=template,
        individual_dir=tmp_path / "site" / "pages",
        copy_pictures=True,
        catalog_path=tmp_path / "catalog.json",
    )

    assert (tmp_path / "site" / "pictures" / "movie-7.png").read_bytes() == png
    assert (tmp_path / "site" / "index.html").read_text() == "pictures/movie-7.png"
    assert (tmp_path / "site" / "pages" / "7.html").read_text() == "../pictures/movie-7.png"


@pytest.mark.parametrize("directory", ("../pictures", "/pictures", r"C:\pictures", ".", " "))
def test_export_html_template_rejects_unsafe_picture_directory(tmp_path: Path, directory: str):
    template = tmp_path / "template.html"
    template.write_text("x", encoding="utf-8")

    with pytest.raises(ValueError, match="relative"):
        export_html_template(
            Catalog(),
            tmp_path / "index.html",
            full_template=template,
            copy_pictures=True,
            picture_directory=directory,
            catalog_path=tmp_path / "catalog.json",
        )


def test_export_html_template_normalizes_windows_picture_directory(tmp_path: Path):
    source = tmp_path / "alien.jpg"
    source.write_bytes(b"picture")
    template = tmp_path / "template.html"
    template.write_text("$$ITEM_BEGIN$$ITEM_PICTUREFILENAME$$ITEM_END", encoding="utf-8")

    export_html_template(
        Catalog([Movie(number=1, picture="alien.jpg")]),
        tmp_path / "site" / "index.html",
        full_template=template,
        copy_pictures=True,
        picture_directory=r"assets\pictures",
        catalog_path=tmp_path / "catalog.json",
    )

    assert (tmp_path / "site" / "assets" / "pictures" / "alien.jpg").exists()
    assert (tmp_path / "site" / "index.html").read_text() == "assets/pictures/alien.jpg"


def test_export_html_template_does_not_rewrite_an_unresolved_picture(tmp_path: Path):
    template = tmp_path / "template.html"
    template.write_text("$$ITEM_BEGIN$$ITEM_PICTUREFILENAME$$ITEM_END", encoding="utf-8")

    export_html_template(
        Catalog([Movie(number=1, picture="missing.jpg")]),
        tmp_path / "site" / "index.html",
        full_template=template,
        copy_pictures=True,
        catalog_path=tmp_path / "catalog.json",
    )

    assert (tmp_path / "site" / "index.html").read_text() == "missing.jpg"


def test_render_picture_tag_escapes_filename_for_html_attribute():
    page = render_individual_template(
        Movie(number=1, picture='cover "one" & two.jpg'),
        Catalog(),
        "$$ITEM_PICTURE|$$ITEM_PICTUREFILENAME",
    )

    assert page == (
        '<img src="cover &quot;one&quot; &amp; two.jpg" alt="pic_movie_1" />|cover "one" & two.jpg'
    )


def test_render_picture_tag_uses_basename_for_windows_link():
    page = render_individual_template(
        Movie(number=1, picture=r"covers\alien.jpg"), Catalog(), "$$ITEM_PICTUREFILENAME"
    )

    assert page == "alien.jpg"


def test_export_html_template_rejects_picture_and_individual_page_collision(tmp_path: Path):
    source = tmp_path / "1.html"
    source.write_bytes(b"picture")
    full = tmp_path / "full-template.html"
    full.write_text("full", encoding="utf-8")
    individual = tmp_path / "individual-template.html"
    individual.write_text("movie", encoding="utf-8")

    with pytest.raises(ValueError, match="collides with HTML output"):
        export_html_template(
            Catalog([Movie(number=1, picture="1.html")]),
            tmp_path / "site" / "index.html",
            full_template=full,
            individual_template=individual,
            individual_dir=tmp_path / "site" / "pictures",
            copy_pictures=True,
            catalog_path=tmp_path / "catalog.json",
        )

    assert not (tmp_path / "site").exists()


def test_export_html_template_rejects_case_only_picture_collision(tmp_path: Path):
    first = tmp_path / "one" / "cover.jpg"
    second = tmp_path / "two" / "COVER.JPG"
    first.parent.mkdir()
    second.parent.mkdir()
    first.write_bytes(b"first")
    second.write_bytes(b"second")
    template = tmp_path / "template.html"
    template.write_text("x", encoding="utf-8")

    with pytest.raises(ValueError, match="picture filename collision"):
        export_html_template(
            Catalog(
                [
                    Movie(number=1, picture="one/cover.jpg"),
                    Movie(number=2, picture="two/COVER.JPG"),
                ]
            ),
            tmp_path / "site" / "index.html",
            full_template=template,
            copy_pictures=True,
            catalog_path=tmp_path / "catalog.json",
        )


def test_cli_export_html_template_writes_full_page(tmp_path: Path, capsys):
    catalog_path = tmp_path / "catalog.json"
    assert main(["-c", str(catalog_path), "add", "Alien", "--year", "1979"]) == 0
    template = tmp_path / "full.html"
    template.write_text(
        "$$ITEM_BEGIN$$ITEM_FORMATTEDTITLE ($$ITEM_YEAR)$$ITEM_END", encoding="utf-8"
    )
    destination = tmp_path / "out" / "index.html"

    assert (
        main(
            [
                "-c",
                str(catalog_path),
                "export-html-template",
                str(destination),
                "--full-template",
                str(template),
            ]
        )
        == 0
    )
    assert "Wrote 1 file(s)" in capsys.readouterr().out
    assert destination.read_text(encoding="utf-8") == "Alien (1979)"
    assert load(catalog_path).get(1).title == "Alien"
