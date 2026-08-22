"""Ant Movie Catalog's upstream `$$TAG_NAME` HTML export template syntax.

`export.pas`'s HTML exporter lets a user author their own templates using
`$$TAG_NAME` placeholders that `ReplaceTagsGeneral`/`ReplaceTagsMovie`
substitute per catalog/per movie. This module renders the *same* placeholder
syntax against AMC Python's own `Movie`/`Catalog` model, so templates users
already have — written for real Ant Movie Catalog — keep working without the
original Windows application. It loads upstream's template *format*; it does
not execute IFPS or reproduce AMC's report designer.

Tag values are computed directly from `Movie`/`Catalog`, not cross-checked
against upstream output (no verified-upstream-parity claim is made — see
`docs/compatibility.md`). A few upstream behaviors are intentionally out of
scope and documented at the point they would apply:

- `$$ITEM_FORMATTEDTITLE1`/`$$ITEM_FORMATTEDTITLE2` reproduce two of
  upstream's title-display patterns ("Original (Translated)" and
  "Translated (Original)") directly from `original_title`/`translated_title`.
  Upstream's plain `$$ITEM_FORMATTEDTITLE` depends on a user-configured
  display preference AMC Python does not model; it uses `Movie.title`
  instead, which already holds the same value upstream calls
  "FormattedTitle" in every native/XML/JSON catalog this port reads.
- `$$ITEM_COLORHTML` (a user-configured color-tag palette) is not modeled
  and always renders empty.
- `$$ITEM_DATEWATCHED`/`$$LABEL_DATEWATCHED` read `movie.extras["DateWatched"]`
  — AMC Python has no first-class `date_watched` field yet, so a real AMC
  catalog's value survives here (XML's generic unknown-attribute retention
  keeps it in `extras`) but is not a typed field.
- Picture tags render the movie's stored linked/embedded picture reference;
  they do not copy picture files or the `apprN.gif`/`appr10_N.gif` rating-icon
  images upstream ships beside a template. Copy those images alongside the
  rendered output yourself, matching your template.
- `$$ITEM_EXTRA_BEGIN`/`$$ITEM_EXTRA_END` (the supplementary-record loop,
  with its own category/checked/range filter syntax) is not implemented.
  Any such block is removed from the output — matching upstream's own
  behavior for a movie with no supplementary records — rather than left as
  literal, unrendered template syntax.
"""

from __future__ import annotations

import re
from pathlib import Path

from .catalog import Catalog
from .model import Movie

_ITEM_BEGIN = "$$ITEM_BEGIN"
_ITEM_END = "$$ITEM_END"
_ITEM_EXTRA_BEGIN = "$$ITEM_EXTRA_BEGIN"
_ITEM_EXTRA_END = "$$ITEM_EXTRA_END"

_LABELS = {
    "$$LABEL_NUMBER": "Number",
    "$$LABEL_CHECKED": "Checked",
    "$$LABEL_MEDIA": "Media",
    "$$LABEL_TYPE": "Type",
    "$$LABEL_SOURCE": "Source",
    "$$LABEL_DATEADD": "Date added",
    "$$LABEL_BORROWER": "Borrower",
    "$$LABEL_RATING": "Rating",
    "$$LABEL_ORIGINALTITLE": "Original title",
    "$$LABEL_TRANSLATEDTITLE": "Translated title",
    "$$LABEL_FORMATTEDTITLE": "Title",
    "$$LABEL_DIRECTOR": "Director",
    "$$LABEL_PRODUCER": "Producer",
    "$$LABEL_WRITER": "Writer",
    "$$LABEL_COMPOSER": "Composer",
    "$$LABEL_ACTORS": "Actors",
    "$$LABEL_COUNTRY": "Country",
    "$$LABEL_YEAR": "Year",
    "$$LABEL_LENGTH": "Length",
    "$$LABEL_CATEGORY": "Category",
    "$$LABEL_CERTIFICATION": "Certification",
    "$$LABEL_URL": "URL",
    "$$LABEL_DESCRIPTION": "Description",
    "$$LABEL_COMMENTS": "Comments",
    "$$LABEL_FILEPATH": "File path",
    "$$LABEL_VIDEOFORMAT": "Video format",
    "$$LABEL_VIDEOBITRATE": "Video bitrate",
    "$$LABEL_AUDIOFORMAT": "Audio format",
    "$$LABEL_AUDIOBITRATE": "Audio bitrate",
    "$$LABEL_RESOLUTION": "Resolution",
    "$$LABEL_FRAMERATE": "Framerate",
    "$$LABEL_LANGUAGES": "Languages",
    "$$LABEL_SUBTITLES": "Subtitles",
    "$$LABEL_SIZE": "Size",
    "$$LABEL_DISKS": "Disks",
    "$$LABEL_COLORTAG": "Color tag",
    "$$LABEL_PICTURE": "Picture",
    "$$LABEL_AUDIOKBPS": "Kbps",
    "$$LABEL_VIDEOKBPS": "Kbps",
    "$$LABEL_UNIT": "MB",
    "$$LABEL_FPS": "fps",
    "$$LABEL_DATEWATCHED": "Date watched",
    "$$LABEL_USERRATING": "My rating",
    "$$LABEL_NBEXTRAS": "Extras",
}

