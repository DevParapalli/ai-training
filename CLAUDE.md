# Working in this repository

Instructions for anyone, person or agent, committing to the AI Builder Track. They apply to every branch.

## Commits

- Every commit MUST be authored and committed as `DevParapalli <hey@parapalli.dev>`. Set it locally before the first commit: `git config user.name DevParapalli && git config user.email hey@parapalli.dev`.
- Commit messages MUST NOT carry `Co-Authored-By`, `Claude-Session`, `Generated with` or any other AI attribution trailer or line, whatever the tooling suggests. No model name or identifier appears in a commit message, a pull request, a code comment or any file.
- Messages follow Conventional Commits: `feat(decks): …`, `fix: …`, `docs: …`, `chore: …`. The subject is one line in sentence case; the body, when there is one, says what changed and why in full sentences.
- Trunk is `main`. Work on branches named `feat/…` or `fix/…` and merge with a pull request.

## Content rules

The README section "What stays out of this repository" is binding: no client names, client systems, internal tools, real figures, internal policy text, real tickets, logs, hostnames, users or credentials. Everything is told from inside the fictional Lafayette O'Reilly Logistics; organisation-specific material goes in `local/`, which is never committed.

## Decks

- `decks/classNN.typ` are the print source, built with Centauri (`scripts/build.sh`). Per-class facts live in the `#let` block at the top of each file; course-wide facts in `decks/course.typ`. Change a fact there, never in a slide.
- `decks/class03.md` is the same class as a web deck on `slidev-theme-proxima`, from a Proxima checkout beside this repository (`../proxima`); `pnpm dev`, `pnpm build`, `pnpm export`. The markdown carries the class facts as literals, so a fact changed in the `.typ` MUST be changed there too.
- Any `.typ` deck presents through the same theme without a port: `pnpm import` writes `decks/<name>-pages.md` from the compiled pages, `pnpm dev:pages` presents it. Pages under `decks/public/` are build output and are not committed; the generated markdown, with its speaker notes, is.
- Slide titles are sentences in sentence case and MUST NOT end with a full stop; both builds stop if one does. A slide whose content does not fit is cut or split, never shrunk.

## Checks before a commit

- `uv run data/generate.py`, then `scripts/build.sh` (Typst) and `pnpm build` (web) MUST succeed.
- Code under `code/classNN/` runs with `uv run` and reads only generated or handwritten data from `data/`.
