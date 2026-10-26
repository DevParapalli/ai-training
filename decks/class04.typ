#import "theme.typ": *

// ---- Class facts: change here, not in the slides ---------------------------
// Token counts are approximate (o200k_base); run code/class04/tokens.py for exact
// ones. Policies live in course.typ (policies, reference-policies).
#let n = 4
#let title = [LLMs in practice]
#let subtitle = [What a model actually reads, how to get output a program can trust, and what data may go near it.]
#let tokens = (
  ([Invoices from Armadillo Security Services not showing in InvoiceHub.], [13]),
  ([Bayerische Unfug Maschinen], [7]),
  ([LOL-SH-4472190], [8]),
)
#let window = (tokens: [128,000], pages: [about 300 pages])
#let made-up-q = [What is the status of shipment LOL-SH-4472190 at Nhava Sheva?]
#let made-up-a = [“LOL-SH-4472190 cleared customs at Nhava Sheva on 12 June and is out for delivery to the consignee.”]
#let ticket = [Bill of entry rejected at Nhava Sheva for LOL-SH-4472190, consignee GST number missing on invoice.]
#let retries = 3
#let example-tickets = (
  ([TKT-418141], [Armadillo returned two driver checks as "inconclusive"], [ASS Restricted], [No AI tool at all]),
  ([TKT-418212], [A deduction on one employee's payslip], [LOL Highly Confidential], [ServiceDesk AI or Lighthouse]),
  ([TKT-418087], [Customs docs rejected for a Kestrel shipment], [LOL Internal], [Any directory tool]),
)
// -----------------------------------------------------------------------------

#show: class.with(n: n)

#title-slide(number: [#n], title: title, subtitle: subtitle,
  facts: ([60 min], [Recorded], [Class #n of #total-classes]))

#outline-slide(current: none)

#section-slide(number: [1], title: [What the model sees], subtitle: [Tokens, the context window, temperature.])

#claim(title: [A model reads tokens, not words, and predicts the next one])[
  #cols(widths: (1.2fr, 1fr),
    [
      Text is chopped into pieces. Common English words are one piece; names, IDs and German are several. Tokens are what you pay for and what the context window is measured in.

      Every answer is one token at a time, each picked from a list of likely next tokens. That's the whole trick.
    ],
    stack(spacing: 0.25cm, ..tokens.map(((t, c)) => tile[#text(size: 0.85em, t) \ *#c tokens*])),
  )
]

#claim(title: [The context window is the model's whole world for one request])[
  #cols(widths: (1.1fr, 1fr),
    [
      Instructions, the ticket, pasted documents, the chat so far and the answer all have to fit. Anything outside doesn't exist for the model. It doesn't remember yesterday unless you send it again.

      Overflow gives an error, or worse, a quiet cut of the start.
    ],
    stats(([#window.tokens], [tokens, a common size]), ([#window.pages], [of plain text])),
  )
]

#claim(title: [Ask about something it can't know, and it answers anyway])[
  #cols(widths: (1fr, 1.1fr),
    [
      *We asked:* #made-up-q

      It has never seen #app.track. It's built to produce likely text, not true text, and a date and a place look likely.

      Temperature 0 for anything a program reads. Higher only for drafts a person edits.
    ],
    tile[*It said:* \ #made-up-a],
  )
]

#section-slide(number: [2], title: [Output a program can trust], subtitle: [Ask well, define the shape, validate, retry, hand over.])

#explain(title: [A prompt has parts, and two good examples beat a paragraph of instructions],
  ([System message], [Who it is and the rules: "You triage tickets for LOL. Never invent shipment IDs."]),
  ([User message], [The job this time: the ticket, the question.]),
  ([Examples], [Two or three solved hard cases. The vague "Account locked" teaches more than another clear one.]),
  ([Context], [Documents and data it wasn't trained on. Class 5.]),
)

#code-slide(title: [If code reads the answer, a schema defines its shape: fields, types, allowed values], file: "code/class04/extract_json.py", highlight: (2, 3, 5))[
  ```python
  class Triage(BaseModel):
      queue: Queue                  # one of our 18 queues, or "other"
      shipment_id: str | None       # LOL-SH-1234567, if the ticket names one
      site: str | None              # Hamburg, Rotterdam, Memphis, ...
      blocking: bool                # is someone unable to work right now?
      summary: str                  # one sentence, plain English
  ```
]

#steps-slide(title: [When the reply doesn't validate, tell the model why, and stop after #retries tries],
  [Validate the reply against the schema],
  [On failure, send back the exact error],
  [Ask again, temperature 0],
  [After #retries tries, hand it to a person])

#section-slide(number: [3], title: [Rules for data], subtitle: [Every prompt leaves the building, unless it doesn't.])

#explain(title: [Every approved tool has a ceiling; nothing above it goes in],
  ..policies.lol.tools.map(((t, lim)) => (t, lim)))

#table-slide(title: [Three tickets from this month, and where each one may go], columns: (auto, 1fr, auto, auto), align: left,
  header: ([Ticket], [What it's about], [Class], [Allowed tools]),
  ..example-tickets.flatten())

#claim(title: [The real policies look a lot like ours, and they're the ones you follow])[
  #cols(..reference-policies.map(p => tile[
    *#p.who* \
    #for pt in p.points [- #pt]
  ]))
  #notes[Swap reference-policies in course.typ per audience. #bum.short (no written policy) and #ass.short (strict, background checks never go in any tool) are in the handout.]
]

#section-slide(number: [4], title: [Mistakes people make], subtitle: [Most of them are "prompt harder".])

#explain(title: [Prompting mistakes: rewording what wording can't fix],
  ([Prompting for missing knowledge], [It can't know shipment status or our runbooks. Fix: give it the data or a tool (class 5).]),
  ([Arithmetic in the model], [It predicts digits. Totals, FX and variances go to code.]),
  ([Parsing free text], [A regex over a chatty reply breaks on the first "Sure! Here's...". Fix: a schema and validation.]),
  ([Retrying forever, or guessing on failure], [Fix: a retry cap, then a person. Never a default queue.]),
)

#explain(title: [Data mistakes: the prompt went somewhere it shouldn't],
  ([Pasting before classifying], [Once it's sent, it's sent. Fix: class first, then the gate, then the prompt.]),
  ([Trusting regex redaction], [It catches emails and IBANs, not "the driver whose check came back inconclusive". Redaction lowers risk; the gate decides.]),
  ([Forgetting training data], [Ticket history holds payslips and bank details. Redact before training, the same as before prompting.]),
  ([Never counting tokens], [Silent truncation drops the start, and the answer still sounds sure. Fix: count before you send.]),
)

#section-slide(number: [5], title: [Code walkthrough], subtitle: [Tokens, the retry loop, and the gate.])

#code-slide(title: [Counting tokens takes three lines, so there's no excuse not to], file: "code/class04/tokens.py", highlight: (1, 3))[
  ```python
  enc = tiktoken.get_encoding("o200k_base")
  for s in SAMPLES:
      ids = enc.encode(s)
      print(f"{len(ids):>3} tokens  {s}")
  ```
]

