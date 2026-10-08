# AI Builder Track

Fifteen one-hour classes on how to tell which problems need AI, which need a model, which need a script, and which need nothing at all, and then how to build the ones that do.

Copyright © 2026 Devansh Parapalli (hey@parapalli.dev). Released under the MIT licence (see `LICENSE`). No sensitivity label is applied yet.

## Who it is for

People who support and build enterprise applications: support engineers, developers, and the leads and managers who decide what gets built. No one writes code in class. Each class spends about 30 minutes on the idea and the steps, for everyone, and about 20 minutes walking through the code, for developers and support engineers. The last 10 minutes are questions. Every class is recorded.

## The company in every example

The track is told from inside **Lafayette O'Reilly Logistics (LOL)**, a global freight and logistics company, looking at the whole company rather than one department. Everything about LOL is invented, in the way certification courses invent their example companies:

- systems: Tracklane (bookings, tracking, customs documents), Ledgerline, Procura, InvoiceHub, PayGrid, Gatehouse, CW Portal, Harbor MDM, Datadock;
- a customer: Bayerische Unfug Maschinen (BUM), whose machines LOL ships worldwide;
- suppliers: Armadillo Security Services (ASS, physical security and background checks), Drymark Institutional Handling (DIH, admin, facilities, janitorial), Gastro Alliance Group (GAG, catering), Stratocumulus Cloud (SC, cloud).

Employees' laptops are managed in Intune with Entra ID sign-in; contractors' laptops come from their agency and go through Harbor MDM. Situations are modelled on common enterprise finance support work; no content is copied from any real client, system or bid. The only real organisations named are TCS and Cisco, on one reference slide in class 8, which is meant to be swapped per audience (`reference-policies` in `decks/course.typ`).

## Layout

```
syllabus.md          the fifteen classes, what each covers and why
data/generate.py     builds the generated ticket and host-signal data (seeded, stdlib only)
data/tickets_handwritten.csv  300 tickets written by hand across the company, the way people actually raise them
data/runbooks/       eight LOL runbooks used for retrieval, tools and agents (classes 9 to 12)
docs/prereading.typ  pre-week Python self-study and the pre-reading for classes 2 to 15
docs/proposal.typ    capstone proposal, worked example (not a draw problem)
docs/proposal-blank.typ  capstone proposal, blank one-page worksheet
decks/course.typ     course-wide facts: company, systems, the running ticket
decks/theme.typ      course theme on top of Centauri
decks/classNN.typ    one deck per class; per-class facts in a #let block at the top
decks/class03.md     class 3 as a web deck (Slidev, slidev-theme-proxima)
code/classNN/        reference code walked through in class
docs/                pre-reading and handouts
local/               organisation-specific material, never committed
```

## Building the decks

Generate the data first; the code walkthroughs read it:

```sh
uv run data/generate.py
```

The decks use [Centauri](https://github.com/DevParapalli/centauri), installed as a local Typst package at version 0.2.0 (see Centauri's README), and its fonts.

```sh
export TYPST_FONT_PATHS=~/Projects/centauri/fonts
typst compile --root . decks/class01.typ build/class01.pdf
typst compile --root . --input projection=light decks/class01.typ build/class01-light.pdf
typst compile --root . --input mode=handout decks/class01.typ build/class01-handout.pdf
```

`scripts/build.sh` builds every class in all three forms.

### Web build

`decks/class03.md` is the same class as a web deck, built with [`slidev-theme-proxima`](https://github.com/DevParapalli/proxima/tree/main/deck) from a Proxima checkout beside this repository (`../proxima`). The Typst deck remains the print source; the markdown carries the class facts as literals.

```sh
pnpm install
pnpm dev        # dev server with presenter mode at /presenter
pnpm build      # static site in build/web/class03
pnpm export     # build/class03-web.pdf
pnpm titles     # the title-only outline
```

## What stays out of this repository

Content MUST NOT include:

- names of clients, client systems, internal tools or internal projects;
- figures from any real system: volumes, accuracy, cost, headcount;
- internal policy text, even paraphrased;
- real tickets, logs, hostnames, users or credentials.

Examples use the fictional company above, generated data, and the handwritten ticket set. Where a class needs an organisation's own rules (class 8), the deck carries a slide that reads from `local/policy.typ`. That file is gitignored; each organisation writes its own, and the public build shows a placeholder.
