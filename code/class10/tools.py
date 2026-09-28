# /// script
# requires-python = ">=3.11"
# dependencies = ["openai>=1.40"]
# ///
"""Class 10: let the model ask for an action. Fake InvoiceHub and Tracklane lookups, and a ticket
that needs a person's yes before it's created."""
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import client

# Stand-ins for real systems. In production these call InvoiceHub and Tracklane.
BATCHES = {"IH-260615-11": {"status": "processing", "since": "06:00", "invoices": 14}}
SHIPMENTS = {"LOL-SH-4472190": {"port": "Nhava Sheva", "status": "held", "reason": "bill of entry rejected"}}


def get_batch_status(batch_id: str) -> dict:
    return BATCHES.get(batch_id, {"error": "no such batch"})


def get_shipment(shipment_id: str) -> dict:
    return SHIPMENTS.get(shipment_id, {"error": "no such shipment"})


def create_ticket(queue: str, summary: str) -> dict:
    if input(f"Create ticket in {queue}: {summary!r}? [y/N] ").lower() != "y":   # a person says yes
        return {"created": False, "reason": "declined by operator"}
    return {"created": True, "id": "TKT-419001"}


TOOLS = {f.__name__: f for f in (get_batch_status, get_shipment, create_ticket)}
SCHEMAS = [
    {"type": "function", "function": {"name": "get_batch_status", "description": "Status of an InvoiceHub import batch, e.g. IH-260615-11.",
     "parameters": {"type": "object", "properties": {"batch_id": {"type": "string"}}, "required": ["batch_id"]}}},
    {"type": "function", "function": {"name": "get_shipment", "description": "Where a shipment is, e.g. LOL-SH-4472190.",
     "parameters": {"type": "object", "properties": {"shipment_id": {"type": "string"}}, "required": ["shipment_id"]}}},
    {"type": "function", "function": {"name": "create_ticket", "description": "Open a ticket. A person must approve.",
     "parameters": {"type": "object", "properties": {"queue": {"type": "string"}, "summary": {"type": "string"}}, "required": ["queue", "summary"]}}},
]


def run(question: str, max_steps: int = 5) -> str:
    messages = [{"role": "user", "content": question}]
    for _ in range(max_steps):
        reply = client().chat.completions.create(model=os.environ["LLM_MODEL"], messages=messages, tools=SCHEMAS)
        msg = reply.choices[0].message
        if not msg.tool_calls:
            return msg.content
        messages.append(msg)
        for call in msg.tool_calls:
            result = TOOLS[call.function.name](**json.loads(call.function.arguments))
            messages.append({"role": "tool", "tool_call_id": call.id, "content": json.dumps(result)})
    return "stopped: too many steps"


if __name__ == "__main__":
    print(run("Is batch IH-260615-11 stuck? If it is, open a ticket for AP systems."))
