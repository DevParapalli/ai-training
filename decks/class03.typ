#import "theme.typ": *

// ---- Class facts: change here, not in the slides ---------------------------
// Measured by code/class03/*.py on data/tickets.csv (seed 20260928). Re-run and
// update if the generator changes. Embedding and LLM figures are illustrative
// until embed_classify.py and llm_classify.py are run with a model and a key.
#let n = 3
#let title = [Classical ML and text]
#let subtitle = [The baseline every AI proposal has to beat, how text becomes numbers, and the mistakes that make a bad model look good.]
#let acc = (baseline: 9, rules: 60, tfidf: 90, handwritten: 71, rules-handwritten: 53, embed: 92, llm: 84)  // % correct
#let biggest-queue = [access-request]
#let p1 = (total: 3000, p1: 33, never: [98.9%])
#let weakest = (queue: [password-reset], recall: [0.76], support: 42)
#let threshold = (at: [0.3], routed: [37%], right: [95%], caught: [4 of 5])   // threshold.py on the handwritten tickets
#let new-ticket = [“Invoices from Armadillo Security Services not showing in InvoiceHub. Batch IH-260301-07.”]
#let sims = (dup: [0.61], status: [0.41], po: [0.19], gl: [0.01])
#let speed = (tfidf: [under 1 ms], embed: [about 20 ms], llm: [about 800 ms])
#let cost = (tfidf: [effectively free], embed: [a few CPU hours], llm: [pay per token])
// -----------------------------------------------------------------------------

#show: class.with(n: n)

#title-slide(number: [#n], title: title, subtitle: subtitle,
  facts: ([60 min], [Recorded], [Class #n of #total-classes]))

#outline-slide(current: none)

#section-slide(number: [1], title: [The baseline], subtitle: [Examples in, a pattern out, and a number to beat.])

#claim(title: [A model learns a mapping from examples, so the examples decide what it can learn])[
  #cols(widths: (1.1fr, 1fr),
    [
      Each old ticket is one example. The *features* are what the model gets to look at: the words, the system named, whether it's period end. The *label* is the right answer: the queue that fixed it.

      If the old labels were sloppy, the model learns the sloppiness too. About 5% of ours are.
    ],
    stack(spacing: 0.35cm,
      tile[*Features* \ "Harbor MDM enrolment stuck for CW-48213" · contingent · portal],
      tile[*Label* \ device-enrolment],
    ),
  )
]

