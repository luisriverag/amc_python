import pytest

from amc.catalog import Catalog, sort_movies
from amc.model import Movie


def test_search_with_no_field_checks_the_default_field_set():
    catalog = Catalog(
        [
            Movie(number=1, title="Alien", director="Ridley Scott"),
            Movie(number=2, title="Predator", director="John McTiernan"),
        ]
    )
    assert [m.number for m in catalog.search("scott")] == [1]
    assert [m.number for m in catalog.search("")] == [1, 2]


def test_search_scoped_to_one_field_ignores_matches_elsewhere():
    catalog = Catalog(
        [
            Movie(number=1, title="Alien", director="Scott"),
            Movie(number=2, title="Scott Pilgrim", director="Wright"),
        ]
    )
    assert [m.number for m in catalog.search("scott", field="director")] == [1]
    assert [m.number for m in catalog.search("scott", field="title")] == [2]


def test_search_rejects_an_unknown_or_extras_field():
    catalog = Catalog([Movie(number=1, title="Alien")])
    with pytest.raises(ValueError, match="unknown movie field"):
        catalog.search("x", field="bogus")
    with pytest.raises(ValueError, match="unknown movie field"):
        catalog.search("x", field="extras")


def test_search_whole_field_only_requires_an_exact_match():
    catalog = Catalog(
        [
            Movie(number=1, title="Alien"),
            Movie(number=2, title="Aliens"),
        ]
    )
    assert [m.number for m in catalog.search("alien", field="title")] == [1, 2]
    assert [m.number for m in catalog.search("alien", field="title", whole_field=True)] == [1]


def test_search_reverse_returns_movies_that_do_not_match():
    catalog = Catalog(
        [
            Movie(number=1, title="Alien"),
            Movie(number=2, title="Predator"),
        ]
    )
    assert [m.number for m in catalog.search("alien", field="title", reverse=True)] == [2]


def test_search_reverse_with_empty_query_matches_nothing():
    catalog = Catalog([Movie(number=1, title="Alien")])
    assert catalog.search("", reverse=True) == []


def test_sort_movies_leaves_the_source_list_untouched():
    original = [Movie(number=1, title="Bravo"), Movie(number=2, title="Alpha")]
    ordered = sort_movies(original, "title")
    assert [m.title for m in ordered] == ["Alpha", "Bravo"]
    assert [m.title for m in original] == ["Bravo", "Alpha"]


def test_sort_movies_rejects_unknown_or_extras_field():
    with pytest.raises(ValueError, match="unknown movie field"):
        sort_movies([Movie(number=1)], "bogus")
    with pytest.raises(ValueError, match="unknown movie field"):
        sort_movies([Movie(number=1)], "extras")
