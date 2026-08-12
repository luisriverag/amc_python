# Contributing

## Local checks

Run the complete currently available check set before committing:

```console
python -m pytest -q
python -m compileall -q src tests
PYTHONPATH=src python -m amc.cli --help >/dev/null
git diff --check
```

As CI tooling is added, this section must remain the canonical local equivalent.

## Test-driven changes

1. Choose one unchecked slice from `docs/IMPLEMENTATION_PLAN.md`.
2. Locate and record its upstream source behavior.
3. Add or register a fixture with provenance.
4. Write a failing compatibility or acceptance test.
5. Add focused unit tests for boundaries and corrupt inputs.
6. Implement the smallest change that passes.
7. Run the whole suite, not only the new test.
8. Update `docs/compatibility.md` and user documentation.

Do not use live network calls in ordinary tests. Do not invent native format details
without source or fixture evidence. Never silently drop unsupported fields.

## Fixtures

Fixture metadata must record producer/version, creation instructions, digest,
expected contents, provenance, and redistribution rights. Keep binary fixtures as
small as possible. Malformed fixtures should document the exact byte mutation.

## Acquiring upstream source

The archive and extracted source are deliberately ignored until licensing and
redistribution are confirmed. Acquire them with:

```console
python tools/acquire_upstream.py --extract-to upstream/source
```

This streams the archive, records its URL, retrieval timestamp, size and SHA-256,
selects an installed `unrar`, `7z`, or `bsdtar`, and creates a deterministic file
inventory. Review `upstream/archive.json` and `upstream/inventory.json`, then copy
verified facts—not unreviewed upstream source—into the documentation.

## Commit scope

Prefer one vertical feature per commit. A format parser change should normally ship
with its fixture, tests, compatibility update, and documentation. Avoid mixing
format work with unrelated GUI changes.

## Code boundaries

- Domain modules do not perform I/O.
- Codecs do not print or display dialogs.
- UI code does not implement merge, validation, or serialization policy.
- Imports are never wrapped in `try`/`except` blocks.
- Public behavior receives type annotations and docstrings.
