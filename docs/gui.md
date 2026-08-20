# Desktop interface

AMC Python includes a prototype desktop interface built with Python's Tk toolkit.
Launch it for the default `catalog.json` with `amc-gui`, pass a catalog directly as
`amc-gui movies.json`, or use `amc --catalog movies.json gui`.

## Tk installation

Tk is included by the official Windows and macOS Python installers. Linux vendors
often split it into an operating-system package. On Debian and Ubuntu install it
before AMC Python:

```console
sudo apt install python3-tk
```

`python3-tk` cannot be listed in wheel dependencies: it is an OS package containing
the CPython Tk extension and native Tk libraries, not a package published for pip.
The packaging check verifies that an isolated wheel installation can import both
`tkinter` and `amc.gui`, and that it registers the `amc-gui` entry point.

## Implemented workflows

- Open an existing JSON, XML, CSV, or native AMC catalog.
- Save the active catalog under a new JSON path.
- Merge another catalog using safe default collision policies.
- **Import Media** first asks whether to import from a folder or choose
  individual files, then adds a movie entry per file from portable facts and,
  for WAV/FLAC/AIFF, duration and bitrate — the desktop equivalent of the
  CLI's `import-media`. Choosing a folder also asks whether to include
  subfolders, mirroring `--recursive`, and then offers an optional
  comma-separated extension filter (e.g. `mkv,mp4,wav`) that narrows the
  folder scan the same way as the CLI's `--extensions`; leaving it blank
  imports every file, matching the CLI's own default. A modal progress dialog
  reports which file is being inspected and can be cancelled mid-scan; like
  the CLI, the catalog is only mutated once, after every selected file has
  been inspected, so cancelling, an empty folder, or an invalid file leaves it
  untouched.
