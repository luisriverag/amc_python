"""Safe discovery of legacy AMC scripts without executing untrusted code."""

from __future__ import annotations

import json
import os
from dataclasses import asdict, dataclass, replace
from pathlib import Path
from typing import Callable, Iterable, TypeVar

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
    normalized = value.replace(";", ",").replace("|", ",")
    return tuple(item.strip() for item in normalized.split(",") if item.strip())


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


def configure_script(
    script: ScriptInfo,
    *,
    options: dict[str, int] | None = None,
    parameters: dict[str, str] | None = None,
) -> ScriptInfo:
    """Apply validated option and parameter choices without executing a script."""
    option_values = _casefold_overrides(options or {}, "option")
    parameter_values = _casefold_overrides(parameters or {}, "parameter")
    known_options = _unique_names((item.name for item in script.options), "option")
    known_parameters = _unique_names(
        (item.name for item in script.parameters), "parameter"
    )
    unknown_options = option_values.keys() - known_options
    unknown_parameters = parameter_values.keys() - known_parameters
    if unknown_options:
        raise ValueError(f"unknown script option: {sorted(unknown_options)[0]!r}")
    if unknown_parameters:
        raise ValueError(f"unknown script parameter: {sorted(unknown_parameters)[0]!r}")

    configured_options = []
    for item in script.options:
        value = option_values.get(item.name.casefold(), item.value)
        allowed = {choice for choice, _description in item.values}
        if allowed and value not in allowed:
            raise ValueError(
                f"invalid value {value} for script option {item.name!r}; "
                f"expected one of {sorted(allowed)}"
            )
        configured_options.append(replace(item, value=value))
    configured_parameters = tuple(
        replace(
            item,
            value=parameter_values.get(item.name.casefold(), item.value),
        )
        for item in script.parameters
    )
    return replace(
        script,
        options=tuple(configured_options),
        parameters=configured_parameters,
    )


def save_script_configuration(script: ScriptInfo, path: str | Path) -> None:
    """Atomically persist public option/parameter values without static state."""
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    document = {
        "format": "amc-python-script-settings",
        "version": 1,
        "script": Path(script.path).name,
        "options": {item.name: item.value for item in script.options},
        "parameters": {item.name: item.value for item in script.parameters},
    }
    try:
        with temporary.open("w", encoding="utf-8") as stream:
            json.dump(document, stream, ensure_ascii=False, indent=2)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        temporary.replace(path)
    finally:
        temporary.unlink(missing_ok=True)


def load_script_configuration(script: ScriptInfo, path: str | Path) -> ScriptInfo:
    """Load and validate a saved configuration for the selected script."""
    with Path(path).open(encoding="utf-8") as stream:
        document = json.load(stream)
    if not isinstance(document, dict):
        raise ValueError("script settings must be a JSON object")
    if document.get("format") != "amc-python-script-settings":
        raise ValueError("unsupported script settings format")
    if document.get("version") != 1:
        raise ValueError(f"unsupported script settings version: {document.get('version')!r}")
    script_name = document.get("script")
    if not isinstance(script_name, str) or script_name.casefold() != Path(script.path).name.casefold():
        raise ValueError("script settings belong to a different script")
    options = document.get("options", {})
    parameters = document.get("parameters", {})
    if not isinstance(options, dict) or any(
        not isinstance(key, str) or isinstance(value, bool) or not isinstance(value, int)
        for key, value in options.items()
    ):
        raise ValueError("script settings options must map names to integers")
    if not isinstance(parameters, dict) or any(
        not isinstance(key, str) or not isinstance(value, str)
        for key, value in parameters.items()
    ):
        raise ValueError("script settings parameters must map names to strings")
    return configure_script(script, options=options, parameters=parameters)


def _casefold_overrides(values: dict[str, T], label: str) -> dict[str, T]:
    result: dict[str, T] = {}
    for name, value in values.items():
        normalized = name.strip().casefold()
        if not normalized:
            raise ValueError(f"script {label} name cannot be empty")
        if normalized in result:
            raise ValueError(f"duplicate script {label}: {name!r}")
        result[normalized] = value
    return result


def _unique_names(values: Iterable[str], label: str) -> set[str]:
    result: set[str] = set()
    for value in values:
        normalized = value.casefold()
        if normalized in result:
            raise ValueError(f"duplicate script {label} declaration: {value!r}")
        result.add(normalized)
    return result
