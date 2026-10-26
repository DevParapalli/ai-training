# Syllabus

Six classes, one hour each. By the end you should be able to look at a problem and say, with reasons, whether it needs a script, a trained model, a language model, or nothing at all. And if it needs something, you should know the steps to build it and be able to read the code that does.

## The company

For six classes we're Lafayette O'Reilly Logistics (LOL), a freight and logistics company, and we look at the whole company, not one department. Operations books and tracks shipments and deals with customs; warehouses run scanners and label printers; finance closes the books and chases payments; HR, legal, sales and customer service all raise tickets too. We ship machines for Bayerische Unfug Maschinen (BUM), and buy security and background checks from Armadillo Security Services (ASS), facilities from Drymark Institutional Handling (DIH), catering from Gastro Alliance Group (GAG), and cloud from Stratocumulus Cloud (SC). None of it is real, so we can use it freely.

## How a class runs

- **30 minutes: the idea and the steps.** For everyone. No code on screen. What the thing is, where it fits, what it costs, where it breaks.
- **20 minutes: the code.** For developers and support engineers. I run the reference code and walk through it. Leads and managers can drop off here; the recording stays up.
- **10 minutes: questions.**

Nobody types along. Exercises that need a keyboard sit in `code/` for after class.

From class 3, each class covers the starting point and the mistakes people make. Everything else lives in that class's deeper-reading handout (`docs/deeper/`): the topics the class skipped, a script to run for each, and reading in order, most practical first.

## The one idea that runs through all of it

Every class ends by putting its topic on the **card**. The card has seven places a problem can land:

1. **A script.** The steps are known and don't change. Cron job, runbook, workflow.
2. **A rule.** The decision is known and has to be explainable line by line.
3. **Classical ML.** There's labelled history, and the input is a table or short text.
4. **A small trained model.** Lots of text, images or audio, enough labels, and cost per call matters.
5. **An LLM with a prompt.** Language in, language out, varied input, few labels, and someone checks the output.
6. **An LLM with retrieval, tools or agents.** It needs private knowledge, has to act in other systems, or takes several steps.
7. **Not yet.** No ground truth to check against, the answer needs a guarantee, or nobody owns the result.

To place a problem, answer six questions:

- Is the rule already written down?
- What goes in: a table, text, or media?
- Is there labelled history?
- What does one wrong answer cost, and who notices?
- Does the answer have to be exact, auditable or repeatable?
- How often does it run, and what can we spend per run?

The cheapest option that stays inside the error budget wins. "No AI needed" is a good answer, and we'll see it a lot.

## Before class 1

Five days of Python self-study, two topics a day, in `docs/prereading.typ`, which also has a short reading before each class. If you write Python for a living, skip it and just run the environment check.

## Part A: choosing the right tool

### 1. What AI actually is

Four eras in one hour: rules, classical ML, deep learning, generative AI. We route the same ticket four ways so the only thing that changes is the method. Then training versus inference, and what a model call looks like from the outside: text goes in over HTTP, text comes back.

Code: the first call, streaming, and the same prompt twice with different answers.

### 2. Automation, ML or AI

The class the rest of the track hangs on. How to write a problem down so it can be judged, the six questions, and the seven places on the card. Supervised, unsupervised, self-supervised and reinforcement learning, each as the question it answers. The task types: classify, predict a number, group, spot the odd one out, forecast, rank, pull out fields, write. And the things AI can't fix: missing data, missing ownership, a need for guarantees.

Exercise: in pairs, place twelve problems on the card and defend each one in a sentence.

Code: the six questions as a small script that suggests a place on the card.

### 3. Classical ML and text

The baseline every AI proposal has to beat. Train and test splits, precision and recall, and when classical ML beats an LLM outright. Text into numbers: regex for anything with a fixed shape, TF-IDF and similarity, embeddings, and the three-way comparison of TF-IDF, embeddings and an LLM on cost, speed and accuracy.

Mistakes: scoring on training data, leakage, accuracy on uneven classes, reading the average, no baseline, trusting a clean test set, never saying "I don't know", picking a cutoff by eye.

Code: a scikit-learn classifier against "always guess the biggest queue", a confidence threshold that sends uncertain tickets to a person, and regex extraction.

Handout: forecasting, anomaly detection, duplicates, embeddings against an LLM, and how transformers work.

## Part B: working with LLMs

### 4. LLMs in practice

Tokens, the context window, temperature, and why models make things up. The parts of a prompt and examples in it. Output a program can trust: a schema, validation, and a retry that ends with a person. Rules for data: our classes and tool ceilings, three example tickets, and one slide on the real policies for reference.

Mistakes: prompting for missing knowledge, arithmetic in the model, parsing free text, retrying forever, pasting before classifying, trusting regex redaction, forgetting training data, never counting tokens.

Code: count tokens, the validated-JSON retry loop, and the gate.

Handout: temperature and overflow, few-shot prompting, running a model yourself, redaction, partner policies, and the EU AI Act, NIST AI RMF, ISO/IEC 42001 and India's DPDP Act.

## Part C: building AI systems

### 5. Building with LLMs

Retrieval: chunk, index, search, answer with citations, filtered by data class. Tools: the model asks, our code acts, and some actions never run without a person. MCP as one plug per system, and a server as code you run. Agents: a goal, a loop, tools, and a reason to stop, with a supervisor handing a customs hold to a worker.

Mistakes: never checking the search, too much context, no "not in the runbooks" path, stale documents, unchecked tool arguments, write tools without approval, no step limit, and private data, untrusted input and a way out in one agent.

Code: a retrieval check with known answers, the answer prompt, the tool loop, and the person at the end of the agent.

Handout: hybrid search, writing tools, an MCP server and the Inspector, agents, and A2A.

## Part D: running AI responsibly

### 6. Running it, and the capstone

Test sets, a named owner and an off switch. Versioning and logging every call, drift, prompt injection, and how much to let it do: assist, co-pilot, supervised agent, autonomous.

Mistakes: a demo instead of a test set, a moving test set, an unchecked LLM judge, ownership by a team, no cost log, unpinned models and prompts, shipping during period close, more code with the same reviewers.

Code: a frozen evaluation, a drift check, and an injection that goes nowhere.

Capstone: teams draw a problem before class (or bring their own), place it on the card, and present a one-page proposal for the cheapest thing that works in three minutes: where it lands, the steps, the error budget, the cost, the owner. "No AI needed" can win. Teams get a worked example and a blank one-page proposal as PDFs.

Handout: LLM-as-judge, prompt injection in depth, tracing and drift tooling, autonomy levels, and what coding assistants change about review.

## Open

- Embedding and LLM figures in class 3 are illustrative until `embed_classify.py` and `llm_classify.py` are run with a model and a key.
- `code/class06/compose.yaml` builds a triage service that isn't in the repository yet.
- Class 6 runs 25 minutes of ideas, 10 of code and 25 of capstone presentations; with more than eight teams, presentations need a second slot.
- Run dates.
