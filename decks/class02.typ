#import "theme.typ": *

// ---- Class facts: change here, not in the slides ---------------------------
#let n = 2
#let title = [Automation, ML or AI?]
#let subtitle = [How to look at a problem and place it, with reasons, before anyone picks a tool.]
#let exercise-minutes = 10
#let problems = (
  [Restart the #app.inv import job after three failed health checks in a row],
  [Route #app.iam requests where the form already names the access type],
  [Alert when the #app.gl close job runs 30 minutes past its usual finish],
  [Forecast ticket volume for the five days around period close],
  [Spot odd CPU and latency across our 60 integration hosts],
  [Route free-text service desk tickets using two years of history],
  [Read fields from 50,000 labelled scanned #ass.short invoices],
  [Summarise a 40-message payroll mismatch thread for the RCA],
  [Draft the first reply to a contractor waiting on #app.mdm enrolment],
  [Answer "how do I reopen a PO" from 600 #app.proc runbooks],
  [Check the #sc.short billing feed and open a posting ticket from chat],
  [Say which GL account will fail reconciliation at the next close],
)
// -----------------------------------------------------------------------------

#show: class.with(n: n)

#title-slide(number: [#n], title: title, subtitle: subtitle,
  facts: ([60 min], [Recorded], [Class #n of #total-classes]))

#outline-slide(current: none)

#section-slide(number: [1], title: [Start from the problem], subtitle: [The tool comes last.])

#claim(title: [Most AI projects that fail picked the tool before they understood the problem])[
  #cols(widths: (1.2fr, 1fr),
    [
      "We should use AI for the service desk" is a tool looking for a job. It skips the questions that decide whether anything needs building at all.

      Start with the problem written as one sentence. The tool falls out of the answers.
    ],
    stats(([7], [places on the card]), ([6], [questions to place a problem]), ([1], [sentence to start])),
  )
  #notes[Ask the room: who has seen an "AI for X" project that should have been a cron job? Let one or two people answer.]
]

#statement(sub: [Cheapest to build and to run, counting the people who check it.])[The #hl[cheapest option] that stays inside the error budget wins.]

#explain(title: [The card has seven places a problem can land],
  ..card-places.enumerate().map(((i, (p, line))) => ([#(i + 1). #p], line)))

#claim(title: [Six questions place almost any problem on the card])[
  #cols(
    [
      + Is the rule already written down?
      + What goes in: a table, text, or media?
      + Is there labelled history?
    ],
    enum(start: 4,
      [What does one wrong answer cost, and who notices?],
      [Does the answer have to be exact, auditable or repeatable?],
      [How often does it run, and what can we spend per run?],
    ),
  )
]

#section-slide(number: [2], title: [Setting up a problem], subtitle: [Write it down so it can be judged.])

#steps-slide(title: [Every problem gets set up the same way, before anyone argues about tools],
  [Write it as one sentence with a verb],
  [Name what goes in and what should come out],
  [Answer the six questions, honestly],
  [Put a number on one wrong answer],
  [Place it; write one line on why])

#split(title: [Worked example: "has the import finished?"], sub: [Accounts payable asks the desk to check an #app.inv batch, several times a day.],
  ([The answer is a lookup], [#app.inv already knows each batch's status. Nobody needs to judge anything.]),
  ([Input is a batch ID], [A fixed shape. A regex finds it in the ticket text.]),
  ([Lands on 1], [A script that reads the status and replies. No model anywhere.]),
)

#split(title: [Worked example: a payroll mismatch], sub: [Summarise a 40-message thread so the RCA can start.],
  ([No rule exists], [Every mismatch is different; what matters changes each time.]),
  ([Language in, language out], [Few labels, varied input, and the analyst reads it anyway.]),
  ([Lands on 5], [An LLM with a prompt. A person checks it before it goes in the RCA.]),
)

#split(title: [Worked example: predicting reconciliation breaks], sub: [Say which GL account will fail at the next close.],
  ([Little ground truth], [Breaks are rare and each has its own cause. There's almost nothing to learn from.]),
  ([Guarantee expected], [Controllers want a yes or no they can act on. A model can only give odds.]),
  ([Lands on 7], [Not yet. A pre-close checklist on the riskiest accounts does more today.]),
)

#section-slide(number: [3], title: [How machines learn], subtitle: [Four paradigms, and the kinds of task they handle.])

#explain(title: [Four ways a machine learns, each answering one question],
  ([Supervised], [“Given examples with the right answer, predict the answer for a new one.”]),
  ([Unsupervised], [“Nobody labelled this. What groups or outliers are in it?”]),
  ([Self-supervised], [“Hide part of the data and predict it.” Language models learn this way.]),
  ([Reinforcement], [“Try, get a reward or a penalty, try again.” We only need to recognise it.]),
)

#claim(title: [Most problems at #co.short are one of eight task types])[
  #cols(
    [
      - *Classify:* which queue, which priority
      - *Predict a number:* hours to resolve
      - *Group:* tickets that look alike
      - *Spot the odd one:* a host behaving strangely
    ],
    [
      - *Forecast:* volume around period close
      - *Rank:* which runbook fits best
      - *Pull out fields:* PO, batch, worker ID
      - *Write:* a summary, a reply, a draft
    ],
  )
]

#claim(title: [A lot of desk work needs a script and nothing else])[
  #cols(
    tile[*Status checks.* #app.inv batch status, export job results. Read it, report it.],
    tile[*Runbook steps.* Rerun the export, extend the #app.cw account. Same steps every time.],
    tile[*Routing by a field.* The #app.iam form already says "approver rights". Read the field.],
  )
]

#claim(title: [Adding AI doesn't fix missing data, missing owners or a need for guarantees])[
  #cols(
    [
      - *No ground truth:* nothing to check its answers against
      - *No owner:* nobody signs off on what it decides
    ],
    [
      - *Needs a guarantee:* a model gives likelihoods
      - *Cause and effect:* history shows what went together, not what caused what
    ],
  )
]

#exercise(title: [Place twelve #co.short problems on the card], minutes: exercise-minutes,
  task: [In pairs, take the twelve problems on the next slide. For each one, pick the cheapest place on the card that stays inside its error budget, and write one sentence on why.],
  output: [Twelve placements, each with one line of reasoning. "No AI needed" is a valid answer and often the right one.])

#claim(title: [Twelve problems to place])[
  #set text(size: 0.82em)
  #cols(enum(..problems.slice(0, 6)), enum(start: 7, ..problems.slice(6)))
  #notes[Suggested answers: 1 script; 2 rule; 3 rule; 4 classical ML; 5 classical ML; 6 classical ML; 7 small trained model; 8 LLM with a prompt; 9 LLM with a prompt, human sends; 10 LLM plus retrieval; 11 LLM plus tools, with approval; 12 not yet.]
]

#section-slide(number: [4], title: [Code walkthrough], subtitle: [The six questions as a small script.])

#code-slide(title: [The six questions fit in a function that returns a place on the card], file: "code/class02/place.py", highlight: (2, 3))[
  ```python
  def place(p: Problem) -> int:
      if p.needs_guarantee or not p.has_ground_truth: return 7
      if p.rule_known: return 1 if p.steps_only else 2
      if p.input == "table" and p.has_labels: return 3
      if p.input == "text" and p.has_labels and p.high_volume: return 3
      if p.input == "media" and p.has_labels and p.high_volume: return 4
      if p.needs_private_knowledge or p.must_act: return 6
      return 5
  ```
]

#claim(title: [The script is a checklist that talks back, not an oracle])[
  It encodes the order we ask the questions in: rule out "not yet" first, then the cheapest options, and only then the LLM. Real problems will argue with it. That argument is the point of the exercise.
  #notes[Run it on the twelve problems live. Where the script and the room disagree, ask which question the script got wrong.]
]

#on-the-card(at: (1, 2, 3, 4, 5, 6, 7), title: [Today covered the whole card])

#close(actions: (
  [Place the problem you brought on the card, and write the one line on why.],
  [Read the class 3 pre-reading on train and test splits.],
  [Run `code/class02/place.py` and add your own problem to it.],
), contact: [Questions after class: the course channel.])
