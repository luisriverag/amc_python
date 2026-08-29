# Upstream source archive provenance

This record separates facts that can be reproduced from the checked-in files from
the acquisition details supplied by the contributor. It does not treat possession
of an archive as proof that a third party published the same bytes.

**`src/original_compressed/amc_sources.rar` has since been removed** from this
repository and its git history, along with `src/original/ElTree/`: the RAR
contained ElTree Lite's source, and ElTree Lite's own license permits
distribution only inside compiled software, never as source (see
`THIRD_PARTY_NOTICES.md`). The row below is retained as a historical record
of the verification that was performed while the archive was still present,
not as a description of what the repository currently contains.

## Recorded archives

| Archive | Reported source | Bytes | SHA-256 | Expanded tree | Comparison |
|---|---|---:|---|---|---|
| `src/original_compressed/amc_sources.rar` (removed) | [AMC source downloads](https://antp.be/software/moviecatalog/sources) (direct download reported by contributor) | 3,321,322 | `96ac957a892094f2b97c9eebcbe31d4f0d78f2557800dcae276ffe551952cfb7` | `src/original/` (ElTree subset also removed) | 876/876 files matched by relative path and SHA-256 at time of verification |
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

The RAR contained a single `amc_sources/` directory; the comparison removed that
one packaging directory before comparing it with `src/original/` (this tree, and
the RAR itself, have since been removed — see the note above). The ZIP stores
its component files at the archive root and compares directly with
`src/antcomponents/`.

`tools/acquire_upstream.py` supports both layouts: it extracts ZIP archives without
an external program, rejects ZIP members that escape the destination, supports
RAR extraction through `unrar`, `unar`, `7z`, or `bsdtar`, and provides
`--strip-root` for the RAR wrapper directory. It remains able to re-acquire and
compare a RAR archive if one is supplied again in the future; none is checked
into the repository now.

At the time of verification, this confirmed that the then-checked-in expanded
trees were exact representations of the two then-checked-in compressed files. It
did **not** supply genuine `.amc` catalog fixtures, prove compatibility with the
upstream application, or resolve the third-party redistribution issues listed in
`THIRD_PARTY_NOTICES.md` — including, at the time, the ElTree issue that has
since been resolved by removing the affected files rather than by clearing
them for redistribution.
