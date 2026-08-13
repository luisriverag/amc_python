# Contributing

## Local checks

Install the development extra once, then run the complete currently available check
set before committing:

```console
python -m pip install -e .[dev]
python tools/check.py
python tools/check_package.py
```

`check.py` runs focused Ruff lint rules, executes all tests with branch measurement,
and enforces an 80% repository-wide coverage floor. It also verifies repository
Markdown links and audit counts, checks README command registration, compiles the
Python tree, validates fixture manifests, smoke-tests the source CLI, and rejects
whitespace errors in staged and unstaged changes. The Ruff configuration currently
checks import/name errors and selected `E4`, `E7`, and `E9` rules; it is not a claim
that a formatter or comprehensive style policy has been adopted.

`check_package.py` builds a wheel, installs it into a temporary virtual environment,
and smoke-tests the installed module and console entry points without letting the
repository `PYTHONPATH` mask packaging errors. These two commands are the canonical
local equivalent of the configured CI jobs. A configured workflow is not evidence
that a hosted run has passed; record hosted-run evidence separately when available.

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
expected contents, provenance, and redistribution rights using the manifest contract
in `tests/fixtures/README.md`. Keep binary fixtures as small as possible. Malformed
fixtures should document the exact byte mutation. Validate a supplied fixture set
with `python tools/validate_fixtures.py --require-manifests`.

## Acquiring upstream source

The archive and extracted source are deliberately ignored until licensing and
redistribution are confirmed. Acquire them with:

```console
python tools/acquire_upstream.py \
  --expected-sha256 <independently-published-digest> \
  --extract-to upstream/source \
  --compare-to src/original
```

This streams the archive, records its URL, retrieval timestamp, size and SHA-256,
selects an installed `unrar`, `7z`, or `bsdtar`, creates a deterministic file
inventory, and writes a snapshot comparison. Omit
`--expected-sha256` only when no independent digest exists; the recorded digest is
then provenance data, not external verification. Review `upstream/archive.json`,
`upstream/inventory.json`, and `upstream/comparison.json`, then copy
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
