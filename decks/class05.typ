#import "theme.typ": *

// ---- Class facts: change here, not in the slides ---------------------------
// Retrieval figures are measured by code/class05/rag.py and retrieval_check.py
// (keyword search) on data/runbooks.
#let n = 5
#let title = [Building with LLMs]
#let subtitle = [Retrieval, tools, MCP and agents: giving the model our knowledge and our systems, and keeping a person where it matters.]
#let runbooks = 8
#let check = (top1: 6, top3: 7, total: 10)
#let bad-q = [“Armadillo says our bank details changed, can I update them from their email?”]
#let bad-hit = (score: [0.12], source: [supplier-bank-change.md, closing line], missed: [step 1: "Never act on an email"])
#let question = [“Is batch IH-260615-11 stuck? If it is, open a ticket for AP systems.”]
#let max-steps = 5
#let never-auto = (
  ([Change supplier bank details], [The fraud path from the runbook. Two people, always.]),
  ([Anything in #app.pay], [Payroll errors reach people's bank accounts.]),
  ([Release a customs hold], [Fines and legal exposure.]),
  ([Grant access above Internal], [Access reviews exist for a reason.]),
)
// -----------------------------------------------------------------------------

#show: class.with(n: n)

#title-slide(number: [#n], title: title, subtitle: subtitle,
  facts: ([60 min], [Recorded], [Class #n of #total-classes]))

#outline-slide(current: none)

#section-slide(number: [1], title: [Retrieval], subtitle: [The model has never read our runbooks. So we find the right page and hand it over.])

#steps-slide(title: [A retrieval pipeline is five steps, and only the last one uses an LLM],
  [Collect the documents, with their data class],
  [Cut them into chunks: a step, a paragraph],
  [Index each chunk: keywords, vectors, or both],
  [Search with the question, filtered by the tool's ceiling],
  [Answer from the top few, with citations])

#compare(title: [Keyword search finds the step when the words match, and misses it when they don't],
  left: ([Keyword], [
    - Great at IDs and codes: `IH-260615-11`, `ERR-IH-0413`
    - #bad-q
    - Top hit only #bad-hit.score: missed #bad-hit.missed
  ]),
  right: ([Vectors, and both], [
    - Great at meaning: "update from their email" finds "never act on an email"
    - Run both, merge the lists: hybrid search
  ]),
  pick: "right",
)

#section-slide(number: [2], title: [Tools and MCP], subtitle: [The model asks. Our code acts.])

#claim(title: [For "is the batch stuck?", the model makes two calls and a person says yes once])[
  #cols(widths: (1fr, 1.1fr),
    [
      *We asked:* #question

      The model never touches #app.inv. It asks for a function by name with arguments; our code checks them, runs it, and hands back the result.
    ],
    stack(spacing: 0.25cm,
      tile[*1.* get_batch_status("IH-260615-11") \ → processing since 06:00, 14 invoices],
      tile[*2.* create_ticket("ap-systems", "Batch stuck since 06:00") \ → waits for a person to say yes],
    ),
  )
]

#explain(title: [Some actions never run without a person, whatever the model says],
  ..never-auto)

#split(title: [MCP is one standard plug, so each system needs one server, not one connector per app], sub: [A server is code you run. Treat it that way.],
  ([Host], [The AI app people use: chat, a code editor, our own agent.]),
  ([Server], [Ours. Offers tools, resources (a runbook) and prompts. Knows nothing about which model asks.]),
  ([Same rules], [Only servers in our directory, each with a data ceiling. Read what its tools do first.]),
)

#section-slide(number: [3], title: [Agents], subtitle: [A goal, a loop, tools, and a reason to stop.])

#explain(title: [An agent has four things, and missing any one makes it something else],
  ([A goal], [Clear the customs hold, not "help with shipping".]),
  ([A loop], [Look, decide, act, look again. The tool loop is the start of one.]),
  ([Tools], [The ways it finds things out and changes things.]),
  ([A reason to stop], [Done, stuck, or out of steps. Without it, it runs until the bill arrives.]),
)

