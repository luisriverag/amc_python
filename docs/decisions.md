# Architecture decision log

A chronological record of this project's genuinely consequential, hard-to-reverse
choices — the ones a future contributor would otherwise have to reconstruct from
git archaeology or ask about. Each entry is short: context, decision,
consequences, status.

Not every design note belongs here. Routine implementation choices stay in code
comments or `docs/architecture.md`'s prose. An entry earns its place here when it
was genuinely a *choice* — a real alternative existed — it is expensive to
reverse, and a future contributor would plausibly ask "why is it like this?"

Add a new entry when a past decision is revisited; do not edit an old one out
from under it. Mark the old entry **Superseded**, with a forward link.

## Index

| ID | Title | Status |
|---|---|---|
| [0001](#adr-0001-no-compatibility-claim-without-a-registered-upstream-fixture) | No compatibility claim without a registered upstream fixture | Accepted |
| [0002](#adr-0002-catalogservice-as-the-one-shared-application-boundary) | `CatalogService` as the one shared application boundary | Accepted |
| [0003](#adr-0003-structured-catalogerror-only-for-diagnosable-catalog-content-problems) | Structured `CatalogError` only for diagnosable catalog-content problems | Accepted |
| [0004](#adr-0004-atomic-same-directory-temp-file-replace-for-every-writer) | Atomic same-directory temp-file replace for every writer | Accepted |
| [0005](#adr-0005-ifps-script-execution-stays-undecided-a-narrower-omdb-provider-instead) | IFPS script execution stays undecided; a narrower OMDb provider instead | Open |
| [0006](#adr-0006-freereport-and-localization-are-not-the-same-kind-of-no) | FreeReport and localization are not the same kind of "no" | Accepted |
| [0007](#adr-0007-split-tests-by-kind-not-by-source-module) | Split tests by kind, not by source module | Accepted |
| [0008](#adr-0008-adopt-mypy-in-default-mode-not-strict) | Adopt mypy in default mode, not strict | Accepted |
| [0009](#adr-0009-adopt-tkinterweb-for-the-desktop-html-preview-pane) | Adopt `tkinterweb` for the desktop HTML preview pane | Accepted |

## ADR-0001: No compatibility claim without a registered upstream fixture

**Context.** Early work risked describing native/XML/CSV support as "done" once
the Python code matched the read Delphi source, even though nothing had run
against genuine Ant Movie Catalog output. That conflates *source-derived* (traced
to identified upstream units) with *upstream-verified* (checked against real
bytes or a real application run) — two very different confidence levels.

**Decision.** Adopt a three-level confidence vocabulary (Internal /
Source-derived / Upstream-verified — see `docs/PORT_AUDIT.md`'s "Confidence
vocabulary") and enforce it mechanically: `docs/compatibility.md`'s status column
may only read `verified` when a provenance-tracked, redistribution-cleared
upstream-generated fixture (or a documented cross-application run) backs it.
Self-authored synthetic fixtures — however structurally faithful, however many
real bugs they catch — max out at `partial`/`investigating` and are labeled
`synthetic` origin in their manifest, never `upstream-generated`. This is
enforced today by `tools/validate_fixtures.py` and `tools/verify_fixtures.py`,
plus the fixture manifest schema in `tests/fixtures/README.md`.

**Consequences.** No format can quietly graduate to "verified" by volume of
Python-side testing alone — genuine upstream artifacts (or a licensed Windows
install of AMC 4.2.3.2 to generate/reopen them) are a hard external dependency,
tracked as the P0 evidence gate in `docs/IMPLEMENTATION_PLAN.md`. This is
deliberately inconvenient: it is the entire reason `docs/PORT_AUDIT.md` exists
as a document distinct from `docs/compatibility.md`, and it forced day-to-day
work to reprioritize toward evidence-independent downstream features (the D0–D6
backlog) whenever no genuine fixture was available. See
`docs/PORT_AUDIT.md` findings 26, 27, 34, and 35 for cases where a genuine
(uncommitted, locally-used) upstream artifact found real bugs synthetic coverage
had missed, and finding 35 for the synthetic fixture that was registered
afterward as a regression guard *without* changing any status to `verified`.

## ADR-0002: `CatalogService` as the one shared application boundary

**Context.** The CLI and desktop GUI both need failure-atomic add/replace/
remove, merge, media import, loans, undo/redo, backup/restore, and export. Built
twice, this logic would drift — a bug fixed in one adapter would silently persist
in the other, and behavioral parity between CLI and GUI would need its own test
suite to verify rather than following from shared code.

**Decision.** One service class, `amc.application.CatalogService`, owns every
mutating workflow and persists against an isolated copy, publishing to the caller
only after atomic persistence succeeds. The CLI and GUI are adapters over it —
argument parsing and terminal/Tk presentation only, per `docs/architecture.md`'s
"One application core" principle — not separate implementations of catalog
policy. The web interface (`amc.web`) is read-only and does not (yet) need this
boundary for mutation, only for `catalog` access.

**Consequences.** A stale-movie-number `KeyError`, a validation `ValueError`, or
a `CatalogError` subclass raised inside `CatalogService` surfaces identically
(same exit code shape in the CLI, same dialog shape in the GUI) because both
adapters wrap the same boundary in one shared exception tuple rather than
duplicating error-handling policy. Adding a new mutating capability means adding
one `CatalogService` method, not two adapter-specific implementations — this is
why picture batch-set/crop, loan grouping policies, and merge collision policies
all appear in the CLI and GUI simultaneously rather than one adapter lagging the
other.

## ADR-0003: Structured `CatalogError` only for diagnosable catalog-content problems

**Context.** `Movie`, `Catalog`, `CatalogService`, and `loans.py` raise plain
`ValueError`/`TypeError`/`KeyError` far more often than a `CatalogError`
subclass. Whether to collapse this into one exception hierarchy came up as an
open question (`docs/PORT_AUDIT.md` design-debt item 8).

**Decision.** Keep the split, permanently. `CatalogError` subclasses are for
structured, diagnosable *catalog-content* problems — corrupt/wrong-format/
wrong-version files, validation failures in data already on disk, merge/renumber
conflicts — where a stable `.code` and an optional byte `.offset` add real value.
Plain `ValueError`/`TypeError` are for local API argument-contract violations
(bad type, out-of-range value passed directly to a constructor or method call),
matching how the standard library and most Python APIs already signal "you
called me wrong." Plain `KeyError` is for dict-like lookup failures
(`Catalog.get()`, `remove_borrower`), mirroring `dict[missing_key]` rather than
inventing a duplicate signal. Full rationale in
`docs/architecture.md`'s "The `CatalogError` / built-in split is deliberate and
permanent" section.

**Consequences.** The CLI's `main()` and the GUI's `_SERVICE_ERRORS` tuple both
already catch every member of this family in one block and present one generic
failure, so migrating the 60+ built-in-`raise` call sites to dedicated
`CatalogError` subclasses would not change either adapter's behavior — it would
only make direct-API argument validation less idiomatic for a future non-CLI,
non-GUI consumer. Not worth doing.

## ADR-0004: Atomic same-directory temp-file replace for every writer

**Context.** A catalog file is a user's data. A writer interrupted mid-write (by
a crash, a full disk, a killed process) must never leave a truncated or
half-written file in the original path.

**Decision.** Every writer in this codebase — JSON/CSV/XML/HTML saves, catalog
copy, picture export, TSV loan-history export, GUI preferences, script settings,
and the native `.amc` writer — writes to a same-directory temporary file first,
fsyncs its contents, atomically replaces the destination (`os.replace`, which is
atomic on the same filesystem), and then fsyncs the destination *directory
entry* too, not just the file — matching the native writer's own original
behavior once that gap was found and closed across every other writer. Existing
destinations additionally receive a fsynced `.bak` copy before replacement where
relevant.

**Consequences.** Every writer needed an injected-failure test (a denied
parent-directory creation, a denied temp-file creation, a serialization error
mid-write) proving the original destination survives untouched — this is
tracked as its own coverage line in `docs/compatibility.md`'s "Atomic output
replacement" row. It also means every new writer added to this codebase must
follow the same pattern from day one rather than being retrofitted later; there
is no "fast path" writer that skips atomicity.

## ADR-0005: IFPS script execution stays undecided; a narrower OMDb provider instead

**Context.** Ant Movie Catalog's "Get Info"/"Update" scripts run as compiled
Innerfuse Pascal Script (IFPS) bytecode inside the Delphi application, with a
real provider API surface (HTTP, DOM parsing, catalog/movie/picture mutation).
Porting that means building a bytecode compiler and a sandboxed VM — comparable
in scope to a standalone interpreter project — and, unlike every other
un-ported subsystem, it carries genuine security exposure: running arbitrary
third-party script bytecode sourced from the web, not just an effort question.

**Decision.** Do not decide this unilaterally. `docs/PORT_AUDIT.md` finding 31
treats general IFPS execution as **explicitly open**, pending a deliberate
product/security-posture call, not a default "port everything" assumption.
Separately, once asked which legacy scripts actually mattered in practice, the
answer scoped a much smaller need: refreshing existing catalog entries and IMDb
lookups. `amc.omdb` is a small, hand-written, auditable first-party Python
provider for exactly that pair, via the OMDb API instead of any script
execution — see ADR context in `docs/architecture.md`'s "Deliberate prototype
boundaries." It reuses `amc.scripts`' isolated preview-then-apply contract
(`ScriptMergePreview`) rather than inventing a second one, and is wired into
both the CLI (`imdb-lookup`) and the desktop GUI (**Movie / Update from
IMDb...**).

**Consequences.** This status is marked **Open**, not Accepted, deliberately —
it is the one item in the D0–D6 backlog that stays off the "pick the next
bounded item" rotation until a human makes the call. `amc.omdb` closes a real
use case without being read as an implicit "no" (or "yes") on the general
question; do not treat its existence as resolving finding 31.

## ADR-0006: FreeReport and localization are not the same kind of "no"

**Context.** Two upstream subsystems have zero Python code and, on the surface,
look like the same kind of gap: printing/reports (FreeReport) and localization
(`.lng` files via `Common/AntTranslator.pas`). Lumping them together as
"unported, someday" would misrepresent both.

**Decision.** These are different, and each got its own explicit call rather
than sitting as an undifferentiated backlog item:
- **Printing/reports: permanent no.** FreeReport's license (LGPLv2) was never
  the blocker — porting it means reimplementing a complete standalone report
  designer and renderer (its own binary format, a design-time UI, print
  preview), an application-sized project disproportionate to this port.
  `export-html-template`/`html_template.py` already covers "produce a
  formatted report from the catalog" as a non-compatible baseline.
- **Localization: a timing decision, not a permanent one.** Upstream's `.lng`
  mechanism is a runtime Delphi RTTI object-graph patcher tied to live VCL
  component instances with no Tk equivalent, so porting the *format* was never
  viable — but a Python-owned i18n layer (externalize `gui.py`'s strings behind
  a key→string lookup) is possible and simply hasn't been built, because there
  is no actual translated content anywhere in this repository yet to load.
  Revisit when there is.

**Consequences.** `docs/PORT_AUDIT.md` findings 29–30 record both calls
explicitly so neither reads as an oversight. A future contributor proposing
Python-owned localization scaffolding should bring real translated strings with
it, not build the loader speculatively; a future contributor proposing a
FreeReport port should expect that to be declined regardless of effort
available, not just re-litigated for lack of documentation.

## ADR-0007: Split tests by kind, not by source module

**Context.** `tests/` grew to 22 flat `test_*.py` files mirroring `src/amc/`
module names, mixing genuinely different kinds of test (pure-function unit
tests, `CatalogService`-orchestrated integration tests, real-fixture
compatibility tests, CLI end-to-end tests, real-Tk-widget GUI tests, and
repository tool/doc-consistency self-tests) inside single files — most visibly
`test_amc.py`, which interleaved storage round-trip tests and 39
`test_cli_*` end-to-end tests across 1276 lines.

**Decision.** Reorganize into `tests/{unit,integration,compatibility,cli,gui}/`
per Milestone 1's original plan, plus a sixth `tests/tooling/` category (not
one of the five originally named) for the `tools/*.py` self-tests and
repository-consistency checks, which don't fit any of the five cleanly. Move
whole files by dominant concern; split only the one file that genuinely
straddled two categories along its own clean naming boundary
(`test_cli_*` → `tests/cli/test_cli.py`), rather than atomizing every file with
one or two incidental CLI smoke checks mixed in — that fragmentation cost more
than it bought.

**Consequences.** `pytest`'s recursive `testpaths` discovery needed no
configuration change. A new test's location now signals its own kind and
dependency weight (a `unit/` test should never need `CatalogService`; a `gui/`
test may need a real display) without reading its imports first. See
`docs/PORT_AUDIT.md`/`docs/IMPLEMENTATION_PLAN.md`'s P3.1 entry for the exact
per-directory breakdown.

## ADR-0008: Adopt mypy in default mode, not strict

**Context.** `src/amc` already carried a `py.typed` marker (implying "this
package's types are meant to be checked") but nothing had ever run a type
checker against it. The question was not just *whether* to adopt one, but at
what strictness — mypy's `--strict` mode on a ~5,000-line, previously
unchecked, heavily `tkinter`/`dataclass`/dynamic-dict codebase would surface an
order of magnitude more findings than default mode, many of them requiring
either invasive annotation-only churn or broad suppressions just to reach zero.

**Decision.** Adopt mypy in its default, non-strict mode
(`pyproject.toml`'s `[tool.mypy]`), fix every one of the 63 errors it found on
first run with real code changes rather than blanket suppressions, and wire it
into `tools/check.py` (hence both CI matrices) at that strictness. Two narrow,
individually-commented `# type: ignore` lines remain for patterns typeshed's
stubs categorically cannot express correctly (a documented
`configparser.ConfigParser.optionxform` customization, and a
`Movie(**values)` dataclass double-star unpack) — not a broad suppression, and
`warn_unused_ignores = true` keeps both honest.

**Consequences.** Fixing those 63 errors surfaced real, if narrow, bugs
independent of typing per se — see `docs/PORT_AUDIT.md` finding 37 for the
list (reused-variable-name collisions holding unrelated types across one
function, a GUI attribute silently shadowing an inherited `tkinter` method, an
unchecked fixed-length list splat into a dataclass constructor). Going stricter
later (`disallow_untyped_defs`, `no_implicit_optional`, etc.) remains available
as a follow-up once the codebase has lived under default mode for a while;
this decision picks the adoption floor, not a ceiling.

## ADR-0009: Adopt `tkinterweb` for the desktop HTML preview pane

**Context.** Upstream's main window can show the selected movie's own page —
rendered through its "Individual" HTML export template — live in a pane
alongside the movie list. Reproducing that in Tk needs an actual HTML/CSS
renderer: Tk has none built in, and this port had exactly one dependency
before this decision (Pillow, used for picture decoding/cropping across the
CLI, GUI, and web interface). Three approaches were weighed: add a rendering
dependency; degrade to a tag-stripped plain-text preview in a `tk.Text`
widget (no new dependency, but not a real HTML view — no tables, images, or
CSS); or open the rendered page in the OS default browser on demand (no new
dependency, full fidelity, but a separate window rather than an inline pane,
which is what was actually asked for).

**Decision.** Add `tkinterweb` (MIT-licensed, pure Python, wraps the `Tkhtml3`
Tcl/Tk widget via the `tkinterweb-tkhtml` package) as an unconditional
dependency in `pyproject.toml`, the same way Pillow already is, rather than a
new optional extra: this port's GUI has never gated on an extras group before,
and `amc.gui` already hard-imports `tkinter` itself (unavailable in some
minimal Python installs, treated as an environmental gap rather than a
packaging concern) — the same posture now covers `tkinterweb`. Confirmed
`tkinterweb-tkhtml` ships prebuilt wheels for Linux (`manylinux1_x86_64`),
Windows (`win_amd64`), and macOS (`macosx_11_0_arm64`) before adopting it, so
this port's Linux/Windows CI matrix and this project's documented macOS
target are all covered without a source build.

**Consequences.** The GUI gains a fourth main-window layout (`HTML`,
alongside `Table`/`Details`/`Poster`) that renders the selected movie through
a user-chosen Individual template via `amc.html_template.
render_individual_template`, loaded into a `tkinterweb.HtmlFrame` with
`base_url` set to the template's own directory so its relative CSS/image
references resolve the same way they would in a real export. This is this
port's second dependency and its first with a compiled/platform-specific
wheel (previously only pure-Python plus Pillow's own wheels); `tools/
check_package.py`'s isolated sdist/wheel install check now also exercises
that this package installs cleanly across the supported Python/platform
matrix. Fidelity is bounded by `Tkhtml3`'s own HTML/CSS support (a mature but
not evergreen-browser-complete engine) — acceptable here since upstream's own
templates target a similarly modest rendering target, not a modern web app.