- Export XML, CSV, static HTML, or experimental native AMC 4.2 output.
- Create and restore validated, atomically replaced backups.
- Add and edit all modeled scalar movie fields in a scrollable validated form;
  remove one movie or an extended table selection in a single atomic operation,
  sort, and renumber movies. The Picture row includes Browse, Crop, and Clear
  controls. Browse validates the selected image, stores a catalog-relative link
  when possible, and can retain the image bytes in the catalog when **Embed** is
  selected. **Crop** opens a modal preview of the chosen picture; dragging a
  rectangle over it and choosing **Apply Crop** replaces the in-memory picture
  bytes with the cropped, re-encoded image (same source format) before the
  movie is saved — no numeric coordinates required, unlike the CLI's `--crop
  X,Y,WIDTH,HEIGHT`. Clearing a picture removes both its link and embedded
  bytes when the movie is saved. The toolbar **Set Pictures**, **Assign
  Pictures**, and **Clear
  Pictures** actions apply to one movie or an extended table selection in a
  single atomic write, mirroring the batch Remove, Loan, and Toggle Checked
  actions: **Set Pictures** prompts for one image file and an Embed/Link choice,
  then applies that same picture to every selected movie (for a shared cover
  across a boxed set or series); **Assign Pictures** opens a scrollable per-movie
  list with its own Browse and Crop buttons for each selected movie, so every
  movie can receive its own picture file — and, when Embed is checked, its own
  interactively selected crop rectangle — in one atomic write, applying a shared
  Embed/Link choice to whichever movies were assigned a file (movies left
  unassigned keep their current picture); **Clear Pictures** removes linked and
  embedded picture
  state from the selection. Description and comments use multiline editors so
  paragraphs are not forced
  through single-line fields; borrower changes remain in the dedicated loan
  controls.
- Search the visible list; filter all, loaned, available, checked, or unchecked
  movies; and review displayed/total counts. The table includes borrower and checked
  status and retains a visible selection across refreshes. Clicking a column heading
  sorts ascending; clicking it again sorts descending. An arrow shows the active
  direction, and missing numeric values remain at the end in either direction.
  The active view filter, layout, and window size are remembered across
  restarts (see **Preferences** below); this does not affect sorting, which
  always starts unsorted for a freshly opened catalog.
- Use Ctrl+F to move directly to search and Escape to clear the current query and
  return to the movie table. Selection-dependent actions are disabled until they
  can succeed, and mutation controls remain disabled while an interchange catalog
  is open read-only. Undo and redo also reflect whether history is available.
- Select a movie to review titles, director, category, actors, borrower, URL,
  description, and comments in a read-only details pane.
- Switch between table-only, combined poster/details, and poster-focused layouts.
  Posters appear by default in the combined Details layout; choosing Poster gives
  the image the full lower pane. Linked
  poster paths are resolved relative to the catalog, and embedded native pictures
  are decoded with Pillow. JPEG, PNG, GIF, BMP, TIFF, and other Pillow-supported
  formats are scaled down to fit without distorting or enlarging them. When a
  catalog moved from Windows retains an unavailable drive path, the GUI also looks
  for the poster filename beside the catalog. Invalid embedded data falls back to a
  valid linked poster.
- Check one movie or an extended selection out to one borrower, or check the
  selection back in. The whole loan batch is validated and persisted atomically;
  one conflicting or unavailable movie leaves every selected loan unchanged. The
  borrower field offers managed and currently active borrower names while remaining
  editable for a new name. Check-in is enabled only when every selected movie is
  currently loaned.
- Review retained check-out and check-in events in a dedicated loan-history table.
  Newest events appear first, Escape closes the history window, and **Export
  History** writes the source-shaped tab-separated history accepted by spreadsheet
  applications.
- Toggle checked/reviewed state for one movie or the extended selection with the
  toolbar or Space. A mixed selection becomes checked; an entirely checked
  selection becomes unchecked. The complete selection is persisted atomically.
- Review aggregate statistics and normalized title/year duplicate groups.
- Open the selected movie's absolute HTTP or HTTPS URL in the system browser with
  **Open URL** or Ctrl+U. Empty, relative, `file:`, and other non-web URLs are
  rejected rather than passed to the operating system, and the action remains
  disabled when the selected movie has no safe web URL.
- Reload the active catalog from disk with F5.
- Undo and redo persisted mutations with the toolbar, Ctrl+Z, and Ctrl+Y. Undo and
  redo are themselves failure-atomic: a write error leaves both the visible catalog
  and history position unchanged. The most recent states are retained up to the
  configurable history limit (100 by default; see **Preferences** below); opening
  or reloading a catalog starts new history.

File, search/view, and catalog actions use separate toolbar rows so controls remain
reachable at the supported 760-pixel minimum window width. The desktop opens at
1100×720 by default and remains resizable down to 760×480.

Keyboard shortcuts include Ctrl+O for Open, Ctrl+Shift+S for Save As, Ctrl+F for
search, Escape to clear search, Ctrl+N for a new movie, Ctrl+M for Import Media,
Ctrl+Z/Ctrl+Y for undo/redo, Ctrl+U for the movie URL, Space for checked state,
Delete for removal, and F5 for reload. Action shortcuts follow the same
enabled/disabled state as their toolbar buttons, so they cannot bypass read-only,
selection, URL-safety, or history checks.
Destructive removal, restore, and renumber workflows require confirmation.
Native `.amc` export also requires confirmation because writer output has not been
verified in upstream AMC. The dialog advises retaining the AMC Python JSON catalog
and, when replacing an existing destination, names the `.bak` file that will retain
its previous bytes. Successful replacement repeats that backup path.
Native AMC, XML, and CSV inputs open as read-only interchange catalogs. The desktop
shows a notice after opening one and requires **Save As** to create a JSON working
catalog before any edit, loan, picture, import, or other persisted mutation. This
prevents the JSON persistence layer from replacing interchange bytes in place.

Editor and loan dialogs wait until the window manager has made them viewable before
taking a modal input grab. This avoids the `grab failed: window not viewable` error
seen with some Linux window managers. Every modal dialog also moves initial keyboard
focus to a specific control when it opens — the title field in Add/Edit, the
borrower field in Loan Out, the first Browse button in Assign Pictures, the Spinbox
in Preferences, and the Cancel button in the crop and Import Media dialogs — so a
keyboard-only user is never left with focus on the dialog's background. This is a
targeted, tested improvement to keyboard reachability, not a verified accessibility
pass: Tk's cross-platform screen-reader support cannot be exercised or verified in
this project's environment, so no assistive-technology compatibility claim is made.

Mutations go through `CatalogService`. A failed persistent mutation is reported in
a dialog and the table is not refreshed with unpublished state. Restore and
renumber require confirmation. Native AMC compatibility remains unverified; the GUI
does not change that status.

Native reads currently default to Windows-1252. Delphi ANSI strings may contain
byte values that Python's strict CP-1252 codec leaves undefined (including `0x90`);
the reader preserves those values as matching control codes instead of refusing to
open the catalog. Locale-specific code-page verification still requires genuine
upstream fixtures.

## Preferences

The desktop remembers the last-used view filter, layout, window size, and
undo/redo history depth across restarts. This is an AMC Python convenience with
no upstream counterpart, so it is deliberately stored outside any catalog file —
never in the JSON catalog, and never confused with a retained Ant Movie Catalog
property — in a small per-user JSON file (`amc.preferences`):
`%APPDATA%\amc-python\gui-preferences.json` on Windows,
`~/Library/Application Support/amc-python/gui-preferences.json` on macOS, and
`$XDG_CONFIG_HOME/amc-python/gui-preferences.json` (or `~/.config/amc-python/...`)
elsewhere. Set `AMC_PYTHON_CONFIG_DIR` to use a different location, such as in
tests or portable installs. Preferences are written atomically whenever the view
filter or layout changes, once when the **Preferences** toolbar button's history
limit is saved, and once more when the window closes to capture its final size.
A missing, corrupt, or invalid preferences file — or a failed write — is never
treated as an error: the desktop falls back to built-in defaults (view All,
layout Details, 1100×720, 100-entry history) rather than failing to start or
blocking a close.

The toolbar **Preferences** button opens a dialog to change how many undo/redo
states (1–1000) the desktop keeps in memory and writes to the JSON catalog on
each undo/redo. The new limit takes effect immediately and does not retroactively
grow or shrink already-retained history.

## Known limitations

The GUI remains a prototype. Mutations currently save immediately, so there is no
unsaved dirty state to prompt about. Import Media has cancellable progress
reporting, but bulk `merge` and batch picture operations do not; there is no
verified accessibility pass (only the keyboard-focus improvements described
above — no screen-reader labels, and no automated or human verification with
assistive technology — Tk has no meaningful AT-SPI bridge on X11 to exercise,
and no screen reader is installed in this project's development container, so
this stays a real gap even after the point below), and no localization. The
batch **Set Pictures**, **Assign Pictures**, and **Clear Pictures** toolbar
actions cover sharing one picture, assigning a distinct picture per movie, and
clearing pictures across an extended selection; the edit dialog's **Crop**
button and each row's **Crop** button in **Assign Pictures** provide
interactive rectangle selection, and CLI `picture-set-many --crop-for` sets a
per-movie crop rectangle from the command line.

Most GUI tests are headless adapter tests that bypass `CatalogWindow.__init__`
and mock every widget. `tests/test_gui_display.py` is different: it builds
real Tk widget trees — the main window, Preferences, Assign Pictures, Import
Media, the edit dialog, and an end-to-end simulated drag-select-and-apply
crop — against a real (possibly virtual) X display, skipping itself wherever
none is available. `tools/check.py` runs it under Xvfb automatically on Linux
when `xvfb-run` is installed and no `DISPLAY` is already set (see
`.github/workflows/ci.yml`, which installs `xvfb` on the Linux job for this).
This is real-display coverage, not a substitute for the still-missing
assistive-technology verification above.
