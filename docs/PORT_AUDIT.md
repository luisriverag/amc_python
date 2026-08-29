# Port progress audit

**Audit date:** 2026-08-14
**Audited commit:** `510d171` plus this documentation review

**Method:** source review, documentation-claim comparison, CLI enumeration, the
complete automated test suite, and inspection of the checked-in Delphi source
snapshot. The supplied archives exactly match all 952 expanded files, but their
origin lacks independent publisher authentication and upstream-generated fixtures
are not available, so no claim of behavioral parity with Ant Movie Catalog can be
verified.
The user has designated the checked-in Delphi files as the authoritative source
baseline for continued implementation; that decision does not independently
authenticate the archives or create genuine compatibility fixtures.

## Executive conclusion

The repository is a functioning **prototype catalog application**, not a verified
drop-in Ant Movie Catalog port. Internal JSON behavior, catalog operations, the
application service, and guarded CLI workflows have useful automated coverage.
Native `.amc` parsing/writing, XML, CSV, metadata, and embedded-picture retention
are implemented from source or synthetic examples but lack genuine upstream
fixtures. Safe subsets also exist for HTML export, media discovery, PCM WAV/
FLAC/AIFF/MP3/MP4/OGG inspection, non-executing script metadata and public
settings, a first-party OMDb-backed IMDb lookup/update provider, desktop/web
presentation, and loans.
IFPS script execution and full upstream desktop workflows are not ported.
Localization and printing/reports are not ported either, and unlike general
script execution, both are now a decided outcome rather than an open gap
(findings 29-30); script execution itself remains genuinely undecided, with
a narrower first-party alternative built for its two highest-value cases
instead (finding 31). Python-owned borrower/history metadata is deliberately
distinguished from upstream
file-format compatibility.

Two progress measures are tracked deliberately:

| Measure | Result | Meaning |
|---|---:|---|
| Prototype implementation | 17 functional package modules, 6 repository tools, 635 passing tests | Python foundation and guarded prototype features exist |
| Source-analysis progress | 952 checked-in upstream/component files; 13 subsystem mappings | Archive/tree identity is established; detailed per-file review is incomplete |
| Upstream port verification | 7 upstream-generated fixtures registered (`tests/fixtures/native-empty-one-movie/`, finding 38; `tests/fixtures/native-sample-catalog/`, finding 39); 0 verified upstream subsystems | Narrow, genuine read-path evidence exists for the first time — empty and blank-one-movie native catalogs across AMC 3.5/4.1/4.2, plus populated movies, all eight represented custom-field types, and embedded pictures across AMC 3.5/4.2; this does not verify native format compatibility as a whole — other versions and a write-then-reopen-in-real-AMC check remain unevidenced |

Line count and test count must not be used as a substitute for upstream
compatibility evidence.

### Confidence vocabulary

- **Internal:** behavior belongs to AMC Python and is tested against its documented
  contract; it makes no upstream claim.
- **Source-derived:** implementation is traced to identified Delphi units and
  symbols, but has no genuine upstream-produced fixture or cross-application run.
- **Upstream-verified:** a provenance-registered upstream artifact or application
  run demonstrates the claimed behavior. No subsystem currently meets this bar.

The tables below apply these meanings narrowly. A row may have high confidence in
an internal safety property while still having low or zero AMC compatibility
confidence.

## Evidence inventory

### Implemented and covered by automated tests

