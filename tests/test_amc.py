import json
import math
from pathlib import Path

import pytest

from amc import Catalog, Movie
from amc.cli import main
from amc.storage import copy_catalog, load, load_csv, load_xml, save, save_csv, save_html, save_xml


def test_catalog_numbers_search_and_json_roundtrip(tmp_path: Path):
    catalog = Catalog()
    catalog.add(Movie(title="Alien", director="Ridley Scott", year=1979))
    catalog.add(Movie(title="Aliens", director="James Cameron", year=1986))
    assert [movie.number for movie in catalog] == [1, 2]
    assert [movie.title for movie in catalog.search("cameron")] == ["Aliens"]
    target = tmp_path / "catalog.json"
    save(catalog, target)
    assert [movie.to_dict() for movie in load(target)] == [movie.to_dict() for movie in catalog]


def test_json_catalog_with_legacy_amc_extension_still_opens(tmp_path: Path):
    target = tmp_path / "legacy-working-catalog.amc"
    original = Catalog([Movie(number=1, title="Alien", year=1979)])
    save(original, target)

    restored = load(target)

    assert [movie.to_dict() for movie in restored] == [
        movie.to_dict() for movie in original
    ]


def test_bom_prefixed_json_catalog_with_legacy_amc_extension_still_opens(
    tmp_path: Path,
):
    target = tmp_path / "legacy-working-catalog.amc"
    document = json.dumps(
        {"format": "amc-python", "version": 1, "movies": [], "metadata": {}}
    )
    target.write_bytes(b"\xef\xbb\xbf" + document.encode("utf-8"))

    assert len(load(target)) == 0


def test_bom_prefixed_json_catalog_opens(tmp_path: Path):
    target = tmp_path / "catalog.json"
    document = json.dumps(
        {"format": "amc-python", "version": 1, "movies": [], "metadata": {}}
    )
    target.write_bytes(b"\xef\xbb\xbf" + document.encode("utf-8"))

    assert len(load(target)) == 0


def test_import_ant_xml(tmp_path: Path):
    source = tmp_path / "catalog.xml"
    source.write_text('''<?xml version="1.0"?><AntMovieCatalog><Catalog><Contents>
      <Movie Number="42" Checked="True"><OriginalTitle>Amélie</OriginalTitle><Year>2001</Year>
      <Length>122 min</Length><Rating>8,3</Rating><CustomField>value</CustomField></Movie>
      </Contents></Catalog></AntMovieCatalog>''', encoding="utf-8")
    movie = next(iter(load_xml(source)))
    assert (movie.number, movie.original_title, movie.year, movie.length, movie.rating) == (42, "Amélie", 2001, 122, 8.3)
    assert movie.checked and movie.extras == {"CustomField": "value"}


def test_import_realistic_attribute_based_ant_xml(tmp_path: Path):
    source = tmp_path / "attributes.xml"
    source.write_text('''<AntMovieCatalog><Catalog><Contents>
      <Movie Number="3" Checked="False" OriginalTitle="Brazil" Year="1985"
       Languages="English, French" VideoBitrate="1200" Framerate="23,976"
       UnknownAttribute="kept"><Description>Future imperfect.</Description></Movie>
      </Contents></Catalog></AntMovieCatalog>''', encoding="utf-8")
    movie = next(iter(load_xml(source)))
    assert (movie.original_title, movie.year, movie.video_bitrate, movie.framerate) == ("Brazil", 1985, 1200, 23.976)
    assert movie.description == "Future imperfect."
    assert movie.extras == {"UnknownAttribute": "kept"}


def test_import_ant_xml_maps_disks_and_size_not_mediacount_and_filesize(tmp_path: Path):
    """`Disks` and `Size` are the real Ant Movie Catalog 4.2.2 XML attribute
    names (confirmed against a genuine upstream export and against
    `Movie Catalog/fields.pas`'s strTagFields table); `MediaCount` and
    `FileSize` never appear in any upstream-produced XML and were a
    previous naming bug in this reader/writer."""
    source = tmp_path / "catalog.xml"
    source.write_text(
        '<AntMovieCatalog><Catalog><Contents>'
        '<Movie Number="1" Checked="False" OriginalTitle="Brazil" '
        'Disks="2" Size="1835" /></Contents></Catalog></AntMovieCatalog>',
        encoding="utf-8",
    )
    movie = next(iter(load_xml(source)))
    assert (movie.media_count, movie.file_size) == (2, 1835)
    assert movie.extras == {}


