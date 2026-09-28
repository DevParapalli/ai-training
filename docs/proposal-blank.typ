// Capstone proposal, blank. A one-page worksheet teams fill in by hand or in any
// tool they like. Build:
//   typst compile --root . docs/proposal-blank.typ build/proposal-blank.pdf
#import "@local/centauri:0.0.0": *

#let boxes = (
  ([The problem], [One sentence, with a verb. What goes in, what should come out.], 2.8cm),
  ([Where it lands on the card], [The place (1 to 7), and the one question that decided it.], 2.6cm),
  ([Steps], [Five at most, in order. What gets built or changed.], 6.4cm),
  ([Error budget], [What one wrong answer costs, and how many you can live with.], 2.8cm),
  ([Cost], [To build, and to run per month.], 2.2cm),
  ([Owner and off switch], [One named person, and how it gets turned off.], 2.2cm),
)

#show: centauri.with(kind: "brief", title: "Building the Right AI System: Capstone Proposal", accent: "lime", stage: "final",
  header: (left: [Building the Right AI System · capstone], right: [Team: #box(width: 3.5cm, line(length: 100%, stroke: 0.5pt))]),
  footer: (left: [“No AI needed” is a valid answer.]))

#text(size: 16pt, weight: 600)[Capstone proposal]
#v(0.2em)
#text(size: 9pt)[Place the problem on the card, then argue for the cheapest thing that works. One page.]
#v(0.6em)

#for (label, hint, height) in boxes {
  block(width: 100%, height: height, breakable: false, inset: 8pt, radius: 6pt, stroke: 0.6pt + luma(190), below: 0.35cm, {
    text(size: 10pt, weight: 600)[#label]
    h(0.6em)
    text(size: 8pt, fill: luma(120), hint)
  })
}
