import re
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent.parent
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


_HEADING = re.compile(r"^#{1,6}\s+(.+?)\s*#*$", re.MULTILINE)
_INLINE_CODE = re.compile(r"`([^`]*)`")
_NON_SLUG_CHAR = re.compile(r"[^\w\s-]", re.UNICODE)
_WHITESPACE_RUN = re.compile(r"\s+")


def _heading_slugs(markdown: str) -> set[str]:
    """Reproduce GitHub's heading-to-anchor slug algorithm closely enough to
    check `#anchor` links: lowercase, drop inline-code backticks (keeping
    their text), strip punctuation other than spaces/hyphens, spaces become
    hyphens, and a repeated slug gets a `-1`, `-2`, ... suffix."""
    used: dict[str, int] = {}
    slugs: set[str] = set()
    for heading in _HEADING.findall(markdown):
        text = _INLINE_CODE.sub(r"\1", heading).strip().lower()
        text = _NON_SLUG_CHAR.sub("", text)
        slug = _WHITESPACE_RUN.sub("-", text.strip())
        if slug in used:
            used[slug] += 1
            slug = f"{slug}-{used[slug]}"
        else:
            used[slug] = 0
        slugs.add(slug)
    return slugs


def test_markdown_link_anchors_resolve():
    """A `path#anchor`/`#anchor` link must name a heading that actually
    exists in the target document (or the current one), not just a file
    that exists — `test_relative_markdown_links_resolve` above deliberately
    only checks the file part."""
    documents = [
        document
        for document in sorted(ROOT.rglob("*.md"))
        if not any(part in {".git", "build", "dist", "upstream"} for part in document.parts)
    ]
    slugs_by_path = {
        document: _heading_slugs(document.read_text(encoding="utf-8")) for document in documents
    }
    broken = []
    for document in documents:
        text = document.read_text(encoding="utf-8")
        for target in MARKDOWN_LINK.findall(text):
            if target.startswith(("http://", "https://", "mailto:")):
                continue
            if "#" not in target:
                continue
            relative, anchor = target.split("#", 1)
            target_path = document if not relative else (document.parent / relative).resolve()
            slugs = slugs_by_path.get(target_path)
            if slugs is not None and anchor not in slugs:
                broken.append(f"{document.relative_to(ROOT)} -> {target}")
    assert broken == []


def test_port_audit_current_counts_match_repository():
    audit = (ROOT / "docs" / "PORT_AUDIT.md").read_text(encoding="utf-8")
    functional_modules = [
        path for path in (ROOT / "src" / "amc").glob("*.py") if path.name != "__init__.py"
    ]
    tools = list((ROOT / "tools").glob("*.py"))
    assert f"{len(functional_modules)} functional package modules" in audit
    assert f"{len(tools)} repository tools" in audit


def test_readme_port_progress_matches_implementation_plan():
    plan = (ROOT / "docs" / "IMPLEMENTATION_PLAN.md").read_text(encoding="utf-8")
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    complete = len(re.findall(r"^- \[x\]", plan, re.MULTILINE))
    total = complete + len(re.findall(r"^- \[ \]", plan, re.MULTILINE))
    percent = round(complete / total * 100)

    assert f"**{percent}% — {complete} of {total} implementation-plan" in readme
    progress = re.search(r"`([█░]+)` \*\*(\d+) / (\d+)\*\*", readme)
    assert progress is not None
    assert (progress.group(1).count("█"), len(progress.group(1))) == (complete, total)
    assert progress.groups()[1:] == (str(complete), str(total))


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
