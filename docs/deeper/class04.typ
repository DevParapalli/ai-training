// Class 4 deeper reading. Build:
//   typst compile --root . docs/deeper/class04.typ build/deeper-class04.pdf
#import "handout.typ": *

#show: handout.with(n: 4, title: [LLMs in practice: what the class skipped, with code to run and where to read more.],
  covered: [Tokens, the context window, made-up answers, prompt parts, schemas with validation and retry, data classes and the gate.])

= How to use this

Class 4 covered the starting point and the mistakes. This handout covers the rest. The first link in each list is the one to read if you only read one.

Most scripts here call a model. Set `LLM_API_KEY`, `LLM_BASE_URL` and `LLM_MODEL` in your shell, or point them at a model on your own machine (section 6). `tokens.py`, `redact.py` and `gate.py` need no key.

= The mistakes, as a checklist

Before an LLM feature goes anywhere near production:

+ Is it being asked for knowledge it can't have? Give it the data or a tool instead.
+ Is any arithmetic done by the model? Move it to code.
+ Does a program read the output? Then there's a schema, validation, and temperature 0.
+ What happens after the last retry? A person, never a default answer.
+ Was the data classified before it was sent, and is the tool's ceiling high enough?
+ Is redaction treated as a safety net, not the decision?
+ Is the same care taken with training data as with prompts?
+ Are tokens counted before sending, so nothing is silently cut?

= Tokens, context and temperature

*Why it matters.* Tokens are what you pay for and what fills the window. Temperature decides whether the same question gets the same answer. Overflowing the window either fails loudly or, worse, quietly drops the start.

*Run.*
#run("uv run code/class04/tokens.py        # no key needed
uv run code/class04/temperature.py   # three temperatures, three runs each
uv run code/class04/overflow.py      # every ticket in one prompt, on purpose
uv run code/class04/made_up.py       # a question it can't know the answer to")

*Try.* Run `tokens.py` on three of your own ticket titles and one in another language you use at work. Run `overflow.py` and find out whether your provider errors or truncates. Run `made_up.py` twice and decide whether the second, "say so if you don't know" answer was actually honest.

*Read.*
#source("https://www.youtube.com/watch?v=7xTGNNLPyMI", [Deep dive into LLMs like ChatGPT], kind: "video, 3.5 h", by: [Andrej Karpathy])[How a chat model is built and why it behaves as it does, for a general audience. Watch the first hour if nothing else.]
#source("https://www.youtube.com/watch?v=zduSFxRajkE", [Let's build the GPT tokenizer], kind: "video, 2 h", by: [Andrej Karpathy])[Why IDs and non-English text cost more tokens, from the inside.]
#source("https://huggingface.co/blog/how-to-generate", [How to generate text], kind: "guide", by: [Hugging Face])[Greedy decoding, sampling, temperature and top-p, with examples.]
#source("https://trychroma.com/research/context-rot", [Context rot], kind: "research report", by: [Chroma, 2025])[Measured across 18 models: performance gets less reliable as input grows, well before the window is full.]
#source("https://arxiv.org/abs/2307.03172", [Lost in the middle], kind: "paper", by: [Liu et al., 2023])[Models use the start and end of a long context better than the middle.]

= Why models make things up

*Why it matters.* The class showed a confident, invented customs status. The fix is never "prompt harder"; it's giving the model the data (class 5) or letting it say it doesn't know.

*Read.*
#source("https://openai.com/index/why-language-models-hallucinate/", [Why language models hallucinate], kind: "article and paper", by: [OpenAI, 2025])[Argues that training and scoring reward guessing over admitting uncertainty. Short and readable.]
#source("https://lilianweng.github.io/posts/2024-07-07-hallucination/", [Extrinsic hallucinations in LLMs], kind: "survey", by: [Lilian Weng])[Causes, detection and mitigation, with references to the research.]

= Prompting and structured output

*Why it matters.* The schema and retry loop from class are the core. Few-shot examples, asking for reasoning, and provider-native structured output are the next steps.

*Run.*
#run("uv run code/class04/extract_json.py   # schema, validation, retry with the error
uv run code/class04/few_shot.py       # zero-shot against hard-case examples, 40 handwritten tickets")

*Try.* Add a `department` field to the `Triage` schema in `extract_json.py` and see what breaks. In `few_shot.py`, swap the five hard examples for five easy ones and compare. Then try asking for step-by-step reasoning before the answer on a payroll variance ticket, and on a routing ticket: it should help the first and only cost tokens on the second.

