// Class 6 deeper reading. Build:
//   typst compile --root . docs/deeper/class06.typ build/deeper-class06.pdf
#import "handout.typ": *

#show: handout.with(n: 6, title: [Running it: what the class skipped, with code to run and where to read more.],
  covered: [Test sets, owners, versioning, drift, prompt injection, how much to let it do, and the capstone.])

= How to use this

Class 6 covered the starting point and the mistakes. This handout covers the rest. The first link in each list is the one to read if you only read one.

`drift.py` needs no key. Everything else calls a model.

= The mistakes, as a checklist

Before an AI feature goes live, and every month after:

+ Is there a frozen test set of real examples, and a score from the last change?
+ Does the score beat the cheapest option on the same set?
+ If an LLM grades outputs, when did a person last grade the same sample, and did they agree?
+ Is the owner a person, and is the off switch written down?
+ Are the model version and prompt version pinned and logged with every call?
+ Is there a cost and latency log, with an alert on each?
+ What signals drift, and who looks at it?
+ Can anything the model reads (email, PDF, web page) make it take an action without a person?
+ Is the autonomy level set by what a mistake costs?

= Evaluation

*Why it matters.* A demo shows the cases that work; an evaluation shows how often it's wrong. The class used a frozen sample of the handwritten tickets. The next steps are grading open-ended output and growing the set from production failures.

*Run.*
#run("uv run code/class06/evaluate.py   # the class 4 triage on 60 frozen handwritten tickets
uv run code/class06/judge.py      # an LLM grading six drafts a person already graded")

`judge.py` includes the traps: a long, polite reply with an invented date, and a short correct one. Count where the judge disagrees with the person.

*Try.* Run `evaluate.py`, then compare its per-queue report with the class 3 classifier on the same tickets. Change one word in the triage prompt and run it again. In `judge.py`, add three drafts of your own, grade them first, then see if the judge agrees.

*Read.*
#source("https://hamel.dev/blog/posts/evals/", [Your AI product needs evals], kind: "guide", by: [Hamel Husain])[Start from real failures, build tests from them, look at the data. Read this first.]
#source("https://hamel.dev/blog/posts/llm-judge/", [Using LLM-as-a-judge], kind: "guide", by: [Hamel Husain])[How to build a judge you can trust: one domain expert, pass or fail, critiques, and agreement checks.]
#source("https://eugeneyan.com/writing/llm-evaluators/", [Evaluating the effectiveness of LLM-evaluators], kind: "survey", by: [Eugene Yan])[What the research says judges are good and bad at.]
#source("https://arxiv.org/abs/2306.05685", [Judging LLM-as-a-judge with MT-Bench and Chatbot Arena], kind: "paper", by: [Zheng et al., 2023])[The position, length and self-preference biases, measured.]
#source("https://arxiv.org/abs/2404.12272", [Who validates the validators?], kind: "paper", by: [Shankar et al., 2024])[Why grading criteria change once people see outputs, and how to keep judges aligned.]
#source("https://inspect.aisi.org.uk/", [Inspect], kind: "framework", by: [UK AI Security Institute])[Open-source evaluation framework, MIT licensed, runs locally.]
#source("https://www.promptfoo.dev/", [promptfoo], kind: "tool")[Test sets and assertions for prompts in a config file, MIT licensed, runs locally.]

= Prompt injection

*Why it matters.* Anything the model reads can carry instructions: tickets, emails, PDFs, retrieved pages, tool results. There is no prompt that reliably stops it. The defence is design: limit what untrusted input can cause.

*Run.*
#run("uv run code/class06/injection.py")

The naive run hands the model a supplier email with hidden instructions and asks for next steps. The defended run routes the bank change with a rule, uses the class 4 schema, which has no field for "verified", and only ever shows the summary to a person.

*Try.* Move the hidden instruction into a runbook chunk and ask `rag.answer()` about bank changes. Then list every place in the class 5 code where text from outside #co.short reaches a prompt.

*Read.*
#source("https://simonwillison.net/series/prompt-injection/", [Prompt injection series], kind: "articles", by: [Simon Willison])[The clearest running record of attacks and why filters keep failing. Start with the oldest posts.]
#source("https://genai.owasp.org/llm-top-10/", [OWASP Top 10 for LLM applications], kind: "guide", by: [OWASP])[Prompt injection is entry one; excessive agency and sensitive information disclosure are the others to read.]
#source("https://arxiv.org/abs/2506.08837", [Design patterns for securing LLM agents against prompt injections], kind: "paper", by: [Beurer-Kellner et al., 2025])[Architectural patterns that make injected text unable to trigger actions, with ten case studies.]
#source("https://arxiv.org/abs/2302.12173", [Not what you've signed up for: indirect prompt injection], kind: "paper", by: [Greshake et al., 2023])[The paper that named indirect injection, with real attacks on real apps.]
#source("https://arxiv.org/abs/2503.18813", [Defeating prompt injections by design (CaMeL)], kind: "paper", by: [Debenedetti et al., 2025])[Separating trusted control flow from untrusted data. For developers.]

