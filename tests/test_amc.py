import json
import math
from pathlib import Path

from amc import Catalog, Movie
from amc.cli import main
from amc.storage import load, load_csv, load_xml, save, save_csv, save_xml


def test_catalog_numbers_search_and_json_roundtrip(tmp_path: Path):
    catalog = Catalog()
    catalog.add(Movie(title="Alien", director="Ridley Scott", year=1979))
    catalog.add(Movie(title="Aliens", director="James Cameron", year=1986))
    assert [movie.number for movie in catalog] == [1, 2]
    assert [movie.title for movie in catalog.search("cameron")] == ["Aliens"]
    target = tmp_path / "catalog.json"
    save(catalog, target)
    assert [movie.to_dict() for movie in load(target)] == [movie.to_dict() for movie in catalog]


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


def test_cli_add_and_list(tmp_path: Path, capsys):
    target = tmp_path / "movies.json"
    assert main(["-c", str(target), "add", "Moon", "--year", "2009"]) == 0
    assert main(["-c", str(target), "list"]) == 0
    assert "Moon (2009)" in capsys.readouterr().out


def test_xml_roundtrip_preserves_supported_and_custom_fields(tmp_path: Path):
    target = tmp_path / "export.xml"
    original = Movie(number=7, title="Moon", year=2009, checked=True, extras={"CustomField": "kept"})
    save_xml(Catalog([original]), target)
    restored = next(iter(load_xml(target)))
    assert (restored.number, restored.title, restored.year, restored.checked) == (7, "Moon", 2009, True)
    assert restored.extras == {"CustomField": "kept"}


def test_cli_edit_and_export(tmp_path: Path):
    catalog = tmp_path / "movies.json"
    xml = tmp_path / "movies.xml"
    main(["-c", str(catalog), "add", "Moo"])
    main(["-c", str(catalog), "edit", "1", "--title", "Moon", "--year", "2009"])
    main(["-c", str(catalog), "export-xml", str(xml)])
    movie = next(iter(load_xml(xml)))
    assert (movie.title, movie.year) == ("Moon", 2009)


def test_sort_is_case_insensitive_and_empty_search_returns_all():
    catalog = Catalog([Movie(title="zulu"), Movie(title="Alpha"), Movie(title="beta")])
    catalog.sort()
    assert [movie.title for movie in catalog] == ["Alpha", "beta", "zulu"]
    assert catalog.search("  ") == list(catalog)


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


def test_merge_resolves_duplicate_numbers():
    catalog = Catalog([Movie(number=1, title="Existing")])
    assert catalog.merge([Movie(number=1, title="Duplicate"), Movie(number=8, title="Free")]) == 2
    assert [(movie.number, movie.title) for movie in catalog] == [(1, "Existing"), (2, "Duplicate"), (8, "Free")]


def test_cli_reports_missing_movie_without_traceback(tmp_path: Path, capsys):
    result = main(["-c", str(tmp_path / "empty.json"), "remove", "99"])
    assert result == 2
    assert "movie 99 does not exist" in capsys.readouterr().err


def test_rejects_future_json_versions(tmp_path: Path):
    target = tmp_path / "future.json"
    target.write_text('{"format":"amc-python","version":99,"movies":[]}', encoding="utf-8")
    try:
        load(target)
    except ValueError as error:
        assert "unsupported catalog version" in str(error)
    else:
        raise AssertionError("future catalog version was accepted")


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


def test_atomic_json_save_preserves_destination_on_serialization_error(tmp_path: Path):
    target = tmp_path / "catalog.json"
    target.write_text("previous contents", encoding="utf-8")
    movie = Movie(title="Unserializable", extras={"bad": object()})
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
