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
