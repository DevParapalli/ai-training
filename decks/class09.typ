#import "theme.typ": *

// ---- Class facts: change here, not in the slides ---------------------------
// Retrieval scores are measured by code/class09/rag.py (keyword search) on data/runbooks.
#let n = 9
#let title = [Retrieval: answering from our own documents]
#let subtitle = [The model doesn't know our runbooks. So we find the right page and hand it over.]
#let runbooks = 8
#let chunks = (total: 56, confidential: 49, internal: 41)
#let good-q = [“Scanner shows yesterday's pick list”]
#let good-hit = (score: [0.39], source: [scanner-resync.md, step 3])
#let bad-q = [“Armadillo says our bank details changed, can I update them from their email?”]
#let bad-hit = (score: [0.12], source: [supplier-bank-change.md, closing line], missed: [step 1: "Never act on an email"])
// -----------------------------------------------------------------------------

#show: class.with(n: n)

#title-slide(number: [#n], title: title, subtitle: subtitle,
  facts: ([60 min], [Recorded], [Class #n of #total-classes]))

#outline-slide(current: none)

#section-slide(number: [1], title: [Why retrieval], subtitle: [Class 6 showed it'll make things up. This is the fix.])

#statement(sub: [Nobody trained it on our runbooks, our tickets or our shipments. It has to be shown them, every time.])[The model has #hl[never read our runbooks].]

#split(title: [Retrieve first, then answer], sub: [Also called RAG: retrieval-augmented generation.],
  ([Find], [Search our documents for the few passages that match the question.]),
  ([Hand over], [Put those passages in the prompt, numbered.]),
  ([Answer and cite], [The model answers only from them, and says which one each point came from.]),
)

#section-slide(number: [2], title: [Building it], subtitle: [Chunk, index, search, answer.])

#steps-slide(title: [A retrieval pipeline is five steps, and only the last one uses an LLM],
  [Collect the documents, with their data class],
  [Cut them into chunks: a step, a paragraph],
  [Index each chunk: keywords, vectors, or both],
  [Search with the question],
  [Answer from the top few, with citations])

#claim(title: [Our first corpus is #runbooks runbooks, cut into #chunks.total chunks])[
  #cols(widths: (1.1fr, 1fr),
    [
      Customs documents in #app.track, #app.inv batches, reopening POs, contractor enrolment, scanners, supplier bank changes, payroll variances, badges.

      One chunk per numbered step. Small enough to be specific, big enough to make sense on its own.
    ],
    stats(([#runbooks], [runbooks]), ([#chunks.total], [chunks])),
  )
]

#claim(title: [The data class decides which chunks a tool may even see])[
  #cols(widths: (1.1fr, 1fr),
    [
      The payroll runbook is LOL Highly Confidential; the bank-change one is Confidential. A tool with a Confidential ceiling never gets the payroll chunks, whatever the question.

      Filter at search time, before anything reaches the prompt (class 8).
    ],
    stats(([#chunks.total], [chunks for Lighthouse]), ([#chunks.confidential], [for a Confidential tool]), ([#chunks.internal], [for an Internal tool])),
  )
]

#section-slide(number: [3], title: [Where it goes wrong], subtitle: [Mostly in the search, not in the model.])

#compare(title: [Keyword search finds the step when the words match, and misses it when they don't],
  left: ([Words match], [
    #good-q
    - Top hit #good-hit.score: #good-hit.source
    - Exactly the right step
  ]),
  right: ([Words don't match], [
    #bad-q
    - Top hit only #bad-hit.score: #bad-hit.source
    - Missed #bad-hit.missed
  ]),
)

#claim(title: [Use both kinds of search, because each misses what the other catches])[
  #cols(
    tile[*Keyword* \ Great at IDs and exact terms: `IH-260615-11`, `ERR-IH-0413`, "Harbor".],
    tile[*Vectors (class 5)* \ Great at meaning: "update bank details from their email" finds "never act on an email".],
    tile[*Both* \ Run the two, merge the results, keep the top few. Called hybrid search.],
  )
]

#explain(title: [Four ways retrieval fails, and how to notice],
  ([Wrong chunk], [The answer cites a passage that doesn't say that. Check citations on a sample every week.]),
  ([Stale document], [The runbook is from before the process changed. Show the "last reviewed" date with every answer.]),
  ([Nothing matches], [It should say "not in the runbooks", not improvise. Test that on purpose.]),
  ([Too much context], [Twenty chunks bury the right one. Three to five is usually enough.]),
)

#section-slide(number: [4], title: [Code walkthrough], subtitle: [Chunk our runbooks, search them, answer with citations.])

#code-slide(title: [Chunking is one split per paragraph or numbered step, tagged with the source], file: "code/class09/rag.py", highlight: (4, 5, 8))[
  ```python
  for path in sorted(RUNBOOKS.glob("*.md")):
      text = path.read_text(encoding="utf-8")
      cls = re.search(r"Class: (LOL [A-Za-z ]+?)\.", text).group(1)
      if CEILING[cls] > CEILING[tool_limit]:
          continue                                   # this tool may not see this runbook
      for part in re.split(r"\n\s*\n|\n(?=\d+\. )", text):
          out.append({"source": path.name, "text": part.strip()})
  ```
]

#code-slide(title: [The prompt tells it to answer only from the extracts, and to say so when they don't help], file: "code/class09/rag.py", highlight: (3, 4))[
  ```python
  hits = search(question)
  context = "\n\n".join(f"[{i + 1}] ({c['source']}) {c['text']}" for i, (_, c) in enumerate(hits))
  return ask("Answer only from the numbered runbook extracts. Cite them like [1]. "
             "If they don't answer the question, say so.\n\n"
             f"{context}\n\nQuestion: {question}", temperature=0)
  ```
]

#on-the-card(at: (6,))

#close(actions: (
  [Ask `rag.py` three questions from the handwritten tickets and check every citation.],
  [Swap the keyword search for embeddings and rerun the bank-change question.],
  [Read the class 10 pre-reading on function calling.],
), contact: [Questions after class: the course channel.])
