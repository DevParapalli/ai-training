#import "theme.typ": *

// ---- Class facts: change here, not in the slides ---------------------------
#let n = 11
#let title = [MCP: one way to plug tools in]
#let subtitle = [The Model Context Protocol, so every tool doesn't need its own integration with every AI app.]
#let server-name = "lol-ops"
#let hosts = ([AI chat apps on the desktop], [Code editors], [Our own agents])
// -----------------------------------------------------------------------------

#show: class.with(n: n)

#title-slide(number: [#n], title: title, subtitle: subtitle,
  facts: ([60 min], [Recorded], [Class #n of #total-classes]))

#outline-slide(current: none)

#section-slide(number: [1], title: [The problem MCP fixes], subtitle: [Every app times every tool.])

#compare(title: [Without a standard, every AI app needs its own connector to every system], pick: "right",
  left: ([Before], [
    - 3 AI apps × 5 of our systems = 15 integrations
    - Each built differently, each maintained separately
    - A #app.track change breaks all of them
  ]),
  right: ([With MCP], [
    - Each system gets one MCP server
    - Each app speaks MCP once
    - 3 + 5 = 8 pieces, and they all fit
  ]),
)

#split(title: [Three parts, like a plug and a socket], sub: [The host is the app people use; the server is what we build.],
  ([Host], [The AI app: a chat app, a code editor, our own agent. It runs the model.]),
  ([Client], [Lives inside the host. One per server it connects to.]),
  ([Server], [Ours. Exposes #app.track lookups, runbooks, prompts. Knows nothing about which model is asking.]),
)

#section-slide(number: [2], title: [What a server offers], subtitle: [Tools, resources and prompts.])

#explain(title: [A server can offer three kinds of thing],
  ([Tools], [Actions the model can ask for: look up a shipment, check a batch. Same idea as class 10.]),
  ([Resources], [Things to read: a runbook, a document, a record. The host decides when to include them.]),
  ([Prompts], [Ready-made instructions a person picks from a menu: "triage this ticket".]),
)

#claim(title: [Two ways to connect: on the same machine, or over the network])[
  #cols(
    tile[*Local (stdio)* \ The host starts the server as a program on your laptop. Simple, private, one user.],
    tile[*Remote (HTTP)* \ The server runs somewhere central. Shared by a team, needs sign-in and access rules.],
  )
]

#section-slide(number: [3], title: [Using it safely], subtitle: [A server is code you run.])

#statement(sub: [Installing an MCP server is installing software. It can read what it's allowed to, and do what it's allowed to.])[A server is #hl[code you run], so treat it that way.]

#claim(title: [MCP servers go through the same rules as any other tool])[
  - Only servers in our directory, each with a data ceiling (class 8)
  - Read what a server's tools actually do before connecting it
  - Remote servers sign users in; they don't share one key
  - Watch for tool descriptions that try to give the model orders
  #notes[A malicious server can put instructions in a tool's description. The model reads descriptions as trusted. That's why the directory exists.]
]

#section-slide(number: [4], title: [Code walkthrough], subtitle: [A small server for operations.])

#code-slide(title: [One tool, one resource and one prompt in about twenty lines], file: "code/class11/server.py", highlight: (1, 3, 8, 13))[
  ```python
  mcp = FastMCP("lol-ops")

  @mcp.tool()
  def get_shipment(shipment_id: str) -> dict:
      """Where a LOL shipment is and why, e.g. LOL-SH-4472190."""
      return SHIPMENTS.get(shipment_id, {"error": "no such shipment"})

  @mcp.resource("runbook://{name}")
  def runbook(name: str) -> str:
      return (RUNBOOKS / f"{name}.md").read_text(encoding="utf-8")

  @mcp.prompt()
  def triage(ticket: str) -> str:
      return f"Route this LOL ticket to one queue and say why in one sentence:\n\n{ticket}"
  ```
]

#code-slide(title: [Adding it to a host is a few lines of config], file: "code/class11/host-config.json")[
  ```json
  {
    "mcpServers": {
      "lol-ops": { "command": "uv", "args": ["run", "code/class11/server.py"] }
    }
  }
  ```
]

#on-the-card(at: (6,))

#close(actions: (
  [Connect `server.py` to an MCP host you're allowed to use and ask about LOL-SH-4472190.],
  [Add a resource for the handwritten tickets, then decide whether it should exist.],
  [Read the class 12 pre-reading on agents.],
), contact: [Questions after class: the course channel.])
