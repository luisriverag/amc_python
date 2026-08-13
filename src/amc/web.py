"""Read-only web catalog aligned with the desktop table/details/poster UX."""

from __future__ import annotations

import argparse
import base64
import binascii
import html
import io
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from threading import RLock
from urllib.parse import parse_qs, urlencode, urlparse

from PIL import Image, UnidentifiedImageError

from .application import CatalogService
from .model import Movie
from .presentation import VIEW_FILTERS, filter_movies, poster_source

HOST = "0.0.0.0"
PORT = 6910
MAX_POSTER_BYTES = 25 * 1024 * 1024
MAX_POSTER_PIXELS = 40_000_000


class CatalogWebState:
    """Reload a changed catalog safely while retaining the last valid snapshot."""

    def __init__(self, path: Path) -> None:
        self.service = CatalogService(path)
        self._modified = self._mtime()
        self._lock = RLock()
        self.reload_error: str | None = None

    def current(self) -> CatalogService:
        with self._lock:
            modified = self._mtime()
            if modified != self._modified:
                try:
                    self.service.reload()
                except (OSError, TypeError, ValueError) as error:
                    self.reload_error = str(error)
                else:
                    self._modified = modified
                    self.reload_error = None
            return self.service

    def _mtime(self) -> int | None:
        try:
            return self.service.path.stat().st_mtime_ns
        except FileNotFoundError:
            return None


