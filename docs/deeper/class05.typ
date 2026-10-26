// Class 5 deeper reading. Build:
//   typst compile --root . docs/deeper/class05.typ build/deeper-class05.pdf
#import "handout.typ": *

#show: handout.with(n: 5, title: [Building with LLMs: what the class skipped, with code to run and where to read more.],
  covered: [Retrieval with citations, the tool loop, MCP in outline, agents and where a person steps in, and the mistakes in each.])

= How to use this

Class 5 covered the starting point and the mistakes. This handout covers the rest. The first link in each list is the one to read if you only read one.

Run the scripts from the repository root. `retrieval_check.py` and `rag.py`'s search need no key; everything that answers, calls tools or drafts does.

= The mistakes, as a checklist

Before a retrieval, tool or agent feature ships:

+ Is there a set of questions with known answers, and how often is the right document in the top three?
+ Does it say "not in the runbooks" when nothing matches, and has that been tested?
+ Does every answer show its sources and their "last reviewed" date?
+ Are chunks filtered by the tool's data ceiling before anything reaches the prompt?
+ Is every tool argument validated before the tool runs?
+ Does anything that writes, pays, sends or grants access wait for a person?
+ Is there a step limit, a time limit and a cost limit?
+ Does any one agent combine private data, untrusted input and a way to send data out? Remove one.
+ Is every MCP server in the directory, and has someone read what its tools do?

= Retrieval: checking it, then improving it

*Why it matters.* When a retrieval answer is wrong, the search is usually at fault, not the model. Measure the search on its own first. Then improve it with hybrid search.

*Run.*
#run("uv run code/class05/retrieval_check.py   # keyword search, ten questions, no key
uv run code/class05/hybrid.py            # keyword, vector and hybrid; downloads an embedding model once
uv run code/class05/rag.py")

`retrieval_check.py` prints every miss with what it found instead. Keyword search misses the questions worded differently from the runbook: "my pass doesn't open the door" against a runbook that says "badge". `hybrid.py` scores keyword, vector and both, merged with reciprocal rank fusion, on the same ten questions.

*Try.* Add three questions from your own team to `QUESTIONS`, worded the way people actually ask. Change `k` in `rag.py`'s answer from 3 to 10 and see whether answers get better or worse. Ask `rag.answer()` something no runbook covers, and check that it says so.

*Read.*
#source("https://www.anthropic.com/research/contextual-retrieval", [Contextual retrieval], kind: "guide", by: [Anthropic])[Chunking, hybrid search, reranking, and measured gains from each. The most practical single read on retrieval.]
#source("https://eugeneyan.com/writing/llm-patterns/", [Patterns for building LLM-based systems and products], kind: "guide", by: [Eugene Yan])[Retrieval, evals, guardrails and caching as patterns, with trade-offs.]
#source("https://jxnl.co/writing/2024/05/22/systematically-improving-your-rag/", [Systematically improving your RAG], kind: "guide", by: [Jason Liu])[Start from retrieval metrics on real questions, then fix the biggest category of failure.]
#source("https://plg.uwaterloo.ca/~gvcormac/cormacksigir09-rrf.pdf", [Reciprocal rank fusion], kind: "paper", by: [Cormack, Clarke and Büttcher, 2009])[Two pages. Why merging by rank beats merging by score.]
#source("https://www.postgresql.org/docs/current/textsearch.html", [Full text search], kind: "docs", by: [PostgreSQL])[Keyword search in the database you already run.]
#source("https://github.com/pgvector/pgvector", [pgvector], kind: "project")[Vector search in Postgres, so hybrid search needs no new service.]
#source("https://www.sqlite.org/fts5.html", [SQLite FTS5], kind: "docs")[Keyword search in a single file, for a laptop prototype.]
#source("https://arxiv.org/abs/2005.11401", [Retrieval-augmented generation for knowledge-intensive NLP tasks], kind: "paper", by: [Lewis et al., 2020])[Where the name RAG comes from.]

= Tools

*Why it matters.* The model asks; our code acts. Tool descriptions are prompts, error results are information, and the approval step is the safety.

*Run.*
#run("uv run code/class05/tools.py")

