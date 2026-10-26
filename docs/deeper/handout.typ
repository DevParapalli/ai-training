// Shared setup for the deeper-reading handouts, one per class from class 3.
// Each handout picks up where its class stopped: the mistakes as a checklist,
// then every topic the class skipped or skimmed, with code to run and reading
// in order, shortest and most practical first.
#import "@local/centauri:0.0.0": *
#import "../../decks/course.typ": *

#let accents = (A: "indigo", B: "teal", C: "ember", D: "lime")
#let accent-of(n) = accents.at(if n <= 3 { "A" } else if n == 4 { "B" } else if n == 5 { "C" } else { "D" })

#let handout(n: 3, title: [], covered: [], body) = {
  show: centauri.with(kind: "report", title: "Class " + str(n) + ": going deeper", accent: accent-of(n), stage: "final",
    header: (left: [#track · class #n, going deeper], right: [#co.name]),
    footer: (left: footer-line))
  cover(title: [Class #n: going deeper], subtitle: title, meta: (
    ([Track], [#track, class #n of #total-classes]),
    ([Class covered], covered),
    ([Code], [#raw("code/class0" + str(n) + "/"), run with `uv run`]),
  ))[]
  outline(depth: 1)
  body
}

/// One reading. `kind` says what it is: guide, docs, book, paper, video, spec.
#let source(url, title, kind: "guide", by: none, why) = [
  - #link(url)[*#title*] #text(fill: luma(110))[(#kind#if by != none [, #by])]. #why
]

/// What to run, as a command line.
#let run(cmd) = block(inset: (x: 8pt, y: 6pt), radius: 4pt, fill: luma(245), width: 100%, raw(cmd, lang: "sh"))