*Read.*
#source("https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview", [Prompt engineering overview], kind: "docs", by: [Anthropic])[Practical techniques in order of impact: be clear, use examples, let it think, structure the prompt. Applies to any provider.]
#source("https://docs.pydantic.dev/latest/", [Pydantic documentation], kind: "docs")[The library behind the schema. Read the pages on models and on JSON schema.]
#source("https://json-schema.org/learn/getting-started-step-by-step", [JSON Schema, getting started], kind: "docs")[What the model actually receives when you hand it a schema.]
#source("https://python.useinstructor.com/", [Instructor], kind: "library docs")[Schema, validation and retry as a library, across providers. Read after writing the loop yourself once.]
#source("https://platform.openai.com/docs/guides/prompt-engineering", [Prompt engineering guide], kind: "docs", by: [OpenAI])[A second provider's take; most advice carries across.]
#source("https://lilianweng.github.io/posts/2023-03-15-prompt-engineering/", [Prompt engineering], kind: "survey", by: [Lilian Weng])[The research behind few-shot, chain-of-thought and friends.]
#source("https://arxiv.org/abs/2201.11903", [Chain-of-thought prompting elicits reasoning in large language models], kind: "paper", by: [Wei et al., 2022])[Where "think step by step" comes from.]

= Running a model yourself

*Why it matters.* An open model on your laptop or a team server keeps data on the machine: our policy lets local models take up to LOL Confidential. The class code works unchanged against any server that speaks the OpenAI-compatible API.

*Run.* Install a local model server, pull a small model, then:
#run("export LLM_BASE_URL=http://localhost:11434/v1   # Ollama's OpenAI-compatible endpoint
export LLM_API_KEY=unused LLM_MODEL=<the model you pulled>
uv run code/class04/extract_json.py")

*Rule of thumb.* Memory first: about two bytes per parameter at full quality, about half a byte at 4-bit. An 8-billion-parameter model needs roughly 5 GB at 4-bit.

*Read.*
#source("https://docs.ollama.com/api/openai-compatibility", [OpenAI compatibility], kind: "docs", by: [Ollama])[The base URL and what's supported. Simplest way to start on a laptop.]
#source("https://github.com/ggml-org/llama.cpp", [llama.cpp], kind: "project")[The engine under most laptop setups, MIT licensed. Its README explains quantisation formats.]
#source("https://docs.vllm.ai/", [vLLM documentation], kind: "docs")[For a team server with a GPU: much higher throughput, same API.]

= Rules for data, in more depth

*Why it matters.* Class 4 covered our directory and ceilings. The people we work with bring their own rules, and the public frameworks are where auditors and customers will start.

*Our partners.* #bum.name: #policies.bum.stance #policies.bum.note #ass.name: #policies.ass.stance Background check results stay ASS Restricted when they reach our tickets, and never go into any AI tool, including ours.

*Run.*
#run("uv run code/class04/redact.py   # no key needed
uv run code/class04/gate.py")

*Try.* Add a pattern for shipment IDs to `redact.py`, then decide whether it should be there: a shipment ID isn't personal data, and the model needs it. Write three sentences from the handwritten tickets that regex redaction can't make safe.

*Read.*
#source("https://genai.owasp.org/llm-top-10/", [OWASP Top 10 for LLM applications], kind: "guide", by: [OWASP])[Sensitive information disclosure is one entry; read it alongside prompt injection for class 6.]
#source("https://microsoft.github.io/presidio/", [Presidio], kind: "library docs", by: [Microsoft])[Open-source detection and redaction of personal data, beyond regex. MIT licensed.]
#source("https://www.nist.gov/itl/ai-risk-management-framework", [AI Risk Management Framework], kind: "framework", by: [NIST])[Voluntary: govern, map, measure, manage. Good as a checklist.]
#source("https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf", [Generative AI profile, NIST AI 600-1], kind: "framework", by: [NIST])[The same framework applied to generative AI specifically.]
#source("https://eur-lex.europa.eu/eli/reg/2024/1689/oj", [EU AI Act, Regulation (EU) 2024/1689], kind: "law", by: [EUR-Lex])[The official text. Sorts AI uses by risk; obligations phase in from 2025.]
#source("https://artificialintelligenceact.eu/", [EU AI Act explorer], kind: "guide", by: [Future of Life Institute])[Unofficial, but the easiest way to find the article you need.]
#source("https://www.iso.org/standard/81230.html", [ISO/IEC 42001], kind: "standard", by: [ISO])[A certifiable management system for AI, like ISO 27001 for security. The standard itself is paid.]
#source("https://www.meity.gov.in/data-protection-framework", [Data protection framework], kind: "law", by: [MeitY, Government of India])[The DPDP Act 2023 and the DPDP Rules 2025. Most obligations apply from May 2027.]
