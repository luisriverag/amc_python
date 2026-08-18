"""JSON persistence and Ant Movie Catalog XML interchange support."""

from __future__ import annotations

import csv
import html
import json
import os
import re
import shutil
import xml.etree.ElementTree as ET
from contextlib import contextmanager
from dataclasses import asdict, fields
from pathlib import Path

from .catalog import Catalog
from .model import Movie
from .native import (
    NATIVE_HEADER_SIZE,
    NATIVE_HEADERS,
    NativeReadLimits,
    NativeWriteLimits,
    read_native_catalog,
    write_native_catalog,
)

_XML_FIELDS = {
    "OriginalTitle": "original_title", "TranslatedTitle": "translated_title",
    "FormattedTitle": "title", "Director": "director", "Producer": "producer",
    "Writer": "writer", "Composer": "composer", "Country": "country",
    "Category": "category", "Certification": "certification", "Year": "year",
    "Length": "length", "FilePath": "file_path",
    "Rating": "rating", "UserRating": "user_rating", "ColorTag": "color_tag",
    "Date": "date", "Borrower": "borrower",
    "MediaLabel": "media_label", "MediaType": "media_type", "MediaCount": "media_count",
    "Source": "source", "URL": "url", "Description": "description", "Comments": "comments",
    "Actors": "actors", "Languages": "languages", "Subtitles": "subtitles",
    "VideoFormat": "video_format", "VideoBitrate": "video_bitrate",
    "AudioFormat": "audio_format", "AudioBitrate": "audio_bitrate",
    "Resolution": "resolution", "Framerate": "framerate", "FileSize": "file_size",
    "Picture": "picture",
}
_PYTHON_TO_XML = {value: key for key, value in _XML_FIELDS.items()}
_INTEGER_FIELDS = {
    "year", "length", "media_count", "video_bitrate", "audio_bitrate",
    "file_size", "color_tag",
}
_FLOAT_FIELDS = {"rating", "user_rating", "framerate"}


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


def load(
    path: str | Path,
    *,
    native_encoding: str = "cp1252",
    native_limits: NativeReadLimits | None = None,
) -> Catalog:
    path = Path(path)
    has_native_header = _has_native_header(path)
    if has_native_header:
        return _load_native(path, native_encoding, native_limits)
    if path.suffix.casefold() == ".amc" and not _has_json_header(path):
        # Keep reporting useful native-header errors for malformed native files,
        # while retaining compatibility with JSON catalogs that older releases
        # allowed users to save with an .amc filename.
        return _load_native(path, native_encoding, native_limits)
    if path.suffix.casefold() == ".xml":
        return load_xml(path)
    if path.suffix.casefold() == ".csv":
        return load_csv(path)
    with path.open(encoding="utf-8") as stream:
        document = json.load(
            stream,
            object_pairs_hook=_json_object,
            parse_constant=_reject_json_constant,
        )
    if isinstance(document, dict):
        format_name = document.get("format", "amc-python")
        if not isinstance(format_name, str) or format_name != "amc-python":
            raise ValueError(f"unsupported catalog format: {format_name!r}")
        version = document.get("version", 1)
        if isinstance(version, bool) or not isinstance(version, int) or version != 1:
            raise ValueError(f"unsupported catalog version: {version!r}")
    rows = document.get("movies", document) if isinstance(document, dict) else document
    if not isinstance(rows, list):
        raise ValueError("catalog JSON must contain a list of movies")
    metadata = document.get("metadata", {}) if isinstance(document, dict) else {}
    if not isinstance(metadata, dict):
        raise ValueError("catalog JSON metadata must be an object")
    movies = []
    for index, row in enumerate(rows):
        try:
            movies.append(Movie.from_dict(row))
        except (TypeError, ValueError) as error:
            raise ValueError(f"invalid movie at index {index}: {error}") from error
    return Catalog(movies, metadata=metadata)


def _json_object(pairs: list[tuple[str, object]]) -> dict[str, object]:
    """Build a JSON object while rejecting ambiguous duplicate member names."""
    result: dict[str, object] = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON object member: {key!r}")
        result[key] = value
    return result


def _reject_json_constant(value: str) -> object:
    """Reject the non-standard NaN and infinity tokens accepted by ``json``."""
    raise ValueError(f"invalid non-finite JSON number: {value}")


def _has_native_header(path: Path) -> bool:
    """Detect exact native headers without interpreting arbitrary binary files."""
    with path.open("rb") as stream:
        return stream.read(NATIVE_HEADER_SIZE) in NATIVE_HEADERS