#exhibit(title: [Always guessing the biggest queue gets #acc.baseline%; rules get #acc.rules%; a simple model gets #acc.tfidf%], source: [Measured on the generated ticket set, 600 held-out tickets])[
  #columns-chart(height: 7cm,
    ([Always "#biggest-queue"], acc.baseline, [#acc.baseline%]),
    ([Thirteen keyword rules], acc.rules, [#acc.rules%]),
    ([TF-IDF + logistic regression], acc.tfidf, [#acc.tfidf%]))
  #notes[The word for today is baseline: if a model can't beat it, it doesn't ship. The rules are the ones a support lead writes on day one, in code/class03/classify.py.]
]

#split(title: [Hold back a test set, like an exam nobody has seen], sub: [Split before you look at anything.],
  ([Train on most of it], [80% of the tickets. The model sees these and their answers.]),
  ([Test on the rest], [20% it never saw. The only score that counts.]),
  ([Split by time if time matters], [Train on last year, test on this quarter. That's how it'll be used.]),
)

#explain(title: [Precision and recall ask two different questions, and the cost of a mistake picks one],
  ([Precision], [Of the tickets it sent to payroll, how many were payroll? Favour it when a wrong action costs more than a miss: auto-replies, auto-extensions.]),
  ([Recall], [Of the real payroll mismatches, how many did it catch? Favour it when a miss costs more: P1s, odd readings on integration hosts.]),
  ([Confusion matrix], [The four counts behind both: hits, misses, false alarms, correct passes.]),
)

#section-slide(number: [2], title: [Text into numbers], subtitle: [Computers don't read. They count.])

#claim(title: [Regular expressions handle anything with a fixed shape, and they never guess])[
  #cols(widths: (1fr, 1.1fr),
    [
      #co.short's IDs all follow patterns. A regex finds them exactly, every time, for free.

      Use regex first. Reach for a model only when the shape isn't fixed.
    ],
    stack(spacing: 0.25cm,
      tile[*Ticket* · `TKT-204117`],
      tile[*#app.inv batch* · `IH-260301-07`],
      tile[*Contractor* · `CW-48213`],
    ),
  )
]

#claim(title: [TF-IDF weighs rare words up, and cosine similarity compares two tickets by angle])[
  #cols(widths: (1.1fr, 1fr),
    [
      New ticket: #new-ticket

      Every ticket becomes a list of word weights; "enrolment" counts, "the" doesn't. The PO ticket scores #sims.po only because it names the same supplier: no order, no synonyms.
    ],
    stats(([#sims.dup], [a past "not showing" ticket]), ([#sims.status], [a status check, other wording]), ([#sims.po], [a PO reopen, same supplier])),
  )
]

#claim(title: [Embeddings turn a whole ticket into one vector that keeps its meaning])[
  #cols(widths: (1.1fr, 1fr),
    [
      A transformer reads the ticket in context, every word looking at every other word, and returns one vector. "Import stuck" and "invoices not showing" land close together with no words in common.

      This is what class 5 builds retrieval on.
    ],
    stats(([1,024], [numbers per ticket]), ([#speed.embed], [per ticket on a laptop])),
  )
  #notes[Recurrent networks, attention and encoder versus decoder are in the class 3 deeper-reading handout. For today, one sentence: attention is why it understands context, and why there's a context window (class 4).]
]

#table-slide(title: [On a fixed task with labels, the small models match the LLM for far less], columns: 4,
  header: ([Method], [Accuracy], [Per ticket], [Per 100k tickets]),
  [TF-IDF + LR], [#acc.tfidf%], speed.tfidf, cost.tfidf,
  [Embeddings + LR], [#acc.embed%], speed.embed, cost.embed,
  [LLM, zero-shot], [#acc.llm%], speed.llm, cost.llm,
  source: [TF-IDF measured; other rows illustrative])

#section-slide(number: [3], title: [Mistakes people make], subtitle: [Each one makes a bad model look good.])

#explain(title: [Measuring mistakes: the score lies and nobody notices],
  ([Scoring on training data], [Like marking an exam the students already saw. Fix: split first, look later.]),
  ([Leakage], [The answer sneaks in: "moved to payroll queue" in the text, resolution notes as input. Fix: only use what was known when the prediction is made.]),
  ([Accuracy on uneven classes], [#p1.p1 of #p1.total tickets are P1. "Never P1" scores #p1.never and catches none. Fix: recall on the class that matters.]),
  ([Reading the average], [#weakest.queue has recall #weakest.recall while the average looks fine. Fix: read the report from the worst queue up.]),
)

#explain(title: [Building mistakes: it works in the notebook and fails on the desk],
  ([No baseline], [90% sounds good until "#biggest-queue" every time is on the slide too. Fix: score the dumbest option first.]),
  ([Trusting a clean test set], [Generated tickets score #acc.tfidf%; tickets people really wrote, #acc.handwritten%. Fix: test on real, messy input.]),
  ([Never saying "I don't know"], [It puts the phishing report and the fridge in a queue anyway. Fix: a confidence threshold and a person.]),
  ([Picking a cutoff by eye], [Duplicate and alarm cutoffs are precision versus recall. Fix: choose it on a labelled sample.]),
)

#claim(title: [A confidence threshold turns "always answers" into "answers when it knows"])[
  #cols(widths: (1.1fr, 1fr),
    [
      On the #dataset.handwritten.rows handwritten tickets, routing only when the model's confidence is above #threshold.at sends #threshold.routed automatically, #threshold.right of them correctly. The rest go to a person, including #threshold.caught tickets that belong in no queue.

      Less automation, far fewer wrong answers. That's usually the trade you want.
    ],
    stats(([#acc.handwritten%], [right, routing everything]), ([#threshold.right], [right, above #threshold.at]), ([#threshold.routed], [routed automatically])),
  )
  #notes[One of the five "other" tickets is a fake bank-change email. Routed to invoices, it makes fraud easier. That's why "I don't know" matters.]
]

#section-slide(number: [4], title: [Code walkthrough], subtitle: [A baseline, a model, and a threshold.])

#code-slide(title: [Split first, then the baseline and the real model are one line each], file: "code/class03/classify.py", highlight: (1, 2, 4))[
  ```python
  train, test = train_test_split(df, test_size=0.2, stratify=df.queue, random_state=7)
  baseline = DummyClassifier(strategy="most_frequent").fit(train.text, train.queue)
  model = make_pipeline(TfidfVectorizer(ngram_range=(1, 2), min_df=2),
                        LogisticRegression(max_iter=1000)).fit(train.text, train.queue)
  print(classification_report(test.queue, model.predict(test.text), digits=2))
  ```
]

#code-slide(title: [The threshold is the model's own confidence, compared with a number you chose], file: "code/class03/threshold.py", highlight: (2, 3, 6))[
  ```python
  proba = model.predict_proba(real.text)
  real["pred"] = model.classes_[proba.argmax(axis=1)]
  real["confidence"] = proba.max(axis=1)

  for t in (0.0, 0.2, 0.25, 0.3, 0.4, 0.5):
      auto = real[real.confidence >= t]
  ```
]

#code-slide(title: [Seven patterns pull out most of what a ticket needs, before any model], file: "code/class03/extract.py", highlight: (2, 3, 4))[
  ```python
  PATTERNS = {
      "ticket":   re.compile(r"\bTKT-\d{6}\b"),
      "shipment": re.compile(r"\bLOL-SH-\d{7}\b"),
      "batch":    re.compile(r"\bIH-\d{6}-\d{2}\b"),
      # ... po, worker, error, account
  }
  ```
]

#explain(title: [In the handout: what we skipped today, each with code to run],
  ([Forecasting], [Ticket volume around period close. `forecast.py`]),
  ([Anomaly detection], [Odd readings on the integration hosts, with no labels. `signals.py`]),
  ([Duplicates and embeddings], [TF-IDF duplicates, local embeddings, the LLM on the same tickets. `duplicates.py`, `embed_classify.py`, `llm_classify.py`]),
  ([How transformers work], [From word counts to attention. Reading only.]),
)

#on-the-card(at: (2, 3, 4))

#close(actions: (
  [Run `classify.py` and `threshold.py`, and pick the threshold you'd ship.],
  [Work through the class 3 handout: `docs/deeper/class03`.],
  [Read the class 4 pre-reading on tokens and schemas.],
), contact: [Questions after class: the course channel.])