| Area | Implementation | Evidence | Confidence |
|---|---|---|---|
| Movie value object | Common flat fields, dictionary conversion, primitive validation | Direct/JSON validation and round-trip tests | Moderate for internal use |
| Catalog collection | Add/get/remove, search, sort, renumber, merge, statistics | Direct unit-style tests | Moderate for internal use |
| Internal JSON v1 | Load/save, envelope/version checks, atomic replacement | Round-trip, future-version, and failed-serialization tests | High for tested cases |
| CSV prototype | Header aliases, primitive conversion, custom columns, export | Synthetic round-trip test | Low for AMC compatibility |
| XML prototype | Movies, catalog properties, custom-field definitions, export | Synthetic import and metadata round-trip tests | Low for AMC compatibility |
| Inspection | JSON/XML/CSV identification plus native 1.0–4.2 header probe | API and CLI tests | Moderate for synthetic cases |
| Validation | Stable diagnostics, native structural validation, CLI exit status | API and CLI tests, including corrupt native input | Moderate for synthetic cases |
| Source acquisition tool | Streaming download, digest, extraction selection, inventory | Local HTTP and synthetic inventory tests | High for tested behavior |
| Engineering checks | Canonical tests/compile/fixture checks, `mypy` type checking (default mode), plus isolated wheel install | Tool unit tests and installed console-script JSON smoke | High for tested environment |
| HTML prototype | Escaped static table with bounded document/row templates | Injection, marker, failure-preservation, and CLI tests | Moderate internally; no AMC template parity |
| Media prototype | File discovery/facts and PCM WAV/FLAC/AIFF/MP3 duration/bitrate (MP3 via a hand-decoded MPEG frame header, not upstream's MediaInfo.dll); CLI `import-media --progress` reporting and a GUI Import Media dialog (file or recursive-folder selection) with the same atomic-after-inspection guarantee | File, WAV, FLAC, AIFF, MP3 (CBR, ID3v2/ID3v1 tag handling, reserved-header rejection, Layer I/II/III frame-length formulas), bounds, filtering, recursive, progress-output, interrupted-scan, and atomic CLI/GUI tests | Moderate for stated subset |
| Script inventory/settings | Bounded non-executing Infos/options/parameters/permissions/static-name parser; validated option/parameter overrides; atomic Python JSON settings | Synthetic metadata, malformed-entry, configuration, persistence, and CLI tests | Moderate for the stated non-executing subset; no runtime parity |
| Application service | Failure-atomic CRUD, merge, media import, loans, undo/redo, backup/restore, and export orchestration | Mutation-failure, persistence, history, and adapter tests | High for tested internal workflows |
| Loan prototype | Single/batch, media-label, and retained-native-number group transitions; managed borrowers; JSON history; source-shaped TSV export | Unit/service/CLI/GUI tests, including atomic conflicts and output preservation | Moderate internally; upstream encoding/behavior unverified |
| Web prototype | Read-only poster table/gallery, expanded details, bounded posters, pagination, search, and safe links | HTTP, escaping, reload, MIME, bounds, and security-header tests | Moderate for stated Python extension; upstream has no corresponding web server |
| Picture prototype | Linked and byte/pixel-bounded validated embedded set/clear/crop, interactive drag-to-select cropping in the desktop edit dialog and each Assign Pictures row, atomic batch set/clear with per-movie crop rectangles across an extended selection (distinct or shared picture/crop per movie), JSON/native retention, and atomic export | Service/CLI/GUI/native tests, including malformed image, crop/bounds, per-movie crop overrides, batch set/clear atomicity, and failure preservation | Moderate internally; upstream path/conversion semantics unverified |
| GUI preferences | Platform-appropriate per-user JSON file for view filter, layout, window size, and configurable undo/redo history depth (editable from a toolbar Preferences dialog and validated through `CatalogService`), atomically written and validated field-by-field on load with default fallback for any missing/invalid data | Round-trip, corrupt-file, invalid-field, platform-path, and history-depth-bounding tests | High internally; AMC Python-only convenience with no upstream counterpart |

### Present but inadequately tested

| Area | Current state | Missing evidence |
|---|---|---|
| GUI | Tk catalog manager with file workflows, CRUD, filters, details/posters, loans, undo/redo, statistics, and duplicates | Headless controller/dialog tests, plus a real-display smoke run (`tests/gui/test_gui_display.py`, real Tk widget trees under Xvfb, self-skipping without a display) covering the main window and the Preferences/Assign Pictures/Import Media/edit/crop/Loan Out/Loan In/Set Pictures/Clear Pictures dialogs, including an end-to-end simulated drag-select-and-apply crop and a real Loan Out combobox-and-button interaction verified against the real service; no verified accessibility pass |
| Installed CLI | Wheel console script and module entry point smoke-tested; empty JSON list exact output checked | Broader installed command contracts remain missing |
| Packaging | Wheel build, isolated install, license inclusion, and smoke checks | Source-distribution build/install remains missing |
| CI | Workflow configured for Linux/Windows and Python 3.10–3.13 | No run result is stored in the repository |
| Atomic CSV/XML | Shared atomic writer, now with destination directory-entry fsync matching the native writer | Injected codec-failure preservation tests cover both formats; permission errors and concurrent writers remain untested |
| Large-file behavior | XML uses iterative inspection | No resource-limit or performance tests |

### Not ported

- Verified native `.amc` write compatibility (a source-derived 4.2 writer exists).
- Verified native read compatibility for any version.
- Catalog preferences beyond retained catalog/custom-field metadata.
- Lossless preservation of repeated/ordered/typed unknown fields.
- Verified upstream external/embedded picture path and conversion semantics.
- Upstream website script compilation/execution (IFPS bytecode compiler and
  sandboxed VM), the complete provider API, result selection and merge,
  license-acceptance workflow, debugging, and static session state (metadata
  and public settings only). Remains genuinely undecided (finding 31): it
  carries real security exposure, not just an effort question, and no
  general "build it" or "don't" call has been made either way. What is
  decided and built is a narrower, first-party alternative for the two
  cases named as actually mattering most (finding 31): `amc.omdb`'s
  OMDb-API-backed IMDb lookup/update, wired into the CLI as `imdb-lookup`
  and, since finding 36, the desktop GUI's **Movie / Update from IMDb...**
  dialog. This is a new Python-owned feature, not IFPS parity, and carries
  no upstream-compatibility claim.
- Full media analysis and codec mapping (portable facts plus PCM WAV/FLAC/AIFF/
  MP3/MP4/OGG duration and bitrate; video-track resolution, framerate, and a
  real codec/container-vs-codec distinction remain unimplemented, since they
  need per-track sample-table parsing this port does not do).
- Upstream verification of grouped-loan and TSV history encoding/consumption.
- Localization resources (decided, not merely unaddressed — see finding 29:
  the `.lng` format itself has no Tk equivalent to port, and a Python-owned
  i18n layer is deliberately deferred until real translated content exists).
- Printing and reports (decided, not merely unaddressed — see finding 30:
  FreeReport's own report designer/renderer is a standalone-application-sized
  port, permanently out of scope; distinct from HTML export, which does
  render upstream's `$$TAG_NAME` template syntax, see the HTML export row
  below).
- Full desktop workflows and upstream UI parity.

## Findings requiring correction

### Critical blockers

1. **Archive identity is recorded, but publisher authentication is incomplete.**
   The supplied RAR and ZIP have recorded source-page claims, byte sizes, SHA-256
   digests, and exact 876-file and 76-file expanded-tree matches. Their precise
   download time and an independently published checksum are unavailable. See the
   archive provenance record for the reproducible facts and remaining limitation.
2. **Source-snapshot redistribution clearance remains incomplete.** A root
   GPLv2 `LICENSE` and an initial component notice inventory now exist, but the
   review found an ElTree license that does not permit source redistribution and
   unresolved per-file review for `Common` and `antcomponents`. See
   `THIRD_PARTY_NOTICES.md`; these are release blockers, not inferred clearance.
3. **There are no upstream-generated fixtures.** Consequently XML/CSV compatibility
   and all upstream parity claims remain unverified.
4. **Native `.amc` verification is blocked, not implementation.** A source-derived
   1.0–4.2 reader now exists, but it has only synthetic byte fixtures. Encoding,
   compiler-layout assumptions, version behavior, and malformed-file compatibility
   cannot be claimed until upstream-generated catalogs are registered.

### Design and quality debt

1. `storage.py` combines dispatch, three codecs, and atomic filesystem behavior; it
   should be split after genuine fixtures establish codec contracts.
2. The shared application service now owns major CLI/GUI mutations and persistence,
   but storage codecs remain concrete functions rather than repository interfaces;
   some adapter-specific presentation and argument translation is necessarily local.
3. `Movie` now applies primitive type and finite-number validation to direct and JSON
   construction. Semantic constraints for most upstream fields remain unknown.
4. XML custom data is flattened into a dictionary, losing repeated names, ordering,
   attributes, and nested structure.
5. [Partially resolved] CSV dialect, locale, and empty-value behavior is still not
   defined from upstream evidence. Duplicate-header behavior is now defined and
   tested as a Python-owned policy (not an upstream-verified one): `load_csv`
   previously let `csv.DictReader` silently discard a column's data whenever two
   headers collapsed onto the same key (either two identical extras headers, or
   two headers, such as `Title`/`title`, that normalize to the same known movie
   field) — the earlier column's value vanished with no diagnostic. It now raises
   a clear `ValueError` identifying both colliding headers before any row is
   read, mirroring the JSON v1 decoder's duplicate-member rejection policy.
6. [Partially resolved] Inspection still parses complete JSON documents merely to
   count records (Python's standard `json` module has no incremental parser, and
   implementing one was judged not worth the complexity for a counting-only path).
   However, `inspect_catalog`/`validate_catalog` and the CLI `inspect`/`validate`
   `--max-input-bytes` option now reject an oversized file before that parse
   starts, matching the `NativeReadLimits`/`inspect_media` bound precedent used
   elsewhere; the previously-undefined resource bound is now defined and
   configurable (default 1 TiB). True streaming JSON record counting remains
   undone.
7. [Partially resolved] Atomic replacement has injected serialization-failure
   coverage for JSON, CSV, and XML, and a generic injected replacement failure is
   covered. Directory durability was a real gap, not just an untested one: the
   native `.amc` writer already fsynced its destination directory entry after
   `os.replace` (so a crash right after rename cannot lose the rename on a
   durable filesystem), but every other atomic writer in the package — JSON/CSV/
   XML/HTML saves and `copy_catalog` in `storage.py`, picture export in
   `application.py`, TSV loan-history export in `loans.py`, GUI preferences in
   `preferences.py`, and script settings in `scripts.py` — only fsynced the file
   contents and skipped the directory entry. `native.py`'s
   `replace_and_sync_directory` helper (made a shared, non-private name for this)
   is now used by every one of those call sites, each with a regression test
   confirming the directory descriptor is fsynced. Permission-denied behavior is
   now defined and tested too: a parent directory that cannot be created, or an
   existing directory that denies new-file creation, propagates an unwrapped
   `PermissionError`/`OSError` (no wrapping into a `CatalogError`) and leaves any
   existing destination and temp-file state untouched, verified by injected
   tests for every `storage.py` atomic writer, `copy_catalog`, and the native
   `.amc` writer — this environment runs its automated checks as `root`, where
   real filesystem permission bits are not enforced, so these tests inject the
   denial rather than relying on `chmod`. Concurrent writers remain untested.
8. [Resolved] Expected errors are still partly represented by public
   `CatalogError` subclasses and partly by built-in `ValueError`, `TypeError`,
   and `KeyError` raised directly from `catalog.py`, `application.py`, and
   elsewhere; that split itself remains an intentional, undocumented-until-now
   design choice rather than something this pass converted to one hierarchy.
   What was a genuine bug, not just missing documentation: the desktop GUI's
   ~20 `try`/`except` boundaries around `CatalogService` calls were supposed to
   all catch the same failure set, but 15 of them caught
   `(CatalogError, OSError, TypeError, ValueError)` while only 5 also caught
   `KeyError` — `Catalog.get()`'s documented signal for a movie number that no
   longer exists (used by `replace`/`remove`/check-out/check-in/set-checked/
   picture operations). A `KeyError` hitting one of the 15 unprotected
   boundaries — for example a stale table selection racing another mutation —
   would have escaped as an unhandled Tk callback traceback instead of the same
   `messagebox.showerror` dialog every other expected failure gets. All ~20
   boundaries now share one module-level `gui._SERVICE_ERRORS` tuple
   (`CatalogError, OSError, TypeError, ValueError, KeyError`); `cli.main()`'s
   equivalent boundary already covered `KeyError` via `LookupError` and is now
   commented to say so explicitly. The remaining scope of this item — deciding
   whether `KeyError`/`ValueError`/`TypeError` call sites should migrate to
   `CatalogError` subclasses instead of being a permanently mixed model — is
   now decided and documented in `docs/architecture.md`'s "Error model"
   section rather than left open: the split stays, because it already
   follows a coherent rule (`CatalogError` subclasses for diagnosable
   catalog-*content* problems that carry a `.code`/`.offset`; plain
   `ValueError`/`TypeError` for local API argument-contract violations,
   matching ordinary Python convention; plain `KeyError` for dict-like
   lookup failures), and because both the CLI's `main()` and the GUI's
   `_SERVICE_ERRORS` already catch every member of this family in one block
   each, so a mass migration of the 60+ built-in-`raise` sites in
   `catalog.py`/`application.py`/`model.py`/`loans.py` to dedicated
   `CatalogError` subclasses would change no observable CLI or GUI behavior —
   only make direct-API argument validation less idiomatic for a future
   non-CLI, non-GUI consumer.
9. The Python native reader deliberately reports truncated records, unlike upstream
   `ReadData`, which catches a movie-record exception and stops. This intentional
   difference needs fixture-backed documentation and stable diagnostics.
10. Upstream `ReadHeader` is only a fixed-length preview: it returns file size and
    trims at a line break but does not validate a native signature. The Python probe
    correctly uses explicit versioned constants and `LoadFromFile` dispatch, but
    fixture cross-checking remains outstanding.
11. XML catalog properties and custom-field definitions are now retained, but
    unknown nested structures and typed values are still normalized into the
    Python metadata representation and have no upstream-generated fixture coverage.
12. [Partially confirmed] Native strings default to CP-1252, version comparisons are
    textual, and Delphi primitive/layout assumptions are encoded directly. They were
    plausible from the source snapshot but not established across compiler settings
    or real catalogs; a genuine native catalog (finding 34) has since confirmed
    cp1252 as broadly correct for one real, undated catalog — it parsed cleanly with
    plausible field values throughout — while also surfacing a real gap the
    synthetic-only evidence had missed (the round-trip bug finding 34 fixes) and an
    open, unresolved observation (occasional apparent UTF-8-in-cp1252 mojibake in
    free-text fields, not automatically repaired). Not established across compiler
    settings, still, and only one real catalog's worth of evidence.
13. Native reads bound file size, movies, individual/cumulative pictures, cumulative
    strings, custom fields/list values, and supplementary records. Exhaustive
    synthetic fixed-record truncations and a seeded 4.2 byte-mutation corpus now
    require bounded public outcomes. Base64 amplification, a property framework,
    and genuine-fixture mutation coverage remain outstanding.
14. Native writes now bound output bytes, cumulative encoded-string bytes, movies,
    individual/cumulative pictures, custom fields/list values, and supplementary
    records before destination replacement. Genuine upstream acceptance remains
    untested.
15. Native-only fields and supplementary records use reserved dictionary keys rather
    than typed format-neutral models, making collisions and merge semantics unclear.
16. `Catalog.metadata` is JSON-validated, deep-copied, and merged atomically with
    `error`, `keep`, `replace`, and `namespace` policies. Nested semantic merging is
    intentionally not performed; genuine interchange verification remains absent.
17. Loan history timestamps are Python-owned timezone-aware ISO-8601 values. The
    optional legacy export converts them to local time and UTF-8 TSV, while upstream
    writes Delphi local time through the process code page; genuine comparison is
    still required.
18. Managed borrower removal intentionally rejects names with active loans, unlike
    upstream `loan.pas`, which clears every matching `strBorrower`. This safer
    divergence is documented but not an upstream-parity behavior.
19. `storage.py` combines JSON, CSV, XML, native dispatch, metadata translation,
    and atomic writes. Codec separation is urgent once genuine fixtures lock contracts.
20. [Resolved] Fixed-record (1.0–3.0) native movie construction now wraps
    `Movie` value errors as `CorruptCatalogError` the same way the modern
    (3.1–4.2) reader already did, so a structural parse failure returns a
    `validate_catalog` diagnostic instead of escaping as an unwrapped
    exception and becoming a generic CLI usage error. Verified with tests
    that force the failure on both readers and confirm the diagnostic
    reaches `validate_catalog`; no currently constructible fixed-record byte
    sequence was found to trigger it under the present `Movie` validation
    rules, so this closes the defensive gap rather than a demonstrated
    exploit.
21. Pre-3.0 picture and borrower sidecars are implemented from
    `TMovieList.ReadPictures`/`ReadBorrowers`, but `ConfigParser` has not been shown
    equivalent to Delphi `TMemIniFile` for duplicate keys, comments, malformed INI,
    or locale-specific decoding. No genuine sidecar fixture exists.
22. [Resolved] JSON content saved under an `.amc` suffix is accepted for
    compatibility with earlier AMC Python releases. This is an internal
    migration behavior, not an Ant Movie Catalog format feature.
    `storage.load()`'s native/JSON content probe now reads the file prefix
    once and reuses it for both the native-header and JSON-start-byte
    checks, instead of opening the file twice. Fixing this also surfaced and
    closed a related bug: a leading UTF-8 BOM was recognized by the JSON
    probe but not stripped before the actual `json.load()` call, so a
    BOM-prefixed JSON catalog (under `.amc` or `.json`) failed to open with a
    confusing `JSONDecodeError` instead of loading; both `storage.load()` and
    `inspection._inspect_json()` now open JSON with `utf-8-sig`, which
    transparently strips a BOM when present and is otherwise identical to
    plain `utf-8`.
23. Script settings use an AMC Python JSON document and basename identity. Upstream
    caches script metadata, license acceptance, options, parameters, and static
    values in its settings INI. Python deliberately excludes license acceptance and
    static values and therefore cannot consume or reproduce that cache.
24. The script reader bounds the first read to 1 MiB, but currently rejects any
    script whose file prefix exceeds that size even when its metadata comment ends
    earlier. It does not compile Pascal, implement IFPS APIs, perform HTTP requests,
    or perform HTTP requests; it can validate isolated field-level merge previews.
25. The read-only web server, its poster table, and retained-file-path display are
    Python extensions. They must not be counted as upstream UI parity. AMC 4.2 file
    path, writer, composer, certification, user-rating, and color-tag values are now
    typed movie fields;
    genuine XML/native fixture comparison remains pending.
26. [Resolved] Two XML field-name bugs, found and fixed against a genuine AMC 4.2.2
    export (a large real catalog, contributed by a user for local debugging, not
    committed to the repository — the first time genuine upstream-generated data has
    been used to validate this port). `Movie Catalog/fields.pas`'s `strTagFields` table
    is the authoritative XML attribute name for every field; grepping the entire
    checked-in Delphi source tree confirmed `"MediaCount"` and `"FileSize"` — the names
    `storage._XML_FIELDS` previously used — appear nowhere in it. The real names are
    `"Disks"` and `"Size"` (present on every movie in the real export; `MediaCount`
    and `FileSize` on none), which this port had apparently invented rather than
    derived from source. Every real AMC XML catalog was therefore silently routing its
    disk-count and file-size data into `extras` instead of the typed `media_count`/
    `file_size` fields. Fixing the name mapping alone would have introduced a second,
    real bug: `Size` is free-form text in upstream (`strSize: string`, not an integer),
    and a multi-part release is exported as `+`-joined sizes (a genuine `"698+696"`
    observed in the same file, affecting a handful of the movies); the existing lenient
    `_number()` regex would have silently kept only the first part. `load_xml` now
    parses `file_size` strictly and retains the original text in
    `extras["xml_file_size_text"]` when it isn't a plain integer, and `save_xml` writes
    that original text straight back to the `Size` attribute rather than losing it
    through the generic extras-child-element fallback. A third, unrelated issue
    surfaced from the same file: it contained a raw multi-byte UTF-8 emoji inside a
    document declared as single-byte `windows-1252` (real corruption in the source
    data, not something this reader produces), which strict XML parsing correctly
    rejected; `load_xml` now retries once with a tolerant decode of the declared
    encoding (`errors="replace"`) before giving up, so a few corrupted characters
    don't fail an otherwise-valid large catalog. The full file round-tripped
    through `load_xml`/`save_xml` with zero field mismatches after these three fixes.
    This is not upgraded to `verified` in `compatibility.md`: no provenance-tracked
    fixture is registered in the repository for this file.
27. `amc.html_template` (new) renders Ant Movie Catalog's own `$$TAG_NAME` HTML
    export template syntax — `export.pas`'s `ReplaceTagsGeneral`/`ReplaceTagsMovie`
    placeholders — against `Movie`/`Catalog`, so a template a user already has for
    real AMC's HTML export keeps working. `Movie Catalog/fields.pas`'s `strTagFields`
    table is the source of the general/item tag names; general, item, rating
    (including the exact `0..29/30..49/50..69/70..89/90..100` appreciation-bucket
    ranges, not an approximation of them), picture, and custom-field tags are
    implemented, plus the `$$ITEM_BEGIN`/`$$ITEM_END` repeat loop for both the
    "full" (all-movies) and "individual" (one page per movie) documents upstream
    supports. Validated locally against the same genuine AMC 4.2.2 export as finding
    26 and that export's own real full/individual templates: both rendered with zero
    leftover `$$` placeholders across the whole catalog. Explicitly out of scope, and
    documented as such in the module docstring: `$$ITEM_FORMATTEDTITLE`'s
    user-configured display-preference variants (uses `Movie.title` — the same value
    upstream itself calls "FormattedTitle" — instead), `$$ITEM_COLORHTML`'s
    user-configured palette, actually copying picture/rating-icon files, and the
    `$$ITEM_EXTRA_*` supplementary-record loop (its category/checked/range filter
    syntax is a separate, non-trivial parser; any such block is stripped from the
    output rather than left as broken template syntax, matching upstream's own
    behavior for a movie with no supplementary records). Wired into the CLI as
    `export-html-template`, distinct from AMC Python's own `{{MOVIES}}`-template
    `export-html`, and into the desktop **Export** action (choosing an `.html`
    destination now asks whether to use an Ant Movie Catalog template instead of
    the default table export). Not registered as `verified`, for the same reason
    as finding 26.
28. `amc.media` now covers MP4/M4A/MOV and OGG Vorbis duration/bitrate, closing
    the last gap this port's own compressed-codec evaluation (D0 in
    `IMPLEMENTATION_PLAN.md`) had left open behind a deferred codec-provider
    interface — that evaluation turned out to be premature for duration/bitrate
    specifically: MP4's ISOBMFF box tree and Ogg's page-granule-position scheme
    are both bounded and fully public, the same properties that made WAV,
    FLAC, and AIFF tractable without a real decoder, once MP3's first-frame
    scan proved a compressed format didn't strictly need one either.
    `_inspect_mp4_movie_header` walks top-level boxes (skipping each one's
    payload via `seek`, since `mdat` — the actual media data — can be
    arbitrarily large) to the mandatory `moov/mvhd` box for a movie-level
    timescale and duration; there is no per-codec bitrate at this level, so
    bitrate is only a whole-file average, the same trade-off already made for
    AIFF-C's non-PCM branch and MP3's VBR files. `.mp4`/`.m4v`/`.mov` populate
    `Movie`'s previously-unused `video_format`/`video_bitrate` fields rather
    than `audio_format`/`audio_bitrate` — these are typically video files in a
    movie catalog, and the two field pairs already existed distinctly for
    exactly this reason; `.m4a` uses the audio fields, since it is an MP4
    container restricted to audio. `_inspect_ogg_vorbis` reads the mandatory
    Vorbis identification packet from an Ogg file's first page for sample rate
    and a nominal bitrate, then searches backward from the end of the file
    (Ogg pages carry no leading index of where the stream ends) for the last
    page's granule position (total PCM samples) to compute duration, falling
    back to a whole-file average bitrate when the nominal bitrate field is
    absent (0), matching real Vorbis encoders under quality-mode VBR.
    Deliberately out of scope, the same way MP3 never attempted VBR-exact
    duration without a parsed Xing/VBRI header: Ogg files multiplexing more
    than one logical bitstream (e.g. Theora video alongside Vorbis audio) and
    Opus streams (`OpusHead` instead of `\x01vorbis`) are rejected with a
    clear error rather than guessed at; video-track resolution, framerate,
    and a real codec name remain unimplemented for MP4, the same sample-table
    reason bitrate is only an average. No upstream-generated MP4/OGG fixture
    exists in this repository (unlike finding 26/27's genuine AMC 4.2.2
    export), so this is not an upstream-compatibility claim at all — MP4 and
    OGG are Python-owned, format-spec-derived parsing exactly like WAV/FLAC/
    AIFF/MP3 already were (`Common/MediaInfo.pas` shows upstream delegates all
    of this to a third-party DLL, so there is no Delphi-native mechanism to
    compare against in the first place).
