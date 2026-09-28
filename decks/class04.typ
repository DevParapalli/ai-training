#import "theme.typ": *

// ---- Class facts: change here, not in the slides ---------------------------
// Weights and similarities measured by code/class04/duplicates.py on data/tickets.csv.
#let n = 4
#let title = [Turning text into numbers]
#let subtitle = [NLP, part 1. Everything a model does with text starts by counting something.]
#let weights-ticket = [“Harbor MDM enrolment stuck. Laptop for CW-48213 shows enrolment pending in Harbor for two days. Can't access anything until it completes.”]
#let weights = (([enrolment], 42, [0.42]), ([harbor], 42, [0.42]), ([pending], 27, [0.27]), ([anything], 23, [0.23]), ([laptop], 18, [0.18]), ([the], 0, [0.00]))
#let new-ticket = [“Invoices from Armadillo Security Services not showing in InvoiceHub. Batch IH-260301-07.”]
#let sims = (dup: [0.61], status: [0.41], po: [0.19], gl: [0.01])
#let cutoffs = (([0.8], [0 matches]), ([0.6], [2 matches]), ([0.4], [9 matches]))
// -----------------------------------------------------------------------------

#show: class.with(n: n)

#title-slide(number: [#n], title: title, subtitle: subtitle,
  facts: ([60 min], [Recorded], [Class #n of #total-classes]))

#outline-slide(current: none)

#section-slide(number: [1], title: [Why text is hard], subtitle: [Three problems every method tries to solve.])

#statement(sub: [Every method in this class and the next is a better answer to the question "which numbers?"])[Computers don't read. #hl[They count.]]

#explain(title: [Text is hard for three reasons, and each method handles them differently],
  ([Same word, different meaning], ["The close is down to two accounts" versus "#app.gl is down". One is progress, one is an outage.]),
  ([Different words, same meaning], ["Invoices not showing", "import stuck", "has the batch finished". Three phrasings, one queue.]),
  ([Order changes meaning], ["Reopen failed after receipt" versus "receipt failed after reopen". Same words, different fix.]),
)

#section-slide(number: [2], title: [From text to tokens], subtitle: [Cleaning, splitting, and pulling out the things with a fixed shape.])

#steps-slide(title: [Cleaning a ticket comes before any counting],
  [Strip signatures and quoted replies],
  [Normalise case where it doesn't carry meaning],
  [Split into tokens: words or word pieces],
  [Replace IDs and amounts with placeholders],
  [Keep a copy of the original text])

#claim(title: [Regular expressions handle anything with a fixed shape, and they never guess])[
  #cols(widths: (1fr, 1.1fr),
    [
      #co.short's IDs all follow patterns: tickets, purchase orders, #app.inv batches, contractor IDs, error codes. A regex finds them exactly, every time, for free.

      Use regex first. Only reach for a model when the shape isn't fixed.
    ],
    stack(spacing: 0.25cm,
      tile[*Ticket* · `TKT-204117`],
      tile[*Purchase order* · `PO-4500318822`],
      tile[*#app.inv batch* · `IH-260301-07`],
      tile[*Contractor* · `CW-48213`],
    ),
  )
]

#section-slide(number: [3], title: [Counting words], subtitle: [Bag of words, TF-IDF and similarity.])

#table-slide(title: [A bag of words counts each word and forgets the order], columns: 5,
  header: ([Ticket], [import], [invoice], [reopen], [failed]),
  [A · "Invoice import from ASS stuck, import shows error"], [2], [1], [0], [0],
  [B · "Reopen failed after the invoice posted"], [0], [1], [1], [1],
  [C · "Receipt failed after reopen"], [0], [0], [1], [1])

#exhibit(title: [TF-IDF gives rare words more weight, so "enrolment" counts and "the" doesn't], source: [Weights for one ticket, measured on the synthetic set])[
  #text(size: 0.8em, fill: gray)[#weights-ticket]
  #v(0.3em)
  #bars-chart(..weights)
]

#claim(title: [Similar tickets point in similar directions, and cosine similarity measures the angle])[
  #cols(widths: (1.1fr, 1fr),
    [
      New ticket: #new-ticket

      Once each ticket is a list of weights, two tickets can be compared by the angle between them. Note the PO ticket scoring #sims.po only because it names the same supplier.
    ],
    stats(([#sims.dup], [a past "not showing" ticket]), ([#sims.status], [a status check, other wording]), ([#sims.po], [a PO reopen, same supplier]), ([#sims.gl], [a GL reconciliation])),
  )
]

#section-slide(number: [4], title: [Words as positions], subtitle: [Word vectors, and where each method falls over.])

#claim(title: [Word vectors put words with similar meanings close together])[
  #cols(widths: (1.1fr, 1fr),
    [
      Train on enough text and every word gets a position in a few hundred dimensions. Words used in the same places end up near each other.

      Now "import stuck" and "invoices not showing" can match even with no words in common.
    ],
    stack(spacing: 0.3cm,
      tile[*import* · upload · load · batch · feed],
      tile[*reopen* · unclose · reactivate · amend],
    ),
  )
  #notes[The catch: one vector per word. "Down" gets the same vector in "#app.gl is down" and "down to two accounts". Class 5 fixes that.]
]

#explain(title: [Each method fixes one problem and leaves another],
  ([Regex], [Exact and free. Misses anything not in the pattern.]),
  ([Bag of words], [Simple and fast. Ignores order and treats synonyms as unrelated.]),
  ([TF-IDF], [Weighs what matters. Still no order, still no synonyms, and fooled by shared names.]),
  ([Word vectors], [Understands synonyms. One meaning per word, whatever the sentence.]),
)

#section-slide(number: [5], title: [Code walkthrough], subtitle: [Pull IDs out of tickets, then find duplicates.])

#code-slide(title: [Seven patterns pull out most of what a ticket needs], file: "code/class04/extract.py", highlight: (2, 3, 4, 5))[
  ```python
  PATTERNS = {
      "ticket":  re.compile(r"\bTKT-\d{6}\b"),
      "shipment": re.compile(r"\bLOL-SH-\d{7}\b"),
      "po":      re.compile(r"\bPO-4500\d{6}\b"),
      "batch":   re.compile(r"\bIH-\d{6}-\d{2}\b"),
      "worker":  re.compile(r"\bCW-\d{5}\b"),
      "error":   re.compile(r"\bERR-[A-Z]{2}-\d{4}\b"),
      "account": re.compile(r"\b\d{4}-\d{2}\b"),
  }
  ```
]

#code-slide(title: [TF-IDF plus cosine similarity finds duplicates in a few lines], file: "code/class04/duplicates.py", highlight: (1, 2, 3))[
  ```python
  vec = TfidfVectorizer(ngram_range=(1, 2), min_df=2).fit(df.text)
  sims = cosine_similarity(vec.transform([NEW]), vec.transform(df.text))[0]
  likely = df[sims > CUTOFF].assign(score=sims[sims > CUTOFF]).sort_values("score")
  ```
]

#claim(title: [The cutoff is a precision and recall choice, the same one from class 3])[
  #cols(widths: (1.1fr, 1fr),
    [
      - *Raise it* and you get fewer suggestions, nearly all real duplicates
      - *Lower it* and you catch more, with more noise
      - Pick it on a labelled sample, never by eye
    ],
    stats(..cutoffs),
  )
]

#on-the-card(at: (2, 3))

#close(actions: (
  [Run `code/class04/extract.py` and add a pattern for invoice numbers.],
  [Try three cutoffs in `duplicates.py` and note what changes.],
  [Read the class 5 pre-reading on attention.],
), contact: [Questions after class: the course channel.])
