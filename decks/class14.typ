#import "theme.typ": *

// ---- Class facts: change here, not in the slides ---------------------------
#let n = 14
#let title = [Running it in production]
#let subtitle = [Deploy it, watch it, know what it costs, and be able to roll it back at 2 am.]
#let budgets = (latency: [2 s], cost: [\$0.002], errors: [1%])
#let freeze = [the last two days of the month and the first three of the next]
// -----------------------------------------------------------------------------

#show: class.with(n: n)

#title-slide(number: [#n], title: title, subtitle: subtitle,
  facts: ([60 min], [Recorded], [Class #n of #total-classes]))

#outline-slide(current: none)

#section-slide(number: [1], title: [Shipping it], subtitle: [A notebook that worked once isn't a service.])

#steps-slide(title: [Getting from a script to a service takes the same five things every time],
  [Package it in a container],
  [Keys from a secret store, not the code],
  [Trace every call],
  [Log cost and latency per call],
  [A way to roll back in one step])

#claim(title: [Every call logs what it cost, how long it took, and which prompt it used])[
  #cols(widths: (1.1fr, 1fr),
    [
      Prompt version, model, tokens in and out, latency, cost. One line per call.

      Without this, the first you hear of a problem is the invoice from the provider, or a user.
    ],
    stats(([#budgets.latency], [latency budget per ticket]), ([#budgets.cost], [cost budget per ticket]), ([#budgets.errors], [error budget])),
  )
  #notes[Budgets are examples. Set real ones per feature and alert when they're crossed.]
]

#section-slide(number: [2], title: [Keeping it right], subtitle: [Things change underneath it.])

#explain(title: [Version everything that can change the answer],
  ([The model], [Providers update models behind the same name. Pin the version.]),
  ([The prompt], [A one-word change can move the score. Give prompts version numbers, like code.]),
  ([The data], [Runbooks get rewritten; the retrieval index has to follow.]),
  ([The test set], [Frozen, but grown with every production failure (class 13).]),
)

#claim(title: [Drift is when the world changes and the model doesn't])[
  #cols(
    tile[*New supplier* \ A new cleaning contractor replaces #dih.short. Tickets say a name the model never saw.],
    tile[*New process* \ EU HS codes change in July. Last month's right answer is this month's wrong one.],
    tile[*New model* \ The provider upgrades. Same prompt, different answers.],
  )
  #v(0.5em)
  Rerun the test set on a schedule and on every change. A drop is the only early warning you get.
]

#section-slide(number: [3], title: [Changing it safely], subtitle: [When to ship, and how to take it back.])

#claim(title: [No changes to anything finance touches during period close])[
  #cols(widths: (1.1fr, 1fr),
    [
      #app.gl, #app.pay and #app.inv are busiest during #freeze. That's when a broken change costs most and is hardest to spot.

      Ship the week after close. Roll back first and investigate second.
    ],
    stats(([5 days], [change freeze per month])),
  )
]

#compare(title: [Coding assistants make more code; they don't make more reviewers],
  left: ([What gets faster], [
    - Writing the first version
    - Tests, boilerplate, glue
    - Trying three approaches instead of one
  ]),
  right: ([What doesn't], [
    - Reading it properly
    - Knowing it's right for our data rules
    - Being on call for it at 2 am
  ]),
)

#section-slide(number: [4], title: [Code walkthrough], subtitle: [A container, a trace viewer and a cost log.])

#code-slide(title: [Compose runs the service and a trace viewer side by side], file: "code/class14/compose.yaml", highlight: (7, 8))[
  ```yaml
  services:
    triage:
      build: .
      environment:
        LLM_API_KEY: ${LLM_API_KEY}
        LLM_MODEL: ${LLM_MODEL}
        PROMPT_VERSION: "triage-v3"
        OTEL_EXPORTER_OTLP_ENDPOINT: http://jaeger:4318
    jaeger:
      image: jaegertracing/all-in-one:1.60
  ```
]

#code-slide(title: [The cost log is one JSON line per call], file: "code/class14/costlog.py", highlight: (2, 3, 4, 5))[
  ```python
  record = {
      "prompt_version": prompt_version, "model": reply.model,
      "tokens_in": u.prompt_tokens, "tokens_out": u.completion_tokens,
      "latency_ms": round((time.perf_counter() - start) * 1000),
      "cost_usd": round((u.prompt_tokens * PRICE["input"] + u.completion_tokens * PRICE["output"]) / 1e6, 6),
  }
  ```
]

#on-the-card(at: (3, 4, 5, 6))

#close(actions: (
  [Run `docker compose up` in `code/class14` and find one trace.],
  [Change the prompt version, rerun the class 13 test set, and compare.],
  [Pick a problem for the capstone: one of yours, or draw one on the day.],
), contact: [Questions after class: the course channel.])