*Try.* Decline the ticket when asked and read what the model tells you. Ask about a batch ID that doesn't exist. Add a `get_runbook` tool that calls `rag.search`, and a check that rejects any `batch_id` not matching `IH-\d{6}-\d{2}` before the tool runs.

*Read.*
#source("https://www.anthropic.com/research/writing-tools-for-agents", [Writing effective tools for agents], kind: "guide", by: [Anthropic])[Naming, descriptions, error messages and how to test tools with the model itself.]
#source("https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview", [Tool use overview], kind: "docs", by: [Anthropic])[The call-and-return loop, in one provider's API.]
#source("https://platform.openai.com/docs/guides/function-calling", [Function calling], kind: "docs", by: [OpenAI])[The same loop in the API the class code uses.]

= MCP

*Why it matters.* MCP turns "every app times every system" integrations into one server per system. A server is still software you install and run, with whatever access you give it.

*Run.* `code/class05/server.py` is a server with one tool, one resource and one prompt. `host-config.json` shows how a host starts it. To poke at it without a host, run the MCP Inspector (Node required):
#run("npx @modelcontextprotocol/inspector uv run code/class05/server.py")

*Try.* Add a resource for the handwritten tickets, then decide whether it should exist given their data class. Read the tool descriptions of one public MCP server and ask what a malicious description could tell the model to do.

*Read.*
#source("https://modelcontextprotocol.io/", [Model Context Protocol], kind: "spec and docs")[Start with the introduction and the architecture page; the specification is for implementers.]
#source("https://github.com/modelcontextprotocol/python-sdk", [MCP Python SDK], kind: "project")[What `server.py` is built on. The README covers tools, resources, prompts and transports.]
#source("https://github.com/modelcontextprotocol/inspector", [MCP Inspector], kind: "tool")[Test a server's tools and resources by hand.]
#source("https://modelcontextprotocol.io/specification/latest", [MCP specification], kind: "spec")[Read the security and authorisation sections before running a remote server.]

= Agents

*Why it matters.* Most problems that look like they need an agent need a fixed workflow: a few model calls in a known order. Agents earn their cost when the steps can't be known in advance, and they need limits and people at the expensive steps.

*Run.*
#run("uv run code/class05/supervisor.py")

*Try.* Run it on the Nhava Sheva ticket and read the draft before saying yes. Then give it a ticket with no shipment ID, and one that isn't customs at all. Find two handwritten tickets that should never reach an agent and say why.

*Read.*
#source("https://www.anthropic.com/research/building-effective-agents", [Building effective agents], kind: "guide", by: [Anthropic])[Workflows against agents, five common patterns, and when not to build an agent. Read this first.]
#source("https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/", [The lethal trifecta for AI agents], kind: "article", by: [Simon Willison])[Private data, untrusted content, and a way to send data out: any agent with all three can be made to leak.]
#source("https://www.anthropic.com/research/effective-context-engineering-for-ai-agents", [Effective context engineering for AI agents], kind: "guide", by: [Anthropic])[What goes into the window at each step of a long-running agent.]
#source("https://www.anthropic.com/research/multi-agent-research-system", [How we built our multi-agent research system], kind: "case study", by: [Anthropic])[A supervisor and workers in production: what worked, what it cost, how they evaluated it.]
#source("https://lilianweng.github.io/posts/2023-06-23-agent/", [LLM powered autonomous agents], kind: "survey", by: [Lilian Weng])[Planning, memory and tool use, with the research behind each.]
#source("https://arxiv.org/abs/2210.03629", [ReAct: synergizing reasoning and acting in language models], kind: "paper", by: [Yao et al., 2022])[The reason-then-act loop most agents still use.]

= Agents talking to agents: A2A

*Why it matters.* MCP connects a model to tools. The Agent2Agent protocol (A2A) connects one agent to another, across systems and vendors: each agent publishes an agent card saying what it can do, and others send it tasks. Use it when the other agent belongs to someone else; inside one codebase, a function call is enough, as in `supervisor.py`.

*Read.*
#source("https://github.com/a2aproject/A2A", [A2A protocol], kind: "spec and project", by: [Linux Foundation])[The specification, samples and SDKs. Read the overview and the agent card section.]
