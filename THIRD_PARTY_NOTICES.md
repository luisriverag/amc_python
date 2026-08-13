# Third-party notices and source-snapshot license review

This repository contains a Python implementation and two historical Delphi source
trees retained as porting evidence. The root [`LICENSE`](LICENSE) covers AMC Python
under GPL-2.0-or-later. It is also the GPL version 2 text shipped with the upstream
Ant Movie Catalog application. Files in the historical trees remain under their
own notices; the root license does not replace those notices.

This inventory is based only on the checked-in snapshot. Because the archive has
not yet been reacquired and matched, it is not a final redistribution clearance.

| Path | Component and credited author | Notice found in snapshot | Review status |
|---|---|---|---|
| `src/original/Movie Catalog/` | Ant Movie Catalog, Antoine Potten and Mickaël Vanneufville | GPL; full GPLv2 text at `dev/license.txt` | Notice present. Snapshot identity still needs verification. |
| `src/original/Common/` | Shared Ant application units | Upstream readme says units are GPL or MPL; individual file headers vary | **Incomplete:** produce a per-file mapping before redistribution. |
| `src/original/FreeReport/` | FreeReport, credited in source primarily to A. Tzyganenko | GNU Library General Public License v2 at `license.txt` | Notice present; modifications and individual bundled units still need review. |
| `src/original/ifps/` | Innerfuse Pascal Script, Carlo Kok / Innerfuse | Custom permissive license with attribution and documentation conditions at `license.txt` | Notice present; required product attribution must be retained. |
| `src/original/rkSmartViewPack/` | rkSmartView, RMKlever | Mozilla Public License 1.1 at `License.txt` | Notice present; file-level modification notices still need review. |
| `src/original/ElTree/` | ElTree Lite, EldoS | Custom freeware EULA at `license.txt` | **Redistribution blocker:** the checked-in text permits distribution only as part of compiled software, not source. Obtain permission or remove this tree before a release. |
| `src/antcomponents/` | Ant components, Antoine Potten, JVCL contributors, and named component authors | MPL 1.1 umbrella notice at `Ant__Licence.txt`, with exceptions | **Incomplete:** CorelButton has a separate notice; XML units state GPL terms; audit every file before redistribution. |
| `src/antcomponents/AntCorelButton.*` | CorelButton, Peter Theill / ConquerWare | Separate freeware terms at `AntCorelButton.txt` | Notice present; keep the copyright and permission text. |
| `src/antcomponents/xml/` | Akretio/JVCL-derived XML units | File headers state GPL terms | Notice present; confirm exact GPL version and upstream provenance. |

## Build-time components named but not included

The upstream readme also names Toolbar 2000/TBX, SynEdit 2, PNGImage, Indy 10,
HTML Viewer Components, and TRegExpr as build dependencies. They are not present in
the two checked-in source trees and are not Python runtime dependencies. Their
licenses must be reviewed if they are later vendored or distributed in artifacts.

## Release blockers

Before publishing an artifact containing either historical tree:

1. reacquire the official archive and record URL, retrieval time, byte size, and
   SHA-256, then prove which checked-in files came from it;
2. resolve the ElTree source-redistribution restriction;
3. finish per-file review of `Common` and `antcomponents`, including modifications
   and conflicting or exceptional notices; and
4. retain every component notice and all attribution/documentation required by it.
