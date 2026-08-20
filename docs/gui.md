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
  and history position unchanged. The most recent 100 states are retained; opening
  or reloading a catalog starts new history.

File, search/view, and catalog actions use separate toolbar rows so controls remain
reachable at the supported 760-pixel minimum window width. The desktop opens at
1100×720 by default and remains resizable down to 760×480.

Keyboard shortcuts include Ctrl+O for Open, Ctrl+Shift+S for Save As, Ctrl+F for
search, Escape to clear search, Ctrl+N for a new movie, Ctrl+Z/Ctrl+Y for undo/redo,
Ctrl+U for the movie URL, Space for checked state, Delete for removal, and F5 for
reload. Action shortcuts follow the same enabled/disabled state as their toolbar
buttons, so they cannot bypass read-only, selection, URL-safety, or history checks.
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
seen with some Linux window managers.

Mutations go through `CatalogService`. A failed persistent mutation is reported in
a dialog and the table is not refreshed with unpublished state. Restore and
renumber require confirmation. Native AMC compatibility remains unverified; the GUI
does not change that status.

Native reads currently default to Windows-1252. Delphi ANSI strings may contain
byte values that Python's strict CP-1252 codec leaves undefined (including `0x90`);
the reader preserves those values as matching control codes instead of refusing to
open the catalog. Locale-specific code-page verification still requires genuine
upstream fixtures.

## Known limitations

The GUI remains a prototype. Mutations currently save immediately, so there is no
unsaved dirty state to prompt about. It does not yet provide progress or
cancellation, accessibility verification, localization, or automated
real-display widget tests. The batch **Set Pictures**, **Assign Pictures**, and
**Clear Pictures** toolbar actions cover sharing one picture, assigning a
distinct picture per movie, and clearing pictures across an extended
selection; the edit dialog's **Crop** button and each row's **Crop** button in
**Assign Pictures** provide interactive rectangle selection, and CLI
`picture-set-many --crop-for` sets a per-movie crop rectangle from the command
line. Current GUI tests are headless adapter tests with mocked dialogs.
