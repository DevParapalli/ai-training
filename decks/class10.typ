#import "theme.typ": *

// ---- Class facts: change here, not in the slides ---------------------------
#let n = 10
#let title = [Tools: letting the model ask for an action]
#let subtitle = [Instead of describing what to check, the model asks our code to check it. Our code decides whether to.]
#let question = [“Is batch IH-260615-11 stuck? If it is, open a ticket for AP systems.”]
#let max-steps = 5
#let never-auto = (
  ([Change supplier bank details], [The fraud path from the runbook. Two people, always.]),
  ([Anything in #app.pay], [Payroll errors reach people's bank accounts.]),
  ([Release a customs hold or regenerate customs documents], [Fines and legal exposure.]),
  ([Grant access above Internal], [Access reviews exist for a reason.]),
)
// -----------------------------------------------------------------------------

#show: class.with(n: n)

#title-slide(number: [#n], title: title, subtitle: subtitle,
  facts: ([60 min], [Recorded], [Class #n of #total-classes]))

#outline-slide(current: none)

#section-slide(number: [1], title: [From talking to doing], subtitle: [A model on its own can only produce text.])

#statement(sub: [The model never touches #app.inv or #app.track. It asks; our code runs the lookup and hands back the result.])[The model #hl[asks]. Our code #hl[acts].]

#split(title: [A tool is a function we describe to the model], sub: [Name, what it does, what it needs.],
  ([get_batch_status], [Status of an #app.inv import batch, given an ID like IH-260615-11.]),
  ([get_shipment], [Where a shipment is and why, given LOL-SH-4472190.]),
  ([create_ticket], [Opens a ticket. A person has to say yes first.]),
)

#section-slide(number: [2], title: [The loop], subtitle: [Ask, call, return, repeat, stop.])

#steps-slide(title: [Every tool call runs the same loop until the model has an answer],
  [Send the question and the tool list],
  [The model asks for a tool and arguments],
  [Our code checks and runs it],
  [The result goes back to the model],
  [Repeat, or stop with an answer])

#claim(title: [For "is the batch stuck?", the model makes two calls and asks us once])[
  #cols(widths: (1fr, 1.1fr),
    [
      *We asked:* #question
    ],
    stack(spacing: 0.25cm,
      tile[*1.* get_batch_status("IH-260615-11") \ → processing since 06:00, 14 invoices],
      tile[*2.* create_ticket("ap-systems", "Batch stuck since 06:00") \ → waits for a person to say yes],
      tile[*3.* Answer: "It's been processing for over 2 hours, which the runbook calls stuck. Ticket raised once you approved."],
    ),
  )
]

#section-slide(number: [3], title: [Keeping it safe], subtitle: [Tools make mistakes real.])

#explain(title: [Some actions never run without a person, whatever the model says],
  ..never-auto)

#claim(title: [Check every argument the model sends, the way you'd check a form from a stranger])[
  - The batch ID matches `IH-\d{6}-\d{2}`, or the call fails
  - The queue is one of ours, or the call fails
  - Read-only tools first; anything that writes goes behind approval
  - A step limit (#max-steps here), so a confused model can't loop forever
  #notes[Arguments come from text the model read, and that text can come from a ticket. Class 7's injection example applies here with real consequences.]
]

#compare(title: [Errors go back to the model as results, not as crashes], pick: "right",
  left: ([Crash], [
    - The run stops
    - Nobody finds out why
    - The user sees nothing
  ]),
  right: ([Result], [
    - `{"error": "no such batch"}`
    - The model can ask for the right ID
    - Or tell the user plainly
  ]),
)

#section-slide(number: [4], title: [Code walkthrough], subtitle: [Three fake tools and the loop.])

#code-slide(title: [A tool is an ordinary function plus a description the model can read], file: "code/class10/tools.py", highlight: (1, 2, 5, 6, 7))[
  ```python
  def get_batch_status(batch_id: str) -> dict:
      return BATCHES.get(batch_id, {"error": "no such batch"})

  def create_ticket(queue: str, summary: str) -> dict:
      if input(f"Create ticket in {queue}: {summary!r}? [y/N] ").lower() != "y":
          return {"created": False, "reason": "declined by operator"}
      return {"created": True, "id": "TKT-419001"}
  ```
]

#code-slide(title: [The loop is short: ask, run what it asked for, send the result back], file: "code/class10/tools.py", highlight: (3, 7, 8))[
  ```python
  for _ in range(max_steps):
      reply = client().chat.completions.create(model=MODEL, messages=messages, tools=SCHEMAS)
      msg = reply.choices[0].message
      if not msg.tool_calls: return msg.content
      messages.append(msg)
      for call in msg.tool_calls:
          result = TOOLS[call.function.name](**json.loads(call.function.arguments))
          messages.append({"role": "tool", "tool_call_id": call.id, "content": json.dumps(result)})
  ```
]

#on-the-card(at: (6,))

#close(actions: (
  [Run `tools.py` and decline the ticket. See what the model says.],
  [Add a `get_runbook` tool that uses the class 9 search.],
  [Read the class 11 pre-reading on MCP.],
), contact: [Questions after class: the course channel.])