def test_import_ant_xml_retains_multipart_size_text_without_data_loss(tmp_path: Path):
    """Ant Movie Catalog's Size field is free-form text, not a plain
    integer: a multi-part release is exported as "+"-joined sizes (e.g. a
    genuine "698+696" observed in a real catalog). Silently taking only the
    first number would discard the rest, so the exact original text is
    retained in extras instead when it isn't a plain integer."""
    source = tmp_path / "catalog.xml"
    source.write_text(
        '<AntMovieCatalog><Catalog><Contents>'
        '<Movie Number="1" OriginalTitle="Split Release" Size="698+696" />'
        '</Contents></Catalog></AntMovieCatalog>',
        encoding="utf-8",
    )
    movie = next(iter(load_xml(source)))
    assert movie.file_size is None
    assert movie.extras == {"xml_file_size_text": "698+696"}

    target = tmp_path / "export.xml"
    save_xml(Catalog([movie]), target)
    reloaded = next(iter(load_xml(target)))
    assert reloaded.file_size is None
    assert reloaded.extras == {"xml_file_size_text": "698+696"}
    assert 'Size="698+696"' in target.read_text(encoding="utf-8")


def test_import_ant_xml_recovers_from_declared_encoding_mismatch(tmp_path: Path):
    """A genuine AMC 4.2.2 export was observed containing a raw multi-byte
    UTF-8 emoji inside a file declared as single-byte windows-1252 (a real
    upstream/Delphi encoding mismatch in the source data, not something
    this writer produces). Strict XML parsing correctly rejects that byte
    sequence; retry once, tolerantly, so the rest of an otherwise-valid
    catalog still loads instead of failing outright."""
    source = tmp_path / "mismatched.xml"
    document = (
        b'<?xml version="1.0" encoding="windows-1252"?>'
        b'<AntMovieCatalog><Catalog><Contents>'
        b'<Movie Number="1" OriginalTitle="Brazil"><Comments>'
        b"cat face: " + "🐱".encode("utf-8") +
        b'</Comments></Movie></Contents></Catalog></AntMovieCatalog>'
    )
    source.write_bytes(document)

    movie = next(iter(load_xml(source)))

    assert movie.original_title == "Brazil"
    assert "cat face:" in movie.comments


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
        ("out", "Sam Bell"), ("in", "Sam Bell")
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

    assert main([
        "-c", str(target), "loan-history-export", str(history),
        "--catalog-name", "Moon.amc",
    ]) == 0

    assert "\tMoon.amc\tOut\t1\t\tMoon\tSam Bell" in history.read_text()


def test_cli_can_include_movies_with_same_media_label(tmp_path: Path):
    target = tmp_path / "movies.json"
    save(Catalog([
        Movie(number=1, title="Part one", media_label="BOX"),
        Movie(number=2, title="Part two", media_label="box"),
    ]), target)

    assert main([
        "-c", str(target), "loan-out", "2", "Ripley", "--include-media-label"
    ]) == 0
    assert [movie.borrower for movie in load(target)] == ["Ripley", "Ripley"]
    assert main([
        "-c", str(target), "loan-in", "1", "--include-media-label"
    ]) == 0
    assert [movie.borrower for movie in load(target)] == ["", ""]


def test_cli_can_include_movies_with_same_retained_native_number(tmp_path: Path):
    target = tmp_path / "movies.json"
    save(Catalog([
        Movie(number=1, title="Part one", extras={"native_movie_number": 7}),
        Movie(number=2, title="Part two", extras={"native_movie_number": 7}),
    ]), target)

    assert main([
        "-c", str(target), "loan-out", "2", "Ripley", "--include-native-number"
    ]) == 0
    assert [movie.borrower for movie in load(target)] == ["Ripley", "Ripley"]


def test_xml_roundtrip_preserves_supported_and_custom_fields(tmp_path: Path):
    target = tmp_path / "export.xml"
    original = Movie(
        number=7, title="Moon", year=2009, checked=True,
        user_rating=8.5, color_tag=2,
        writer="Duncan Jones", composer="Clint Mansell",
        certification="R", file_path="Media/Moon.mkv",
        extras={"CustomField": "kept"},
    )
    save_xml(Catalog([original]), target)
    restored = next(iter(load_xml(target)))
    assert (restored.number, restored.title, restored.year, restored.checked) == (7, "Moon", 2009, True)
    assert (restored.writer, restored.composer, restored.certification) == (
        "Duncan Jones", "Clint Mansell", "R"
    )
    assert restored.file_path == "Media/Moon.mkv"
    assert (restored.user_rating, restored.color_tag) == (8.5, 2)
    assert restored.extras == {"CustomField": "kept"}


