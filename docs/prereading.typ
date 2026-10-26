// Pre-reading for the AI Builder Track: the pre-week Python self-study, then one
// short reading before each class. Build:
//   typst compile --root . docs/prereading.typ build/prereading.pdf
#import "@local/centauri:0.0.0": *
#import "../decks/course.typ": *

#show: centauri.with(kind: "report", title: "Building the Right AI System: pre-reading", accent: "ember", stage: "final",
  header: (left: [#track · pre-reading], right: [#co.name]),
  footer: (left: footer-line))

#cover(title: [Pre-reading], subtitle: [Five days of Python before the track starts, then one short reading before each class. Ten to fifteen minutes each.], meta: (
  ([Track], [#track, #total-classes classes]),
  ([Company in the examples], [#co.name (invented)]),
  ([Code and data], [The course repository: `code/`, `data/`]),
))[]

#outline(depth: 1)

= Before the track: Python in five days

Two topics a day, about 45 minutes each. If you write Python daily, skip to day 5 and run the environment check.

Everything runs with `uv`, which installs Python and each script's packages for you. Install it once, then any script in the repo runs with `uv run path/to/script.py`.

== Day 1: running code, and values

- *Running a script.* Install `uv`, then run `uv run code/class02/place.py`. You should see seven problems placed on the card.
- *Values and variables.* Numbers, text (strings) and true/false. `queue = "invoice-import"` gives a name to a value. Print things to see them: `print(queue)`.

Try: write a script that stores a ticket ID and a queue in two variables and prints one line with both.

== Day 2: lists, dictionaries and loops

- *Lists* hold things in order: `queues = ["payroll", "catering", "hardware"]`.
- *Dictionaries* hold things by name: `ticket = {"id": "TKT-418004", "queue": "shipment-ops"}`.
- *Loops* do something to each item: `for q in queues: print(q)`.

Try: make a list of three ticket dictionaries and print only the ones in `shipment-ops`.

== Day 3: functions, and reading files

- *Functions* give a name to a few lines so you can reuse them: `def is_urgent(ticket): return ticket["priority"] in ("P1", "P2")`.
- *Reading a CSV.* `data/tickets_handwritten.csv` has 300 tickets. Python's `csv` module reads it row by row.

Try: count how many handwritten tickets are P1 or P2.

== Day 4: tables with pandas

- *pandas* reads a CSV into a table in one line: `pd.read_csv("data/tickets_handwritten.csv")`.
- *Counting and filtering.* `df.queue.value_counts()` counts tickets per queue. `df[df.department == "Warehouse"]` keeps only warehouse tickets.

Try: which department raises the most P1 and P2 tickets?


== Day 5: calling a web service, and the environment check

- *HTTP and JSON.* A model provider is a web service. You send JSON, you get JSON back. The class code wraps this in one function, `ask()`.
- *Environment variables* keep keys out of code. Set `LLM_API_KEY`, `LLM_BASE_URL` and `LLM_MODEL` in your shell, never in a file you commit.

Environment check, all three should work before class 1:

+ `uv --version` prints a version.
+ `uv run data/generate.py` writes `data/tickets.csv`.
+ `uv run code/class01/first_call.py` prints an answer from the model.

= Before class 2: writing a problem down

Most AI projects that go nowhere started with a tool and went looking for a problem. Class 2 turns that around. Before it, practise the first step: writing one problem from your own work so it can be judged.

A good problem statement is one sentence with a verb, and it says what goes in and what should come out:

- *Weak:* "Use AI for customs."
- *Better:* "When customs rejects a shipment's documents, tell the ops coordinator which document is wrong and what's missing."

Then answer, roughly, for your problem:

+ Is the rule already written down anywhere?
+ What goes in: a table, text, or images?
+ Do we have past examples with the right answer attached?
+ What does one wrong answer cost, and who notices?
+ Does the answer have to be exact or explainable?
+ How often does it happen?

Bring the sentence and your six answers to class 2. Don't worry about the answer being "no AI needed". That's often the right one.

= Before class 3: train and test, and regular expressions

A model learns from examples. The obvious way to check it is to ask it about examples it has seen, and that's exactly the mistake.

Think of an exam. If students see the paper beforehand, their marks tell you nothing. So we split our examples: most for learning (training), some kept back and never shown (testing). Only the test score counts.

Two traps to know before class:

- *Leakage.* The answer sneaks into the training data. A ticket that says "moved to the payroll queue" in its text teaches the model to read the answer, not the problem.
- *Accuracy on uneven data.* If 99 in 100 tickets aren't P1, a model that always says "not P1" is 99% accurate and useless.

And one tool to recognise: a *regular expression* (regex) describes the shape of a piece of text. Anything at LOL with a fixed shape, like `TKT-\d{6}` for ticket IDs or `LOL-SH-\d{7}` for shipments, can be found exactly, every time, for free. Read the patterns in `code/class03/extract.py`; you don't need to write regex fluently, only to notice when a problem is "find the thing with a fixed shape".

Question to bring: in your team's work, what would "always guess the most common answer" get right, and how often?

= Before class 4: tokens, schemas and our AI policy

Models don't read words; they read *tokens*, pieces of text. Common English words are one token; company names, IDs and other languages split into several. Tokens are what you pay for, and the context window, everything the model can see in one request, is counted in them.

When a person reads a model's answer, "close enough" is fine. When a program reads it, it isn't. So we ask for JSON, and a *schema* says which fields must be there, what type each is, and which values are allowed:

```json
{ "queue": "shipment-ops", "shipment_id": "LOL-SH-4472190", "blocking": true }
```

Before any of that, the data has to be allowed to go. Data at LOL is in one of five classes: #policies.lol.classes.join(", "). Every approved AI tool has a ceiling, the highest class it may receive:

#for (tool, limit) in policies.lol.tools [- *#tool:* #limit]

Try: run `uv run code/class04/tokens.py` and see how "Bayerische Unfug Maschinen" splits.

Question to bring: find one thing you did last week that would have needed a class decided before it went into a tool.

= Before class 5: retrieval, tools and agents

The model has never read our runbooks and can't look anything up. Class 5 fixes both.

- *Retrieval.* Search our documents for the passages that match the question, hand them to the model, and have it answer only from them, with citations. Keyword search is good at exact things like `IH-260615-11`; embeddings (class 3) are good at meaning. The best search uses both.
- *Tools.* The model asks our code, by name, to look something up or do something. It never touches the system; our code decides whether to run the request. Reading is usually fine. Anything that changes money, access or what leaves the building waits for a person.
- *Agents.* A goal, a loop, tools, and a reason to stop. Class 5 runs one on a customs hold at Nhava Sheva, with a person deciding whether the drafted email goes.

Try: read two runbooks in `data/runbooks/` and write one question each could answer, worded differently from the runbook itself.

Question to bring: for one multi-step task in your team, before what step does a mistake become expensive? That's where the person goes.

= Before class 6: evaluation, and your capstone proposal

A demo shows the cases that work. An evaluation shows how often it's wrong: collect real examples, write down the right answer for each, freeze the set, and score every change against it. In class 3, a simple classifier got 71% of the 300 handwritten tickets right. Anything more expensive has to beat that, or be better at something we can name.

Class 6 ends with the capstone presentations, three minutes per team. Prepare before class:

+ Form a team of three or four. Draw one problem from the list below, or bring your own.
+ Write it as one sentence, answer the six questions from class 2, and place it on the card.
+ Fill in the blank one-page proposal: the problem, where it lands, steps, error budget, cost, owner and off switch. The worked example shows the level of detail.
+ Remember "no AI needed" is a valid answer, and sometimes the winning one.

Problems for the draw:

#enum(..capstone-problems)