29. Localization is decided as a deliberately deferred, not merely
    unaddressed, gap. Reading `Common/AntTranslator.pas` — the actual `.lng`
    loader, since no `.lng` file itself is present in the checked-in source
    snapshot to treat as a fixture — shows the mechanism is a runtime Delphi
    RTTI object-graph patcher: each line is a dotted VCL property path (e.g.
    `Button1.Caption=Fermer`, including indexed collection/list/tree items)
    resolved and assigned live via `GetPropInfo`/`SetStrProp` against actual
    form/frame/component instances. That mechanism is structurally tied to
    VCL forms and has no Tk equivalent to receive it, so "parity" with the
    `.lng` format is not a coherent target for this port's Tk GUI regardless
    of effort spent — it was never a bounded slice waiting to be picked up.
    A localized Python GUI is separately possible as a wholly Python-owned
    feature (externalize `gui.py`'s hardcoded English strings behind a
    key→string lookup, add a loader), but there is no actual translated
    content available anywhere in this repository to load even if that
    scaffolding existed. Decided: don't build it now. An i18n layer with no
    translations behind it is untestable beyond "does English fall back to
    English" — speculative infrastructure for a hypothetical need, not a
    slice with a real test to write, the same standard every other item in
    this document is held to. This is a timing decision, not a permanent
    one: revisit once a contributor supplies real translated strings, at
    which point the externalization refactor becomes a bounded, testable
    slice like any other.