_RATING_IMAGE_ROW = ("appr0.gif", "appr1.gif", "appr2.gif", "appr3.gif", "appr4.gif")


def render_full_template(
    catalog: Catalog,
    template: str,
    *,
    source_name: str = "",
    line_break: str = "<br>",
    individual_filename: str = "{number}.html",
) -> str:
    """Render the "full catalog" document: one page listing every movie.

    Everything outside a `$$ITEM_BEGIN`/`$$ITEM_END` pair is emitted once;
    everything inside is repeated once per movie, matching upstream's own
    `ExportToHTML`. `$$ITEM_BEGIN` may appear at most once (upstream also
    only supports one repeated block per document).
    """
    page = _replace_general_tags(template, catalog, source_name, line_break)
    return _expand_item_loop(page, catalog, line_break, individual_filename)


def render_individual_template(
    movie: Movie,
    catalog: Catalog,
    template: str,
    *,
    source_name: str = "",
    line_break: str = "<br>",
    record_number: int = 1,
    individual_filename: str = "{number}.html",
) -> str:
    """Render one movie's own page from the "individual" template."""
    page = _replace_general_tags(template, catalog, source_name, line_break)
    return _replace_movie_tags(
        page,
        movie,
        line_break=line_break,
        record_number=record_number,
        individual_filename=individual_filename,
    )


def export_html_template(
    catalog: Catalog,
    destination: str | Path,
    *,
    full_template: str | Path | None = None,
    individual_template: str | Path | None = None,
    individual_dir: str | Path | None = None,
    individual_filename: str = "{number}.html",
    source_name: str = "",
    line_break: str = "<br>",
    max_template_bytes: int = 1024 * 1024,
) -> list[Path]:
    """Render a full-catalog page and/or one page per movie, atomically.

    At least one of *full_template*/*individual_template* is required.
    *destination* is the full-catalog page's path; *individual_dir* (default:
    *destination*'s own directory) holds one file per movie, named by
    *individual_filename* (a `str.format` pattern taking `number`). Returns
    every path written. Nothing is written until every template has rendered
    successfully — a partially-written export is worse than none.
    """
    if full_template is None and individual_template is None:
        raise ValueError("at least one of full_template or individual_template is required")
    destination = Path(destination)
    writes: list[tuple[Path, str]] = []
    if full_template is not None:
        source = _read_template(Path(full_template), max_template_bytes)
        writes.append(
            (
                destination,
                render_full_template(
                    catalog,
                    source,
                    source_name=source_name,
                    line_break=line_break,
                    individual_filename=individual_filename,
                ),
            )
        )
    if individual_template is not None:
        source = _read_template(Path(individual_template), max_template_bytes)
        out_dir = Path(individual_dir) if individual_dir is not None else destination.parent
        for number, movie in enumerate(catalog, start=1):
            writes.append(
                (
                    out_dir / individual_filename.format(number=movie.number),
                    render_individual_template(
                        movie,
                        catalog,
                        source,
                        source_name=source_name,
                        line_break=line_break,
                        record_number=number,
                        individual_filename=individual_filename,
                    ),
                )
            )
    from .storage import _atomic_text  # local import: avoid a storage<->html_template cycle

    written: list[Path] = []
    for path, document in writes:
        with _atomic_text(path) as stream:
            stream.write(document)
        written.append(path)
    return written


def _read_template(path: Path, max_bytes: int) -> str:
    if path.stat().st_size > max_bytes:
        raise ValueError(f"HTML template exceeds size limit: {path}")
    return path.read_text(encoding="utf-8")


