#import "theme.typ": *

// ---- Class facts: change here, not in the slides ---------------------------
#let n = 15
#let title = [How much to let it do, and the capstone]
#let subtitle = [Where each kind of work sits between "helps a person" and "runs on its own", then your turn.]
#let ladder = (
  ([Assist], [It suggests; a person does everything.], [Drafting the reply to BUM about the Santos delay]),
  ([Co-pilot], [It does the work; a person checks each result.], [Customs document fixes, payroll variance write-ups]),
  ([Supervised agent], [It runs; a person approves the risky steps and watches the numbers.], [Customs holds end to end, with the send behind approval]),
  ([Autonomous], [It runs; a person looks at samples.], [Replying to "has the InvoiceHub batch finished?"]),
)
#let capstone = (minutes: (build: 25, present: 3), team: [3 to 4 people])
// -----------------------------------------------------------------------------

#show: class.with(n: n)

#title-slide(number: [#n], title: title, subtitle: subtitle,
  facts: ([60 min], [Recorded], [Class #n of #total-classes]))

#outline-slide(current: none)

#section-slide(number: [1], title: [How much to let it do], subtitle: [Four levels, and most work stops at the second.])

#explain(title: [Four levels of autonomy, each with an example from #co.short],
  ..ladder.map(((l, what, eg)) => (l, [#what \ #text(fill: gray)[#eg]])))

#statement(sub: [Supplier bank changes, payroll, and anything that sends money or a customs submission stay at co-pilot or below.])[The level depends on #hl[what a mistake costs], not on how good the model is.]

#claim(title: [What changes in the job, and what doesn't])[
  #cols(
    [
      *Changes*
      - Less looking things up, more checking answers
      - Writing test sets and owner cards becomes normal work
      - Knowing when to say "this doesn't need AI"
    ],
    [
      *Doesn't*
      - Someone owns every outcome
      - Customers still call when it goes wrong
      - Judgement on the hard 10% stays with people
    ],
  )
]

#section-slide(number: [2], title: [The capstone], subtitle: [Place a problem nobody's seen, and argue for the cheapest thing that works.])

#steps-slide(title: [Each team gets one problem and #capstone.minutes.build minutes],
  [Write it as one sentence],
  [Answer the six questions from class 2],
  [Place it on the card],
  [Fill in the one-page proposal],
  [Present in #capstone.minutes.present minutes])

#explain(title: [The one-page proposal has six boxes, and "no AI needed" fits in all of them],
  ([The problem], [One sentence, with a verb.]),
  ([Where it lands], [The place on the card, and the question that decided it.]),
  ([Steps], [Five at most. What gets built, in order.]),
  ([Error budget], [What one wrong answer costs, and how many we can live with.]),
  ([Cost], [To build, and to run per month.]),
  ([Owner and off switch], [Who answers for it, and how it gets turned off.]),
)

#claim(title: [Problems for the draw])[
  #set text(size: 0.85em)
  #cols(
    enum(
      [Match #bum.short's EUR receipts to invoices automatically, net of bank charges],
      [Tell dispatch which trucks will miss their slot at Felixstowe tomorrow],
      [Answer drivers' payslip questions in their own language],
      [Flag supplier emails asking for bank changes before anyone reads them],
    ),
    enum(start: 5,
      [Summarise every customs hold for the weekly ops review],
      [Predict which warehouse Wi-Fi access point fails next],
      [Book visitor passes from a meeting invite],
      [Decide which background check results need a second look],
    ),
  )
  #notes[Suggested placements, for after the presentations: 1 rule plus classical ML; 2 classical ML; 3 LLM with retrieval, co-pilot; 4 rule plus a classifier, person in the loop; 5 LLM with a prompt; 6 not yet, then anomaly detection; 7 a script; 8 not for any AI tool: ASS Restricted data.]
]

#section-slide(number: [3], title: [Closing], subtitle: [Fifteen classes on one card.])

#on-the-card(at: (1, 2, 3, 4, 5, 6, 7), title: [The whole track, on one card])

#statement(sub: [Most of the time it's a script, a rule or a small model. When it's an LLM, it's one with a test set, an owner and an off switch.])[The #hl[cheapest option] that stays inside the error budget wins.]

#close(title: [What to do after the track], actions: (
  [Take one problem from your team through the six questions this week.],
  [If it needs AI, write the owner card before anyone writes code.],
  [Everything is in the repo: decks, code, data, runbooks.],
), contact: [#footer-line])
