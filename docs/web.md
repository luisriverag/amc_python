# Web interface

Launch the read-only web catalog on the requested default address:

```console
amc-web movies.json
```

Open `http://localhost:6910/` from the same machine. The server binds to
`0.0.0.0:6910`, as requested, so other machines that can reach the host may also
read the catalog. For local-only use, run:

```console
amc-web movies.json --host 127.0.0.1
```

The web interface is a new AMC Python feature rather than a ported upstream web
server. Its UX deliberately follows the original/desktop catalog manager: a movie
table, search, All/Loaned/Available/Checked/Unchecked views, movie details, linked
or embedded posters, checked and borrower columns, and safe HTTP(S) movie links.
Column headings toggle ascending/descending sorting and display the active direction.
The Layout selector switches between the information-dense original-style table and
a responsive poster-card gallery. Cards retain the current search/view/sort/page
controls and show availability or the current borrower without exposing mutations.
It is keyboard accessible, responsive for narrower screens, requires no JavaScript,
and does not import or require Tk.
Results are paginated with selectable, bounded page sizes of 25, 50, 100, or 250
rows. Search, view, sorting, direction, and page size are retained in navigation
links, preventing a large catalog from producing an unbounded HTML response.

The server notices when another AMC Python process replaces the catalog and reloads
it before the next request. If the changed file is incomplete or invalid, readers
continue seeing the last valid snapshot and receive a visible reload warning; a
failed reload never replaces the published web view with partial data.

The interface is intentionally read-only. It has no authentication or TLS and must
not expose catalog mutations on an untrusted network. Use the service-backed desktop
or CLI for editing, loans, imports, backups, and exports. Linked poster files are
served only after the same catalog-relative resolution used by the desktop UI.
Responses include a restrictive content-security policy, referrer protection, and
content-sniffing protection. Posters are decoded before serving and receive their
detected image MIME type rather than trusting the catalog filename. Poster responses
are limited to 25 MiB and 40 million decoded pixels; missing, unreadable, malformed,
or oversized images produce an HTTP error instead of terminating a request handler
or consuming unbounded decode memory.
