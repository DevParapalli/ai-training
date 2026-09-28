# /// script
# requires-python = ">=3.11"
# dependencies = ["mcp>=1.2"]
# ///
"""Class 11: a small MCP server. One tool (shipment lookup), one resource (a runbook), one prompt (triage).
Any MCP host can use it: add it to the host's config and it shows up."""
from pathlib import Path

from mcp.server.fastmcp import FastMCP

RUNBOOKS = Path(__file__).resolve().parent.parent.parent / "data" / "runbooks"
SHIPMENTS = {"LOL-SH-4472190": {"port": "Nhava Sheva", "status": "held", "reason": "bill of entry rejected"}}

mcp = FastMCP("lol-ops")


@mcp.tool()
def get_shipment(shipment_id: str) -> dict:
    """Where a LOL shipment is and why, e.g. LOL-SH-4472190."""
    return SHIPMENTS.get(shipment_id, {"error": "no such shipment"})


@mcp.resource("runbook://{name}")
def runbook(name: str) -> str:
    """A LOL runbook by file name, e.g. tracklane-customs-docs."""
    return (RUNBOOKS / f"{name}.md").read_text(encoding="utf-8")


@mcp.prompt()
def triage(ticket: str) -> str:
    """Triage a ticket into one of LOL's queues."""
    return f"Route this LOL ticket to one queue and say why in one sentence:\n\n{ticket}"


if __name__ == "__main__":
    mcp.run()          # stdio by default; mcp.run(transport="streamable-http") for a shared server
