"""Safe discovery of legacy AMC scripts without executing untrusted code."""

from __future__ import annotations

from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Callable, TypeVar

MAX_SCRIPT_HEADER_BYTES = 1024 * 1024
T = TypeVar("T")


@dataclass(frozen=True, slots=True)
class ScriptInfo:
    path: str
    title: str
    authors: str = ""
    description: str = ""
    site: str = ""
    language: str = ""
    version: str = ""
    requires: str = ""
    comments: str = ""
    license: str = ""
    get_info: bool = True
    requires_movies: bool = True
    legacy_format: bool = False
    options: tuple["ScriptOption", ...] = ()
    parameters: tuple["ScriptParameter", ...] = ()
    excluded_fields: tuple[str, ...] = ()
    picture: bool = True
    add_extras: bool = True
    delete_extras: bool = True
    modify_extras: bool = True
    excluded_extra_fields: tuple[str, ...] = ()
    extra_picture: bool = True
    static_names: tuple[str, ...] = ()
    metadata_warnings: tuple[str, ...] = ()

    def to_dict(self) -> dict[str, object]:
        return asdict(self)


@dataclass(frozen=True, slots=True)
class ScriptOption:
    name: str
    value: int
    default: int
    values: tuple[tuple[int, str], ...] = ()


@dataclass(frozen=True, slots=True)
class ScriptParameter:
    name: str
    value: str
    default: str
    description: str


def _option(line: str) -> ScriptOption:
    name, encoded = line.split("=", 1)
    parts = encoded.split("|")
    values = []
    for item in parts[2:]:
        if not item or "=" not in item:
            continue
        raw_value, description = item.split("=", 1)
        values.append((int(raw_value or 0), description))
    default = int(parts[1]) if len(parts) > 1 and parts[1] else values[0][0] if values else 0
    value = int(parts[0]) if parts[0] else default
    return ScriptOption(name, value, default, tuple(values))


def _parameter(line: str) -> ScriptParameter:
    name, encoded = line.split("=", 1)
    parts = encoded.split("|", 2)
    parts.extend([""] * (3 - len(parts)))
    return ScriptParameter(name, parts[0], parts[1], parts[2])


def _section_values(lines: list[str]) -> dict[str, str]:
    return dict(line.split("=", 1) for line in lines)


def _names(value: str) -> tuple[str, ...]:
    return tuple(item.strip() for item in value.replace(";", ",").split(",") if item.strip())


def _parsed_items(
    lines: list[str], parser: Callable[[str], T], label: str
) -> tuple[tuple[T, ...], tuple[str, ...]]:
    """Parse independent metadata entries while retaining stable diagnostics."""
    values = []
    warnings = []
    for index, line in enumerate(lines, start=1):
        try:
            values.append(parser(line))
        except (TypeError, ValueError):
            warnings.append(f"invalid {label} entry {index}")
    return tuple(values), tuple(warnings)


def inspect_script(path: str | Path) -> ScriptInfo:
    """Read the bracketed metadata comment from an AMC script without execution."""
    path = Path(path)
    with path.open("rb") as stream:
        header = stream.read(MAX_SCRIPT_HEADER_BYTES + 1)
    if len(header) > MAX_SCRIPT_HEADER_BYTES:
        raise ValueError("script metadata header exceeds size limit")
    try:
        text = header.decode("utf-8-sig")
    except UnicodeDecodeError:
        text = header.decode("cp1252")
    if not text.startswith("(*") or "*)" not in text:
        return ScriptInfo(str(path), path.name, legacy_format=True)
    comment = text[2:text.index("*)")]
    sections: dict[str, list[str]] = {}
    section = ""
    for raw_line in comment.splitlines():
        line = raw_line.strip()
        if line.startswith("[") and line.endswith("]"):
            section = line[1:-1]
            sections.setdefault(section, [])
        elif section and "=" in line:
            sections[section].append(line)
    info = _section_values(sections.get("Infos", []))
    fields = _section_values(sections.get("Fields", []))
    extra_fields = _section_values(sections.get("ExtraFields", []))
    def boolean(key: str, default: bool) -> bool:
        return info.get(key, "1" if default else "0") != "0"

    def section_boolean(values: dict[str, str], key: str, default: bool) -> bool:
        return values.get(key, "1" if default else "0") != "0"
    options, option_warnings = _parsed_items(
        sections.get("Options", []), _option, "option"
    )
    parameters, parameter_warnings = _parsed_items(
        sections.get("Parameters", []), _parameter, "parameter"
    )
    return ScriptInfo(
        str(path), info.get("Title") or path.name, info.get("Authors", ""),
        info.get("Description", ""), info.get("Site", ""), info.get("Language", ""),
        info.get("Version", ""), info.get("Requires", ""), info.get("Comments", ""),
        info.get("License", ""), boolean("GetInfo", True),
        boolean("RequiresMovies", True), False,
        options,
        parameters,
        _names(fields.get("Excluded", "")),
        section_boolean(fields, "Picture", True),
        section_boolean(extra_fields, "AddExtras", True),
        section_boolean(extra_fields, "DeleteExtras", True),
        section_boolean(extra_fields, "ModifyExtras", True),
        _names(extra_fields.get("Excluded", "")),
        section_boolean(extra_fields, "Picture", True),
        tuple(
            line.split("=", 1)[0].strip()
            for line in sections.get("Static", [])
            if line.split("=", 1)[0].strip()
        ),
        option_warnings + parameter_warnings,
    )


def discover_scripts(directory: str | Path) -> list[ScriptInfo]:
    """Return deterministic metadata for `.ifs` files directly in a directory."""
    directory = Path(directory)
    if not directory.is_dir():
        raise ValueError(f"script path is not a directory: {directory}")
    return [inspect_script(path) for path in sorted(directory.glob("*.ifs"))]
