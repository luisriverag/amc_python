# Documentation

Use this page to find the right guide without needing to read the implementation
and compatibility material first.

## Using AMC Python

- [Getting started](getting-started.md) — installation, a first catalog, migration,
  backups, and interface selection.
- [Command-line contract](cli.md) — stable machine-readable output, exit statuses,
  and safety-sensitive operations.
- [Desktop interface](gui.md) — Tk setup, supported workflows, and limitations.
- [Web interface](web.md) — starting and safely binding the read-only web view.

## Formats and compatibility

- [Compatibility matrix](compatibility.md) — current support claims and their
  evidence level.
- [JSON v1 contract](data-formats/json-v1.md) — the canonical storage schema and
  compatibility policy.
- [Architecture](architecture.md) — module boundaries, error handling, and resource
  limits.
- [Port audit](PORT_AUDIT.md) — evidence-based progress and remaining gaps.

## Contributing and porting

- [Contribution guide](../CONTRIBUTING.md) — development setup, checks, fixtures,
  and change expectations.
- [Implementation plan](IMPLEMENTATION_PLAN.md) — milestones and prioritized work.
- [Critical port sprints](NEXT_SPRINTS.md) — ordered near-term work, exit checks,
  and deferred non-critical features.
- [Upstream archive provenance](upstream/archive-provenance.md) — source snapshot
  origin, digests, and authentication limitations.
- [Upstream source inventory](upstream/source-inventory.md) — Delphi-to-Python source
  mapping.

The checked-in files below `original/` are historical upstream help sources, not
documentation for the Python application.
