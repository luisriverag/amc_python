# AMC website-script fixtures

These are genuine Ant Movie Catalog "Get Info" scripts, contributed by a user
for local debugging and used to validate `amc.scripts.inspect_script()`
against real script syntax — the same role the genuine XML export played for
`amc.storage`'s XML codec (see `docs/PORT_AUDIT.md` findings 26/27) and the
two IMDb scripts played for finding 31.

- **Source:** `https://update.antp.be/amc/scripts/`, Ant Movie Catalog's own
  official script-update feed. The contributor supplied a snapshot of this
  feed (314 files: 41 currently-listed scripts/shared units plus a 272-file
  `archive/` of scripts for now-defunct sites), retrieved 2026-08-21.
- **What is committed here:** only the 14 files below, a deliberate subset —
  not the full snapshot. Each carries its own explicit, redistribution-
  permitting license in its `[Infos]` header (`License=`), checked
  individually before inclusion: 12 are GPLv2-or-later or GPLv3-or-later
  (compatible with this repository's own GPLv2 posture), 2 are MIT. The
  remaining ~300 files in the contributor's snapshot are deliberately **not**
  committed: most of the archived scripts (defunct-site scripts, largely
  undated) and about half of the current top-level scripts carry no
  `License=` field at all, and one (`FilmAffinity (ES).ifs`) has a
  non-standard attribution-only license whose terms were judged worth a
  closer, separate read rather than a default "yes." Being reachable from
  the official update feed is not, by itself, treated as a redistribution
  grant here — only an explicit, legible license in the file's own metadata
  is.
- **Files and their own attribution** (author/license text is authoritative
  in each file's `[Infos]` section; summarized here for convenience):

  | File | Authors (per script metadata) | License |
  |---|---|---|
  | `Allocine (FR).ifs` | Antoine Potten, Nazgul64, Raoul_Volfoni, HerveM, MarcelT | GPLv2-or-later |
  | `Amazon (FR).ifs` | ScorEpioN, jmcc, baffab, HerveM | GPLv2-or-later |
  | `Filmweb (PL).ifs` | Dekert, Ariell, athe | GPLv2-or-later |
  | `IMDB (Actor images).ifs` | J (Original); API version by Claude AI | GPLv2-or-later |
  | `IMDB.ifs` | Antoine Potten, KaraGarga, baffab, Thermal Ions, bad4u, Sancho, Joe, cage, Elman, MrObama2022 | GPLv2-or-later |
  | `IMDB_ALT.ifs` | Purfview; contributor Elman | MIT (Copyright (c) 2025 Purfview) |
  | `IMDB_ALT_ES.ifs` | Purfview; contributor Elman | MIT (Copyright (c) 2025 Purfview) |
  | `ItalianMultisite (IT).ifs` | Antoine Potten et al. (IMDb portion); MrObama, Fulvio53s03 et al. (Italian portion) | GPLv2-or-later |
  | `JsonUtils.pas` | (unattributed in header) | GPL |
  | `MyMovies (IT).ifs` | Fulvio53s03, MrObama, seraphico (original by Claudio Rinaldi) | GPLv2-or-later |
  | `OFDb-mobi-IMDb.ifs` | Gerol | GPLv2-or-later |
  | `cp1250.pas` | Dekert | GPLv2-or-later |
  | `csfd.cz.ifs` | Ike Blaster, MadMaxx, Dmitry501, Inteline, Kalten, kecinzer, MI'RA, kubalav | GPLv3-or-later |
  | `en2pl.pas` | Dekert | GPLv2-or-later |

- **Not validated for correctness or execution.** These files are read as
  bounded, non-executing metadata sources only — `amc.scripts` never
  compiles or runs Pascal, and this fixture set does not change that. They
  exist to prove `inspect_script()`/`discover_scripts()` parse real-world
  script syntax (multi-line license blocks, 30+ option entries, embedded
  quotes and non-ASCII text) without crashing or misreading structure.
- **What using them found:** a real, previously unhandled bug —
  `inspect_script()` crashed with an unhandled `UnicodeDecodeError` on any
  script using a single-byte code page other than cp1252 (`Filmweb (PL).ifs`
  is cp1250; several of the contributor's other, uncommitted archive files
  hit the same bug). Fixed to decode tolerantly instead of raising, matching
  every other malformed-input path in this module. See
  `docs/PORT_AUDIT.md` finding 33.
