"""CLI end-to-end tests: exercising `amc.cli.main` argv handling and exit
codes, one JSON catalog per invocation via `tmp_path`."""

import json
from pathlib import Path

import pytest

from amc import Catalog, Movie
from amc.cli import main
from amc.storage import load, load_xml, save


def test_cli_add_and_list(tmp_path: Path, capsys):
    target = tmp_path / "movies.json"
    assert main(["-c", str(target), "add", "Moon", "--year", "2009"]) == 0
    assert main(["-c", str(target), "list"]) == 0
    assert "Moon (2009)" in capsys.readouterr().out


def test_cli_loan_out_and_in(tmp_path: Path, capsys):
    target = tmp_path / "movies.json"
    main(["-c", str(target), "add", "Moon"])

    assert main(["-c", str(target), "loan-out", "1", "Sam Bell"]) == 0
    assert load(target).get(1).borrower == "Sam Bell"
    assert main(["-c", str(target), "loan-in", "1"]) == 0
    assert load(target).get(1).borrower == ""
    assert main(["-c", str(target), "loan-history", "--json"]) == 0
    output = capsys.readouterr().out
    assert "Checked out #1 to Sam Bell" in output
    events = json.loads(output.splitlines()[-1])
    assert [(event["action"], event["borrower"]) for event in events] == [
        ("out", "Sam Bell"),
        ("in", "Sam Bell"),
    ]


def test_cli_manages_and_lists_borrowers(tmp_path: Path, capsys):
    target = tmp_path / "movies.json"
    assert main(["-c", str(target), "borrower-add", "Sam Bell"]) == 0
    assert main(["-c", str(target), "borrowers", "--json"]) == 0
    assert json.loads(capsys.readouterr().out.splitlines()[-1]) == ["Sam Bell"]
    assert main(["-c", str(target), "borrower-remove", "sam bell"]) == 0
    assert load(target).metadata["amc_python_borrowers"] == []


def test_cli_exports_upstream_style_loan_history(tmp_path: Path):
    target = tmp_path / "movies.json"
    history = tmp_path / "history.csv"
    main(["-c", str(target), "add", "Moon"])
    main(["-c", str(target), "loan-out", "1", "Sam Bell"])

    assert (
        main(
            [
                "-c",
                str(target),
                "loan-history-export",
                str(history),
                "--catalog-name",
                "Moon.amc",
            ]
        )
        == 0
    )

    assert "\tMoon.amc\tOut\t1\t\tMoon\tSam Bell" in history.read_text()


def test_cli_can_include_movies_with_same_media_label(tmp_path: Path):
    target = tmp_path / "movies.json"
    save(
        Catalog(
            [
                Movie(number=1, title="Part one", media_label="BOX"),
                Movie(number=2, title="Part two", media_label="box"),
            ]
        ),
        target,
    )

    assert main(["-c", str(target), "loan-out", "2", "Ripley", "--include-media-label"]) == 0
    assert [movie.borrower for movie in load(target)] == ["Ripley", "Ripley"]
    assert main(["-c", str(target), "loan-in", "1", "--include-media-label"]) == 0
    assert [movie.borrower for movie in load(target)] == ["", ""]


def test_cli_can_include_movies_with_same_retained_native_number(tmp_path: Path):
    target = tmp_path / "movies.json"
    save(
        Catalog(
            [
                Movie(number=1, title="Part one", extras={"native_movie_number": 7}),
                Movie(number=2, title="Part two", extras={"native_movie_number": 7}),
            ]
        ),
        target,
    )

    assert main(["-c", str(target), "loan-out", "2", "Ripley", "--include-native-number"]) == 0
    assert [movie.borrower for movie in load(target)] == ["Ripley", "Ripley"]


