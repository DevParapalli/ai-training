#import "theme.typ": *

// ---- Class facts: change here, not in the slides ---------------------------
// Policies live in course.typ (policies, reference-policies). Swap the reference
// policies per audience; the LOL, BUM and ASS ones are part of the story.
#let n = 8
#let title = [Rules for data]
#let subtitle = [Before any of our data goes near a model: what may go where, and how we make sure it doesn't go anywhere else.]
#let example-tickets = (
  ([TKT-418141], [Armadillo returned two driver checks as "inconclusive"], [ASS Restricted], [No AI tool at all]),
  ([TKT-418212], [A deduction on one employee's payslip], [LOL Highly Confidential], [ServiceDesk AI or Lighthouse]),
  ([TKT-418087], [Customs docs rejected for a Kestrel shipment], [LOL Internal], [Any directory tool]),
  ([TKT-418255], [Suspicious bank-change email from "Drymark"], [LOL Confidential], [Lighthouse, or a local model]),
)
// -----------------------------------------------------------------------------

#show: class.with(n: n)

#title-slide(number: [#n], title: title, subtitle: subtitle,
  facts: ([60 min], [Recorded], [Class #n of #total-classes]))

#outline-slide(current: none)

#section-slide(number: [1], title: [Why this comes first], subtitle: [Everything from here on sends data somewhere.])

#statement(sub: [A prompt is a copy of our data, sent to someone else's computer, unless we decide otherwise.])[Every prompt #hl[leaves the building], unless it doesn't.]

#split(title: [Three companies, three very different attitudes], sub: [We're in the middle, and we work with both ends.],
  ([#policies.lol.who], [#policies.lol.stance]),
  ([#policies.bum.who], [#policies.bum.stance]),
  ([#policies.ass.who], [#policies.ass.stance]),
)

#section-slide(number: [2], title: [Our policy at #co.short], subtitle: [A directory of tools, each with a ceiling.])

#claim(title: [We sort data into five classes, from Public to Restricted])[
  #cols(..policies.lol.classes.enumerate().map(((i, c)) => tile[#text(size: 1.4em, weight: 300)[#(i + 1)] \ *#c*]))
  #v(0.6em)
  Payslips, bank details and background checks sit at the top. Shipment tracking for a customer who already knows about it sits near the bottom.
]

#explain(title: [Every approved tool has a ceiling; nothing above it goes in],
  ..policies.lol.tools.map(((t, lim)) => (t, lim)))

#table-slide(title: [Four tickets from this month, and where each one may go], columns: (auto, 1fr, auto, auto), align: left,
  header: ([Ticket], [What it's about], [Class], [Allowed tools]),
  ..example-tickets.flatten())

#section-slide(number: [3], title: [The people we work with], subtitle: [Their data comes with their rules.])

#split(title: [#bum.name: no written policy], sub: [#policies.bum.stance],
  ([What that means for them], [Their staff can put our rate cards or our emails into Copilot, and nothing stops it.]),
  ([What that means for us], [Nothing changes on our side. #policies.bum.note]),
  ([What we don't do], [Assume their shipping documents are fine to paste anywhere because they're "only BUM's".]),
)

#claim(title: [#ass.name: strict, and their rules follow their data into our systems])[
  #cols(widths: (1fr, 1fr),
    [
      #for c in policies.ass.classes [#c \ ]
    ],
    [
      #for r in policies.ass.rules [- #r]
    ],
  )
  #notes[Background check results arrive in our tickets (TKT-418141, TKT-418199). They're ASS Restricted when they arrive and they stay that way. No AI tool, including ours.]
]

#section-slide(number: [4], title: [For reference: the real ones], subtitle: [The policies that apply to the people in this room.])

#claim(title: [The real policies look a lot like the ones we made up])[
  #cols(..reference-policies.map(p => tile[
    *#p.who* \
    #for pt in p.points [- #pt]
  ]))
  #notes[Swap reference-policies in course.typ for each audience. Keep this to one slide; the class is about the habit, not the rulebook.]
]

#explain(title: [Where the public frameworks sit],
  ([EU AI Act], [Sorts AI uses by risk, from banned to minimal. Obligations are being phased in from 2025.]),
  ([NIST AI RMF], [A voluntary US framework: govern, map, measure, manage. Good as a checklist.]),
  ([ISO/IEC 42001], [A certifiable management system for AI, like ISO 27001 for security.]),
  ([India's DPDP Act], [Personal data protection. Applies to employee and customer data we hold.]),
)

#section-slide(number: [5], title: [Making it stick], subtitle: [Redact before the prompt, and a gate that says no.])

#steps-slide(title: [Every call to a model goes through the same four checks],
  [Classify the data, or refuse],
  [Redact what the tool may not see],
  [Check the tool's ceiling],
  [Log what was sent, and where])

#claim(title: [The same rules apply to training data, not only to prompts])[
  - Ticket history has payslip complaints, bank details and background checks in it
  - A model trained on it can repeat what it saw
  - Redact before training, the same way as before prompting
  #notes[The class 3 classifier trained on generated data. On real history, redact first.]
]

#section-slide(number: [6], title: [Code walkthrough], subtitle: [Redaction and the gate.])

#code-slide(title: [Redaction swaps what must not leave for a placeholder the model can still reason about], file: "code/class08/redact.py", highlight: (2, 3, 4, 5, 6))[
  ```python
  RULES = [
      (re.compile(r"[\w.+-]+@[\w-]+(?:\.[\w-]+)+"), "<email>"),
      (re.compile(r"\b[A-Z]{2}\d{2}(?:\s?[A-Z0-9]{1,4}){3,8}\b"), "<iban>"),
      (re.compile(r"\bE\d{6}\b"), "<employee-id>"),
      (re.compile(r"\bCW-\d{5}\b"), "<contractor-id>"),
      (re.compile(r"\+?\d[\d\s-]{8,}\d"), "<phone>"),
  ]
  ```
]

#code-slide(title: [The gate refuses anything unclassified, and anything above the tool's ceiling], file: "code/class08/gate.py", highlight: (2, 3, 4, 5))[
  ```python
  def allowed(tool: str, data_class: str | None) -> bool:
      if data_class not in LEVELS:                    # unclassified: refuse, don't guess
          return False
      limit = DIRECTORY.get(tool, "LOL Public")       # anything not in the directory
      return LEVELS.index(data_class) <= LEVELS.index(limit)
  ```
]

#claim(title: [Regex redaction catches the shapes, and misses everything else])[
  #cols(widths: (1.1fr, 1fr),
    [
      It finds emails, IBANs, employee and contractor IDs, phone numbers. It won't find "the driver whose check came back inconclusive" or a name typed in lowercase.

      So redaction lowers the risk. The gate and the data class decide whether the text goes at all.
    ],
    tile[*Before* \ Employee E204518, +44 7700 900123, DE89 3704 0044 0532 0130 00 \ *After* \ Employee \<employee-id\>, \<phone\>, \<iban\>],
  )
]

#on-the-card(at: (), title: [This class isn't a place on the card; it's the gate in front of places 3 to 6])

#close(actions: (
  [Find three tickets in the handwritten set that must never reach an AI tool, and say why.],
  [Add a pattern to `redact.py` for shipment IDs, then decide whether it should be there.],
  [Read the class 9 pre-reading on embeddings.],
), contact: [Questions after class: the course channel.])