def _replace_general_tags(page: str, catalog: Catalog, source_name: str, line_break: str) -> str:
    metadata = catalog.metadata.get("amc_xml", {}) if isinstance(catalog.metadata, dict) else {}
    if not isinstance(metadata, dict):
        metadata = {}
    replacements = {
        "$$FILENAME": source_name,
        "$$FILEPATH": source_name,
        "$$TOTALMOVIES": str(len(catalog)),
        "$$TOTALDISKS": str(sum(movie.media_count or 0 for movie in catalog)),
        "$$OWNER_NAME": str(metadata.get("owner", "")),
        "$$OWNER_MAIL": str(metadata.get("mail", "")),
        "$$OWNER_SITE": str(metadata.get("site", "")),
        "$$DESCRIPTION": _with_line_breaks(str(metadata.get("description", "")), line_break),
    }
    replacements.update(_LABELS)
    for tag, value in replacements.items():
        page = page.replace(tag, value)
    return page


def _expand_item_loop(
    page: str, catalog: Catalog, line_break: str, individual_filename: str
) -> str:
    start = page.find(_ITEM_BEGIN)
    if start == -1:
        return page
    end = page.find(_ITEM_END, start)
    body_start = start + len(_ITEM_BEGIN)
    body_end = end if end != -1 else len(page)
    body = page[body_start:body_end]
    after = page[body_end + len(_ITEM_END) :] if end != -1 else ""
    rendered = "".join(
        _replace_movie_tags(
            body,
            movie,
            line_break=line_break,
            record_number=index,
            individual_filename=individual_filename,
        )
        for index, movie in enumerate(catalog, start=1)
    )
    return page[:start] + rendered + after


def _strip_extra_blocks(page: str) -> str:
    """Remove every `$$ITEM_EXTRA_BEGIN(...)...$$ITEM_EXTRA_END` block.

    Matches upstream's own output for a movie with no supplementary
    records, since the per-extra loop itself is not implemented (see the
    module docstring).
    """
    pattern = re.compile(
        re.escape(_ITEM_EXTRA_BEGIN) + r"(\([^)]*\))?.*?" + re.escape(_ITEM_EXTRA_END),
        re.DOTALL,
    )
    return pattern.sub("", page)


def _replace_movie_tags(
    page: str,
    movie: Movie,
    *,
    line_break: str,
    record_number: int,
    individual_filename: str,
) -> str:
    page = _strip_extra_blocks(page)
    replacements = {
        "$$ITEM_RECNR": str(record_number),
        "$$ITEM_NUMBER": str(movie.number),
        "$$ITEM_CHECKED": "x" if movie.checked else " ",
        "$$ITEM_COLORTAG": str(movie.color_tag or 0),
        "$$ITEM_COLORHTML": "",
        "$$ITEM_TYPE": movie.media_type,
        "$$ITEM_MEDIA": movie.media_label,
        "$$ITEM_SOURCE": movie.source,
        "$$ITEM_DATEADD": movie.date,
        "$$ITEM_BORROWER": movie.borrower,
        "$$ITEM_DATEWATCHED": str(movie.extras.get("DateWatched", "")),
        "$$ITEM_ORIGINALTITLE": movie.original_title,
        "$$ITEM_TRANSLATEDTITLE": movie.translated_title,
        "$$ITEM_FORMATTEDTITLE1": _combine_titles(movie.original_title, movie.translated_title),
        "$$ITEM_FORMATTEDTITLE2": _combine_titles(movie.translated_title, movie.original_title),
        "$$ITEM_FORMATTEDTITLE": movie.title,
        "$$ITEM_DIRECTOR": movie.director,
        "$$ITEM_PRODUCER": movie.producer,
        "$$ITEM_WRITER": movie.writer,
        "$$ITEM_COMPOSER": movie.composer,
        "$$ITEM_ACTORS": _with_line_breaks(movie.actors, line_break),
        "$$ITEM_COUNTRY": movie.country,
        "$$ITEM_YEAR": "" if movie.year is None else str(movie.year),
        "$$ITEM_LENGTH": "" if movie.length is None else str(movie.length),
        "$$ITEM_CATEGORY": movie.category,
        "$$ITEM_CERTIFICATION": movie.certification,
        "$$ITEM_URL": movie.url,
        "$$ITEM_COMMENTS": _with_line_breaks(movie.comments, line_break),
        "$$ITEM_DESCRIPTION": _with_line_breaks(movie.description, line_break),
        "$$ITEM_FILEPATH": movie.file_path,
        "$$ITEM_FORMAT": movie.video_format,
        "$$ITEM_VIDEOFORMAT": movie.video_format,
        "$$ITEM_AUDIOFORMAT": movie.audio_format,
        "$$ITEM_VIDEOBITRATE": "" if movie.video_bitrate is None else str(movie.video_bitrate),
        "$$ITEM_AUDIOBITRATE": "" if movie.audio_bitrate is None else str(movie.audio_bitrate),
        "$$ITEM_RESOLUTION": movie.resolution,
        "$$ITEM_FRAMERATE": "" if movie.framerate is None else _trim_float(movie.framerate),
        "$$ITEM_SIZE": _size_text(movie),
        "$$ITEM_LANGUAGES": movie.languages,
        "$$ITEM_SUBTITLES": movie.subtitles,
        "$$ITEM_DISKS": "" if movie.media_count is None else str(movie.media_count),
        "$$ITEM_NBEXTRAS": "0",
        "$$ITEM_FILEINDIV": individual_filename.format(number=movie.number),
    }
    replacements.update(_rating_tags("USERRATING", "USERAPPR", movie.user_rating))
    replacements.update(_rating_tags("RATING", "APPR", movie.rating, appreciation_alias=True))
    replacements.update(_picture_tags(movie))
    for tag, value in replacements.items():
        page = page.replace(tag, value)
    return _replace_custom_field_tags(page, movie)


