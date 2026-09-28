#import "theme.typ": *

// ---- Class facts: change here, not in the slides ---------------------------
// TF-IDF is measured on data/tickets.csv. Embedding and LLM figures are
// illustrative until code/class05 is run with a model and a key; replace them then.
#let n = 5
#let title = [From sequences to transformers]
#let subtitle = [NLP, part 2. How models learned to read in context, and when a small one beats a big one.]
#let acc = (tfidf: 90, embed: 92, llm: 84)
#let speed = (tfidf: [under 1 ms], embed: [about 20 ms], llm: [about 800 ms])
#let cost = (tfidf: [effectively free], embed: [a few CPU hours], llm: [pay per token])
#let embed-model = "Qwen/Qwen3-Embedding-0.6B"
#let embed-dims = [1,024]
#let attention-sentence = [The #hl[close job] failed after the journal import because #hl[it] timed out.]
// -----------------------------------------------------------------------------

#show: class.with(n: n)

#title-slide(number: [#n], title: title, subtitle: subtitle,
  facts: ([60 min], [Recorded], [Class #n of #total-classes]))

#outline-slide(current: none)

#section-slide(number: [1], title: [Reading in order], subtitle: [The first attempts at context.])

#claim(title: [Recurrent networks read one word at a time and carry a memory forward])[
  #cols(widths: (1.1fr, 1fr),
    [
      An RNN reads "receipt failed after reopen" word by word, updating a small memory after each one. By the end, that memory holds a summary of the sentence.

      Word order finally counts.
    ],
    [
      *The problem:* the memory fades. By word 200 of a payroll thread, word 3 is mostly gone. And reading one word at a time is slow to train.
    ],
  )
]

#claim(title: [LSTMs added gates to decide what to keep, which helped but didn't fix speed])[
  #cols(widths: (1.1fr, 1fr),
    [
      Gates decide what to write into memory, what to keep and what to forget. Long tickets hold together much better.

      For a few years, this was how translation and speech worked.
    ],
    [
      *Still:* one word after another. Training can't spread across thousands of GPUs, so models stayed small.
    ],
  )
]

#section-slide(number: [2], title: [Attention], subtitle: [The idea the whole of generative AI rests on.])

#statement(sub: [Instead of reading in a line, each word looks at every other word and decides which ones matter to it.])[Every word looks at #hl[every other word], all at once.]

#claim(title: [Attention lets "it" find "close job" in the same sentence])[
  #cols(widths: (1.2fr, 1fr),
    text(size: 1.5em, attention-sentence),
    [
      To understand "it", the model weighs every other word. "Close job" gets most of the weight, "journal import" some, "the" almost none.

      Each layer does this for every word at once, many times over.
    ],
  )
]

#claim(title: [A transformer stacks attention layers, and it trains in parallel])[
  #cols(widths: (1.1fr, 1fr),
    [
      Attention, then a small network per word, repeated dozens of times. Because every word is handled at once, training spreads across huge numbers of GPUs.

      That's what made very large models possible.
    ],
    [
      *The cost:* every word compares itself with every other word, so work grows with the square of the length. That's why models have a context window (class 6).
    ],
  )
]

#section-slide(number: [3], title: [Two families, and how they're trained], subtitle: [Encoders, decoders, pretraining and fine-tuning.])

#compare(title: [Encoders understand text; decoders write it],
  left: ([Encoder, BERT-style], [
    - Reads the whole text in both directions
    - Produces a vector for the text
    - Good at classifying, searching, matching
  ]),
  right: ([Decoder, GPT-style], [
    - Reads left to right, predicts the next token
    - Produces more text
    - Good at writing, summarising, following instructions
  ]),
)

#split(title: [Pretrain once on everything, then fine-tune on your task], sub: [The expensive part is done by someone else.],
  ([Pretraining], [Predict hidden or next words across a huge amount of public text. Weeks, many GPUs.]),
  ([Fine-tuning], [Train a little more on a few thousand labelled tickets. Hours, one GPU or a CPU.]),
  ([Or neither], [Use a pretrained model as it is: embeddings for search, a prompt for the rest.]),
)