def _has_json_header(path: Path) -> bool:
    """Recognize a JSON object or array without decoding an entire catalog."""
    with path.open("rb") as stream:
        prefix = stream.read(4096)
    if prefix.startswith(b"\xef\xbb\xbf"):
        prefix = prefix[3:]
    return prefix.lstrip().startswith((b"{", b"["))


def _load_native(
    path: Path, encoding: str, limits: NativeReadLimits | None
) -> Catalog:
    native = read_native_catalog(path, encoding=encoding, limits=limits)
    metadata = {
        "native": {
            "version": native.properties.version,
            "owner": native.properties.owner,
            "mail": native.properties.mail,
            "site": native.properties.site,
            "description": native.properties.description,
            "column_settings": native.properties.column_settings,
            "gui_properties": native.properties.gui_properties,
            "custom_fields": [asdict(field) for field in native.properties.custom_fields],
        }
    }
    return Catalog(native.movies, metadata=metadata)


def save(catalog: Catalog, path: str | Path) -> None:
    path = Path(path)
    with _atomic_text(path) as stream:
        json.dump({"format": "amc-python", "version": 1, "metadata": catalog.metadata, "movies": [m.to_dict() for m in catalog]}, stream, ensure_ascii=False, indent=2)
        stream.write("\n")


def save_native(
    catalog: Catalog,
    path: str | Path,
    *,
    encoding: str = "cp1252",
    limits: NativeWriteLimits | None = None,
) -> None:
    """Write an AMC 4.2 native catalog without changing the JSON default format."""
    write_native_catalog(catalog, path, encoding=encoding, limits=limits)


def copy_catalog(source: str | Path, destination: str | Path) -> None:
    """Validate and atomically copy a catalog without reserializing its contents."""
    source = Path(source)
    destination = Path(destination)
    if source.resolve() == destination.resolve():
        raise ValueError("source and destination catalog paths must differ")
    destination.parent.mkdir(parents=True, exist_ok=True)
    temporary = destination.with_name(f".{destination.name}.tmp")
    try:
        with source.open("rb") as incoming, temporary.open("wb") as outgoing:
            shutil.copyfileobj(incoming, outgoing)
            outgoing.flush()
            os.fsync(outgoing.fileno())
        # Validate the bytes that will actually be installed, rather than opening
        # the source a second time and permitting a check/use race.
        load(temporary)
        temporary.replace(destination)
    finally:
        temporary.unlink(missing_ok=True)


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
    catalog_node = ET.SubElement(root, "Catalog")
    metadata = _xml_metadata(catalog.metadata)
    properties = ET.SubElement(catalog_node, "Properties")
    for tag in ("Owner", "Mail", "Site", "Description"):
        value = metadata.get(tag.casefold(), "")
        if value:
            properties.set(tag, str(value))
    definitions = metadata.get("custom_fields", [])
    if isinstance(definitions, list) and definitions:
        definitions_node = ET.SubElement(catalog_node, "CustomFieldsProperties")
        for setting in ("ColumnSettings", "GUIProperties", "OtherProperties"):
            value = metadata.get(_camel_to_snake(setting), "")
            if value:
                definitions_node.set(setting, str(value))
        for definition in definitions:
            if not isinstance(definition, dict):
                continue
            field_node = ET.SubElement(definitions_node, "CustomField")
            for key, value in definition.items():
                if key == "list_values" and isinstance(value, (list, tuple)):
                    for item in value:
                        ET.SubElement(field_node, "ListValue", {"Text": str(item)})
                elif value not in (None, "", False, [], ()):
                    field_node.set(_snake_to_camel(key), str(value))
    contents = ET.SubElement(catalog_node, "Contents")
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
                if not isinstance(value, (str, int, float, bool)) and value is not None:
                    raise ValueError(
                        f"movie extra {tag!r} cannot be represented losslessly in AMC XML"
                    )
                ET.SubElement(node, tag).text = "" if value is None else str(value)
    tree = ET.ElementTree(root)
    ET.indent(tree, space="  ")
    with _atomic_text(path) as stream:
        tree.write(stream, encoding="unicode", xml_declaration=True)