def test_cli_edit_and_export(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    xml = tmp_path / "movies.xml"
    main(["-c", str(catalog), "add", "Moo"])
    main(["-c", str(catalog), "edit", "1", "--title", "Moon", "--year", "2009"])
    main(["-c", str(catalog), "export-xml", str(xml)])
    movie = next(iter(load_xml(xml)))
    assert (movie.title, movie.year) == ("Moon", 2009)


def test_cli_native_export_accepts_encoding_and_budgets(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    target = tmp_path / "movies.amc"
    save(Catalog([Movie(title="Amélie")]), catalog)

    assert main([
        "-c", str(catalog), "export-amc", str(target),
        "--encoding", "utf-8", "--max-output-bytes", "4096",
        "--max-string-bytes", "1024", "--max-picture-bytes", "16",
        "--max-total-picture-bytes", "32",
        "--max-movies", "1", "--max-custom-fields", "0",
        "--max-list-values", "0", "--max-extras-per-movie", "0",
        "--max-total-extras", "0",
    ]) == 0

    assert target.exists()


@pytest.mark.parametrize(("option", "message"), [
    ("--max-movies", "movie-count limit"),
    ("--max-custom-fields", "custom-field limit"),
    ("--max-list-values", "list-value limit"),
    ("--max-extras-per-movie", "supplementary-record limit"),
    ("--max-total-extras", "supplementary-record limit"),
])
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

    assert main([
        "-c", str(catalog), "export-amc", str(target),
        "--max-output-bytes", "64",
    ]) == 2

    assert target.read_bytes() == b"trusted"


def test_cli_embeds_exports_and_clears_picture(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    source = tmp_path / "cover.jpg"
    destination = tmp_path / "copy.jpg"
    save(Catalog([Movie(title="Alien")]), catalog)
    from PIL import Image

    Image.new("RGB", (2, 2), "green").save(source)
    expected = source.read_bytes()

    assert main([
        "-c", str(catalog), "picture-set", "1", str(source), "--embed"
    ]) == 0
    source.unlink()
    assert main([
        "-c", str(catalog), "picture-export", "1", str(destination)
    ]) == 0
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

    assert main([
        "-c", str(catalog), "picture-set-many",
        "--assign", f"1={cover_one}",
        "--assign", f"2={cover_two}",
    ]) == 0

    assert load(catalog).get(1).picture == str(cover_one)
    assert load(catalog).get(2).picture == str(cover_two)


def test_cli_rejects_malformed_picture_set_many_assignments(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    save(Catalog([Movie(number=1, title="One")]), catalog)

    assert main([
        "-c", str(catalog), "picture-set-many", "--assign", "not-an-assignment",
    ]) == 2
    assert main([
        "-c", str(catalog), "picture-set-many", "--assign", "x=cover.jpg",
    ]) == 2


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

    assert main([
        "-c", str(catalog), "picture-set-many",
        "--assign", f"1={cover_one}",
        "--assign", f"2={cover_two}",
        "--embed",
        "--crop", "0,0,1,1",
        "--crop-for", "1=1,1,1,1",
    ]) == 0

    exported_one = tmp_path / "exported-one.png"
    assert main([
        "-c", str(catalog), "picture-export", "1", str(exported_one),
    ]) == 0
    with Image.open(exported_one) as cropped:
        assert cropped.getpixel((0, 0)) == (0, 255, 0)

    exported_two = tmp_path / "exported-two.png"
    assert main([
        "-c", str(catalog), "picture-export", "2", str(exported_two),
    ]) == 0
    with Image.open(exported_two) as cropped:
        assert cropped.getpixel((0, 0)) == (255, 255, 0)


def test_cli_rejects_malformed_or_unknown_crop_for_entries(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    cover = tmp_path / "cover.jpg"
    cover.write_bytes(b"image")
    save(Catalog([Movie(number=1, title="One")]), catalog)

    assert main([
        "-c", str(catalog), "picture-set-many",
        "--assign", f"1={cover}", "--embed", "--crop-for", "not-an-entry",
    ]) == 2
    assert main([
        "-c", str(catalog), "picture-set-many",
        "--assign", f"1={cover}", "--embed", "--crop-for", "9=0,0,1,1",
    ]) == 2


def test_cli_clears_pictures_for_multiple_movies_in_one_invocation(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    save(
        Catalog([
            Movie(number=1, title="One", picture="one.jpg"),
            Movie(number=2, title="Two", picture="two.jpg"),
        ]),
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

    assert main([
        "-c", str(catalog), "picture-set", "1", str(source),
        "--embed", "--crop", "1,1,2,2",
    ]) == 0
    assert main([
        "-c", str(catalog), "picture-export", "1", str(destination)
    ]) == 0
    with Image.open(destination) as cropped:
        assert cropped.size == (2, 2)


def test_cli_rejects_malformed_crop(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    source = tmp_path / "cover.png"
    save(Catalog([Movie(title="Alien")]), catalog)
    source.write_bytes(b"unused")

    assert main([
        "-c", str(catalog), "picture-set", "1", str(source),
        "--embed", "--crop", "1,2,3",
    ]) == 2
    assert load(catalog).get(1).picture == ""


def test_sort_is_case_insensitive_and_empty_search_returns_all():
    catalog = Catalog([Movie(title="zulu"), Movie(title="Alpha"), Movie(title="beta")])
    catalog.sort()
    assert [movie.title for movie in catalog] == ["Alpha", "beta", "zulu"]
    assert catalog.search("  ") == list(catalog)


def test_descending_sort_keeps_missing_values_last():
    catalog = Catalog([
        Movie(title="Unknown"),
        Movie(title="Older", year=1979),
        Movie(title="Newer", year=2009),
    ])

    catalog.sort("year", reverse=True)

    assert [(movie.title, movie.year) for movie in catalog] == [
        ("Newer", 2009),
        ("Older", 1979),
        ("Unknown", None),
    ]


def test_csv_roundtrip_with_amc_headers_and_custom_fields(tmp_path: Path):
    source = tmp_path / "import.csv"
    source.write_text("Number,OriginalTitle,Year,Rating,Checked,Inventory Code\n9,Brazil,1985,8.1,yes,A-42\n", encoding="utf-8")
    movie = next(iter(load_csv(source)))
    assert (movie.number, movie.original_title, movie.year, movie.rating, movie.checked) == (9, "Brazil", 1985, 8.1, True)
    assert movie.extras == {"Inventory Code": "A-42"}
    target = tmp_path / "export.csv"
    save_csv(Catalog([movie]), target)
    restored = next(iter(load(target)))
    assert restored.to_dict() == movie.to_dict()


def test_csv_load_rejects_duplicate_extras_header(tmp_path: Path):
    source = tmp_path / "import.csv"
    source.write_text("Title,Inventory Code,Inventory Code\nAlien,A-1,A-2\n", encoding="utf-8")
    with pytest.raises(ValueError, match="duplicate CSV header 'Inventory Code'"):
        load_csv(source)


def test_csv_load_rejects_headers_colliding_on_the_same_known_field(tmp_path: Path):
    source = tmp_path / "import.csv"
    source.write_text("Title,title\nAlien,alien\n", encoding="utf-8")
    with pytest.raises(ValueError, match="duplicate CSV header 'title' collides with 'Title'"):
        load_csv(source)


def test_html_export_is_static_escaped_and_atomic(tmp_path: Path):
    target = tmp_path / "catalog.html"
    save_html(Catalog([
        Movie(number=1, title='<script>alert("x")</script>', year=1979,
              director="Scott & Co."),
    ]), target)
    document = target.read_text(encoding="utf-8")
    assert "<!doctype html>" in document
    assert '&lt;script&gt;alert(&quot;x&quot;)&lt;/script&gt;' in document
    assert "Scott &amp; Co." in document
    assert '<script>alert("x")</script>' not in document


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
    assert (restored.original_title, restored.year, restored.rating) == (
        "Alien", 1979, 8.0
    )


def test_html_export_supports_bounded_explicit_template(tmp_path: Path):
    template = tmp_path / "template.html"
    template.write_text("<main><h1>My movies</h1>{{MOVIES}}</main>", encoding="utf-8")
    target = tmp_path / "catalog.html"
    save_html(Catalog([Movie(title="Alien & Aliens")]), target, template=template)
    assert target.read_text(encoding="utf-8") == (
        '<main><h1>My movies</h1>      <tr><td class="number">1</td>'
        '<td class="title">Alien &amp; Aliens</td><td class="year"></td>'
        '<td class="director"></td></tr></main>'
    )

    previous = target.read_bytes()
    template.write_text("no marker", encoding="utf-8")
    with pytest.raises(ValueError, match="exactly one"):
        save_html(Catalog(), target, template=template)
    assert target.read_bytes() == previous


def test_html_export_supports_escaped_row_template(tmp_path: Path):
    row = tmp_path / "row.html"
    row.write_text(
        '<article data-number="{{NUMBER}}"><b>{{TITLE}}</b> '
        '<span>{{YEAR}}</span> <i>{{DIRECTOR}}</i></article>',
        encoding="utf-8",
    )
    target = tmp_path / "catalog.html"
    save_html(
        Catalog([Movie(title="A & B", year=2000, director="<Director>")]),
        target,
        row_template=row,
    )
    document = target.read_text(encoding="utf-8")
    assert (
        '<article data-number="1"><b>A &amp; B</b> <span>2000</span> '
        '<i>&lt;Director&gt;</i></article>' in document
    )
    row.write_text("{{UNSAFE}}", encoding="utf-8")
    previous = target.read_bytes()
    with pytest.raises(ValueError, match="unknown HTML row template marker"):
        save_html(Catalog(), target, row_template=row)
    assert target.read_bytes() == previous


def test_html_row_template_supports_every_modeled_scalar_field(tmp_path: Path):
    row = tmp_path / "row.html"
    row.write_text(
        "{{DISPLAY_TITLE}}|{{ORIGINAL_TITLE}}|{{RATING}}|{{CHECKED}}|{{DESCRIPTION}}",
        encoding="utf-8",
    )
    target = tmp_path / "catalog.html"
    save_html(
        Catalog([Movie(
            title="Display", original_title="A & B", rating=8.5, checked=True,
            description="<safe>",
        )]),
        target,
        row_template=row,
    )
    assert "Display|A &amp; B|8.5|true|&lt;safe&gt;" in target.read_text(
        encoding="utf-8"
    )


def test_renumber_and_statistics():
    catalog = Catalog([
        Movie(number=8, title="A", year=2000, length=100, rating=8, checked=True),
        Movie(number=20, title="B", year=2010, length=90, rating=6),
    ])
    catalog.renumber()
    assert [movie.number for movie in catalog] == [1, 2]
    assert catalog.statistics() == {
        "movies": 2, "checked": 1, "total_length": 190,
        "average_rating": 7, "earliest_year": 2000, "latest_year": 2010,
    }


def test_duplicate_detection_normalizes_titles_and_uses_year():
    catalog = Catalog([
        Movie(number=1, title=" Alien ", year=1979),
        Movie(number=2, translated_title="alien", year=1979),
        Movie(number=3, title="Alien", year=2000),
        Movie(number=4),
        Movie(number=5),
    ])
    assert [[movie.number for movie in group] for group in catalog.duplicates()] == [[1, 2]]


def test_merge_resolves_duplicate_numbers():
    catalog = Catalog([Movie(number=1, title="Existing")])
    assert catalog.merge([Movie(number=1, title="Duplicate"), Movie(number=8, title="Free")]) == 2
    assert [(movie.number, movie.title) for movie in catalog] == [(1, "Existing"), (2, "Duplicate"), (8, "Free")]


def test_merge_movie_collision_policies_are_atomic():
    for policy, expected, count in (
        ("skip", [(1, "Existing"), (8, "Free")], 1),
        ("replace", [(1, "Replacement"), (8, "Free")], 2),
        ("renumber", [(1, "Existing"), (2, "Replacement"), (8, "Free")], 2),
    ):
        catalog = Catalog([Movie(number=1, title="Existing")])
        incoming = [Movie(number=1, title="Replacement"), Movie(number=8, title="Free")]
        assert catalog.merge(incoming, collision=policy) == count
        assert [(movie.number, movie.title) for movie in catalog] == expected
        assert incoming[0].number == 1

    catalog = Catalog([Movie(number=1, title="Existing")])
    with pytest.raises(ValueError, match="duplicate movie number: 1"):
        catalog.merge(
            [Movie(number=2, title="Would append"), Movie(number=1, title="Conflict")],
            collision="error",
        )
    assert [(movie.number, movie.title) for movie in catalog] == [(1, "Existing")]


def test_merge_metadata_keep_and_replace_policies():
    source = Catalog(metadata={"shared": "incoming", "new": 2})
    kept = Catalog(metadata={"shared": "existing", "old": 1})
    kept.merge(source, metadata="keep")
    assert kept.metadata == {"shared": "existing", "old": 1, "new": 2}

    replaced = Catalog(metadata={"shared": "existing", "old": 1})
    replaced.merge(source, metadata="replace")
    assert replaced.metadata == {"shared": "incoming", "old": 1, "new": 2}


def test_merge_metadata_namespace_preserves_complete_sources():
    destination = Catalog(metadata={"owner": "Destination"})
    destination.merge(
        Catalog(metadata={"owner": "First", "custom": {"a": 1}}),
        metadata="namespace",
    )
    destination.merge(
        Catalog(metadata={"owner": "Second"}), metadata="namespace"
    )

    assert destination.metadata == {
        "owner": "Destination",
        "amc_python_merge_namespaces": {
            "import_1": {"owner": "First", "custom": {"a": 1}},
            "import_2": {"owner": "Second"},
        },
    }


def test_merge_metadata_namespace_rejects_reserved_key_shape_atomically():
    destination = Catalog(
        metadata={"amc_python_merge_namespaces": "reserved by user"}
    )
    with pytest.raises(ValueError, match="must be an object"):
        destination.merge(Catalog(metadata={"owner": "Incoming"}), metadata="namespace")
    assert destination.metadata == {
        "amc_python_merge_namespaces": "reserved by user"
    }


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

    assert main([
        "-c", str(destination), "import", str(source),
        "--native-encoding", "utf-8",
    ]) == 0

    assert load(destination).get(1).original_title == "千と千尋"


def test_cli_import_rejects_unknown_native_string_encoding(tmp_path: Path, capsys):
    from amc.native import write_native_catalog

    source = tmp_path / "source.amc"
    destination = tmp_path / "catalog.json"
    write_native_catalog(Catalog([Movie(original_title="Alien")]), source)

    assert main([
        "-c", str(destination), "import", str(source),
        "--native-encoding", "not-a-codec",
    ]) == 2

    assert "unknown encoding" in capsys.readouterr().err
    assert not destination.exists()


def test_cli_import_enforces_native_read_limits_before_merge(tmp_path: Path, capsys):
    from amc.native import write_native_catalog

    source = tmp_path / "source.amc"
    destination = tmp_path / "catalog.json"
    write_native_catalog(Catalog([Movie(number=1, original_title="Alien")]), source)
    save(Catalog([Movie(number=9, title="Existing")]), destination)
    original = destination.read_bytes()

    assert main([
        "-c", str(destination), "import", str(source), "--max-movies", "0"
    ]) == 2

    assert "exceeds movie-count limit" in capsys.readouterr().err
    assert destination.read_bytes() == original


def test_cli_import_exposes_metadata_namespace_policy(tmp_path: Path):
    destination = tmp_path / "destination.json"
    source = tmp_path / "source.json"
    save(Catalog(metadata={"owner": "Destination"}), destination)
    save(Catalog(metadata={"owner": "Incoming"}), source)

    assert main([
        "-c", str(destination), "import", str(source), "--metadata", "namespace"
    ]) == 0
    assert load(destination).metadata["amc_python_merge_namespaces"] == {
        "import_1": {"owner": "Incoming"}
    }


def test_cli_list_search_and_stats_support_json(tmp_path: Path, capsys):
    target = tmp_path / "catalog.json"
    save(Catalog([
        Movie(number=1, title="Alien", director="Ridley Scott", length=117),
        Movie(number=2, title="Aliens", director="James Cameron", length=137),
    ]), target)

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


def test_cli_duplicates_supports_json(tmp_path: Path, capsys):
    target = tmp_path / "catalog.json"
    save(Catalog([
        Movie(number=1, title="Alien", year=1979),
        Movie(number=2, original_title="alien", year=1979),
    ]), target)
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
    assert main([
        "-c", str(target), "edit", "1", "--set", 'original_title="Alien"',
        "--set", "year=1979", "--set", "rating=8.5", "--set", "checked=true",
        "--set", 'extras={"edition":"Director cut"}',
    ]) == 0
    movie = load(target).get(1)
    assert (movie.original_title, movie.year, movie.rating, movie.checked) == (
        "Alien", 1979, 8.5, True
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


def test_cli_exit_status_constants_are_stable():
    from amc.cli import EXIT_ERROR, EXIT_INVALID_CATALOG, EXIT_SUCCESS

    assert (EXIT_SUCCESS, EXIT_INVALID_CATALOG, EXIT_ERROR) == (0, 1, 2)


def test_copy_catalog_validates_and_preserves_destination_on_failure(tmp_path: Path):
    source = tmp_path / "source.json"
    destination = tmp_path / "backup.json"
    save(Catalog([Movie(title="Alien")]), source)
    destination.write_bytes(b"existing backup")

    copy_catalog(source, destination)
    assert destination.read_bytes() == source.read_bytes()
    assert next(iter(load(destination))).title == "Alien"

    source.write_text("not json", encoding="utf-8")
    previous = destination.read_bytes()
    with pytest.raises(json.JSONDecodeError):
        copy_catalog(source, destination)
    assert destination.read_bytes() == previous
    assert not (tmp_path / ".backup.json.tmp").exists()


def test_copy_catalog_validates_the_copied_bytes(monkeypatch, tmp_path: Path):
    source = tmp_path / "source.json"
    destination = tmp_path / "backup.json"
    save(Catalog([Movie(title="Valid before copy")]), source)
    destination.write_bytes(b"existing backup")

    def corrupt_during_copy(incoming, outgoing):
        incoming.read()
        outgoing.write(b"not json")

    monkeypatch.setattr("amc.storage.shutil.copyfileobj", corrupt_during_copy)
    with pytest.raises(json.JSONDecodeError):
        copy_catalog(source, destination)
    assert destination.read_bytes() == b"existing backup"
    assert not (tmp_path / ".backup.json.tmp").exists()


def test_cli_backup_and_restore_roundtrip(tmp_path: Path):
    catalog = tmp_path / "catalog.json"
    backup = tmp_path / "backup.json"
    save(Catalog([Movie(title="Original")]), catalog)

    assert main(["-c", str(catalog), "backup", str(backup)]) == 0
    save(Catalog([Movie(title="Changed")]), catalog)
    assert main(["-c", str(catalog), "restore", str(backup)]) == 0
    assert next(iter(load(catalog))).title == "Original"


def test_copy_catalog_rejects_same_path(tmp_path: Path):
    target = tmp_path / "catalog.json"
    save(Catalog(), target)
    with pytest.raises(ValueError, match="paths must differ"):
        copy_catalog(target, target)


def test_rejects_future_json_versions(tmp_path: Path):
    target = tmp_path / "future.json"
    target.write_text('{"format":"amc-python","version":99,"movies":[]}', encoding="utf-8")
    try:
        load(target)
    except ValueError as error:
        assert "unsupported catalog version" in str(error)
    else:
        raise AssertionError("future catalog version was accepted")


@pytest.mark.parametrize(
    ("document", "message"),
    [
        ('{"format":null,"version":1,"movies":[]}', "unsupported catalog format"),
        ('{"format":"amc-python","version":true,"movies":[]}', "unsupported catalog version"),
        ('{"format":"amc-python","version":"1","movies":[]}', "unsupported catalog version"),
        ('{"format":"amc-python","version":1,"movies":[null]}', "invalid movie at index 0"),
        ('{"format":"amc-python","version":1,"movies":[{},42]}', "invalid movie at index 1"),
    ],
)
def test_json_envelope_and_rows_use_strict_schema(
    tmp_path: Path, document: str, message: str
):
    target = tmp_path / "invalid.json"
    target.write_text(document, encoding="utf-8")

    with pytest.raises(ValueError, match=message):
        load(target)


@pytest.mark.parametrize(
    ("document", "message"),
    [
        ('{"movies":[],"movies":[]}', "duplicate JSON object member: 'movies'"),
        ('{"movies":[{"title":"first","title":"second"}]}', "duplicate JSON object member: 'title'"),
        ('{"movies":[{"rating":NaN}]}', "invalid non-finite JSON number: NaN"),
        ('{"metadata":{"limit":Infinity},"movies":[]}', "invalid non-finite JSON number: Infinity"),
    ],
)
def test_json_parser_rejects_ambiguous_or_nonstandard_values(
    tmp_path: Path, document: str, message: str
):
    target = tmp_path / "invalid.json"
    target.write_text(document, encoding="utf-8")

    with pytest.raises(ValueError, match=message):
        load(target)


def test_json_model_rejects_ambiguous_types():
    for data, message in (
        ({"number": True}, "number must be an integer"),
        ({"number": "1"}, "number must be an integer"),
        ({"rating": "8"}, "rating must be a finite number"),
        ({"extras": []}, "extras must be an object"),
    ):
        try:
            Movie.from_dict(data)
        except TypeError as error:
            assert message in str(error)
        else:
            raise AssertionError(f"invalid movie data accepted: {data}")


def test_direct_model_construction_uses_the_same_validation():
    invalid = (
        ({"title": None}, "title must be a string"),
        ({"year": "2001"}, "year must be an integer or null"),
        ({"checked": 1}, "checked must be a boolean"),
        ({"rating": math.nan}, "rating must be a finite number or null"),
        ({"framerate": math.inf}, "framerate must be a finite number or null"),
        ({"extras": []}, "movie extras must be an object"),
    )
    for values, message in invalid:
        try:
            Movie(**values)
        except TypeError as error:
            assert str(error) == message
        else:
            raise AssertionError(f"direct construction accepted invalid values: {values}")


def test_movie_copies_caller_owned_extras():
    extras = {"Inventory Code": "A-42"}
    movie = Movie(extras=extras)
    extras["Inventory Code"] = "changed"
    assert movie.extras == {"Inventory Code": "A-42"}


def test_movie_deep_copies_and_validates_extras():
    extras = {"nested": {"values": [1]}}
    movie = Movie(extras=extras)
    extras["nested"]["values"].append(2)
    assert movie.extras == {"nested": {"values": [1]}}

    with pytest.raises(TypeError, match="extras keys must be strings"):
        Movie(extras={1: "invalid"})
    with pytest.raises(TypeError, match="extras must be JSON-compatible"):
        Movie(extras={"invalid": math.nan})


def test_atomic_json_save_preserves_destination_on_serialization_error(tmp_path: Path):
    target = tmp_path / "catalog.json"
    target.write_text("previous contents", encoding="utf-8")
    movie = Movie(title="Unserializable")
    # Exercise the writer's atomic failure path even though construction rejects
    # this value by introducing it through the deliberately mutable extras API.
    movie.extras["bad"] = object()
    try:
        save(Catalog([movie]), target)
    except TypeError:
        pass
    else:
        raise AssertionError("unserializable value was accepted")
    assert target.read_text(encoding="utf-8") == "previous contents"
    assert not (tmp_path / ".catalog.json.tmp").exists()


def test_written_json_uses_documented_envelope(tmp_path: Path):
    target = tmp_path / "catalog.json"
    save(Catalog([Movie(title="Alien")]), target)
    document = json.loads(target.read_text(encoding="utf-8"))
    assert document["format"] == "amc-python"
    assert document["version"] == 1
    assert len(document["movies"]) == 1


def test_json_roundtrip_preserves_catalog_metadata(tmp_path: Path):
    target = tmp_path / "catalog.json"
    catalog = Catalog([Movie(title="Alien")], metadata={"owner": "Ripley", "nested": {"x": 1}})

    save(catalog, target)
    restored = load(target)

    assert restored.metadata == catalog.metadata
    assert next(iter(restored)).title == "Alien"


def test_xml_roundtrip_preserves_catalog_and_custom_field_metadata(tmp_path: Path):
    source = tmp_path / "metadata.xml"
    source.write_text('''<AntMovieCatalog Format="4.2"><Catalog>
      <Properties Owner="Antoine" Mail="a@example.test" Site="example.test" Description="Movies"/>
      <CustomFieldsProperties ColumnSettings="columns" GUIProperties="gui">
        <CustomField Tag="Inventory" Name="Inventory code" Type="List" MultiValues="True">
          <ListValue Text="A"/><ListValue Text="B"/>
        </CustomField>
      </CustomFieldsProperties>
      <Contents><Movie Number="1" OriginalTitle="Brazil" Inventory="A"/></Contents>
    </Catalog></AntMovieCatalog>''', encoding="utf-8")

    catalog = load_xml(source)
    metadata = catalog.metadata["amc_xml"]
    assert (metadata["owner"], metadata["mail"], metadata["column_settings"]) == (
        "Antoine", "a@example.test", "columns"
    )
    assert metadata["custom_fields"][0]["list_values"] == ["A", "B"]

    target = tmp_path / "roundtrip.xml"
    save_xml(catalog, target)
    restored = load_xml(target)
    assert restored.metadata == catalog.metadata
    assert next(iter(restored)).extras["Inventory"] == "A"


def test_xml_export_rejects_structured_extra_instead_of_losing_it(tmp_path: Path):
    catalog = Catalog([Movie(title="Alien", extras={"native_records": [{"tag": "x"}]})])

    try:
        save_xml(catalog, tmp_path / "catalog.xml")
    except ValueError as error:
        assert "cannot be represented losslessly" in str(error)
    else:
        raise AssertionError("structured movie extra was flattened into XML")


def test_catalog_metadata_is_validated_and_deep_copied():
    metadata = {"owner": "Ripley", "nested": {"values": [1]}}
    catalog = Catalog(metadata=metadata)
    metadata["nested"]["values"].append(2)
    assert catalog.metadata == {"owner": "Ripley", "nested": {"values": [1]}}

    for invalid, message in (
        ([], "metadata must be an object"),
        ({1: "value"}, "keys must be strings"),
        ({"bad": object()}, "JSON-compatible"),
        ({"bad": math.nan}, "JSON-compatible"),
    ):
        try:
            Catalog(metadata=invalid)
        except TypeError as error:
            assert message in str(error)
        else:
            raise AssertionError(f"invalid metadata was accepted: {invalid!r}")


def test_catalog_merge_metadata_conflict_is_atomic():
    destination = Catalog([Movie(number=1, title="Existing")], metadata={"a": 1, "z": 1})
    source = Catalog([Movie(number=2, title="Incoming")], metadata={"b": 2, "z": 9})

    try:
        destination.merge(source)
    except ValueError as error:
        assert str(error) == "conflicting catalog metadata: z"
    else:
        raise AssertionError("conflicting metadata was merged")

    assert destination.metadata == {"a": 1, "z": 1}
    assert [movie.title for movie in destination] == ["Existing"]