def render_catalog(
    service: CatalogService,
    *,
    query: str = "",
    view: str = "All",
    sort: str = "number",
    descending: bool = False,
    reload_error: str | None = None,
    page: int = 1,
    page_size: int = 100,
    layout: str = "Table",
) -> str:
    """Render the searchable table and selected-movie links as escaped HTML."""
    movies = service.catalog.search(query) if query.strip() else list(service.catalog)
    movies = filter_movies(movies, view)
    sort_fields = {"number", "title", "year", "director", "checked", "borrower"}
    if sort not in sort_fields:
        raise ValueError(f"unknown web sort field: {sort}")
    if sort == "title":
        key = lambda movie: movie.display_title().casefold()
    else:
        key = lambda movie: getattr(movie, sort)
    present = [movie for movie in movies if key(movie) is not None]
    missing = [movie for movie in movies if key(movie) is None]
    movies = sorted(present, key=key, reverse=descending) + missing
    if page < 1:
        raise ValueError("web page must be positive")
    if page_size not in {25, 50, 100, 250}:
        raise ValueError("unsupported web page size")
    if layout not in {"Table", "Posters"}:
        raise ValueError("unknown web layout")
    total_results = len(movies)
    total_pages = max(1, (total_results + page_size - 1) // page_size)
    if page > total_pages:
        page = total_pages
    start = (page - 1) * page_size
    movies = movies[start : start + page_size]

    def page_link(target: int, label: str) -> str:
        params = urlencode({
            "q": query,
            "view": view,
            "sort": sort,
            "desc": int(descending),
            "page": target,
            "size": page_size,
            "layout": layout,
        })
        return f"<a href='/?{html.escape(params, quote=True)}'>{label}</a>"

    def heading(field: str, label: str) -> str:
        reverse = sort == field and not descending
        params = urlencode({
            "q": query,
            "view": view,
            "sort": field,
            "desc": int(reverse),
            "size": page_size,
            "layout": layout,
        })
        marker = " ▼" if sort == field and descending else " ▲" if sort == field else ""
        return f"<th scope='col'><a href='/?{html.escape(params, quote=True)}'>{label}{marker}</a></th>"

    rows = "".join(
        "<tr><td>{number}</td><td><a href='/movie/{number}'>{title}</a></td>"
        "<td>{year}</td><td>{director}</td><td>{checked}</td><td>{borrower}</td></tr>".format(
            number=movie.number,
            title=html.escape(movie.display_title()),
            year=movie.year or "",
            director=html.escape(movie.director),
            checked="Yes" if movie.checked else "",
            borrower=html.escape(movie.borrower),
        )
        for movie in movies
    )
    cards = "".join(
        "<article class='card'><a href='/movie/{number}'>"
        "<div class='cover'>{poster}</div><h2>{title}</h2></a>"
        "<p>{year}{separator}{director}</p><p>{status}</p></article>".format(
            number=movie.number,
            poster=(
                f"<img src='/poster/{movie.number}' alt='' loading='lazy'>"
                if poster_source(movie, service.path)
                else "<span aria-hidden='true'>No poster</span>"
            ),
            title=html.escape(movie.display_title()),
            year=movie.year or "",
            separator=" · " if movie.year and movie.director else "",
            director=html.escape(movie.director),
            status=(
                f"Loaned to {html.escape(movie.borrower)}"
                if movie.borrower
                else "Available"
            ),
        )
        for movie in movies
    )
    options = "".join(
        f"<option{' selected' if item == view else ''}>{item}</option>"
        for item in VIEW_FILTERS
    )
    sizes = "".join(
        f"<option{' selected' if item == page_size else ''}>{item}</option>"
        for item in (25, 50, 100, 250)
    )
    layouts = "".join(
        f"<option{' selected' if item == layout else ''}>{item}</option>"
        for item in ("Table", "Posters")
    )
    previous = page_link(page - 1, "← Previous") if page > 1 else ""
    following = page_link(page + 1, "Next →") if page < total_pages else ""
    body = f"""
<header><h1>AMC Python</h1><p>{html.escape(service.path.name)}</p></header>
<main><form><label>Search <input name='q' value='{html.escape(query, quote=True)}'></label>
<label>View <select name='view'>{options}</select></label><label>Layout <select name='layout'>{layouts}</select></label><label>Rows <select name='size'>{sizes}</select></label><input type='hidden' name='sort' value='{html.escape(sort, quote=True)}'><button>Apply</button></form>
{f"<p class='warning' role='alert'>Catalog reload failed; showing the last valid snapshot: {html.escape(reload_error)}</p>" if reload_error else ""}
<p role='status'>Showing {start + 1 if total_results else 0}–{start + len(movies)} of {total_results} matching movie(s); {len(service.catalog)} total</p>
{f"<div class='table-scroll'><table><caption class='sr-only'>Movie catalog</caption><thead><tr>{heading('number', '#')}{heading('title', 'Title')}{heading('year', 'Year')}{heading('director', 'Director')}{heading('checked', 'Checked')}{heading('borrower', 'Borrower')}</tr></thead><tbody>{rows}</tbody></table></div>" if layout == "Table" else f"<section class='poster-grid' aria-label='Movie posters'>{cards}</section>"}<nav aria-label='Catalog pages'>{previous}<span>Page {page} of {total_pages}</span>{following}</nav></main>"""
    return _page("Catalog", body)


def render_movie(service: CatalogService, movie: Movie) -> str:
    """Render one movie using the desktop details/poster vocabulary."""
    fields = (
        ("Original title", movie.original_title), ("Director", movie.director),
        ("Category", movie.category), ("Actors", movie.actors),
        ("Borrower", movie.borrower), ("Description", movie.description),
        ("Comments", movie.comments),
    )
    details = "".join(
        f"<dt>{html.escape(label)}</dt><dd>{html.escape(str(value))}</dd>"
        for label, value in fields if value
    )
    poster = poster_source(movie, service.path)
    image = f"<img src='/poster/{movie.number}' alt='Poster for {html.escape(movie.display_title(), quote=True)}'>" if poster else "<p>No poster assigned</p>"
    link = ""
    parsed = urlparse(movie.url.strip())
    if parsed.scheme.casefold() in {"http", "https"} and parsed.netloc:
        safe_url = html.escape(movie.url.strip(), quote=True)
        link = f"<p><a href='{safe_url}' rel='noopener noreferrer'>Open movie URL</a></p>"
    return _page(movie.display_title(), f"<header><a href='/'>← Catalog</a><h1>{html.escape(movie.display_title())}</h1></header><main class='details'>{image}<section><dl>{details}</dl>{link}</section></main>")


def poster_response(service: CatalogService, movie: Movie) -> tuple[bytes, str]:
    """Return a verified, bounded poster payload and its detected MIME type."""
    source = poster_source(movie, service.path)
    if source is None:
        raise FileNotFoundError("movie has no readable poster")

    kind, value = source
    if kind == "data":
        # Base64 expands data by roughly 4/3. Reject oversized values before
        # allocating the decoded copy, then enforce the exact limit afterward.
        if len(value) > ((MAX_POSTER_BYTES + 2) // 3) * 4:
            raise ValueError("poster exceeds the web size limit")
        try:
            data = base64.b64decode(value, validate=True)
        except (binascii.Error, ValueError) as error:
            raise ValueError("poster contains invalid base64 data") from error
    else:
        path = Path(value)
        if path.stat().st_size > MAX_POSTER_BYTES:
            raise ValueError("poster exceeds the web size limit")
        data = path.read_bytes()

    if len(data) > MAX_POSTER_BYTES:
        raise ValueError("poster exceeds the web size limit")
    try:
        with Image.open(io.BytesIO(data)) as image:
            width, height = image.size
            if width <= 0 or height <= 0 or width * height > MAX_POSTER_PIXELS:
                raise ValueError("poster exceeds the web pixel limit")
            content_type = Image.MIME.get(image.format or "")
            image.verify()
    except (OSError, UnidentifiedImageError) as error:
        raise ValueError("poster is not a supported image") from error
    if content_type is None:
        raise ValueError("poster image type is unknown")
    return data, content_type


def _page(title: str, body: str) -> str:
    return f"""<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width'><title>{html.escape(title)} — AMC Python</title><style>
:root{{--accent:#234f78;--line:#c8d2dc;--paper:#fff;--bg:#edf1f5}}*{{box-sizing:border-box}}body{{margin:0;background:var(--bg);font:16px system-ui;color:#17212b}}header,main{{max-width:1100px;margin:auto;padding:1rem}}header{{background:var(--accent);color:white}}header a{{color:white}}form{{display:flex;gap:1rem;align-items:end;flex-wrap:wrap}}input,select,button{{font:inherit;padding:.5rem}}.warning{{padding:.75rem;border-left:5px solid #a33;background:#fff0f0}}.table-scroll{{overflow-x:auto}}table{{width:100%;border-collapse:collapse;background:var(--paper)}}th,td{{padding:.65rem;border:1px solid var(--line);text-align:left}}th{{background:#dce6ef}}th a{{color:#17212b}}tbody tr:hover{{background:#f4f8fb}}nav{{display:flex;justify-content:center;align-items:center;gap:1.5rem;padding:1rem}}.poster-grid{{display:grid;grid-template-columns:repeat(auto-fill,minmax(170px,1fr));gap:1rem}}.card{{background:white;border:1px solid var(--line);padding:.75rem}}.card a{{color:inherit;text-decoration:none}}.card h2{{font-size:1.05rem;margin:.65rem 0}}.card p{{margin:.35rem 0;color:#45515d}}.cover{{height:250px;display:grid;place-items:center;background:#dce6ef;color:#586875}}.cover img{{width:100%;height:100%;object-fit:contain}}.details{{display:grid;grid-template-columns:minmax(220px,320px) 1fr;gap:2rem;background:white}}.details img{{max-width:100%;max-height:420px}}dt{{font-weight:700;margin-top:.8rem}}dd{{margin:.2rem 0;white-space:pre-wrap}}.sr-only{{position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0,0,0,0)}}a:focus-visible,input:focus-visible,select:focus-visible,button:focus-visible{{outline:3px solid #f5b942;outline-offset:2px}}@media(max-width:650px){{.details{{grid-template-columns:1fr}}table{{font-size:.85rem}}}}
</style></head><body>{body}</body></html>"""


def handler_for(state: CatalogWebState) -> type[BaseHTTPRequestHandler]:
    class Handler(BaseHTTPRequestHandler):
        def do_GET(self) -> None:
            parsed = urlparse(self.path)
            service = state.current()
            try:
                if parsed.path == "/":
                    params = parse_qs(parsed.query)
                    query = params.get("q", [""])[0]
                    if len(query) > 500:
                        self.send_error(400, "search query is too long")
                        return
                    self._html(render_catalog(
                        service,
                        query=query,
                        view=params.get("view", ["All"])[0],
                        sort=params.get("sort", ["number"])[0],
                        descending=params.get("desc", ["0"])[0] == "1",
                        reload_error=state.reload_error,
                        page=int(params.get("page", ["1"])[0]),
                        page_size=int(params.get("size", ["100"])[0]),
                        layout=params.get("layout", ["Table"])[0],
                    ))
                elif parsed.path.startswith("/movie/"):
                    self._html(render_movie(service, service.catalog.get(int(parsed.path[7:]))))
                elif parsed.path.startswith("/poster/"):
                    self._poster(service, service.catalog.get(int(parsed.path[8:])))
                else:
                    self.send_error(404)
            except (KeyError, ValueError):
                self.send_error(404)

        def _html(self, value: str) -> None:
            data = value.encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Security-Policy", "default-src 'none'; img-src 'self'; style-src 'unsafe-inline'; form-action 'self'; base-uri 'none'; frame-ancestors 'none'")
            self.send_header("Referrer-Policy", "no-referrer")
            self.send_header("X-Content-Type-Options", "nosniff")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)

        def _poster(self, service: CatalogService, movie: Movie) -> None:
            try:
                data, content_type = poster_response(service, movie)
            except FileNotFoundError:
                self.send_error(404, "poster is not available")
                return
            except (OSError, ValueError) as error:
                self.send_error(422, str(error))
                return
            self.send_response(200)
            self.send_header("Content-Type", content_type)
            self.send_header("Cache-Control", "private, max-age=300")
            self.send_header("X-Content-Type-Options", "nosniff")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)

    return Handler


def run(path: Path, *, host: str = HOST, port: int = PORT) -> None:
    state = CatalogWebState(path)
    server = ThreadingHTTPServer((host, port), handler_for(state))
    print(f"AMC Python web catalog: http://{host}:{port}/")
    server.serve_forever()


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(prog="amc-web", description="AMC Python read-only web catalog")
    parser.add_argument("catalog", nargs="?", type=Path, default=Path("catalog.json"))
    parser.add_argument("--host", default=HOST); parser.add_argument("--port", type=int, default=PORT)
    args = parser.parse_args(argv); run(args.catalog, host=args.host, port=args.port)


if __name__ == "__main__":
    main()
