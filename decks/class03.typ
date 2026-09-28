#import "theme.typ": *

// ---- Class facts: change here, not in the slides ---------------------------
// Measured by code/class03/*.py on data/tickets.csv (seed 20260928). Re-run and
// update if the generator changes.
#let n = 3
#let title = [Classical ML, done properly]
#let subtitle = [The baseline every AI proposal has to beat, and how to measure it without fooling yourself.]
#let acc = (baseline: 9, rules: 60, tfidf: 90, handwritten: 71, rules-handwritten: 53)          // % on the 600-ticket test set
#let biggest-queue = [access-request]
#let p1 = (total: 3000, p1: 33, never: [98.9%])
#let weakest = (queue: [password-reset], recall: [0.76], support: 42)
#let cm = (tp: 23, fn: 2, fp: 3, tn: 572)                // payroll-mismatch against the rest, measured
#let volume = (normal: [5.4], close: [12.2])              // tickets per weekday
#let faults = (flagged: 101, injected: 52, caught: 52)
// -----------------------------------------------------------------------------

#show: class.with(n: n)

#title-slide(number: [#n], title: title, subtitle: subtitle,
  facts: ([60 min], [Recorded], [Class #n of #total-classes]))

#outline-slide(current: none)

#section-slide(number: [1], title: [What a model learns from], subtitle: [Examples in, a pattern out.])

#claim(title: [A model learns a mapping from examples, so the examples decide what it can learn])[
  #cols(widths: (1.1fr, 1fr),
    [
      Each old ticket is one example. The *features* are what the model gets to look at: the words, the system named, whether it's period end. The *label* is the right answer: the queue that fixed it.

      Training finds weights that turn features into labels. If the old labels were sloppy, the model learns the sloppiness too. About 5% of ours are.
    ],
    stack(spacing: 0.35cm,
      tile[*Features* \ "Harbor MDM enrolment stuck for CW-48213" · contingent · portal],
      tile[*Label* \ cw-device],
    ),
  )
]

#display-slide(title: [The word for today], sub: [If a model can't beat this, it doesn't ship])[Baseline]

