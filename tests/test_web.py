import base64
import io
import threading
from pathlib import Path
from unittest.mock import patch
from urllib.request import urlopen

from http.server import ThreadingHTTPServer

from PIL import Image

from amc.application import CatalogService
from amc.model import Movie
from amc.web import (
    CatalogWebState,
    HOST,
    PORT,
    handler_for,
    main,
    poster_response,
    render_catalog,
    render_movie,
)


def _service(tmp_path: Path) -> CatalogService:
    service = CatalogService(tmp_path / "movies.json")
    service.add_many([
        Movie(title="Alien <script>", year=1979, director="Ridley Scott"),
        Movie(title="Moon", checked=True, borrower="Sam", description="Lunar mystery"),
    ])
    return service


def test_catalog_page_filters_and_escapes_movies(tmp_path: Path):
    page = render_catalog(_service(tmp_path), query="Moon", view="Checked")

    assert "Moon" in page
    assert "Alien <script>" not in page
    assert "Showing 1–1 of 1 matching movie(s); 2 total" in page
    assert "<option selected>Checked</option>" in page


def test_catalog_page_escapes_untrusted_fields(tmp_path: Path):
    page = render_catalog(_service(tmp_path))

    assert "Alien &lt;script&gt;" in page
    assert "Alien <script>" not in page


def test_catalog_page_sorts_columns_and_preserves_filter_parameters(tmp_path: Path):
    page = render_catalog(
        _service(tmp_path), view="All", sort="title", descending=True
    )

    assert page.index("Moon") < page.index("Alien &lt;script&gt;")
    assert "Title ▼" in page
    assert "sort=year&amp;desc=0" in page
    assert "<caption class='sr-only'>Movie catalog</caption>" in page


def test_catalog_page_rejects_unknown_sort_field(tmp_path: Path):
    try:
        render_catalog(_service(tmp_path), sort="extras")
    except ValueError as error:
        assert "unknown web sort field" in str(error)
    else:
        raise AssertionError("unknown web sort field was accepted")


def test_catalog_page_paginates_bounded_rows_and_preserves_state(tmp_path: Path):
    service = CatalogService(tmp_path / "large.json")
    service.add_many([Movie(title=f"Movie {number:03}") for number in range(30)])

    page = render_catalog(
        service, sort="title", descending=True, page=2, page_size=25
    )

    assert page.count("<tr><td>") == 5
    assert "Showing 26–30 of 30 matching movie(s); 30 total" in page
    assert "Page 2 of 2" in page
    assert "size=25" in page
    assert "← Previous" in page
    assert "Next →" not in page


def test_catalog_page_rejects_unbounded_page_sizes(tmp_path: Path):
    try:
        render_catalog(_service(tmp_path), page_size=10_000)
    except ValueError as error:
        assert "unsupported web page size" in str(error)
    else:
        raise AssertionError("unbounded web page size was accepted")


def test_catalog_poster_layout_matches_desktop_view_and_escapes_cards(
    tmp_path: Path,
):
    page = render_catalog(_service(tmp_path), layout="Posters")

    assert "class='poster-grid'" in page
    assert page.count("class='card'") == 2
    assert "Alien &lt;script&gt;" in page
    assert "Loaned to Sam" in page
    assert "<table>" not in page
    assert "<option selected>Posters</option>" in page


def test_catalog_page_rejects_unknown_layout(tmp_path: Path):
    try:
        render_catalog(_service(tmp_path), layout="Editor")
    except ValueError as error:
        assert "unknown web layout" in str(error)
    else:
        raise AssertionError("unknown web layout was accepted")


def test_movie_page_matches_details_and_allows_only_web_links(tmp_path: Path):
    service = _service(tmp_path)
    safe = Movie(number=3, title="Safe", url="https://example.com/movie", comments="A&B")
    unsafe = Movie(number=4, title="Unsafe", url="javascript:alert(1)")

    safe_page = render_movie(service, safe)
    unsafe_page = render_movie(service, unsafe)

    assert "Open movie URL" in safe_page
    assert "A&amp;B" in safe_page
    assert "javascript:" not in unsafe_page


