# Agents

This repository contains IETF Internet-Drafts authored in kramdown-rfc2629
markdown. Each top-level directory (other than `Tools/`) is an individual
draft.

## Repository layout

- Each draft lives in its own subdirectory (e.g. `http2-encoded-data/`,
  `rfc8089-bis-core/`).
- `Tools/skel/` is the skeleton used when creating a new draft; see the
  root `Makefile` for how it is invoked.
- `.github/` contains issue and PR templates, and contributing guidelines.

## Source of truth

The authoritative source for each draft is `draft.md` in its subdirectory.
This is a kramdown-rfc2629 document (YAML front matter + markdown body);
see `Tools/skel/draft.md` for the blank template.

PRs must update `draft.md`. See `.github/CONTRIBUTING.md` and
`.github/PULL_REQUEST_TEMPLATE.md` for contribution expectations, including
the EDITORIAL / SUBSTANTIVE / TECHNICAL classification.

## Versioned XML files

Each subdirectory also contains numbered `.xml` files
(`draft-kerwin-<name>-NN.xml`). These are point-in-time snapshots generated
from `draft.md` and committed to the repository. The highest-numbered XML
file is the current version; the Makefile derives this automatically.

## Build

The toolchain is `markdown → xml → txt + html`. Each draft subdirectory has
a `Makefile` (copied from `Tools/skel/Makefile`) that drives the build.

Prerequisites (not vendored; must be installed separately):

- [kramdown-rfc2629](https://github.com/cabo/kramdown-rfc2629)
- [xml2rfc](https://xml2rfc.ietf.org/)
- [idnits](https://tools.ietf.org/tools/idnits/) (for the `idnits` target)

Key make targets (run from inside a draft's directory):

- `make` / `make latest` — build HTML and plain-text output
- `make clean` — remove generated HTML and TXT
- `make next` — bump to the next version number
- `make diff` — diff the current version against the previous one (requires
  `rfcdiff`)
- `make idnits` — run nit checks
- `make update` — re-copy the Makefile from `Tools/skel/`

Generated `.html` and `.txt` files are git-ignored (see `.gitignore`).

The `rebuild` script in the repository root runs `make` in each `http2-*`
subdirectory.

## Licensing and conduct

- `LICENSE.md` — IETF Trust Legal Provisions (TLP)
- `code_of_conduct.md` — Contributor Covenant 3.0
