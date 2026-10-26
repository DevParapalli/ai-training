# AI Builder Track

Six one-hour classes on telling which problems need AI, which need a model, which need a script, and which need nothing at all, and then on building the ones that do.

Copyright © 2026 Devansh Parapalli (hey@parapalli.dev). Released under the MIT licence (see `LICENSE`).

## Who it is for

People who support and build enterprise applications: support engineers, developers, and the leads and managers who decide what gets built.

Nobody writes code in class. Each class runs in three parts:

- **30 minutes: the idea and the steps.** For everyone.
- **20 minutes: the code.** For developers and support engineers.
- **10 minutes: questions.**

From class 3, the class covers the starting point and the mistakes people make; each class has a deeper-reading handout with the rest: code to run and reading in order.

Every class is recorded.

## The company in every example

The track is told from inside **Lafayette O'Reilly Logistics (LOL)**, a global freight and logistics company. We look at the whole company, not one department. Everything about LOL is invented, the way certification courses invent their example companies:

- **Systems:** Tracklane (bookings, tracking, customs documents), Ledgerline, Procura, InvoiceHub, PayGrid, Gatehouse, CW Portal, Harbor MDM, Datadock.
- **Customer:** Bayerische Unfug Maschinen (BUM), whose machines LOL ships worldwide.
- **Suppliers:** Armadillo Security Services (ASS, physical security and background checks), Drymark Institutional Handling (DIH, admin, facilities, janitorial), Gastro Alliance Group (GAG, catering), Stratocumulus Cloud (SC, cloud).

Employees' laptops are managed in Intune with Entra ID sign-in. Contractors' laptops come from their agency and go through Harbor MDM. Situations are modelled on common enterprise finance support work.

## Layout

```
syllabus.md                   the six classes, what each covers and why
data/generate.py              builds the generated ticket and host-signal data (seeded, stdlib only)
data/tickets_handwritten.csv  300 tickets written by hand, the way people actually raise them
data/runbooks/                eight LOL runbooks for retrieval, tools and agents (class 5)
docs/prereading.typ           pre-week Python self-study and pre-reading for classes 2 to 6
docs/deeper/classNN.typ       deeper-reading handouts for classes 3 to 6: mistakes, code to run, links
docs/proposal.typ             capstone proposal, worked example
docs/proposal-blank.typ       capstone proposal, blank one-page worksheet
decks/course.typ              course-wide facts: company, systems, the running ticket
decks/theme.typ               course theme on top of Centauri
decks/classNN.typ             one deck per class, per-class facts in a #let block at the top
code/classNN/                 reference code walked through in class
scripts/build.sh              builds every deck
```

## Building

Generate the data first. The code walkthroughs read it.

```sh
uv run data/generate.py
```

The decks use [Centauri](https://github.com/DevParapalli/centauri) 0.2.0, installed as a local Typst package (see Centauri's README), and its fonts.

```sh
export TYPST_FONT_PATHS=~/Projects/centauri/fonts
typst compile --root . decks/class01.typ build/class01.pdf
typst compile --root . --input projection=light decks/class01.typ build/class01-light.pdf
typst compile --root . --input mode=handout decks/class01.typ build/class01-handout.pdf
```

`scripts/build.sh` builds every class in all three forms, the pre-reading, the handouts and the proposals.