#claim(title: [A sentence embedding turns a whole ticket into one vector that keeps its meaning])[
  #cols(widths: (1.1fr, 1fr),
    [
      An encoder reads the ticket in context and returns one vector. "Import stuck" and "invoices not showing" land close together, and "down" means different things in different sentences.

      This fixes the one-meaning-per-word problem from class 4. Class 9 builds retrieval on it.
    ],
    stats(([#embed-dims], [numbers per ticket]), ([#speed.embed], [per ticket on a laptop])),
  )
]

#section-slide(number: [4], title: [Small model or big model], subtitle: [The same tickets, classified three ways.])

#exhibit(title: [On a fixed task with labels, the small models match or beat the LLM for far less], source: [TF-IDF measured on the synthetic set; embedding and LLM figures illustrative])[
  #columns-chart(height: 6.5cm,
    ([TF-IDF + LR], acc.tfidf, [#acc.tfidf%]),
    ([Embeddings + LR], acc.embed, [#acc.embed%]),
    ([LLM, zero-shot], acc.llm, [#acc.llm%]))
  #notes[The LLM loses on the vague tickets: it has never seen how #co.short's analysts label "numbers look wrong in PayGrid". The small models learned it from history.]
]

#table-slide(title: [The gap in accuracy is small next to the gap in cost and speed], columns: 4,
  header: ([Method], [Accuracy], [Per ticket], [Per 100k tickets]),
  [TF-IDF + LR], [#acc.tfidf%], speed.tfidf, cost.tfidf,
  [Embeddings + LR], [#acc.embed%], speed.embed, cost.embed,
  [LLM, zero-shot], [#acc.llm%], speed.llm, cost.llm,
  source: [TF-IDF measured; other rows illustrative])

#compare(title: [Pick the small model when the task is fixed, and the LLM when it keeps changing],
  left: ([Small task model], [
    - One job, done the same way every time
    - Labelled examples exist
    - High volume, low cost, data stays local
  ]),
  right: ([General LLM], [
    - The task changes or needs writing
    - No labels, or not enough
    - Volume is modest and someone checks the output
  ]),
)

#section-slide(number: [5], title: [Code walkthrough], subtitle: [Embeddings with a simple classifier, then the LLM on the same tickets.])

#code-slide(title: [Local embeddings plus logistic regression, and no data leaves the machine], file: "code/class05/embed_classify.py", highlight: (1, 2, 3))[
  ```python
  enc = SentenceTransformer("Qwen/Qwen3-Embedding-0.6B")
  X_train, X_test = enc.encode(list(train.text)), enc.encode(list(test.text))
  clf = LogisticRegression(max_iter=1000).fit(X_train, train.queue)
  print(f"accuracy {clf.score(X_test, test.queue):.3f}")
  ```
]

#code-slide(title: [The LLM version has no training step, and a cost on every call], file: "code/class05/llm_classify.py", highlight: (2, 3))[
  ```python
  def classify(text: str) -> str:
      prompt = f"Route this LOL service desk ticket to exactly one of {QUEUES}. Reply with the queue name only.\n\n{text}"
      return ask(prompt, temperature=0).strip().lower()

  preds = [classify(t) for t in sample.text]
  ```
]

#claim(title: [Run all three on the same test set before choosing, and write down why])[
  - Accuracy per queue, not just overall
  - Time per ticket, measured, not guessed
  - Cost per 100,000 tickets at today's prices
  - Where the ticket text goes for each option (class 8)
]

#on-the-card(at: (4, 5))

#close(actions: (
  [Run both scripts in `code/class05` and put your numbers in the comparison table.],
  [Note which queue each method gets wrong most.],
  [Read the class 6 pre-reading on tokens.],
), contact: [Questions after class: the course channel.])