#code-slide(title: [The retry loop ends with a person, not a guess], file: "code/class04/extract_json.py", highlight: (5, 6, 7))[
  ```python
  def triage(ticket: str, attempts: int = 3) -> Triage:
      prompt = f"{SYSTEM}\n\nTicket:\n{ticket}"
      for _ in range(attempts):
          raw = ask(prompt, temperature=0)
          try: return Triage.model_validate_json(raw)
          except ValidationError as err:
              prompt += f"\n\nYour last reply was invalid:\n{err}\nReply again with valid JSON only."
      raise RuntimeError("no valid reply after retries; send to a person")
  ```
]

#code-slide(title: [The gate refuses anything unclassified, and anything above the tool's ceiling], file: "code/class04/gate.py", highlight: (2, 3, 4, 5))[
  ```python
  def allowed(tool: str, data_class: str | None) -> bool:
      if data_class not in LEVELS:                    # unclassified: refuse, don't guess
          return False
      limit = DIRECTORY.get(tool, "LOL Public")       # anything not in the directory
      return LEVELS.index(data_class) <= LEVELS.index(limit)
  ```
]

#explain(title: [In the handout: what we skipped today, each with code to run],
  ([Temperature and overflow], [See the spread, and see what your provider does at the limit. `temperature.py`, `overflow.py`, `made_up.py`]),
  ([Few-shot prompting], [Zero-shot against hard-case examples on the handwritten tickets. `few_shot.py`]),
  ([Running a model yourself], [Point `LLM_BASE_URL` at a local server; memory is the limit.]),
  ([Redaction and the frameworks], [`redact.py`, partner policies, EU AI Act, NIST AI RMF, ISO/IEC 42001, DPDP.]),
)

#on-the-card(at: (5,))

#close(actions: (
  [Run `extract_json.py` on five handwritten tickets and note any retries.],
  [Work through the class 4 handout: `docs/deeper/class04`.],
  [Read the class 5 pre-reading on retrieval and tools.],
), contact: [Questions after class: the course channel.])