def _replace_custom_field_tags(page: str, movie: Movie) -> str:
    for match in re.findall(r"\$\$ITEM_CF_(\w+)", page):
        value = _lookup_extra(movie.extras, match)
        page = page.replace(f"$$ITEM_CF_{match}", "" if value is None else str(value))
    for match in re.findall(r"\$\$LABEL_CF_(\w+)", page):
        page = page.replace(f"$$LABEL_CF_{match}", match.replace("_", " ").title())
    return page


def _lookup_extra(extras: dict, tag: str) -> object | None:
    if tag in extras:
        return extras[tag]
    folded = tag.casefold()
    for key, value in extras.items():
        if str(key).casefold() == folded:
            return value
    return None


def _rating_tags(
    value_tag: str, image_tag: str, rating: float | None, *, appreciation_alias: bool = False
) -> dict[str, str]:
    prefix = f"$$ITEM_{value_tag}"
    image_prefix = f"$$ITEM_{image_tag}"
    if rating is None:
        tags = {f"{prefix}10": "", f"{prefix}4": "", f"{image_prefix}10": ""}
        if appreciation_alias:
            tags["$$ITEM_APPRECIATION"] = ""
        tags[prefix] = ""
        return tags
    internal = round(rating * 10)
    ten = round(internal / 10)
    four = _four_scale(internal)
    tags = {
        f"{prefix}10": str(ten),
        f"{prefix}4": str(four),
        f"{image_prefix}10": f'<img src="appr10_{ten}.gif" alt="{ten}/10" />',
        f"{image_prefix}4": f'<img src="{_RATING_IMAGE_ROW[four]}" alt="{four}/4" />',
        # Upstream always formats this as `FormatFloat('#0.0', rating)`: exactly
        # one decimal place, never trimmed.
        prefix: f"{rating:.1f}",
    }
    if appreciation_alias:
        tags["$$ITEM_APPRECIATION"] = tags[f"{image_prefix}4"]
    return tags


def _four_scale(internal: int) -> int:
    """Bucket a 0-100 internal rating into upstream's 0-4 appreciation scale.

    Mirrors export.pas's exact `case iRating of 0..29: 0; 30..49: 1;
    50..69: 2; 70..89: 3; 90..100: 4` — not a formula, to avoid a subtly
    wrong approximation of it.
    """
    if internal <= 29:
        return 0
    if internal <= 49:
        return 1
    if internal <= 69:
        return 2
    if internal <= 89:
        return 3
    return 4


def _picture_tags(movie: Movie) -> dict[str, str]:
    picture = movie.picture
    filename = Path(picture).name.replace("\\", "/") if picture else ""
    image = f'<img src="{filename}" alt="pic_movie_{movie.number}" />' if filename else ""
    return {
        "$$ITEM_PICTUREFILENAME": filename,
        "$$ITEM_PICTUREFILENAME_NP": filename,
        "$$ITEM_PICTURE": image,
        "$$ITEM_PICTURE_NP": image,
    }


def _size_text(movie: Movie) -> str:
    raw = movie.extras.get("xml_file_size_text")
    if isinstance(raw, str) and raw:
        return raw
    return "" if movie.file_size is None else str(movie.file_size)


def _combine_titles(first: str, second: str) -> str:
    if not second:
        return first
    if not first:
        return second
    return f"{first} ({second})"


def _with_line_breaks(text: str, line_break: str) -> str:
    return text.replace("\r\n", line_break).replace("\n", line_break) if line_break else text


def _trim_float(value: float) -> str:
    text = f"{value:.3f}".rstrip("0").rstrip(".")
    return text or "0"
