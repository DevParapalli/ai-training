# Syllabus

Fifteen classes, one hour each, three weeks. By the end you should be able to look at a problem and say, with reasons, whether it needs a script, a trained model, a language model, or nothing at all. And if it needs something, you should know the steps to build it and be able to read the code that does.

## The company

For fifteen classes we're Lafayette O'Reilly Logistics (LOL), a freight and logistics company, and we look at the whole company, not one department. Operations books and tracks shipments and deals with customs; warehouses run scanners and label printers; finance closes the books and chases payments; HR, legal, sales and customer service all raise tickets too. We ship machines for Bayerische Unfug Maschinen (BUM), and buy security and background checks from Armadillo Security Services (ASS), facilities from Drymark Institutional Handling (DIH), catering from Gastro Alliance Group (GAG), and cloud from Stratocumulus Cloud (SC). None of it is real, so we can use it freely.

## How a class runs

- **30 minutes: the idea and the steps.** For everyone. No code on screen. What the thing is, where it fits, what it costs, where it breaks.
- **20 minutes: the code.** For developers and support engineers. I run the reference code and walk through it. Leads and managers can drop off here; the recording stays up.
- **10 minutes: questions.**

Nobody types along. Exercises that need a keyboard sit in `code/` for after class.

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

### 3. Classical ML, done properly

The baseline every AI proposal has to beat. Train and test splits, and why leaking the answer into training makes everything look great. Baselines. Why 99% accuracy can mean nothing. Precision, recall and the confusion matrix, with alarms as the example. Anomaly detection on metrics and a simple volume forecast. When classical ML beats an LLM outright: cost, speed, repeatability, explainability.

Code: a scikit-learn ticket classifier scored against "always guess the biggest queue".

### 4. NLP, part 1: turning text into numbers

Computers don't read, they count. Why text is hard: the same word meaning different things, different words meaning the same thing, order changing the meaning. Cleaning and tokenising. Regex for the things with a fixed shape: hostnames, IPs, error codes, ticket IDs. Bag of words, TF-IDF, similarity. Word vectors: similar meaning, nearby numbers. Where each one falls over.

Code: pull fields out of tickets, then find duplicate tickets with TF-IDF.

### 5. NLP, part 2: from sequences to transformers

Reading word by word and forgetting the start (RNNs, LSTMs). Attention: every word looks at every other word. The transformer. Encoders versus decoders, BERT-style versus GPT-style. Pretraining, then fine-tuning. Sentence embeddings. Small task models versus big general ones.

Code: classify the same tickets three ways, TF-IDF, local embeddings, and an LLM, and compare accuracy, speed and cost side by side.

## Part B: working with LLMs

### 6. LLMs under the hood

Tokens, next-token prediction, the context window, temperature and sampling, why models make things up with a straight face, which models exist and who runs them, and what running one yourself involves.

Code: count tokens, overflow a context window on purpose, turn the temperature up and down.

### 7. Prompting, and output a program can trust

System and user messages, examples in the prompt, asking for reasoning, and the part that matters in production: getting output a program can trust. Schemas, validation, retrying with the error. What prompting can't fix.

Code: a prompt that returns validated JSON, and a retry loop that feeds the validation error back.

### 8. Rules for data

Before any of our data goes near a model. Three policies side by side: ours at LOL (a directory of approved tools, each with the highest data class it may take), BUM's (Copilot switched on in Office and nothing written down), and ASS's (strict: approved tools only, everything else blocked or isolated). Then one slide on the real TCS and Cisco policies for reference, and where the public frameworks sit: the EU AI Act, the NIST AI Risk Management Framework, ISO/IEC 42001, and India's DPDP Act. The same rules apply to training data for classical models, not only to prompts.

Code: a redaction step and a gate that refuses to send anything it can't classify.

## Part C: building AI systems

### 9. Retrieval: answering from our own documents

Classes 4 and 5 already covered embeddings, so this one is about using them: chunking, indexing, searching, then answering from what was found and citing it. How retrieval goes wrong and how to notice. Mixing keyword and vector search.

Code: a small retrieval pipeline over LOL's eight runbooks (data/runbooks), with citations.

### 10. Tools: letting the model ask for an action

Letting a model ask for an action instead of describing one. Tool schemas, the call-and-return loop, several tools, errors, and which actions should never run without a person saying yes.

Code: a model that checks a (fake) service status and opens a (fake) ticket.

### 11. MCP

Why every tool needed its own integration, and how the Model Context Protocol fixes that. Hosts, clients and servers. Tools, resources and prompts. Transports. Reading an MCP config. And the part people skip: a server is code you run, so treat it like code you run.

Code: a small MCP server with one tool, one resource and one prompt.

### 12. Agents, and agents talking to agents

What makes something an agent: a goal, a loop, tools, and a reason to stop. Where people have to step in. One agent handing work to another, and the A2A protocol for doing that across systems.

Code: a supervisor agent handing a task to a worker agent, with a step limit.

## Part D: running AI responsibly

### 13. Evaluation, accountability and security

If you can't say how often it's wrong, you don't know whether it works. Test sets built from real questions, LLM-as-judge and its blind spots, and the same precision and recall from class 3. Who owns a wrong answer. Prompt injection and the other ways a model gets talked into things. A checklist for reading a vendor's AI proposal.

Code: an evaluation run with a fixed test set and a report.

### 14. Running it in production

Deploying, tracing, logs, cost and latency budgets, caching, versioning models and prompts, drift for classical models and LLMs alike, rollback, and change windows. Also what coding assistants change about review: more code, same number of reviewers.

Code: deploy with `docker compose`, add tracing and a cost log.

### 15. How much to let it do, and the capstone

How much to let it do on its own: assist, co-pilot, supervised agent, autonomous. Where support work sits on that scale today, and what changes in the job and what doesn't.

Capstone: teams draw a problem nobody has seen, place it on the card, and write a one-page proposal for the cheapest thing that works: where it lands, the steps, the error budget, the cost. Three minutes each to present. "No AI needed" can win. Teams get a worked example and a blank one-page proposal as PDFs, and may bring their own problem instead of drawing one.

## Open

- Embedding and LLM figures in class 5 are illustrative until the class 5 scripts are run with a model and a key.
- Run dates.