def test_poster_response_verifies_image_and_detects_mime_type(tmp_path: Path):
    service = _service(tmp_path)
    output = io.BytesIO()
    Image.new("RGB", (2, 3), "navy").save(output, format="PNG")
    data = output.getvalue()
    movie = Movie(
        number=3,
        title="Poster",
        extras={"native_picture_base64": base64.b64encode(data).decode("ascii")},
    )

    assert poster_response(service, movie) == (data, "image/png")


def test_poster_response_rejects_oversized_link_before_reading(tmp_path: Path):
    service = _service(tmp_path)
    poster = tmp_path / "large.png"
    poster.write_bytes(b"not read")
    movie = Movie(number=3, title="Large", picture=poster.name)

    with patch("amc.web.MAX_POSTER_BYTES", 2), patch.object(
        Path, "read_bytes", side_effect=AssertionError("oversized poster was read")
    ):
        try:
            poster_response(service, movie)
        except ValueError as error:
            assert "size limit" in str(error)
        else:
            raise AssertionError("oversized poster was accepted")


def test_poster_response_rejects_excessive_decoded_dimensions(tmp_path: Path):
    service = _service(tmp_path)
    output = io.BytesIO()
    Image.new("RGB", (2, 3), "navy").save(output, format="PNG")
    movie = Movie(
        number=3,
        title="Poster",
        extras={
            "native_picture_base64": base64.b64encode(output.getvalue()).decode("ascii")
        },
    )

    with patch("amc.web.MAX_POSTER_PIXELS", 5):
        try:
            poster_response(service, movie)
        except ValueError as error:
            assert "pixel limit" in str(error)
        else:
            raise AssertionError("oversized poster dimensions were accepted")


def test_poster_endpoint_uses_request_catalog_service(tmp_path: Path):
    service = CatalogService(tmp_path / "posters.json")
    poster = tmp_path / "cover.png"
    Image.new("RGB", (2, 3), "navy").save(poster)
    movie = service.add(Movie(title="Poster", picture=poster.name))
    state = CatalogWebState(service.path)
    server = ThreadingHTTPServer(("127.0.0.1", 0), handler_for(state))
    thread = threading.Thread(target=server.serve_forever)
    thread.start()
    try:
        with urlopen(
            f"http://127.0.0.1:{server.server_port}/poster/{movie.number}"
        ) as response:
            assert response.status == 200
            assert response.headers["Content-Type"] == "image/png"
            assert response.read() == poster.read_bytes()
    finally:
        server.shutdown()
        thread.join()
        server.server_close()


def test_web_entry_point_defaults_to_requested_public_address():
    with patch("amc.web.run") as run:
        main(["movies.json"])

    run.assert_called_once_with(Path("movies.json"), host=HOST, port=PORT)
    assert (HOST, PORT) == ("0.0.0.0", 6910)


def test_web_module_does_not_import_tk_desktop_adapter():
    source = Path("src/amc/web.py").read_text(encoding="utf-8")
    assert "from .gui" not in source
    assert "tkinter" not in source


def test_web_state_reloads_external_catalog_changes(tmp_path: Path):
    service = _service(tmp_path)
    state = CatalogWebState(service.path)
    external = CatalogService(service.path)
    external.add(Movie(title="Arrival"))

    current = state.current()

    assert [movie.display_title() for movie in current.catalog] == [
        "Alien <script>",
        "Moon",
        "Arrival",
    ]
    assert state.reload_error is None


def test_web_state_retains_last_valid_snapshot_after_bad_external_write(
    tmp_path: Path,
):
    service = _service(tmp_path)
    state = CatalogWebState(service.path)
    service.path.write_text("not json", encoding="utf-8")

    current = state.current()
    page = render_catalog(current, reload_error=state.reload_error)

    assert len(current.catalog) == 2
    assert state.reload_error
    assert "Catalog reload failed; showing the last valid snapshot" in page