def save_html(
    catalog: Catalog,
    path: str | Path,
    *,
    template: str | Path | None = None,
    row_template: str | Path | None = None,
) -> None:
    """Write escaped movie rows into a safe static HTML document or template."""
    row_source = (
        '      <tr><td class="number">{{NUMBER}}</td>'
        '<td class="title">{{DISPLAY_TITLE}}</td><td class="year">{{YEAR}}</td>'
        '<td class="director">{{DIRECTOR}}</td></tr>'
    )
    if row_template is not None:
        row_path = Path(row_template)
        if row_path.stat().st_size > 256 * 1024:
            raise ValueError("HTML row template exceeds size limit")
        row_source = row_path.read_text(encoding="utf-8")
    allowed = {
        item.name.upper() for item in fields(Movie) if item.name != "extras"
    } | {"DISPLAY_TITLE"}
    markers = set(re.findall(r"{{([A-Z_]+)}}", row_source))
    unknown = sorted(markers - allowed)
    if unknown:
        raise ValueError(f"unknown HTML row template marker: {unknown[0]}")
    rows = []
    for movie in catalog:
        values = {"DISPLAY_TITLE": html.escape(movie.display_title())}
        for item in fields(Movie):
            if item.name == "extras":
                continue
            value = getattr(movie, item.name)
            if value is None:
                text = ""
            elif isinstance(value, bool):
                text = "true" if value else "false"
            else:
                text = str(value)
            values[item.name.upper()] = html.escape(text)
        row = row_source
        for marker, value in values.items():
            row = row.replace(f"{{{{{marker}}}}}", value)
        rows.append(row)
    body = "\n".join(rows)
    default_template = """<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Movie Catalog</title><style>body{{font-family:sans-serif;margin:2rem}}table{{border-collapse:collapse;width:100%}}th,td{{border:1px solid #ccc;padding:.4rem;text-align:left}}th{{background:#eee}}.number,.year{{text-align:right}}</style></head>
<body><h1>Movie Catalog</h1><table>
    <thead><tr><th>Number</th><th>Title</th><th>Year</th><th>Director</th></tr></thead>
    <tbody>
{{MOVIES}}
    </tbody>
  </table></body></html>
"""
    if template is None:
        source = default_template
    else:
        template_path = Path(template)
        if template_path.stat().st_size > 1024 * 1024:
            raise ValueError("HTML template exceeds size limit")
        source = template_path.read_text(encoding="utf-8")
    if source.count("{{MOVIES}}") != 1:
        raise ValueError("HTML template must contain exactly one {{MOVIES}} marker")
    document = source.replace("{{MOVIES}}", body)
    with _atomic_text(Path(path)) as stream:
        stream.write(document)


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
    try:
        root = ET.parse(path).getroot()
    except ET.ParseError as error:
        raise ValueError(f"invalid catalog XML: {error}") from error
    metadata = _read_xml_metadata(root)
    catalog = Catalog(metadata={"amc_xml": metadata} if metadata else {})
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


def _read_xml_metadata(root: ET.Element) -> dict[str, object]:
    result: dict[str, object] = {}
    properties = root.find("./Catalog/Properties")
    if properties is not None:
        for tag in ("Owner", "Mail", "Site", "Description"):
            value = properties.get(tag)
            if value is not None:
                result[tag.casefold()] = value
    definitions = root.find("./Catalog/CustomFieldsProperties")
    if definitions is not None:
        for setting in ("ColumnSettings", "GUIProperties", "OtherProperties"):
            value = definitions.get(setting)
            if value is not None:
                result[_camel_to_snake(setting)] = value
        fields: list[dict[str, object]] = []
        for node in definitions.findall("CustomField"):
            definition = {_camel_to_snake(key): value for key, value in node.attrib.items()}
            values = [item.get("Text", "") for item in node.findall("ListValue")]
            if values:
                definition["list_values"] = values
            fields.append(definition)
        if fields:
            result["custom_fields"] = fields
    return result


def _xml_metadata(metadata: dict[str, object]) -> dict[str, object]:
    xml = metadata.get("amc_xml")
    if isinstance(xml, dict):
        return xml
    native = metadata.get("native")
    return native if isinstance(native, dict) else {}


def _camel_to_snake(value: str) -> str:
    return re.sub(r"(?<!^)(?=[A-Z])", "_", value).casefold()


def _snake_to_camel(value: str) -> str:
    special = {
        "tag": "Tag", "name": "Name", "extension": "Ext", "field_type": "Type",
        "default_value": "DefaultValue", "media_info": "MediaInfo",
        "multi_values": "MultiValues", "multi_value_separator": "MultiValuesSep",
        "remove_parentheses": "MultiValuesRmP", "patch_values": "MultiValuesPatch",
        "excluded_in_scripts": "ExcludedInScripts", "gui_properties": "GUIProperties",
        "list_auto_add": "ListAutoAdd", "list_sort": "ListSort",
        "list_auto_complete": "ListAutoComplete",
        "list_use_catalog_values": "ListUseCatalogValues",
    }
    return special.get(value, "".join(part.capitalize() for part in value.split("_")))