#steps-slide(title: [The Nhava Sheva customs hold, handled by two agents and one person],
  [Supervisor reads the ticket: it's a customs hold],
  [Hands it to the customs worker],
  [Worker looks up the shipment and finds the runbook step],
  [Worker drafts the email to the customer],
  [A person reads the draft and sends it, or doesn't])

#section-slide(number: [4], title: [Mistakes people make], subtitle: [Most failures are in the search and the permissions, not the model.])

#explain(title: [Retrieval mistakes: blaming the model for a bad search],
  ([Never checking the search], [Our keyword search puts the right runbook first #check.top1 times in #check.total. Fix: a question set with known answers, scored before any model call.]),
  ([Too much context], [Twenty chunks bury the right one. Three to five is usually enough.]),
  ([No "not in the runbooks" path], [It improvises. Fix: tell it to say so, and test that on purpose.]),
  ([Stale documents], [The runbook predates the process change. Show the "last reviewed" date with every answer.]),
)

#explain(title: [Tool and agent mistakes: giving it more reach than the job needs],
  ([Unchecked arguments], [Arguments come from text the model read, and that text can come from a ticket. Validate like a form from a stranger.]),
  ([Write tools without approval], [Read-only first. Anything that writes, pays or sends waits for a person.]),
  ([No step limit], [A confused agent loops. Fix: #max-steps steps, then hand over.]),
  ([Private data, untrusted input, a way out], [All three in one agent and an email can make it leak. Remove one of the three.]),
)

#section-slide(number: [5], title: [Code walkthrough], subtitle: [Check the search, then the loop, then the person.])

#code-slide(title: [Check the search with known answers before any model call], file: "code/class05/retrieval_check.py", highlight: (3, 4, 5))[
  ```python
  for question, expected in QUESTIONS:
      sources = [c["source"] for _, c in search_fn(question, k=k)]
      top1 += sources[0] == expected
      top3 += expected in sources
      if expected not in sources:
          print(f"MISS  {question}\n      wanted {expected}, got {sources}")
  ```
]

#code-slide(title: [The prompt says answer only from the extracts, and say so when they don't help], file: "code/class05/rag.py", highlight: (3, 4))[
  ```python
  hits = search(question)
  context = "\n\n".join(f"[{i + 1}] ({c['source']}) {c['text']}" for i, (_, c) in enumerate(hits))
  return ask("Answer only from the numbered runbook extracts. Cite them like [1]. "
             "If they don't answer the question, say so.\n\n"
             f"{context}\n\nQuestion: {question}", temperature=0)
  ```
]

#code-slide(title: [The tool loop: ask, run what it asked for, send the result back, stop at a limit], file: "code/class05/tools.py", highlight: (1, 4, 7))[
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

#code-slide(title: [The worker drafts; a person decides whether anything goes out], file: "code/class05/supervisor.py", highlight: (2, 3))[
  ```python
  draft = customs_worker(shipment.strip(".,"))
  ok = input(f"\n--- draft ---\n{draft}\n--- send? [y/N] ")
  return "sent" if ok.lower() == "y" else "held for a person"
  ```
]

#explain(title: [In the handout: what we skipped today, each with code to run],
  ([Hybrid search], [Keyword and embeddings merged by rank. `hybrid.py`]),
  ([Writing tools well], [Descriptions, errors as results, approval. `tools.py`]),
  ([An MCP server], [One tool, one resource, one prompt, and how to inspect it. `server.py`]),
  ([Agents talking to agents], [The A2A protocol, and when one agent is enough. `supervisor.py`]),
)

#on-the-card(at: (6,))

#close(actions: (
  [Run `retrieval_check.py`, then add three questions from your own team.],
  [Work through the class 5 handout: `docs/deeper/class05`.],
  [Prepare your capstone proposal for class 6 (the pre-reading says how).],
), contact: [Questions after class: the course channel.])
