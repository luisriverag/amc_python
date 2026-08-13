# Compatibility fixtures

Each fixture set lives in its own directory with a `manifest.json`. Binary and
exported files must never be committed without a manifest and a redistribution
decision. Run `python tools/validate_fixtures.py --require-manifests` when genuine
fixtures are available; the canonical check validates every manifest currently
present without requiring one so external/private fixture sets remain usable.

A manifest has this shape:

```json
{
  "id": "amc-4.2.3.2-empty",
  "origin": "upstream-generated",
  "format": "AMC native 4.2",
  "producer": "Ant Movie Catalog",
  "producer_version": "4.2.3.2",
  "created_at": "2026-08-12T00:00:00Z",
  "creation_steps": "Launch AMC 4.2.3.2 and save a new empty catalog.",
  "provenance": "Created by ... on ... from installer digest ...",
  "redistribution": "allowed",
  "expected_contents": "Empty catalog with default catalog properties.",
  "files": [
    {"path": "empty.amc", "sha256": "<64 lowercase hexadecimal characters>"},
    {"path": "empty.xml", "sha256": "<64 lowercase hexadecimal characters>"}
  ]
}
```

`origin` is `upstream-generated`, `synthetic`, or `mutated`. Redistribution is
`allowed`, `not-allowed`, or `unknown`; upstream-generated files cannot remain
`unknown`. Paths are relative to the manifest directory and cannot escape it.
For corrupt fixtures, describe the exact mutation in `creation_steps` and use
`origin: mutated`.
