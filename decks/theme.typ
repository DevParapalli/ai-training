// Course theme on top of Centauri. Every deck starts with:
//   #import "theme.typ": *
//   #show: class.with(n: 1)
// Build light slides with --input projection=light; dark is the default.

#import "@local/centauri:0.0.0": *
#import "course.typ": *

/// Each part of the track has its own accent, so a deck shows where it sits.
#let parts = (
  A: (name: [Choosing the right tool], accent: "indigo"),
  B: (name: [Working with LLMs], accent: "teal"),
  C: (name: [Building AI systems], accent: "ember"),
  D: (name: [Running AI responsibly], accent: "lime"),
)

#let part-of(n) = if n <= 5 { "A" } else if n <= 8 { "B" } else if n <= 12 { "C" } else { "D" }

/// Deck setup for class `n`.
#let class(n: 1, body) = {
  let part = parts.at(part-of(n))
  show: centauri.with(
    kind: "deck",
    aspect: "16:9",
    projection: sys.inputs.at("projection", default: "dark"),
    accent: part.accent,
    label: track,
    date: [Class #n of #total-classes],
    presenter: footer-line,
    title: track + ", class " + str(n),
  )
  body
}

/// The seven places on the card, in order, with one line each.
#let card-places = (
  ([A script], [The steps are known and don't change.]),
  ([A rule], [The decision is known and must be explainable line by line.]),
  ([Classical ML], [Labelled history, and the input is a table or short text.]),
  ([A small trained model], [Lots of text, images or audio, enough labels, cost per call matters.]),
  ([An LLM with a prompt], [Varied language in and out, few labels, someone checks the output.]),
  ([An LLM plus retrieval, tools or agents], [Needs private knowledge, has to act, or takes several steps.]),
  ([Not yet], [No ground truth, needs a guarantee, or nobody owns the result.]),
)

/// Closing slide that puts the class topic on the card. `at` lists the 1-based
/// places the topic covers; those rows are set in strong ink.
#let on-the-card(at: (), title: [Where today sits on the card]) = explain(
  title: title,
  ..card-places.enumerate().map(((i, (p, line))) => {
    if (i + 1) in at { (hl[#(i + 1). #p], hl(line)) } else { ([#(i + 1). #p], line) }
  }),
)