= Running it in production

*Why it matters.* A script that worked once isn't a service. At 2 am you need to know which prompt and model ran, what it cost, how slow it was, and how to roll back.

*Run.*
#run("uv run code/class06/drift.py   # unseen words, confidence and queue mix, no key")

`costlog.py` is a function to import: it writes one JSON line per call with prompt version, model, tokens, latency and cost. `compose.yaml` shows the shape of a deployment with a trace viewer; the triage service it builds isn't in the repository yet, so read it rather than run it.

*Try.* Wrap the triage call in `costlog.logged_call` and run `evaluate.py`; total the cost of one evaluation run. In `drift.py`, add a third batch: generated tickets with every "Armadillo" replaced by a new supplier's name.

*Read.*
#source("https://huyenchip.com/2022/02/07/data-distribution-shifts-and-monitoring.html", [Data distribution shifts and monitoring], kind: "guide", by: [Chip Huyen])[Kinds of drift, how to detect each, and what to monitor. Classical ML, applies to LLMs.]
#source("https://opentelemetry.io/docs/specs/semconv/gen-ai/", [Semantic conventions for generative AI], kind: "spec", by: [OpenTelemetry])[Standard names for model, tokens and latency in traces, so any trace viewer understands them.]
#source("https://langfuse.com/self-hosting", [Langfuse self-hosting], kind: "docs")[Open-source tracing, prompt versions and cost for LLM apps, on your own servers.]
#source("https://www.jaegertracing.io/docs/", [Jaeger documentation], kind: "docs")[The trace viewer in `compose.yaml`.]
#source("https://docs.docker.com/compose/", [Docker Compose documentation], kind: "docs")[Enough to read and change `compose.yaml`.]
#source("https://sre.google/sre-book/embracing-risk/", [Embracing risk], kind: "book chapter", by: [Google SRE book])[Error budgets, the idea behind "what one wrong answer costs".]
#source("https://papers.nips.cc/paper/2015/hash/86df7dcfd896fcaf2674f757a2463eba-Abstract.html", [Hidden technical debt in machine learning systems], kind: "paper", by: [Sculley et al., 2015])[The model is the small box in the middle; everything around it is the work.]
#source("https://docs.evidentlyai.com/", [Evidently], kind: "library docs")[Open-source drift and data quality reports for classical models, Apache 2.0.]

= How much to let it do

*Why it matters.* Autonomy is a design choice, separate from how capable the model is. The level should follow what a mistake costs: supplier bank changes, payroll and customs stay at co-pilot or below, however good the model gets.

*Read.*
#source("https://arxiv.org/abs/2506.12469", [Levels of autonomy for AI agents], kind: "paper", by: [Feng, McDonald and Zhang, 2025])[Five levels defined by the person's role: operator, collaborator, consultant, approver, observer.]
#source("https://www.microsoft.com/en-us/research/project/guidelines-for-human-ai-interaction/", [Guidelines for human-AI interaction], kind: "guidelines", by: [Microsoft Research])[Eighteen tested guidelines, such as making clear how well the system does what it does.]

= Coding assistants and review

*Why it matters.* Coding assistants make more code; they don't make more reviewers. The evidence on productivity is mixed, and the bottleneck moves to reading and owning the result.

*Read.*
#source("https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/", [Measuring the impact of early-2025 AI on experienced open-source developer productivity], kind: "study", by: [METR, 2025])[A randomised trial: developers were 19% slower with AI tools while believing they were faster. Small sample; read the caveats.]
#source("https://cloud.google.com/devops/state-of-devops", [State of AI-assisted software development, 2025], kind: "report", by: [DORA, Google Cloud])[Survey of nearly 5,000 professionals: AI amplifies a team's existing strengths and weaknesses.]

= The capstone, after class

Take the proposal your team presented and do the one thing it didn't: for a script or rule, write it; for a model, build the baseline and the test set first; for "not yet", write down what would have to be true to revisit it. The worked example is in `docs/proposal.typ`.
