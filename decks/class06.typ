#import "theme.typ": *

// ---- Class facts: change here, not in the slides ---------------------------
// Token counts are approximate (o200k_base); run code/class06/tokens.py for exact ones.
#let n = 6
#let title = [LLMs under the hood]
#let subtitle = [Tokens, the context window, temperature, and why a model answers questions it can't know.]
#let tokens = (
  ([Invoices from Armadillo Security Services not showing in InvoiceHub.], [13]),
  ([Bayerische Unfug Maschinen], [7]),
  ([LOL-SH-4472190], [8]),
  ([Die Rechnung ist noch nicht angekommen.], [9]),
)
#let window = (tokens: [128,000], pages: [about 300 pages], tickets: [roughly 4,000 of our tickets])
#let cost = (per-ticket-in: 400, per-ticket-out: 150, per-day: 300)
#let price = (input: [\$0.50], output: [\$1.50])   // per million tokens, illustrative mid-range hosted model
#let monthly = [about \$4 a month]
#let made-up-q = [What is the status of shipment LOL-SH-4472190 at Nhava Sheva?]
#let made-up-a = [“LOL-SH-4472190 cleared customs at Nhava Sheva on 12 June and is out for delivery to the consignee.”]
#let local = (params: [8 billion], ram-4bit: [about 5 GB], ram-16bit: [about 16 GB])
// -----------------------------------------------------------------------------

#show: class.with(n: n)

