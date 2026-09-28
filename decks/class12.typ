#import "theme.typ": *

// ---- Class facts: change here, not in the slides ---------------------------
#let n = 12
#let title = [Agents, and agents talking to agents]
#let subtitle = [A goal, a loop, tools, and a reason to stop. Then one agent handing work to another.]
#let max-steps = 6
#let case = (
  ticket: [Bill of entry rejected at Nhava Sheva for LOL-SH-4472190, consignee GST number missing on invoice.],
  steps: (
    [Supervisor reads the ticket: it's a customs hold],
    [Hands it to the customs worker],
    [Worker looks up the shipment in #app.track],
    [Worker finds the customs runbook step],
    [Worker drafts the email to the customer],
    [A person reads the draft and sends it, or doesn't],
  ),
)
// -----------------------------------------------------------------------------

#show: class.with(n: n)

#title-slide(number: [#n], title: title, subtitle: subtitle,
  facts: ([60 min], [Recorded], [Class #n of #total-classes]))

#outline-slide(current: none)

#section-slide(number: [1], title: [What makes something an agent], subtitle: [Most "agents" are a prompt with a marketing budget.])

#explain(title: [An agent has four things, and missing any one makes it something else],
  ([A goal], [Clear the customs hold, not "help with shipping".]),
  ([A loop], [Look, decide, act, look again. Class 10's loop is the start of one.]),
  ([Tools], [The ways it can find things out and change things.]),
  ([A reason to stop], [Done, stuck, or out of steps. Without it, it runs until the bill arrives.]),
)

#compare(title: [A chatbot answers; an agent keeps going until the job's done or it can't go on],
  left: ([Chatbot], [
    - One question, one answer
    - A person does the next step
    - Easy to check
  ]),
  right: ([Agent], [
    - Plans several steps
    - Calls tools between them
    - Harder to check, so it needs limits
  ]),
)

#section-slide(number: [2], title: [Where people step in], subtitle: [The part that decides whether this is safe.])

#claim(title: [Put a person at the points where a mistake leaves the building])[
  #cols(
    tile[*Before sending* \ Emails to customers and suppliers, customs submissions.],
    tile[*Before paying or changing money* \ Anything in #app.pay or supplier bank details.],
    tile[*When it's unsure* \ Two options that look equally good means ask, not pick.],
  )
  #notes[Everything else can run: lookups, searches, drafts. The agent does the legwork; a person makes the call that matters.]
]

#claim(title: [Limits are what make an agent safe to leave running])[
  - A step limit: #max-steps here, then it stops and hands over
  - A time limit and a cost limit per task
  - Read-only by default; write tools behind approval
  - Every step logged, so a person can replay what happened
]

#section-slide(number: [3], title: [One agent handing to another], subtitle: [A supervisor and a specialist.])

#steps-slide(title: [The customs hold from class 1's world, handled by two agents and one person],
  ..case.steps)

#split(title: [Agent-to-agent (A2A) is how agents on different systems talk], sub: [An open protocol, the way MCP is for tools.],
  ([Agent card], [Each agent publishes what it can do and how to reach it.]),
  ([Tasks], [One agent sends another a task and gets updates as it progresses.]),
  ([Not MCP], [MCP connects a model to tools. A2A connects one agent to another agent.]),
)

#section-slide(number: [4], title: [Code walkthrough], subtitle: [A supervisor, a customs worker, and a person at the end.])

#code-slide(title: [The worker looks things up and drafts, and never sends], file: "code/class12/supervisor.py", highlight: (3, 4, 5, 6))[
  ```python
  def customs_worker(shipment_id: str) -> str:
      """Worker: look the shipment up, find the runbook step, draft the email. Never sends it."""
      ship = get_shipment(shipment_id)
      steps = search(f"customs documents {ship.get('reason', '')}", k=2)
      notes = "\n".join(c["text"] for _, c in steps)
      return ask(f"Shipment: {ship}\nRunbook:\n{notes}\n\nDraft a short email ...", temperature=0.3)
  ```
]

#code-slide(title: [The supervisor routes, and a person decides whether anything goes out], file: "code/class12/supervisor.py", highlight: (2, 7, 8))[
  ```python
  for step in range(MAX_STEPS):
      decision = ask("... Reply CUSTOMS or HUMAN.\n\n" + ticket, temperature=0).strip().upper()
      if decision == "CUSTOMS":
          shipment = next((w for w in ticket.split() if w.startswith("LOL-SH-")), None)
          if not shipment: return "handed to a person: no shipment ID in the ticket"
          draft = customs_worker(shipment.strip(".,"))
          ok = input(f"\n--- draft ---\n{draft}\n--- send? [y/N] ")
          return "sent" if ok.lower() == "y" else "held for a person"
  ```
]

#on-the-card(at: (6,))

#close(actions: (
  [Run `supervisor.py` on the Nhava Sheva ticket and read the draft before saying yes.],
  [Find two handwritten tickets that should never reach an agent, and say why.],
  [Read the class 13 pre-reading on evaluation.],
), contact: [Questions after class: the course channel.])
