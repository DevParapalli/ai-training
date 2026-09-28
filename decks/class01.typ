#import "theme.typ": *

// ---- Class facts: change here, not in the slides ---------------------------
#let n = 1
#let title = [What AI actually is]
#let subtitle = [Four eras, one ticket routed four ways, and the first call to a model.]
#let minutes = (idea: 30, code: 20, questions: 10)
#let rule-phrase = [“InvoiceHub” or “invoice import”]
#let rule-miss = [“armadillo stuff still not there??”]
#let history-size = [two years of service desk tickets]
#let run-a = [“This is an InvoiceHub import status issue. Send it to the invoice-import queue and check batch IH-260301-07.”]
#let run-b = [“Invoice import. ERR-IH-0413 usually means the batch file failed validation, so AP can't match yet.”]
// -----------------------------------------------------------------------------

#show: class.with(n: n)

#title-slide(number: [#n], title: title, subtitle: subtitle,
  facts: ([60 min], [Recorded], [Class #n of #total-classes]))

#outline-slide(current: none)

#section-slide(number: [1], title: [How this track works], subtitle: [Fifteen classes, one company, one idea running through all of them.])

#steps-slide(title: [Every class runs the same way],
  [#minutes.idea min on the idea and the steps, for everyone],
  [#minutes.code min on the code, for developers and support],
  [#minutes.questions min of questions],
  [Exercises live in the repo, for after class])

#split(title: [We are #co.name], sub: [#co.what. For the next fifteen classes, this is our company. Yes, the initials are on purpose.],
  ([What we do], [Move freight: bookings, customs, warehouses, trucks. Plus everything behind it: finance, HR, IT, facilities.]),
  ([Why it's hard], [Freight across 40+ countries, money in 11 currencies, and a short payment on nearly every cross-border receipt.]),
  ([What's real], [Nothing. The company, the systems, the people and the numbers are made up, so we can use them freely.]),
)

#explain(title: [Who we deal with, and why they show up in our tickets],
  ([#bum.name (#bum.short)], [#bum.role #bum.money]),
  ([#ass.name (#ass.short)], [#ass.role #ass.money]),
  ([#dih.name (#dih.short)], [#dih.role]),
  ([#gag.name (#gag.short)], [#gag.role]),
  ([#sc.name (#sc.short)], [#sc.role]),
)

#explain(title: [The systems our tickets are about],
  ([#app.track], [Bookings, tracking, customs documents and the driver app. If it's slow, trucks wait.]),
  ([#app.gl], [General ledger and period close. Busy on the last days of every month.]),
  ([#app.proc], [Purchase orders. People ask us to reopen them more than you'd think.]),
  ([#app.inv], [Imports supplier invoices in batches. "Did it finish?" is a daily question.]),
  ([#app.pay], [Payroll. Rare tickets, but every one needs a root cause.]),
  ([#app.iam and #app.mdm], [Access for everyone. Employees' laptops sit in Intune; contractors' go through #app.mdm.]),
)

#statement(sub: [Every class ends by putting its topic somewhere on a card with seven places. We build the card in class 2.])[By the end, you can say #hl[which problems need AI], and which don't.]

#section-slide(number: [2], title: [Four eras], subtitle: [Same ticket, four methods. Watch what changes.])

#display-slide(title: [The ticket], sub: [#ticket.short. #ticket.body])[#ticket.id]

#claim(title: [Rules: a person writes every decision, the machine just follows])[
  #cols(widths: (1.1fr, 1fr),
    [
      Somebody writes it out. If the text says #rule-phrase, send it to the invoice queue. If it mentions a PO number and "reopen", send it to procurement.

      Nothing to train, nothing to guess. Every decision reads back line by line.
    ],
    [
      *Works well when* the logic is known and stable, and an auditor has to follow it.

      *Falls over when* someone writes #rule-miss and no rule saw that coming.
    ],
  )
  #notes[Thresholds, alert routing and compliance checks should stay rules. Being auditable beats being clever there.]
]

#claim(title: [Classical ML: the machine finds the pattern, a person picks what it looks at])[
  #cols(widths: (1.1fr, 1fr),
    [
      Feed it #history-size with the queue that fixed each one. It works out which words point to which queue.

      You still choose the inputs: the words, the system named, whether it's period end.
    ],
    [
      *Works well when* there's labelled history and the input is a table or short text. Cheap, fast, runs on a laptop.

      *Falls over when* there are no labels, or a new queue shows up and everything needs relabelling.
    ],
  )
]

#claim(title: [Deep learning: the machine also works out what to look at])[
  #cols(widths: (1.1fr, 1fr),
    [
      Stack enough layers and the early ones find simple patterns, the later ones combine them. Letters, then words, then phrases, then meaning.

      Nobody hand-picks the inputs any more. Scanned background-check invoices from #ass.short can go straight in.
    ],
    [
      *Works well when* the input is raw text, images or audio and there's a lot of it.

      *Falls over when* labels run short. It needs far more of them, needs GPUs to train, and is hard to explain.
    ],
  )
]

#claim(title: [Generative AI: nobody trains for your task, you describe it])[
  #cols(widths: (1.1fr, 1fr),
    [
      The model already learned language by predicting the next word across a huge amount of text. You write the task in plain words: route this ticket to the right queue.

      Same model can summarise it, draft the reply to AP, find the runbook.
    ],
    [
      *Works well when* the input varies and nobody has labels.

      *Falls over when* it's confidently wrong, gives a different answer next time, costs money per call, or sends data somewhere it shouldn't go (class 8).
    ],
  )
]

#statement(sub: [Rules, then learned patterns, then learned inputs, then described tasks. Each era is cheaper to start and harder to pin down than the one before.])[Same ticket. #hl[Only the method changed.]]

#section-slide(number: [3], title: [Training and inference], subtitle: [Two very different jobs that people call by the same name.])

#compare(title: [Training builds the model once; inference uses it every time someone asks],
  left: ([Training], [
    - Done by a model provider, rarely by us
    - Weeks, huge amounts of text, thousands of GPUs
    - Produces a file of numbers: the weights
  ]),
  right: ([Inference], [
    - Done every time we send a request
    - Milliseconds to seconds, one prompt at a time
    - Costs per token, and that bill is ours
  ]),
  pick: "right",
)

#explain(title: [Four things generative AI is not],
  ([A database], [It doesn't look facts up. It predicts likely text, which is often right and sometimes invented.]),
  ([Deterministic], [Ask twice, get two answers. Settings reduce this; they don't remove it.]),
  ([A search engine], [It knows what it was trained on, up to a date. #co.short's runbooks have to be handed to it (class 9).]),
  ([Magic], [It's a very large pattern predictor. Useful, and wrong in patterned ways we can learn to spot.]),
)

#steps-slide(title: [Calling a model is an HTTP request with text in and text out],
  [Get an API key and keep it out of the code],
  [Send a message: who you are, what you want],
  [The provider runs inference on its machines],
  [Text comes back, with a count of tokens used])

#section-slide(number: [4], title: [Code walkthrough], subtitle: [For developers and support. Everyone else: the recording stays up.])

#code-slide(title: [The first call is a few lines, and most of them are setup], file: "code/class01/first_call.py", highlight: (5, 6, 7))[
  ```python
  TICKET = "TKT-204117: InvoiceHub import for Armadillo Security Services shows ERR-IH-0413 since 02:00."

  reply = client().chat.completions.create(
      model=os.environ["LLM_MODEL"],
      messages=[{"role": "user", "content": f"Which support queue should handle this ticket? {TICKET}"}],
  )
  print(reply.choices[0].message.content)
  ```
]

#code-slide(title: [Streaming shows the answer arriving token by token], file: "code/class01/stream.py", highlight: (3, 4))[
  ```python
  stream = client().chat.completions.create(model=os.environ["LLM_MODEL"], messages=messages, stream=True)

  for chunk in stream:
      print(chunk.choices[0].delta.content or "", end="", flush=True)
  ```
]

#claim(title: [Ask the same thing twice and the two answers differ])[
  #cols(tile[*Run 1* \ #run-a], tile[*Run 2* \ #run-b])
  #v(0.6em)
  Both are fine here. In class 7 we make the output something a program can check, so "fine" stops being a judgement call.
]

#on-the-card(at: (1, 2, 3, 4, 5))

#close(actions: (
  [Run `code/class01/first_call.py` against the course key.],
  [Read the class 2 pre-reading: one page on writing a problem down.],
  [Bring one problem from your own work, written as a single sentence.],
), contact: [Questions after class: the course channel.])