#title-slide(number: [#n], title: title, subtitle: subtitle,
  facts: ([60 min], [Recorded], [Class #n of #total-classes]))

#outline-slide(current: none)

#section-slide(number: [1], title: [Tokens], subtitle: [What the model actually reads, and what you actually pay for.])

#claim(title: [A model doesn't read words; it reads tokens, and our names are expensive])[
  #cols(widths: (1.2fr, 1fr),
    [
      Text gets chopped into pieces before the model sees it. Common English words are one piece. Company names, IDs and German are several.

      Tokens are also the unit you're billed in, and the unit the context window is measured in.
    ],
    stack(spacing: 0.25cm, ..tokens.map(((t, c)) => tile[#text(size: 0.85em, t) \ *#c tokens*])),
  )
  #notes[Numbers are approximate. Run tokens.py live and show how LOL-SH-4472190 splits into digits.]
]

#statement(sub: [Every answer is one token at a time, each picked from a list of likely next tokens.])[It's predicting the #hl[next token]. That's the whole trick.]

#section-slide(number: [2], title: [The context window], subtitle: [Everything the model can see at once.])

#claim(title: [The context window is the model's whole world for one request])[
  #cols(widths: (1.1fr, 1fr),
    [
      Your instructions, the ticket, any documents you paste, the chat so far, and the answer it's writing: all of it has to fit.

      Anything outside the window doesn't exist for the model. It doesn't remember yesterday's chat unless you send it again.
    ],
    stats(([#window.tokens], [tokens, a common size]), ([#window.pages], [of plain text]), ([#window.tickets], [at most])),
  )
]

#compare(title: [When it overflows, you get an error or, worse, a quiet cut],
  left: ([Error], [
    - The provider refuses the request
    - Annoying, but you know
    - Fix: send less, or summarise first
  ]),
  right: ([Silent truncation], [
    - The start of the text is dropped
    - The answer looks confident anyway
    - Fix: count tokens before you send
  ]),
  pick: "right",
)

#section-slide(number: [3], title: [Temperature and making things up], subtitle: [Why the same question gets different answers, and some of them invented.])

#explain(title: [Temperature sets how adventurous the pick is],
  ([0], [Takes the most likely token nearly every time. Best for routing, extracting, anything a program reads.]),
  ([0.7], [Some variety. Fine for drafting a reply a person will edit.]),
  ([1.5], [Loose. Creative on a good day, nonsense on a bad one. We don't use it at work.]),
)

#claim(title: [Ask about something it can't know, and it answers anyway])[
  #cols(widths: (1fr, 1.1fr),
    [
      *We asked:* #made-up-q

      The model has never seen #app.track. It has no idea where that container is.
    ],
    tile[*It said:* \ #made-up-a],
  )
  #notes[That's a hallucination: plausible text with nothing behind it. The fix is never "prompt harder"; it's giving the model the real data (class 9) or a tool to look it up (class 10).]
]

#split(title: [Why it makes things up], sub: [It's built to produce likely text, not true text.],
  ([No lookup], [It isn't checking a database. It's continuing a pattern.]),
  ([Rewarded for answering], [Training favours confident, helpful-sounding replies.]),
  ([Specific looks right], [A date and a place read as fact, so it supplies them.]),
)

#section-slide(number: [4], title: [Who runs the model], subtitle: [Hosted, our gateway, or on a laptop.])

#compare(title: [Hosted models are the strongest; local ones keep data on the machine],
  left: ([Hosted API], [
    - Strongest models, no hardware
    - Pay per token
    - Our text leaves the building (class 8)
  ]),
  right: ([Open model, run locally], [
    - Weights you download and run
    - Smaller, a bit weaker
    - Data stays on the laptop or server
  ]),
)

#claim(title: [Running one yourself is a memory problem before it's anything else])[
  #cols(widths: (1.1fr, 1fr),
    [
      A model's size is its number of parameters. Each one needs memory: two bytes at full quality, about half a byte when compressed to 4 bits.

      So a laptop with a decent GPU, or a lot of RAM, runs a small model fine. A server runs bigger ones for a whole team.
    ],
    stats(([#local.params], [parameters, a small model]), ([#local.ram-4bit], [memory at 4-bit]), ([#local.ram-16bit], [memory at full quality])),
  )
]

#claim(title: [Routing every ticket with an LLM costs less than people think, and more than a regex])[
  #cols(widths: (1.1fr, 1fr),
    [
      #cost.per-day tickets a day, about #cost.per-ticket-in tokens in and #cost.per-ticket-out out each, at #price.input per million in and #price.output per million out.

      Cheap. Now compare with the classifier from class 3, which costs nothing per call and gets 90%.
    ],
    stats(([#monthly], [illustrative monthly bill])),
  )
  #notes[Prices vary by provider and change often; the point is the shape of the sum, not the figure.]
]

#section-slide(number: [5], title: [Code walkthrough], subtitle: [Count tokens, overflow a window, turn the temperature up.])

#code-slide(title: [Counting tokens takes three lines, so there's no excuse not to], file: "code/class06/tokens.py", highlight: (1, 3))[
  ```python
  enc = tiktoken.get_encoding("o200k_base")
  for s in SAMPLES:
      ids = enc.encode(s)
      print(f"{len(ids):>3} tokens  {s}")
  ```
]

#code-slide(title: [Three temperatures, three runs each, and you can see the spread], file: "code/class06/temperature.py", highlight: (2, 4))[
  ```python
  PROMPT = "Write a one-line subject for a ticket about Rotterdam scanners not syncing."
  for t in (0.0, 0.7, 1.5):
      for _ in range(3):
          print(" ", ask(PROMPT, temperature=t).strip())
  ```
]

#code-slide(title: [Telling it to admit what it doesn't know helps, but doesn't make it true], file: "code/class06/made_up.py", highlight: (2, 3))[
  ```python
  print(ask("What is the current status of LOL shipment LOL-SH-4472190 at Nhava Sheva?"))
  print(ask("What is the current status of LOL shipment LOL-SH-4472190 at Nhava Sheva? "
            "If you don't have access to that data, say so and stop."))
  ```
]

#on-the-card(at: (5,))

#close(actions: (
  [Run `tokens.py` on three of your own ticket titles.],
  [Run `made_up.py` and write down whether the second answer was honest.],
  [Read the class 7 pre-reading on JSON and schemas.],
), contact: [Questions after class: the course channel.])