def test_cli_edit_and_export(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    xml = tmp_path / "movies.xml"
    main(["-c", str(catalog), "add", "Moo"])
    main(["-c", str(catalog), "edit", "1", "--title", "Moon", "--year", "2009"])
    main(["-c", str(catalog), "export-xml", str(xml)])
    movie = next(iter(load_xml(xml)))
    assert (movie.title, movie.year) == ("Moon", 2009)


def test_cli_export_scope_checked_includes_only_checked_movies(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    xml = tmp_path / "movies.xml"
    save(
        Catalog(
            [
                Movie(number=1, title="Alien", checked=True),
                Movie(number=2, title="Aliens", checked=False),
            ]
        ),
        catalog,
    )

    assert main(["-c", str(catalog), "export-xml", str(xml), "--scope", "checked"]) == 0

    assert [movie.title for movie in load_xml(xml)] == ["Alien"]
    assert len(load(catalog)) == 2


def test_cli_export_sort_by_and_reverse_do_not_change_the_catalog(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    xml = tmp_path / "movies.xml"
    save(Catalog([Movie(number=1, title="Bravo"), Movie(number=2, title="Alpha")]), catalog)

    assert main(["-c", str(catalog), "export-xml", str(xml), "--sort-by", "title"]) == 0
    assert [movie.title for movie in load_xml(xml)] == ["Alpha", "Bravo"]
    assert [movie.title for movie in load(catalog)] == ["Bravo", "Alpha"]

    assert (
        main(
            [
                "-c",
                str(catalog),
                "export-xml",
                str(xml),
                "--sort-by",
                "title",
                "--sort-reverse",
            ]
        )
        == 0
    )
    assert [movie.title for movie in load_xml(xml)] == ["Bravo", "Alpha"]


def test_cli_native_export_accepts_encoding_and_budgets(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    target = tmp_path / "movies.amc"
    save(Catalog([Movie(title="Amélie")]), catalog)

    assert (
        main(
            [
                "-c",
                str(catalog),
                "export-amc",
                str(target),
                "--encoding",
                "utf-8",
                "--max-output-bytes",
                "4096",
                "--max-string-bytes",
                "1024",
                "--max-picture-bytes",
                "16",
                "--max-total-picture-bytes",
                "32",
                "--max-movies",
                "1",
                "--max-custom-fields",
                "0",
                "--max-list-values",
                "0",
                "--max-extras-per-movie",
                "0",
                "--max-total-extras",
                "0",
            ]
        )
        == 0
    )

    assert target.exists()


@pytest.mark.parametrize(
    ("option", "message"),
    [
        ("--max-movies", "movie-count limit"),
        ("--max-custom-fields", "custom-field limit"),
        ("--max-list-values", "list-value limit"),
        ("--max-extras-per-movie", "supplementary-record limit"),
        ("--max-total-extras", "supplementary-record limit"),
    ],
)
def test_cli_native_export_exposes_structural_budgets(
    tmp_path: Path, capsys, option: str, message: str
):
    catalog = tmp_path / f"{option[2:]}.json"
    target = tmp_path / f"{option[2:]}.amc"
    field = {"tag": "Mood", "field_type": "List", "list_values": ["Calm"]}
    movie = Movie(extras={"native_supplementary_records": [{}]})
    save(Catalog([movie], metadata={"native": {"custom_fields": [field]}}), catalog)
    target.write_bytes(b"trusted")

    assert main(["-c", str(catalog), "export-amc", str(target), option, "0"]) == 2

    assert message in capsys.readouterr().err
    assert target.read_bytes() == b"trusted"


def test_cli_native_export_rejects_invalid_budget_atomically(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    target = tmp_path / "movies.amc"
    save(Catalog([Movie(title="Alien")]), catalog)
    target.write_bytes(b"trusted")

    assert (
        main(
            [
                "-c",
                str(catalog),
                "export-amc",
                str(target),
                "--max-output-bytes",
                "64",
            ]
        )
        == 2
    )

    assert target.read_bytes() == b"trusted"


def test_cli_embeds_exports_and_clears_picture(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    source = tmp_path / "cover.jpg"
    destination = tmp_path / "copy.jpg"
    save(Catalog([Movie(title="Alien")]), catalog)
    from PIL import Image

    Image.new("RGB", (2, 2), "green").save(source)
    expected = source.read_bytes()

    assert main(["-c", str(catalog), "picture-set", "1", str(source), "--embed"]) == 0
    source.unlink()
    assert main(["-c", str(catalog), "picture-export", "1", str(destination)]) == 0
    assert destination.read_bytes() == expected
    assert main(["-c", str(catalog), "picture-clear", "1"]) == 0
    assert load(catalog).get(1).picture == ""


def test_cli_sets_pictures_for_multiple_movies_in_one_invocation(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    cover_one = tmp_path / "one.jpg"
    cover_one.write_bytes(b"image one")
    cover_two = tmp_path / "two.jpg"
    cover_two.write_bytes(b"image two")
    save(
        Catalog([Movie(number=1, title="One"), Movie(number=2, title="Two")]),
        catalog,
    )

    assert (
        main(
            [
                "-c",
                str(catalog),
                "picture-set-many",
                "--assign",
                f"1={cover_one}",
                "--assign",
                f"2={cover_two}",
            ]
        )
        == 0
    )

    assert load(catalog).get(1).picture == str(cover_one)
    assert load(catalog).get(2).picture == str(cover_two)


def test_cli_rejects_malformed_picture_set_many_assignments(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    save(Catalog([Movie(number=1, title="One")]), catalog)

    assert (
        main(
            [
                "-c",
                str(catalog),
                "picture-set-many",
                "--assign",
                "not-an-assignment",
            ]
        )
        == 2
    )
    assert (
        main(
            [
                "-c",
                str(catalog),
                "picture-set-many",
                "--assign",
                "x=cover.jpg",
            ]
        )
        == 2
    )


def test_cli_applies_per_movie_crop_rectangles_in_picture_set_many(tmp_path: Path):
    from PIL import Image

    catalog = tmp_path / "movies.json"
    cover_one = tmp_path / "one.png"
    image_one = Image.new("RGB", (4, 4), "red")
    image_one.putpixel((1, 1), (0, 255, 0))
    image_one.save(cover_one)
    cover_two = tmp_path / "two.png"
    image_two = Image.new("RGB", (4, 4), "blue")
    image_two.putpixel((0, 0), (255, 255, 0))
    image_two.save(cover_two)
    save(
        Catalog([Movie(number=1, title="One"), Movie(number=2, title="Two")]),
        catalog,
    )

    assert (
        main(
            [
                "-c",
                str(catalog),
                "picture-set-many",
                "--assign",
                f"1={cover_one}",
                "--assign",
                f"2={cover_two}",
                "--embed",
                "--crop",
                "0,0,1,1",
                "--crop-for",
                "1=1,1,1,1",
            ]
        )
        == 0
    )

    exported_one = tmp_path / "exported-one.png"
    assert (
        main(
            [
                "-c",
                str(catalog),
                "picture-export",
                "1",
                str(exported_one),
            ]
        )
        == 0
    )
    with Image.open(exported_one) as cropped:
        assert cropped.getpixel((0, 0)) == (0, 255, 0)

    exported_two = tmp_path / "exported-two.png"
    assert (
        main(
            [
                "-c",
                str(catalog),
                "picture-export",
                "2",
                str(exported_two),
            ]
        )
        == 0
    )
    with Image.open(exported_two) as cropped:
        assert cropped.getpixel((0, 0)) == (255, 255, 0)


def test_cli_rejects_malformed_or_unknown_crop_for_entries(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    cover = tmp_path / "cover.jpg"
    cover.write_bytes(b"image")
    save(Catalog([Movie(number=1, title="One")]), catalog)

    assert (
        main(
            [
                "-c",
                str(catalog),
                "picture-set-many",
                "--assign",
                f"1={cover}",
                "--embed",
                "--crop-for",
                "not-an-entry",
            ]
        )
        == 2
    )
    assert (
        main(
            [
                "-c",
                str(catalog),
                "picture-set-many",
                "--assign",
                f"1={cover}",
                "--embed",
                "--crop-for",
                "9=0,0,1,1",
            ]
        )
        == 2
    )


def test_cli_clears_pictures_for_multiple_movies_in_one_invocation(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    save(
        Catalog(
            [
                Movie(number=1, title="One", picture="one.jpg"),
                Movie(number=2, title="Two", picture="two.jpg"),
            ]
        ),
        catalog,
    )

    assert main(["-c", str(catalog), "picture-clear", "1", "2"]) == 0

    assert load(catalog).get(1).picture == ""
    assert load(catalog).get(2).picture == ""


def test_cli_crops_embedded_picture(tmp_path: Path):
    from PIL import Image

    catalog = tmp_path / "movies.json"
    source = tmp_path / "cover.png"
    destination = tmp_path / "crop.png"
    save(Catalog([Movie(title="Alien")]), catalog)
    Image.new("RGB", (5, 4), "purple").save(source)

    assert (
        main(
            [
                "-c",
                str(catalog),
                "picture-set",
                "1",
                str(source),
                "--embed",
                "--crop",
                "1,1,2,2",
            ]
        )
        == 0
    )
    assert main(["-c", str(catalog), "picture-export", "1", str(destination)]) == 0
    with Image.open(destination) as cropped:
        assert cropped.size == (2, 2)


def test_cli_rejects_malformed_crop(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    source = tmp_path / "cover.png"
    save(Catalog([Movie(title="Alien")]), catalog)
    source.write_bytes(b"unused")

    assert (
        main(
            [
                "-c",
                str(catalog),
                "picture-set",
                "1",
                str(source),
                "--embed",
                "--crop",
                "1,2,3",
            ]
        )
        == 2
    )
    assert load(catalog).get(1).picture == ""


def test_cli_exports_html(tmp_path: Path):
    catalog = tmp_path / "catalog.json"
    target = tmp_path / "catalog.html"
    save(Catalog([Movie(title="Alien")]), catalog)
    assert main(["-c", str(catalog), "export-html", str(target)]) == 0
    assert '<td class="title">Alien</td>' in target.read_text(encoding="utf-8")


def test_cli_exports_native_42_catalog(tmp_path: Path):
    catalog = tmp_path / "catalog.json"
    target = tmp_path / "catalog.amc"
    save(Catalog([Movie(original_title="Alien", year=1979, rating=8.0)]), catalog)

    assert main(["-c", str(catalog), "export-amc", str(target)]) == 0

    restored = load(target).get(1)
    assert (restored.original_title, restored.year, restored.rating) == ("Alien", 1979, 8.0)


def test_cli_import_exposes_collision_policy(tmp_path: Path, capsys):
    destination = tmp_path / "destination.json"
    source = tmp_path / "source.json"
    save(Catalog([Movie(number=1, title="Existing")]), destination)
    save(Catalog([Movie(number=1, title="Incoming")]), source)

    assert main(["-c", str(destination), "import", str(source), "--collision", "skip"]) == 0
    assert "Imported 0 movie(s)" in capsys.readouterr().out
    assert [(movie.number, movie.title) for movie in load(destination)] == [(1, "Existing")]


def test_cli_import_accepts_explicit_native_string_encoding(tmp_path: Path):
    from amc.native import write_native_catalog

    source = tmp_path / "utf8.amc"
    destination = tmp_path / "catalog.json"
    write_native_catalog(
        Catalog([Movie(number=1, original_title="千と千尋")]),
        source,
        encoding="utf-8",
    )

    assert (
        main(
            [
                "-c",
                str(destination),
                "import",
                str(source),
                "--native-encoding",
                "utf-8",
            ]
        )
        == 0
    )

    assert load(destination).get(1).original_title == "千と千尋"


def test_cli_import_rejects_unknown_native_string_encoding(tmp_path: Path, capsys):
    from amc.native import write_native_catalog

    source = tmp_path / "source.amc"
    destination = tmp_path / "catalog.json"
    write_native_catalog(Catalog([Movie(original_title="Alien")]), source)

    assert (
        main(
            [
                "-c",
                str(destination),
                "import",
                str(source),
                "--native-encoding",
                "not-a-codec",
            ]
        )
        == 2
    )

    assert "unknown encoding" in capsys.readouterr().err
    assert not destination.exists()


def test_cli_import_enforces_native_read_limits_before_merge(tmp_path: Path, capsys):
    from amc.native import write_native_catalog

    source = tmp_path / "source.amc"
    destination = tmp_path / "catalog.json"
    write_native_catalog(Catalog([Movie(number=1, original_title="Alien")]), source)
    save(Catalog([Movie(number=9, title="Existing")]), destination)
    original = destination.read_bytes()

    assert main(["-c", str(destination), "import", str(source), "--max-movies", "0"]) == 2

    assert "exceeds movie-count limit" in capsys.readouterr().err
    assert destination.read_bytes() == original


def test_cli_import_exposes_metadata_namespace_policy(tmp_path: Path):
    destination = tmp_path / "destination.json"
    source = tmp_path / "source.json"
    save(Catalog(metadata={"owner": "Destination"}), destination)
    save(Catalog(metadata={"owner": "Incoming"}), source)

    assert main(["-c", str(destination), "import", str(source), "--metadata", "namespace"]) == 0
    assert load(destination).metadata["amc_python_merge_namespaces"] == {
        "import_1": {"owner": "Incoming"}
    }


def test_cli_list_search_and_stats_support_json(tmp_path: Path, capsys):
    target = tmp_path / "catalog.json"
    save(
        Catalog(
            [
                Movie(number=1, title="Alien", director="Ridley Scott", length=117),
                Movie(number=2, title="Aliens", director="James Cameron", length=137),
            ]
        ),
        target,
    )

    assert main(["-c", str(target), "list", "--json"]) == 0
    listing = json.loads(capsys.readouterr().out)
    assert [row["title"] for row in listing] == ["Alien", "Aliens"]

    assert main(["-c", str(target), "search", "Cameron", "--json"]) == 0
    search = json.loads(capsys.readouterr().out)
    assert [row["title"] for row in search] == ["Aliens"]

    assert main(["-c", str(target), "stats", "--json"]) == 0
    assert json.loads(capsys.readouterr().out) == {
        "average_rating": None,
        "checked": 0,
        "earliest_year": None,
        "latest_year": None,
        "movies": 2,
        "total_length": 254,
    }


def test_cli_search_field_whole_field_and_reverse(tmp_path: Path, capsys):
    target = tmp_path / "catalog.json"
    save(
        Catalog(
            [
                Movie(number=1, title="Alien", director="Ridley Scott"),
                Movie(number=2, title="Scott Pilgrim", director="Edgar Wright"),
            ]
        ),
        target,
    )

    assert main(["-c", str(target), "search", "scott", "--field", "director", "--json"]) == 0
    assert [row["number"] for row in json.loads(capsys.readouterr().out)] == [1]

    assert main(["-c", str(target), "search", "scott", "--field", "title", "--json"]) == 0
    assert [row["number"] for row in json.loads(capsys.readouterr().out)] == [2]

    assert (
        main(
            [
                "-c",
                str(target),
                "search",
                "alien",
                "--field",
                "title",
                "--whole-field",
                "--json",
            ]
        )
        == 0
    )
    assert [row["number"] for row in json.loads(capsys.readouterr().out)] == [1]

    assert (
        main(["-c", str(target), "search", "scott", "--field", "director", "--reverse", "--json"])
        == 0
    )
    assert [row["number"] for row in json.loads(capsys.readouterr().out)] == [2]


def test_cli_search_rejects_an_unknown_field(tmp_path: Path):
    target = tmp_path / "catalog.json"
    save(Catalog([Movie(number=1, title="Alien")]), target)

    assert main(["-c", str(target), "search", "x", "--field", "bogus"]) == 2


def test_cli_duplicates_supports_json(tmp_path: Path, capsys):
    target = tmp_path / "catalog.json"
    save(
        Catalog(
            [
                Movie(number=1, title="Alien", year=1979),
                Movie(number=2, original_title="alien", year=1979),
            ]
        ),
        target,
    )
    assert main(["-c", str(target), "duplicates", "--json"]) == 0
    groups = json.loads(capsys.readouterr().out)
    assert [[movie["number"] for movie in group] for group in groups] == [[1, 2]]


def test_cli_reports_missing_movie_without_traceback(tmp_path: Path, capsys):
    result = main(["-c", str(tmp_path / "empty.json"), "remove", "99"])
    assert result == 2
    assert "movie 99 does not exist" in capsys.readouterr().err


def test_cli_does_not_overwrite_native_catalog_with_json(tmp_path: Path, capsys):
    from amc.native import write_native_catalog

    target = tmp_path / "movies.amc"
    write_native_catalog(Catalog([Movie(original_title="Alien")]), target)
    original_bytes = target.read_bytes()

    assert main(["-c", str(target), "add", "Aliens"]) == 2
    assert "read-only" in capsys.readouterr().err
    assert target.read_bytes() == original_bytes


def test_cli_edit_set_supports_complete_typed_fields(tmp_path: Path):
    target = tmp_path / "catalog.json"
    save(Catalog([Movie(number=1, title="Before")]), target)
    assert (
        main(
            [
                "-c",
                str(target),
                "edit",
                "1",
                "--set",
                'original_title="Alien"',
                "--set",
                "year=1979",
                "--set",
                "rating=8.5",
                "--set",
                "checked=true",
                "--set",
                'extras={"edition":"Director cut"}',
            ]
        )
        == 0
    )
    movie = load(target).get(1)
    assert (movie.original_title, movie.year, movie.rating, movie.checked) == (
        "Alien",
        1979,
        8.5,
        True,
    )
    assert movie.extras == {"edition": "Director cut"}


def test_cli_edit_set_rejects_invalid_values_without_saving(tmp_path: Path):
    target = tmp_path / "catalog.json"
    save(Catalog([Movie(number=1, title="Before")]), target)
    previous = target.read_bytes()
    assert main(["-c", str(target), "edit", "1", "--set", 'year="1979"']) == 2
    assert target.read_bytes() == previous
    assert main(["-c", str(target), "edit", "1", "--set", "number=2"]) == 2
    assert target.read_bytes() == previous


_OMDB_RECORD = {
    "Title": "Alien",
    "Year": "1979",
    "Rated": "R",
    "Runtime": "117 min",
    "Genre": "Horror, Sci-Fi",
    "Director": "Ridley Scott",
    "Writer": "Dan O'Bannon",
    "Actors": "Sigourney Weaver",
    "Plot": "A crew encounters a deadly lifeform.",
    "Language": "English",
    "Country": "United States",
    "imdbRating": "8.5",
    "imdbID": "tt0078748",
    "Response": "True",
}


def test_cli_imdb_lookup_previews_without_saving(monkeypatch, tmp_path: Path, capsys):
    calls = []

    def fake_fetch(**kwargs):
        calls.append(kwargs)
        return dict(_OMDB_RECORD)

    monkeypatch.setattr("amc.cli.fetch_omdb_record", fake_fetch)
    target = tmp_path / "catalog.json"
    save(Catalog([Movie(number=1, title="Alien")]), target)

    assert main(["-c", str(target), "imdb-lookup", "1", "--api-key", "testkey"]) == 0

    assert calls[0]["api_key"] == "testkey"
    assert calls[0]["title"] == "Alien"
    movie = load(target).get(1)
    assert movie.director == ""  # preview only, catalog untouched
    output = capsys.readouterr().out
    assert "Preview for #1" in output
    assert "use --apply to save" in output
    assert "director: '' -> 'Ridley Scott'" in output


def test_cli_imdb_lookup_apply_saves_the_previewed_changes(monkeypatch, tmp_path: Path, capsys):
    monkeypatch.setattr("amc.cli.fetch_omdb_record", lambda **kwargs: dict(_OMDB_RECORD))
    target = tmp_path / "catalog.json"
    save(Catalog([Movie(number=1, title="Alien")]), target)

    assert main(["-c", str(target), "imdb-lookup", "1", "--api-key", "k", "--apply"]) == 0

    movie = load(target).get(1)
    assert movie.director == "Ridley Scott"
    assert movie.rating == 8.5
    assert movie.year == 1979
    assert "Updated #1" in capsys.readouterr().out


def test_cli_imdb_lookup_reports_no_changes_without_touching_the_catalog(
    monkeypatch, tmp_path: Path, capsys
):
    matching = Movie(
        number=1,
        title="Alien",
        director="Ridley Scott",
        writer="Dan O'Bannon",
        actors="Sigourney Weaver",
        description="A crew encounters a deadly lifeform.",
        category="Horror, Sci-Fi",
        country="United States",
        languages="English",
        certification="R",
        year=1979,
        length=117,
        rating=8.5,
        url="https://www.imdb.com/title/tt0078748/",
    )
    monkeypatch.setattr("amc.cli.fetch_omdb_record", lambda **kwargs: dict(_OMDB_RECORD))
    target = tmp_path / "catalog.json"
    save(Catalog([matching]), target)
    previous = target.read_bytes()

    assert main(["-c", str(target), "imdb-lookup", "1", "--api-key", "k", "--apply"]) == 0

    assert target.read_bytes() == previous
    assert "No changes for #1" in capsys.readouterr().out


def test_cli_imdb_lookup_uses_the_env_var_api_key_when_no_flag_given(monkeypatch, tmp_path: Path):
    calls = []
    monkeypatch.setattr(
        "amc.cli.fetch_omdb_record",
        lambda **kwargs: calls.append(kwargs) or dict(_OMDB_RECORD),
    )
    monkeypatch.setenv("OMDB_API_KEY", "from-env")
    target = tmp_path / "catalog.json"
    save(Catalog([Movie(number=1, title="Alien")]), target)

    assert main(["-c", str(target), "imdb-lookup", "1"]) == 0

    assert calls[0]["api_key"] == "from-env"


def test_cli_imdb_lookup_prefers_an_existing_imdb_url_over_title_search(
    monkeypatch, tmp_path: Path
):
    calls = []
    monkeypatch.setattr(
        "amc.cli.fetch_omdb_record",
        lambda **kwargs: calls.append(kwargs) or dict(_OMDB_RECORD),
    )
    target = tmp_path / "catalog.json"
    save(
        Catalog(
            [
                Movie(number=1, title="Alien", url="https://www.imdb.com/title/tt0078748/"),
            ]
        ),
        target,
    )

    assert main(["-c", str(target), "imdb-lookup", "1", "--api-key", "k"]) == 0

    assert calls[0]["imdb_id"] == "tt0078748"
    assert calls[0]["title"] == ""


def test_cli_imdb_lookup_requires_an_api_key(monkeypatch, tmp_path: Path):
    monkeypatch.delenv("OMDB_API_KEY", raising=False)
    target = tmp_path / "catalog.json"
    save(Catalog([Movie(number=1, title="Alien")]), target)
    assert main(["-c", str(target), "imdb-lookup", "1"]) == 2


def test_cli_exit_status_constants_are_stable():
    from amc.cli import EXIT_ERROR, EXIT_INVALID_CATALOG, EXIT_SUCCESS

    assert (EXIT_SUCCESS, EXIT_INVALID_CATALOG, EXIT_ERROR) == (0, 1, 2)


def test_cli_backup_and_restore_roundtrip(tmp_path: Path):
    catalog = tmp_path / "catalog.json"
    backup = tmp_path / "backup.json"
    save(Catalog([Movie(title="Original")]), catalog)

    assert main(["-c", str(catalog), "backup", str(backup)]) == 0
    save(Catalog([Movie(title="Changed")]), catalog)
    assert main(["-c", str(catalog), "restore", str(backup)]) == 0
    assert next(iter(load(catalog))).title == "Original"
