# Upstream source archive provenance

This record separates facts that can be reproduced from the checked-in files from
the acquisition details supplied by the contributor. It does not treat possession
of an archive as proof that a third party published the same bytes.

## Recorded archives

| Archive | Reported source | Bytes | SHA-256 | Expanded tree | Comparison |
|---|---|---:|---|---|---|
| `src/original_compressed/amc_sources.rar` | [AMC source downloads](https://antp.be/software/moviecatalog/sources) (direct download reported by contributor) | 3,321,322 | `96ac957a892094f2b97c9eebcbe31d4f0d78f2557800dcae276ffe551952cfb7` | `src/original/` | 876/876 files match by relative path and SHA-256 |
| `src/components_compressed/antcomponents.zip` | [AMC source downloads](https://antp.be/software/moviecatalog/sources) (direct download reported by contributor) | 202,942 | `e0da81e5c0c150c285587c58e5218b07e7bd269461938e683d4416b04128bf80` | `src/antcomponents/` | 76/76 files match by relative path and SHA-256 |

The archives were first committed in repository commit `4303c7a` on 2026-08-13.
The precise download time was not recorded. The original archive's page does not
currently provide a separately authenticated or published checksum in this
repository, so the digests above identify the supplied bytes rather than acting as
independent publisher authentication.

## Verification

On 2026-08-13, both archives were extracted into clean temporary directories. A
deterministic inventory comparison checked relative paths and SHA-256 content
digests. Directory names and archive timestamps were not used to decide equality.
There were no changed, missing, or unexpected files in either comparison.

The RAR contains a single `amc_sources/` directory; the comparison removes that
one packaging directory before comparing it with `src/original/`. The ZIP stores
its component files at the archive root and compares directly with
`src/antcomponents/`.

`tools/acquire_upstream.py` supports both layouts: it extracts ZIP archives without
an external program, rejects ZIP members that escape the destination, supports
RAR extraction through `unrar`, `unar`, `7z`, or `bsdtar`, and provides
`--strip-root` for the RAR wrapper directory.

This confirms that the checked-in expanded trees are exact representations of the
two checked-in compressed files. It does **not** supply genuine `.amc` catalog
fixtures, prove compatibility with the upstream application, or resolve the
third-party redistribution issues listed in `THIRD_PARTY_NOTICES.md`.