#exhibit(title: [Always guessing the biggest queue gets #acc.baseline%; rules get #acc.rules%; a simple model gets #acc.tfidf%], source: [Measured on the generated ticket set, 600 held-out tickets])[
  #columns-chart(height: 7cm,
    ([Always "#biggest-queue"], acc.baseline, [#acc.baseline%]),
    ([Nine keyword rules], acc.rules, [#acc.rules%]),
    ([TF-IDF + logistic regression], acc.tfidf, [#acc.tfidf%]))
  #notes[The rules are the ones a support lead would write on day one. They're in code/class03/classify.py. 80% from nine lines is a strong result; say so.]
]

#section-slide(number: [2], title: [Measuring it honestly], subtitle: [Most bad models look great on the data they were trained on.])

#split(title: [Hold back a test set, like an exam you haven't seen], sub: [Split before you look at anything.],
  ([Train on most of it], [80% of the tickets. The model sees these examples and their answers.]),
  ([Test on the rest], [20% it never saw. This is the only score that counts.]),
  ([Split by time if time matters], [Train on last year, test on this quarter. That's how it'll be used.]),
)

#claim(title: [Leakage is when the answer sneaks into the training data, and the score lies])[
  #cols(
    [
      - The description says "moved to the invoice queue"
      - Resolution notes, written after the fact, are used as input
      - The same ticket appears twice, once on each side of the split
    ],
    [
      Each one makes the test score look excellent and the live results poor.

      *Rule of thumb:* only use what was known at the moment the prediction would be made.
    ],
  )
]

#claim(title: [#p1.never accuracy means nothing when almost no tickets are P1])[
  #cols(widths: (1fr, 1.1fr),
    [
      Out of #p1.total tickets, #p1.p1 are P1, nearly all payroll mismatches. A model that always says "not P1" is right #p1.never of the time.

      It has never caught a single P1.
    ],
    stats(([#p1.total], [tickets]), ([#p1.p1], [actually P1]), ([#p1.never], [accuracy of "never P1"]), ([0], [P1s caught])),
  )
]

#explain(title: [Precision and recall ask two different questions],
  ([Precision], [Of the tickets it sent to payroll, how many really were payroll? Low precision wastes analysts' time.]),
  ([Recall], [Of the real payroll mismatches, how many did it send there? Low recall means an RCA starts late.]),
  ([F1], [One number that balances the two. Useful for comparing; hides which one is weak.]),
  ([Confusion matrix], [The four counts behind all of it: hits, misses, false alarms, correct passes.]),
)

#table-slide(title: [The confusion matrix is four counts, and every metric comes from them], columns: 3,
  header: ([], [Predicted payroll], [Predicted other]),
  [Actually payroll], [#cm.tp · caught], [#cm.fn · missed],
  [Actually other], [#cm.fp · false alarm], [#cm.tn · correct pass],
  source: [Test set, payroll-mismatch against everything else])

#compare(title: [Which one to favour depends on what a mistake costs],
  left: ([Favour recall], [
    - Payroll mismatches and P1s
    - Odd readings on the integration hosts
    - A miss costs more than a false alarm
  ]),
  right: ([Favour precision], [
    - Auto-replying to #app.inv status checks
    - Auto-extending #app.cw accounts
    - A wrong action costs more than a miss
  ]),
)

#section-slide(number: [3], title: [Two more jobs classical ML does well], subtitle: [Finding the odd one out, and saying what comes next.])

#claim(title: [Anomaly detection found every injected fault in the host signal feed, with no labels])[
  #cols(widths: (1.1fr, 1fr),
    [
      Our monitoring sends hourly CPU, memory and job latency for 60 integration hosts. An isolation forest keeps splitting the data at random; readings that get separated in very few splits are the odd ones.

      Nobody had to write a threshold for each host.
    ],
    stats(([#faults.flagged], [readings flagged]), ([#faults.caught / #faults.injected], [injected faults caught])),
  )
  #notes[About half the flags are real faults, half are busy hours that look unusual. That's the precision trade-off again. Show code/class03/signals.py.]
]

#claim(title: [Ticket volume doubles around period close, so a forecast has to know the calendar])[
  #cols(widths: (1.1fr, 1fr),
    [
      #app.gl, payroll and #sc.short billing tickets pile up in the last two days of the month and the first three of the next. A seasonal model learns the weekly shape and the close spike.

      The baseline to beat is simple: this close looks like last close.
    ],
    stats(([#volume.normal], [tickets a normal weekday]), ([#volume.close], [tickets a close weekday])),
  )
]

#compare(title: [Classical ML beats an LLM when the input is structured and the volume is high], pick: "left",
  left: ([Classical ML], [
    - Fractions of a cent per million predictions
    - Milliseconds, runs on a laptop CPU
    - Same input, same answer, every time
    - Weights you can inspect
  ]),
  right: ([LLM], [
    - Cost per call, every call
    - Hundreds of milliseconds to seconds
    - Answers vary between runs
    - Hard to explain a single decision
  ]),
)

#steps-slide(title: [Building a classical model always follows the same six steps],
  [Collect labelled history],
  [Split before looking],
  [Score the baseline],
  [Train a simple model],
  [Measure on the test set],
  [Decide: ship, improve, or stop])

#section-slide(number: [4], title: [Code walkthrough], subtitle: [A ticket classifier in scikit-learn, scored against the baseline and the rules.])

#code-slide(title: [Split first, and keep the queue mix the same on both sides], file: "code/class03/classify.py", highlight: (2,))[
  ```python
  df = tickets()
  train, test = train_test_split(df, test_size=0.2, stratify=df.queue, random_state=7)
  ```
]

#code-slide(title: [The rules a support lead would write on day one are nine regular expressions], file: "code/class03/classify.py", highlight: (2, 3))[
  ```python
  RULES = [
      (r"password|locked out|account locked", "password-reset"),
      (r"invoicehub|invoice import|batch ih-", "invoice-import-status"),
      (r"reopen|closed too early|po-4500", "po-reopen"),
      (r"harbor|enrol|lol image", "cw-device"),
      (r"payroll|paygrid", "payroll-mismatch"),
      # ... four more
  ]
  ```
]

#code-slide(title: [The baseline and the real model are each one line], file: "code/class03/classify.py", highlight: (1, 2, 3))[
  ```python
  baseline = DummyClassifier(strategy="most_frequent").fit(train.text, train.queue)
  model = make_pipeline(TfidfVectorizer(ngram_range=(1, 2), min_df=2),
                        LogisticRegression(max_iter=1000)).fit(train.text, train.queue)
  print(classification_report(test.queue, model.predict(test.text)))
  ```
]

#claim(title: [Read the report from the worst queue up, not from the average down])[
  - The weakest queue is *#weakest.queue*, with recall #weakest.recall on #weakest.support test tickets
  - Those are the vague ones: "Account locked" with no system named, so it looks like an access request
  - Compare the overall score to the baseline before saying anything is good
  #notes[Show the report live. Point at payroll first, then the average.]
]

#claim(title: [On tickets written the way people actually write, it drops to #acc.handwritten%, and it never says "I don't know"])[
  #cols(widths: (1fr, 1.1fr),
    [
      We wrote #dataset.handwritten.rows tickets by hand, across the whole company: one-word titles, typos, two problems in one, forwarded chains. The model trained on the generated set gets #acc.handwritten% of them. The day-one rules get #acc.rules-handwritten%.

      The five that belong in no queue, a test ticket, a phishing report, a suspicious bank-change email, it puts in one anyway.
    ],
    stack(spacing: 0.3cm,
      tile[*"Vendor bank change request"* (a fraud attempt) \ went to invoice-import],
      tile[*"Break room fridge"* \ went to ledger-close],
      tile[*"Payroll - Leeds double payment"* \ went to customer-payments],
    ),
  )
  #notes[Run code/class03/handwritten.py live. The fix for "not ours" tickets is a confidence threshold plus a person, not a better model. The bank-change one matters: it should have gone to security, and a model that routes it to invoices makes fraud easier.]
]

#on-the-card(at: (3,))

#close(actions: (
  [Run `code/class03/classify.py` and find the weakest queue on your machine.],
  [Change the split to time-based and see what happens to the score.],
  [Read the class 4 pre-reading on regular expressions.],
), contact: [Questions after class: the course channel.])
