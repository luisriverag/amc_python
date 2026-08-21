# Third-party notices and source-snapshot license review

This repository contains a Python implementation and two historical Delphi source
trees retained as porting evidence. The root [`LICENSE`](LICENSE) covers AMC Python
under GPL-2.0-or-later. It is also the GPL version 2 text shipped with the upstream
Ant Movie Catalog application. Files in the historical trees remain under their
own notices; the root license does not replace those notices.

This inventory is based on the checked-in snapshot. The supplied compressed
archives exactly match the expanded trees as documented in
`docs/upstream/archive-provenance.md`, but that content match is not a final
redistribution clearance.

| Path | Component and credited author | Notice found in snapshot | Review status |
|---|---|---|---|
| `src/original/Movie Catalog/` | Ant Movie Catalog, Antoine Potten and Mickaël Vanneufville | GPL; full GPLv2 text at `dev/license.txt` | Notice present. Archive/tree equality is verified; publisher authentication is incomplete. |
| `src/original/Common/` | Shared Ant application units | Upstream readme says units are GPL or MPL; individual file headers vary | Every retained file is mapped in `docs/upstream/license-inventory.json`; `ComboBoxAutoWidth.pas` remains unresolved because it has only a source-post URL and no license grant. |
| `src/original/FreeReport/` | FreeReport, credited in source primarily to A. Tzyganenko | GNU Library General Public License v2 at `license.txt` | Notice present; modifications and individual bundled units still need review. |
| `src/original/ifps/` | Innerfuse Pascal Script, Carlo Kok / Innerfuse | Custom permissive license with attribution and documentation conditions at `license.txt` | Notice present; required product attribution must be retained. |
| `src/original/rkSmartViewPack/` | rkSmartView, RMKlever | Mozilla Public License 1.1 at `License.txt` | Notice present; file-level modification notices still need review. |
| `src/original/ElTree/` | ElTree Lite, EldoS | Custom freeware EULA at `license.txt` | **Redistribution blocker:** the checked-in text permits distribution only as part of compiled software, not source. Obtain permission or remove this tree before a release. |
| `src/antcomponents/` | Ant components, Antoine Potten, JVCL contributors, and named component authors | MPL 1.1 umbrella notice at `Ant__Licence.txt`, with exceptions | Per-file mapping complete in `docs/upstream/license-inventory.json`; CorelButton's separate notice and the XML units' GPL headers are identified there. |
| `src/antcomponents/AntCorelButton.*` | CorelButton, Peter Theill / ConquerWare | Separate freeware terms at `AntCorelButton.txt` | Notice present; keep the copyright and permission text. |
| `src/antcomponents/xml/` | Akretio/JVCL-derived XML units | File headers state GPL terms | Notice present; confirm exact GPL version and upstream provenance. |
| `tests/fixtures/scripts/` | 14 genuine Ant Movie Catalog "Get Info" scripts, various community authors (Antoine Potten and others; Purfview) — see the file for the full per-file table | Each file's own `[Infos]` `License=` field: 12 GPLv2-or-later/GPLv3-or-later, 2 MIT (`IMDB_ALT.ifs`/`IMDB_ALT_ES.ifs`, Copyright (c) 2025 Purfview); full text and per-file attribution in `tests/fixtures/scripts/PROVENANCE.md` | Notice present per file; this is a curated subset of a larger contributor-supplied snapshot of `update.antp.be/amc/scripts/` — only files with their own explicit, redistribution-permitting license were selected, not the full snapshot (`PROVENANCE.md` records the selection criterion and what was excluded). |

## Build-time components named but not included

The upstream readme also names Toolbar 2000/TBX, SynEdit 2, PNGImage, Indy 10,
HTML Viewer Components, and TRegExpr as build dependencies. They are not present in
the two checked-in source trees and are not Python runtime dependencies. Their
licenses must be reviewed if they are later vendored or distributed in artifacts.

## Release blockers

Before publishing an artifact containing either historical tree:

1. independently authenticate the supplied archives against the publisher (the
   contributor-reported source page, sizes, hashes, and exact tree matches are
   recorded, but no publisher checksum or precise retrieval time is available);
2. resolve the ElTree source-redistribution restriction;
3. resolve the absent license grant for `Common/ComboBoxAutoWidth.pas` and confirm
   whether it may be redistributed; and
4. retain every component notice and all attribution/documentation required by it.

The machine-readable per-file inventory is checked by
`python tools/check_license_inventory.py`. Its `notice` status identifies a source
or umbrella notice, `companion` associates non-source build/resource files with
reviewed source, and `unresolved` is a release blocker. This classification records
the evidence in the snapshot; it is not legal advice or publisher authentication.

The Python wheel and source distribution intentionally exclude `src/original/`,
`src/original_compressed/`, `src/antcomponents/`, and
`src/components_compressed/`. `python tools/check_package.py` builds and inspects the
source distribution and fails if any of those evidence trees appears. This prevents
the known blockers from leaking into Python release artifacts; it does not grant
permission to redistribute the historical trees through another channel.