30. Printing/reports is decided as permanently out of scope, not pending a
    license review that already concluded. `src/original/FreeReport/
    license.txt` is LGPLv2, redistributable under this repository's existing
    GPLv2 posture — there is no remaining license question, contrary to this
    document's own earlier "decide port/omission after ... license review"
    framing. What remains, and is what this finding actually decides, is
    that FreeReport is a complete Delphi report designer and renderer (its
    own binary report definition format, a design-time UI, print preview,
    and a large source tree under `src/original/FreeReport/SOURCE/`):
    porting it is a standalone-application-sized effort, not a bounded
    slice, disproportionate to the rest of this port's scope and to the
    value it would add on top of what already exists. Decided: don't port
    FreeReport. `export-html-template`/`amc.html_template` (finding 27)
    already renders real AMC HTML export templates against the catalog,
    covering "produce a formatted report from the catalog" as a
    non-compatible baseline. A specifically PDF/print-friendly export beyond
    HTML remains a separate, smaller, and genuinely open possible future
    item if actually requested — this finding closes the FreeReport-port
    question specifically, not every conceivable printing-adjacent feature.
31. Website script execution: the general IFPS bytecode compiler and
    sandboxed VM findings 29-30's sibling decision left open (real security
    exposure from running arbitrary third-party script bytecode sourced
    from the web, not just an effort question) is still not being built.
    Instead, asked which of the legacy scripts mattered most, the answer
    scoped the actual need down to two cases: refreshing metadata on movies
    already in the catalog ("update scripts") and IMDb lookups specifically.
    Neither needs a Pascal interpreter. `amc.omdb` (new module) is a small,
    hand-written, auditable Python provider for exactly that pair, via the
    OMDb API (https://www.omdbapi.com/) — a REST API that legally re-serves
    a curated subset of IMDb's own data as JSON under its own terms.
    Scraping imdb.com directly was considered and rejected: it is against
    IMDb's Terms of Service and fragile to markup changes. `fetch_omdb_record`
    looks a movie up by IMDb ID or title/year with an explicit, caller-
    supplied API key (never hardcoded, never persisted — obtained separately
    at https://www.omdbapi.com/apikey.aspx) and a bounded timeout;
    `movie_fields_from_omdb` maps its response onto `Movie` fields, excluding
    `Poster` (image download is a separate, unimplemented capability) and
    fields with no `Movie` equivalent (`Ratings`, `Metascore`, `BoxOffice`,
    `Awards`, `Production`, `Website`, `DVD`); `preview_omdb_update` builds an
    isolated, unmutated candidate and field-level diff, reusing
    `amc.scripts`' `ScriptFieldChange`/`ScriptMergePreview` shape rather than
    inventing a second one for the same "isolated candidate, apply only if
    accepted" idea a legacy-script result already gets. Wired into the CLI
    as `imdb-lookup NUMBER [--api-key KEY] [--imdb-id ID] [--apply]`
    (dry-run preview by default; `--apply` writes through the existing
    `CatalogService.replace`, no new service primitive needed since a
    preview's candidate movie is already a complete, valid `Movie`); not yet
    wired into the desktop GUI, left for a follow-up increment. This closes
    the "update scripts and IMDb" slice of website script execution as a
    real, tested capability while leaving general script execution exactly
    as undecided as finding 29-30 found it — this is a new, narrower,
    first-party feature, not IFPS parity, and makes no upstream-compatibility
    claim (`amc.scripts` continues to read only metadata comments and never
    executes a `.ips` script body).
32. [Resolved] `Movie.length` was being set in the wrong unit by every
    `amc.media`-derived import (`movie_from_media`, so CLI `import-media`
    and the GUI's **Import Media** workflow), found while mapping OMDb's
    `Runtime` field (finding 31) onto the same field and checking what unit
    it was actually supposed to be in. Upstream's own documentation is
    explicit that `Length` is minutes (`Movie Catalog/help/options_en.html`:
    "Read the length of the file (in minutes) and put it in the 'Length'
    field"), and every other place this port already treats it as minutes —
    the GUI statistics dialog's "Total length (minutes)" label,
    `$$ITEM_LENGTH` in `amc.html_template` — agrees. `movie_from_media` was
    the one outlier, passing `MediaInfo.length_seconds` (correctly named and
    correctly seconds, the natural unit for one media file's exact duration)
    straight into `Movie.length` unconverted: a 90-second clip produced
    `length=90`, read everywhere else in the application as 90 *minutes*.
    Every WAV/FLAC/AIFF/MP3/MP4/OGG import was affected since D0's first
    media-analysis format. Fixed by converting seconds to minutes (rounded)
    at exactly this one boundary, with a regression test asserting the
    conversion and a second confirming an unknown duration still leaves
    `length` unset rather than becoming `0`.
33. [Resolved] `inspect_script()` crashed with an unhandled
    `UnicodeDecodeError` on any real script using a single-byte code page
    other than cp1252, found by running it against 314 genuine Ant Movie
    Catalog scripts a user contributed for local debugging — a snapshot of
    `update.antp.be/amc/scripts/`, the official script-update feed (not
    committed to the repository in full; see below for what is). The
    fallback chain was `utf-8-sig` then `cp1252`; cp1252 leaves five byte
    positions undefined (0x81/0x8D/0x8F/0x90/0x9D), and a real script in
    another single-byte code page — a genuine Polish script, `cp1250` —
    legitimately uses them, so Python's `cp1252` codec raised instead of
    decoding. 37 of the 314 real files (about 12%) hit this and crashed
    outright, rather than degrading gracefully the way every other
    malformed-input path in `amc.scripts` already does. Fixed by decoding
    the `cp1252` fallback with `errors="replace"` instead of letting it
    raise: the exact source code page is genuinely unknown here (the same
    open question already recorded for native `.amc` string decoding), and
    the structural `[Infos]`/`[Options]`/`[Parameters]` syntax this function
    actually parses is plain ASCII regardless of code page, so a handful of
    mis-decoded characters in a title or description no longer costs the
    whole file. Verified: re-running the same 314-file snapshot afterward
    produced zero exceptions (277 real script headers parsed, 37
    correctly identified as `legacy_format` with no header at all).
    Fourteen of these files — the ones carrying their own explicit,
    redistribution-permitting license (12 GPLv2-or-later/GPLv3-or-later,
    2 MIT) — are now committed as real fixtures at
    `tests/fixtures/scripts/` (see its `PROVENANCE.md` for the full
    per-file author/license table and the selection criterion). The
    remaining ~300 files in the contributor's snapshot — most of a 272-file
    archive of scripts for now-defunct sites, plus about half of the
    current top-level scripts, neither carrying an explicit license, and
    one file with non-standard attribution-only terms — are deliberately
    not committed; reachability from the official update feed was not, on
    its own, treated as a redistribution grant.
34. [Resolved] The native `.amc` reader and writer could not round-trip a
    real AMC 4.2 catalog, found and fixed against a genuine native export a
    user contributed for local debugging (not committed to the repository —
    the first genuine native-format data this port has had access to,
    parallel to findings 26/27's genuine XML export). The catalog loaded
    cleanly (no corruption diagnostics beyond the standard unverified-
    structure warning) and produced plausible, correctly-typed field values
    throughout, which is itself real evidence for a format that previously
    had zero fixtures of any kind. Writing the loaded catalog back out and
    reloading it, to check for a lossless round trip the way `load_xml`/
    `save_xml` were checked against finding 26's export, surfaced a real,
    concrete bug: `_read_native_string` already losslessly preserves
    Windows-1252's five undefined byte positions (0x81/0x8D/0x8F/0x90/0x9D)
    by decoding each to the identically-numbered Unicode code point rather
    than raising or dropping it — a real movie's string field genuinely
    contained one of these bytes — but `write_native_catalog`'s string
    encoder had no inverse: encoding that exact character straight back
    with plain `str.encode("cp1252")` failed outright, since cp1252 itself
    has no mapping for it. Fixed by adding `_encode_native_string`, the
    missing inverse of the existing `_decode_native_string`, used by
    `_write_string`. Re-running the full write-then-reload round trip
    against the same real catalog afterward matched every field on every
    movie exactly. Separately, and left as an open, evidence-backed
    observation rather than an automatic fix: a small number of free-text
    fields (comments copied from elsewhere, by their content) show the same
    shape as UTF-8 bytes decoded as cp1252 — mojibake, not a crash or data
    loss — confirming design-debt item 12's "not established across
    compiler settings or real catalogs" note with genuine evidence rather
    than resolving it: a reliable, general "detect and repair
    accidentally-double-encoded text" heuristic risks misfiring on
    legitimately cp1252 text and was judged not safe to build from one
    real catalog's evidence alone.
35. Registered `tests/fixtures/edge-cases/` (`manifest.json`, `origin:
    synthetic`): a hand-authored, two-movie native `.amc` + XML pair
    containing zero bytes derived from any real catalog, engineered from
    finding 34's real-catalog observations to exercise, in one committed
    fixture: the native format having no stored title field at all (only
    `original_title`/`translated_title` — a movie's native-read `title` is
    therefore always empty, which is expected behavior rather than a bug);
    the undefined-CP-1252-byte (0x90) preservation path in both the native
    reader and writer; minutes-denominated `Movie.length`; and
    `extras["xml_file_size_text"]`'s multi-part `Size` text. Per this
    document's own confidence vocabulary, a self-authored fixture — however
    structurally faithful — is `synthetic` origin, not `upstream-generated`,
    and registering it does not move any format's status to "verified";
    that still requires provenance-tracked upstream bytes. Covered by
    `tests/compatibility/test_storage.py::test_edge_case_fixture_native_and_xml_agree_on_synthetic_movies`
    and `tools/verify_fixtures.py`.
36. Wired `amc.omdb` into the desktop GUI as a **Movie / Update from
    IMDb...** dialog, closing the gap the "Website scripts" row and finding
    31 had left open ("wire the OMDb provider into the desktop GUI"). It
    reuses `preview_omdb_update`'s exact isolated-preview contract the CLI's
    `imdb-lookup` command already uses: fetching only builds and displays a
    field-change preview in the dialog, and nothing is written to the
    catalog until the user reviews it and clicks Apply, gated on the same
    selected-exactly-one-and-writable rule as Edit. The API key field
    defaults to the `OMDB_API_KEY` environment variable (matching the CLI's
    own default) and is neither persisted to `amc.preferences` nor written
    anywhere else — this repository still has no plaintext-secret-storage
    story, and this dialog does not start one. Verified with a real Tk
    widget tree under Xvfb: a patched OMDb response driving a real
    fetch-preview-apply round trip
    (`test_update_from_imdb_dialog_previews_then_applies_a_real_change`),
    and a patched network failure confirming the dialog reports the error
    and stays open with Apply disabled rather than closing or applying a
    partial change
    (`test_update_from_imdb_dialog_reports_a_lookup_failure_without_closing`),
    both in `tests/gui/test_gui_display.py`.
37. Added `mypy` (default, non-strict mode) to the canonical local check
    command and both CI matrices, closing part of Milestone 1's "formatting,
    linting, static typing, and coverage" item and P3.2 of the upstream
    backlog — `src/amc` already carried a `py.typed` marker, but nothing had
    run a type checker against it. Fixing the resulting 63 errors across 7
    files surfaced four categories: (1) genuine, if harmless, bugs — two
    reused-loop/local-variable-name collisions (`cli.py`'s `defaults`/`value`,
    `native.py`'s `movie`/`value`) that happened to hold unrelated types
    across the same function, invisible at runtime only because Python has no
    per-block scoping, and a `CatalogWindow.location` GUI attribute silently
    shadowing `tkinter`'s own inherited `Grid.location` (`grid_location`)
    method; (2) a real gap in `_read_movie_extras`'s construction of
    `NativeExtra` records, which spread a `list[str]` of exactly 7 elements
    into the constructor relying only on the loop always producing that exact
    length — now built from explicit named locals instead; (3) type
    annotations that were simply narrower than reality (several `dict`
    invariance cases, an untyped `_number` helper, an `object`-typed
    `catalog.metadata` retrieval in `amc.loans` now validated the same way
    `borrowers()` already did); and (4) legitimate dynamic patterns typeshed's
    stubs cannot express precisely — a `_BinaryReader`/`_BinaryWriter`
    `Protocol` pair now documents the actual minimal interface
    `native.py`'s bounded stream wrappers need instead of the overly broad
    `BinaryIO`, and two narrow `# type: ignore` comments remain for
    `configparser.ConfigParser.optionxform` reassignment (a documented
    `ConfigParser` customization mechanism mypy's stub categorically
    disallows) and a `Movie(**values)` dataclass double-star unpack (a known
    mypy limitation, not a real type mismatch). Fixing all of this changed no
    observed behavior; the full suite (563 tests) passes unchanged before and
    after, verified since this sandbox's Python lacks `tkinter` via the same
    throwaway tkinter-enabled-Python-3.12 venv used for finding 36.
38. Fixed a real reader/writer bug in five native fields — `year`, `length`,
    `video_bitrate`, `audio_bitrate`, and `media_count` (upstream's `Disks`)
    — found from genuine empty and one-movie AMC 3.5/4.1/4.2 catalogs a user
    generated and contributed for exactly this purpose, then registered as
    this port's first `upstream-generated` fixtures with explicit
    redistribution permission: `tests/fixtures/native-empty-one-movie/`
    (three empty catalogs, versions 3.5/4.1/4.2, and two one-movie catalogs,
    versions 4.1/4.2). The one-movie fixtures' single, never-edited movie
    read back with `year=-1`, `length=-1`, `media_count=-1`,
    `video_bitrate=-1`, and `audio_bitrate=-1` instead of `None`. Root cause:
    `_read_movie` mapped these five fields with `value or None`, which only
    substitutes `None` for the falsy value `0` — not upstream's actual "no
    value" sentinel, confirmed by the checked-in Delphi source's own
    `TMovie.Reset` (`Movie Catalog/movieclass.pas`: `iYear := -1`,
    `iLength := -1`, `iVideoBitrate := -1`, `iAudioBitrate := -1`,
    `iDisks := -1`) and matching `rating`/`user_rating`'s adjacent handling
    in the same function, which already used the correct
    `None if value < 0 else value` pattern. The native writer had the exact
    inverse bug — `movie.year or 0` (etc.) wrote the plain integer `0` for
    an unset field, not upstream's own `-1`, which would not present the
    same "no value" state if the Python-written file were reopened in
    genuine AMC. Both sides now match `rating`'s existing convention.
    Verified against all five genuine files: identical movies
    (`Movie.to_dict()` equality) after a full native write-then-reread round
    trip through this port's own reader/writer, for both the corrected
    empty-catalog case (0 movies, versions 3.5/4.1/4.2) and the corrected
    one-movie case (versions 4.1/4.2). Covered by both a synthetic
    byte-level regression test
    (`test_read_amc_42_movie_preserves_undefined_year_length_and_bitrates`,
    `test_write_amc_42_movie_encodes_unset_year_length_and_bitrates_as_negative_one`)
    and, now that the genuine files are committed, direct tests against them
    (`test_reads_a_genuine_empty_native_catalog`,
    `test_reads_a_genuine_one_movie_native_catalog_with_every_optional_field_unset`,
    `test_genuine_native_fixture_round_trips_through_this_ports_writer`),
    all in `tests/compatibility/test_native.py`; the manifest's
    `verification` block independently checks the same facts via
    `tools/verify_fixtures.py`. This is the first native-format bug this
    port has found and fixed from genuine files spanning three different AMC
    versions in one pass, rather than from one contributor's single
    populated catalog (findings 26/27/34), and the first time this port has
    had permission to commit any genuine native fixture at all. It still
    does not move native format's overall status to `verified` (see the
    confidence vocabulary above): these five files cover only the
    empty-catalog and blank-one-movie shape, not populated movies, custom
    fields, pictures, other versions, or a write-then-reopen-in-real-AMC
    check.
39. Fixed a real, total-parse-failure bug in AMC 4.x custom-field
    definitions: any catalog with a `List`-type custom field crashed
    `read_native_catalog` outright with a `CorruptCatalogError: invalid
    native string length: <garbage>` (not a graceful degradation — the
    entire catalog failed to load). Found from the official demo catalog
    that ships with Ant Movie Catalog itself (`Sample_4.2.0.amc`, a user's
    own AMC install, contributed for local debugging; a redistribution
    decision on it is separate from and pending after this fix, given its
    embedded movie-poster images). Root cause: `_read_custom_field`
    compared the parsed `field_type` string against the bare literal
    `"list"`, but upstream's own serializer writes the literal Pascal enum
    identifier — confirmed directly in the checked-in Delphi source,
    `ConvertFieldTypeToString` in `Movie Catalog/movieclass.pas`, which
    returns `'ftList'` (and `'ftBoolean'`, `'ftDate'`, `'ftInteger'`,
    `'ftReal'`/`'ftReal1'`/`'ftReal2'`, `'ftString'`, `'ftText'`, `'ftUrl'`,
    `'ftVirtual'` for the other ten field types) — not `'List'`. Because the
    comparison never matched, the reader silently skipped the list-value
    section entirely instead of reading it, corrupting every subsequent
    byte offset for the rest of the properties stream and eventually
    crashing on a garbage string length. The native writer's mirror-image
    `_write_custom_field` had the identical bug (`== "list"` instead of
    `== "ftlist"`), so a Python-constructed list-type custom field
    silently wrote no list values at all rather than raising. Both fixed to
    compare against `"ftlist"` (casefolded). This also exposed that the
    *existing* synthetic test coverage for list-type custom fields
    (`test_read_amc_42_custom_field_definition`,
    `test_custom_field_parser_applies_definition_and_list_limits`,
    `test_write_native_42_round_trip_retained_data`,
    `test_native_writer_limits_custom_fields_and_list_values`,
    `test_native_writer_rejects_malformed_metadata_atomically`) had
    synthesized the same wrong bare `"List"` string throughout — a
    self-consistent but incorrect assumption that passed cleanly against
    the buggy code and would not have been caught without a genuine
    upstream-produced catalog to check against. All five tests corrected to
    `"ftList"`, so they now exercise the real behavior. Verified: after the
    fix, `Sample_4.2.0.amc` parses cleanly (7 movies, 8 custom fields
    spanning 8 of upstream's 11 field types including a working `ftList`
    field with real list values) and round-trips losslessly through this
    port's writer via `amc.storage.load`/`write_native_catalog` (movie-field
    equality, including every custom field value, every embedded picture —
    verified as valid JPEG/PNG bytes via Pillow — and every supplementary
    record). A genuine AMC 3.5.1 sample of the same demo catalog
    (`Sample_3.5.1.amc`, 7 movies, no custom fields defined in that older
    export) also round-trips losslessly and was unaffected by this
    specific bug (3.5 predates the custom-fields feature). Both sample
    files are now committed at `tests/fixtures/native-sample-catalog/`
    (redistribution permission granted separately from the bug fix, given
    their embedded movie-poster images — see that directory's
    `manifest.json`), with genuine-fixture regression tests in
    `tests/compatibility/test_native.py` covering the populated-movie read,
    all eight custom-field types and their values, embedded-picture
    decoding for every movie, and the full read/write/reread round trip for
    both files. This is this port's first genuine, redistribution-cleared
    native fixture evidence for populated movies, custom fields, and
    embedded pictures — it still does not move native format's overall
    status to `verified`, since a documented cross-application test (write,
    then reopen in genuine AMC) remains outstanding.

## Gap matrix against the original application

This matrix distinguishes a source-located feature from a completed port. “Subset”
means Python implements useful behavior but not the complete upstream workflow.

| Original subsystem | Upstream source | Python coverage | Remaining gap |
|---|---|---|---|
| Native catalog persistence | `movieclass.pas`, `movieclass_old.pas` | Source-derived 1.0–4.2 reads, legacy sidecar lookup, and experimental 4.2 writes; read/write/reread round-trip checked byte-for-decoded-field against genuine native catalogs — a committed empty/one-movie 3.5/4.1/4.2 set (`tests/fixtures/native-empty-one-movie/`) and a committed populated-catalog 3.5/4.2 set with custom fields and embedded pictures (`tests/fixtures/native-sample-catalog/`), this port's first genuine, redistribution-cleared native fixtures — which found and fixed a real encode/decode asymmetry (finding 34), a real `-1`-sentinel-vs-`None` bug in five integer fields confirmed against the checked-in Delphi source itself (finding 38), and a real total-parse-failure bug for `List`-type custom fields (finding 39); finding 35's synthetic fixture adds a further regression guard alongside the genuine ones | Code-page behavior beyond one real catalog; pre-3.0 sidecar verification; 3.5/4.1 writers; every remaining version beyond 3.5/4.1/4.2; upstream open/save/reopen evidence |
| Movie and custom-field model | `movieclass.pas`, `fields.pas`, `customfieldsmanager.pas`, `extrasedit.pas` | Common scalar fields plus opaque metadata/extras retention | Typed writer/composer/certification/file-path and extra records; duplicate/order/type preservation; custom-field editing semantics and defaults |
| XML/CSV import and export | `movieclass.pas`, `import2*.pas`, `export.pas` | Synthetic XML/CSV codecs | Upstream dialect/locale fixtures, streaming/resource limits, repeated/nested unknown XML, and cross-application round trips |
| Main catalog workflows | `main.pas`, `sort.pas`, `filter*.pas`, forms | CRUD, merge, search, filters, sort, duplicate review, renumber, backup/restore | Full selection/group actions, preferences, progress/cancellation, unsaved-state workflows, and verified behavioral parity |
| Pictures | `TMoviePicture` in `movieclass.pas`, picture forms | Link/embed/clear/export/crop, bounded poster display, and atomic batch set/clear | Upstream import modes, naming/copy/move rules, conversion options, and genuine embedded/linked fixtures |
| Loans | `loan.pas`, `loanhistory.pas` | Atomic loan transitions, grouping options, managed names, history, TSV export | Upstream settings and dialogs, process-code-page TSV verification, deletion semantics, and genuine consumption tests |
| Website scripts | `getscript*.pas`, `ifps/` | Metadata, permissions, option/parameter configuration, Python JSON settings, now validated against 14 committed real scripts plus a 314-file contributor snapshot used locally (finding 33 — found and fixed a real crash on non-cp1252 scripts); separately, a first-party (not IFPS) OMDb-backed IMDb lookup/update provider (`amc.omdb`, CLI `imdb-lookup`, and since finding 36 the desktop GUI's **Movie / Update from IMDb...** dialog) covers the two cases named most-used, with an isolated merge preview reusing the same safe-merge shape below | IFPS compiler/runtime and general script execution remain undecided (finding 31, real security exposure); complete API inventory, HTTP/browser interactions, license acceptance, debugger, and results UI for actual IFPS scripts |
| Media analysis | `getmedia.pas`, `Common/MediaInfo.pas` | Portable file facts and PCM WAV/FLAC/AIFF/MP3/MP4/OGG duration and bitrate (upstream delegates all of this, including WAV, to the third-party `MediaInfo.dll`; every format here is instead parsed directly from its own public format spec — MP4 from the `moov/mvhd` box, OGG from the Vorbis identification header and the stream's last granule position) | MediaInfo integration/version checks, video-track resolution/framerate/real codec name (needs per-track sample-table parsing this port does not do), the full tag map, stream selection, filters, and field merge behavior |
| HTML export | `export.pas`, `ConstValues.pas` (`strTagFields`/`TAG_*`), `fields.pas` | Safe bounded Python table/templates, plus `amc.html_template` rendering upstream's own `$$TAG_NAME` general/item/rating/picture/custom-field tags and the `$$ITEM_BEGIN`/`$$ITEM_END` full+individual document loop, validated locally against a genuine AMC 4.2.2 export's own real templates | The `$$ITEM_EXTRA_*` supplementary-record loop (with its category/checked/range filter syntax), upstream picture/rating-icon file copying, multi-file/SQL export, and fixture comparison of rendered tag values against genuine upstream output |
| Preferences/localization | `programsettings.pas`, `languages/`, help | No compatible settings or language-resource loader; localization decided as deliberately deferred (finding 29) — the `.lng` format has no Tk equivalent, and a Python-owned i18n layer awaits real translated content | Settings XML, per-user state, translated UI/help, and migration; localization scaffolding itself only once translated content exists |
| Printing/reports | `printform.pas`, `amcreport/`, `FreeReport/` | Not ported; decided as permanently out of scope (finding 30) — FreeReport's license is resolved (LGPLv2) but porting its designer/renderer is an application-sized effort disproportionate to this port | None planned; HTML template export already covers the underlying "formatted report" need as a non-compatible baseline |
| Desktop presentation | `main.pas` and `.dfm` forms | Broad Tk prototype with headless adapter tests plus real-display smoke tests under Xvfb | Form/workflow parity, accessibility verification, localization, and platform packaging |
| Web presentation | No upstream server counterpart | Read-only AMC Python extension | Authentication/TLS deployment layer if exposed beyond localhost; it is intentionally outside parity accounting |

## Requirement traceability

| Port requirement | Code | Tests | Upstream evidence | Status |
|---|---|---|---|---|
| Acquire/inventory source | `tools/acquire_upstream.py` | `tooling/test_acquire_upstream.py` | Supplied archives exactly match the 952-file snapshot; publisher authentication is unavailable | Archive/tree identity confirmed; acquisition timestamp and independent digest pending |
| Native header probe | Source-derived 1.0–4.2 recognition in `inspection.py` | All ten headers, truncation, unknown-version, CLI, and warning tests | Constants and dispatch in `movieclass.pas` | Implemented from source; genuine fixtures pending |
| Native catalog reader | `native.py`, storage/CLI import | Source-derived synthetic happy/error tests | `TMovieList.LoadFromFile`, `ReadRecords`, fixed records, `ReadData`, pictures/custom/extras | 1.0–4.2 implemented; no genuine verification |
| Native catalog writer | `native.py`, `storage.py`, `export-amc` | Synthetic round trip; atomic failure; malformed metadata/rating/separator; invalid-limit; encoded-string; full service/CLI budget and resource tests | `TMovieList.SaveToFile` and nested `WriteData` methods | Strict bounded configurable 4.2 writer implemented from source; upstream acceptance unverified |
| Internal working format | `storage.py`, JSON v1 spec | `compatibility/test_storage.py` | Not applicable | Implemented |
| AMC XML reader/writer | `storage.py` | Synthetic tests | None | Prototype only |
| AMC CSV reader/writer | `storage.py` | Synthetic tests | None | Prototype only |
| Catalog operations | `catalog.py` | Direct tests | None | Prototype only |
| CLI adapter | `cli.py` | In-process tests plus installed entry-point/JSON smoke | None | Partial |
| Desktop adapter | `gui.py`, `application.py` | Headless controller/dialog and service tests | Source workflows located; no display/genuine workflow fixture | Broad prototype; no upstream UI parity |
| Scripts | `scripts.py`, `configure-script` | Synthetic metadata, validation, persistence, and CLI tests | `getscript_readscripts.pas`, `getscript_properties.pas` | Metadata/public-settings subset; no IFPS execution, providers, results, or upstream cache parity |
| Media/HTML | `media.py`, `storage.py` | Synthetic bounded subset tests | `getmedia.pas`, `Common/MediaInfo.pas`, `export.pas` | Prototype subsets; no full codec or template parity |
| Pictures/loans | Linked/embedded picture set/clear/export and native retention; current borrower; managed list; JSON history; TSV export; opt-in loan groups | Synthetic unit/service/CLI/GUI/native tests | `TMoviePicture` in `movieclass.pas`; `loan.pas`; `loanhistory.pas` characterized | Source-derived prototypes pending genuine picture/loan verification |

## Next audited milestone

Do not claim additional AMC compatibility without fixture evidence. The ordered
near-term roadmap is maintained in [`NEXT_SPRINTS.md`](NEXT_SPRINTS.md). Its first
gate requires independently recorded source acquisition, resolution or exclusion of
the remaining redistribution blockers, and provenance manifests for genuine AMC
4.2.3.2 empty and one-movie catalogs plus their XML exports. Codec correction,
lossless interchange work, and release hardening follow only after their preceding
sprint exit checks pass.

## Audit reproduction

```console
python -m pip install -e .[dev]
git status --short --branch
git log --oneline --decorate -8
python tools/check.py
python tools/check_package.py
```

Observed for this audit:

| Command/check | Result |
|---|---|
| `python tools/check.py` | 635 tests passed; 88% aggregate branch coverage; Ruff lint, Ruff format, mypy, compilation, fixture-manifest validation, license-inventory validation, native-expectation verification, and source CLI help passed |
| `python tools/check_package.py` | Source distribution built and checked to exclude historical evidence trees; wheel built and installed into an isolated environment; module and `amc`, `amc-gui`, and `amc-web` entry-point smoke checks passed |
| `python tools/validate_fixtures.py` | 3 manifests validated — `tests/fixtures/native-empty-one-movie/` and `tests/fixtures/native-sample-catalog/`, this port's first genuine, upstream-generated native fixtures (see findings 38–39) — narrowing, but not closing, the compatibility-fixture gap |
| `git diff --check` | Passed |

The source-tree check applies focused Ruff diagnostics, `ruff format --check`, mypy
in its default, non-strict mode (see ADR-0008 in `docs/decisions.md`), and an 80%
aggregate branch coverage floor. The packaging
check is intentionally separate because it builds and installs an isolated wheel
rather than importing from `src/`.
