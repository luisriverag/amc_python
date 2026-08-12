"""JSON persistence and Ant Movie Catalog XML interchange support."""

from __future__ import annotations

import json
import os
import re
import csv
import xml.etree.ElementTree as ET
from contextlib import contextmanager
from dataclasses import fields
from pathlib import Path

from .catalog import Catalog
from .model import Movie

_XML_FIELDS = {
    "OriginalTitle": "original_title", "TranslatedTitle": "translated_title",
    "FormattedTitle": "title", "Director": "director", "Producer": "producer",
    "Country": "country", "Category": "category", "Year": "year", "Length": "length",
    "Rating": "rating", "Date": "date", "Borrower": "borrower",
    "MediaLabel": "media_label", "MediaType": "media_type", "MediaCount": "media_count",
    "Source": "source", "URL": "url", "Description": "description", "Comments": "comments",
    "Actors": "actors", "Languages": "languages", "Subtitles": "subtitles",
    "VideoFormat": "video_format", "VideoBitrate": "video_bitrate",
    "AudioFormat": "audio_format", "AudioBitrate": "audio_bitrate",
    "Resolution": "resolution", "Framerate": "framerate", "FileSize": "file_size",
    "Picture": "picture",
}
_PYTHON_TO_XML = {value: key for key, value in _XML_FIELDS.items()}
_INTEGER_FIELDS = {"year", "length", "media_count", "video_bitrate", "audio_bitrate", "file_size"}
_FLOAT_FIELDS = {"rating", "framerate"}


@contextmanager
def _atomic_text(path: Path, *, encoding: str = "utf-8", newline: str | None = None):
    """Yield a durable temporary stream and atomically replace *path* on success."""
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    try:
        with temporary.open("w", encoding=encoding, newline=newline) as stream:
            yield stream
            stream.flush()
            os.fsync(stream.fileno())
        temporary.replace(path)
    finally:
        temporary.unlink(missing_ok=True)


def load(path: str | Path) -> Catalog:
    path = Path(path)
    if path.suffix.casefold() == ".xml":
        return load_xml(path)
    if path.suffix.casefold() == ".csv":
        return load_csv(path)
    with path.open(encoding="utf-8") as stream:
        document = json.load(stream)
    if isinstance(document, dict) and document.get("format") not in (None, "amc-python"):
        raise ValueError(f"unsupported catalog format: {document.get('format')!r}")
    if isinstance(document, dict) and document.get("version", 1) != 1:
        raise ValueError(f"unsupported catalog version: {document.get('version')!r}")
    rows = document.get("movies", document) if isinstance(document, dict) else document
    if not isinstance(rows, list):
        raise ValueError("catalog JSON must contain a list of movies")
    return Catalog(Movie.from_dict(row) for row in rows)


def save(catalog: Catalog, path: str | Path) -> None:
    path = Path(path)
    with _atomic_text(path) as stream:
        json.dump({"format": "amc-python", "version": 1, "movies": [m.to_dict() for m in catalog]}, stream, ensure_ascii=False, indent=2)
        stream.write("\n")


def load_csv(path: str | Path) -> Catalog:
    """Load a UTF-8 CSV file whose headers use Python or AMC field names."""
    aliases = {key.casefold(): value for key, value in _XML_FIELDS.items()}
    known = {item.name for item in fields(Movie)}
    catalog = Catalog()
    with Path(path).open(encoding="utf-8-sig", newline="") as stream:
        for row_number, row in enumerate(csv.DictReader(stream), start=2):
            values: dict[str, object] = {}
            extras: dict[str, str] = {}
            for header, text in row.items():
                if header is None:
                    continue
                field = aliases.get(header.strip().casefold(), header.strip().casefold().replace(" ", "_"))
                text = text or ""
                if field in _INTEGER_FIELDS or field == "number":
                    values[field] = _number(text, int)
                elif field in _FLOAT_FIELDS:
                    values[field] = _number(text, float)
                elif field == "checked":
                    values[field] = text.casefold() in {"true", "yes", "1", "x"}
                elif field in known and field != "extras":
                    values[field] = text
                elif header.strip():
                    extras[header.strip()] = text
            values["number"] = int(values.get("number") or 0)
            values["extras"] = extras
            try:
                catalog.add(Movie.from_dict(values), renumber=False)
            except (TypeError, ValueError) as error:
                raise ValueError(f"invalid CSV row {row_number}: {error}") from error
    return catalog


def save_csv(catalog: Catalog, path: str | Path) -> None:
    """Export common movie fields to an Excel-compatible UTF-8 CSV file."""
    path = Path(path)
    fieldnames = [item.name for item in fields(Movie) if item.name != "extras"]
    extra_names = sorted(
        {str(key) for movie in catalog for key in movie.extras}
        - set(fieldnames)
    )
    with _atomic_text(path, encoding="utf-8-sig", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=fieldnames + extra_names)
        writer.writeheader()
        for movie in catalog:
            row = {name: getattr(movie, name) for name in fieldnames}
            row.update({str(key): value for key, value in movie.extras.items() if str(key) in extra_names})
            writer.writerow(row)


def save_xml(catalog: Catalog, path: str | Path) -> None:
    """Write an XML catalog that Ant Movie Catalog can import."""
    path = Path(path)
    root = ET.Element("AntMovieCatalog", {"Format": "4.2.2 Python"})
    contents = ET.SubElement(ET.SubElement(root, "Catalog"), "Contents")
    for movie in catalog:
        node = ET.SubElement(
            contents,
            "Movie",
            {"Number": str(movie.number), "Checked": str(movie.checked)},
        )
        for field, tag in _PYTHON_TO_XML.items():
            value = getattr(movie, field)
            if value not in (None, ""):
                # AMC stores regular fields as Movie attributes; Picture and
                # multiline text are also accepted as child elements.
                if field in {"description", "comments", "picture"}:
                    ET.SubElement(node, tag).text = str(value)
                else:
                    node.set(tag, str(value))
        for tag, value in movie.extras.items():
            if tag not in _XML_FIELDS:
                ET.SubElement(node, tag).text = str(value)
    tree = ET.ElementTree(root)
    ET.indent(tree, space="  ")
    with _atomic_text(path) as stream:
        tree.write(stream, encoding="unicode", xml_declaration=True)


def _number(value: str | None, kind: type[int] | type[float]):
    if not value or not value.strip():
        return None
    match = re.search(r"[-+]?\d+(?:[.,]\d+)?", value)
    if not match:
        return None
    normalized = match.group().replace(",", ".")
    return kind(float(normalized)) if kind is int else kind(normalized)


def load_xml(path: str | Path) -> Catalog:
    """Read the XML export produced by Ant Movie Catalog 3.x/4.x."""
    root = ET.parse(path).getroot()
    catalog = Catalog()
    for node in root.findall(".//Movie"):
        values: dict[str, object] = {
            "number": int(_number(node.get("Number"), int) or 0),
            "checked": (node.get("Checked") or "").casefold() in {"true", "yes", "1"},
        }
        extras: dict[str, str] = {}
        raw_fields = {key: value for key, value in node.attrib.items() if key not in {"Number", "Checked"}}
        raw_fields.update({child.tag: child.text or "" for child in node})
        for tag, text in raw_fields.items():
            field = _XML_FIELDS.get(tag)
            if field in _INTEGER_FIELDS:
                values[field] = _number(text, int)
            elif field in _FLOAT_FIELDS:
                values[field] = _number(text, float)
            elif field:
                values[field] = text
            else:
                extras[tag] = text
        values["extras"] = extras
        catalog.add(Movie(**values), renumber=False)
    return catalog
