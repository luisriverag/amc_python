import re
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
MARKDOWN_LINK = re.compile(r"(?<!!)\[[^]]+\]\(([^)]+)\)")


def test_relative_markdown_links_resolve():
    missing = []
    for document in sorted(ROOT.rglob("*.md")):
        if any(part in {".git", "build", "dist", "upstream"} for part in document.parts):
            continue
        text = document.read_text(encoding="utf-8")
        for target in MARKDOWN_LINK.findall(text):
            if target.startswith(("http://", "https://", "mailto:", "#")):
                continue
            relative = target.split("#", 1)[0]
            if relative and not (document.parent / relative).resolve().exists():
                missing.append(f"{document.relative_to(ROOT)} -> {target}")
    assert missing == []


def test_port_audit_current_counts_match_repository():
    audit = (ROOT / "docs" / "PORT_AUDIT.md").read_text(encoding="utf-8")
    functional_modules = [
        path for path in (ROOT / "src" / "amc").glob("*.py")
        if path.name != "__init__.py"
    ]
    tools = list((ROOT / "tools").glob("*.py"))
    assert f"{len(functional_modules)} functional package modules" in audit
    assert f"{len(tools)} repository tools" in audit


def test_readme_commands_are_registered_by_cli_parser():
    from amc.cli import parser

    help_text = parser().format_help()
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    commands = {
        match.group(1)
        for match in re.finditer(r"^amc(?: -c \S+)? ([a-z][a-z-]+)", readme, re.MULTILINE)
    }
    assert commands
    assert all(command in help_text for command in commands)
