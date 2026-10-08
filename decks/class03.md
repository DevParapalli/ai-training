---
theme: ../../proxima/deck
title: Building the Right AI System, class 3
colorSchema: dark
themeConfig:
  accent: indigo
  label: Building the Right AI System
  date: Class 3 of 15
  presenter: © 2026 Devansh Parapalli
layout: cover
number: 3
facts: [60 min, Recorded, Class 3 of 15]
---

<!-- Web build of decks/class03.typ with slidev-theme-proxima. The Typst deck is the
print source; figures below are the class facts from its #let block (measured by
code/class03/*.py on data/tickets.csv, seed 20260928). -->

# Classical ML, done properly

The baseline every AI proposal has to beat, and how to measure it without fooling yourself.

---
layout: outline
---

# What this session covers

---
layout: section
---

# What a model learns from

Examples in, a pattern out.

---

# A model learns a mapping from examples, so the examples decide what it can learn

<Cols widths="1.1fr 1fr">
<Col>

Each old ticket is one example. The **features** are what the model gets to look at: the words, the system named, whether it's period end. The **label** is the right answer: the queue that fixed it.

Training finds weights that turn features into labels. If the old labels were sloppy, the model learns the sloppiness too. About 5% of ours are.

</Col>
<Col>
<Tile>

**Features**<br>"Harbor MDM enrolment stuck for CW-48213" · contingent · portal

</Tile>
<Tile>

**Label**<br>cw-device

</Tile>
</Col>
</Cols>

---
layout: display
---

# The word for today

If a model can't beat this, it doesn't ship

## Baseline

---
layout: exhibit
source: Measured on the generated ticket set, 600 held-out tickets
---

# Always guessing the biggest queue gets 9%; rules get 60%; a simple model gets 90%

<ColumnsChart :height="203" :items="[['Always &quot;access-request&quot;', 9, '9%'], ['Nine keyword rules', 60, '60%'], ['TF-IDF + logistic regression', 90, '90%']]" />

<!--
The rules are the ones a support lead would write on day one. They're in code/class03/classify.py. 80% from nine lines is a strong result; say so.
-->

---
layout: section
---

# Measuring it honestly

Most bad models look great on the data they were trained on.

---
layout: split
---

# Hold back a test set, like an exam you haven't seen

Split before you look at anything.

1. **Train on most of it** 80% of the tickets. The model sees these examples and their answers.
2. **Test on the rest** 20% it never saw. This is the only score that counts.
3. **Split by time if time matters** Train on last year, test on this quarter. That's how it'll be used.

---

# Leakage is when the answer sneaks into the training data, and the score lies

<Cols>
<Col>

- The description says "moved to the invoice queue"
- Resolution notes, written after the fact, are used as input
- The same ticket appears twice, once on each side of the split

</Col>
<Col>

Each one makes the test score look excellent and the live results poor.

**Rule of thumb:** only use what was known at the moment the prediction would be made.

</Col>
</Cols>

---

# 98.9% accuracy means nothing when almost no tickets are P1

<Cols widths="1fr 1.1fr">
<Col>

Out of 3000 tickets, 33 are P1, nearly all payroll mismatches. A model that always says "not P1" is right 98.9% of the time.

It has never caught a single P1.

</Col>
<Col>
<Stats>
  <Stat value="3000" label="tickets" />
  <Stat value="33" label="actually P1" />
  <Stat value="98.9%" label="accuracy of &quot;never P1&quot;" />
  <Stat value="0" label="P1s caught" />
</Stats>
</Col>
</Cols>

---
layout: explain
---

# Precision and recall ask two different questions

| Precision | Of the tickets it sent to payroll, how many really were payroll? Low precision wastes analysts' time. |
|---|---|
| Recall | Of the real payroll mismatches, how many did it send there? Low recall means an RCA starts late. |
| F1 | One number that balances the two. Useful for comparing; hides which one is weak. |
| Confusion matrix | The four counts behind all of it: hits, misses, false alarms, correct passes. |

---
layout: table
source: Test set, payroll-mismatch against everything else
---

# The confusion matrix is four counts, and every metric comes from them

|  | Predicted payroll | Predicted other |
|---|---|---|
| Actually payroll | 23 · caught | 2 · missed |
| Actually other | 3 · false alarm | 572 · correct pass |

---
layout: compare
---

# Which one to favour depends on what a mistake costs

::left::

## Favour recall

- Payroll mismatches and P1s
- Odd readings on the integration hosts
- A miss costs more than a false alarm

::right::

## Favour precision

- Auto-replying to InvoiceHub status checks
- Auto-extending CW Portal accounts
- A wrong action costs more than a miss

---
layout: section
---

# Two more jobs classical ML does well

Finding the odd one out, and saying what comes next.

---

# Anomaly detection found every injected fault in the host signal feed, with no labels

<Cols widths="1.1fr 1fr">
<Col>

Our monitoring sends hourly CPU, memory and job latency for 60 integration hosts. An isolation forest keeps splitting the data at random; readings that get separated in very few splits are the odd ones.

Nobody had to write a threshold for each host.

</Col>
<Col>
<Stats>
  <Stat value="101" label="readings flagged" />
  <Stat value="52 / 52" label="injected faults caught" />
</Stats>
</Col>
</Cols>

<!--
About half the flags are real faults, half are busy hours that look unusual. That's the precision trade-off again. Show code/class03/signals.py.
-->

---

# Ticket volume doubles around period close, so a forecast has to know the calendar

<Cols widths="1.1fr 1fr">
<Col>

Ledgerline, payroll and S.C. billing tickets pile up in the last two days of the month and the first three of the next. A seasonal model learns the weekly shape and the close spike.

The baseline to beat is simple: this close looks like last close.

</Col>
<Col>
<Stats>
  <Stat value="5.4" label="tickets a normal weekday" />
  <Stat value="12.2" label="tickets a close weekday" />
</Stats>
</Col>
</Cols>

---
layout: compare
pick: left
---

# Classical ML beats an LLM when the input is structured and the volume is high

::left::

## Classical ML

- Fractions of a cent per million predictions
- Milliseconds, runs on a laptop CPU
- Same input, same answer, every time
- Weights you can inspect

::right::

## LLM

- Cost per call, every call
- Hundreds of milliseconds to seconds
- Answers vary between runs
- Hard to explain a single decision

---
layout: steps
---

# Building a classical model always follows the same six steps

1. Collect labelled history
2. Split before looking
3. Score the baseline
4. Train a simple model
5. Measure on the test set
6. Decide: ship, improve, or stop

---
layout: section
---

# Code walkthrough

A ticket classifier in scikit-learn, scored against the baseline and the rules.

---
layout: code
file: code/class03/classify.py
---

# Split first, and keep the queue mix the same on both sides

```python {2}
df = tickets()
train, test = train_test_split(df, test_size=0.2, stratify=df.queue, random_state=7)
```

---
layout: code
file: code/class03/classify.py
---

# The rules a support lead would write on day one are nine regular expressions

```python {2,3}
RULES = [
    (r"password|locked out|account locked", "password-reset"),
    (r"invoicehub|invoice import|batch ih-", "invoice-import-status"),
    (r"reopen|closed too early|po-4500", "po-reopen"),
    (r"harbor|enrol|lol image", "cw-device"),
    (r"payroll|paygrid", "payroll-mismatch"),
    # ... four more
]
```

---
layout: code
file: code/class03/classify.py
---

# The baseline and the real model are each one line

```python {1,2,3}
baseline = DummyClassifier(strategy="most_frequent").fit(train.text, train.queue)
model = make_pipeline(TfidfVectorizer(ngram_range=(1, 2), min_df=2),
                      LogisticRegression(max_iter=1000)).fit(train.text, train.queue)
print(classification_report(test.queue, model.predict(test.text)))
```

---

# Read the report from the worst queue up, not from the average down

- The weakest queue is *password-reset*, with recall 0.76 on 42 test tickets
- Those are the vague ones: "Account locked" with no system named, so it looks like an access request
- Compare the overall score to the baseline before saying anything is good

<!--
Show the report live. Point at payroll first, then the average.
-->

---

# On tickets written the way people actually write, it drops to 71%, and it never says "I don't know"

<Cols widths="1fr 1.1fr">
<Col>

We wrote 300 tickets by hand, across the whole company: one-word titles, typos, two problems in one, forwarded chains. The model gets 71% of them; the day-one rules get 53%.

The five that belong in no queue, a test ticket, a phishing report, a suspicious bank-change email, it puts in one anyway.

</Col>
<Col>
<Tile>

**"Vendor bank change request"** (a fraud attempt) went to invoice-import

</Tile>
<Tile>

**"Break room fridge"** went to ledger-close

</Tile>
<Tile>

**"Payroll - Leeds double payment"** went to customer-payments

</Tile>
</Col>
</Cols>

<!--
Run code/class03/handwritten.py live. The fix for "not ours" tickets is a confidence threshold plus a person, not a better model. The bank-change one matters: it should have gone to security, and a model that routes it to invoices makes fraud easier.
-->

---
layout: explain
dense: true
---

# Where today sits on the card

| 1. A script | The steps are known and don't change. |
|---|---|
| 2. A rule | The decision is known and must be explainable line by line. |
| **3. Classical ML** | **Labelled history, and the input is a table or short text.** |
| 4. A small trained model | Lots of text, images or audio, enough labels, cost per call matters. |
| 5. An LLM with a prompt | Varied language in and out, few labels, someone checks the output. |
| 6. An LLM plus retrieval, tools or agents | Needs private knowledge, has to act, or takes several steps. |
| 7. Not yet | No ground truth, needs a guarantee, or nobody owns the result. |

---
layout: close
contact: "Questions after class: the course channel."
---

# What to do next

1. Run `code/class03/classify.py` and find the weakest queue on your machine.
2. Change the split to time-based and see what happens to the score.
3. Read the class 4 pre-reading on regular expressions.
