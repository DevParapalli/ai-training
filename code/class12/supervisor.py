# /// script
# requires-python = ">=3.11"
# dependencies = ["openai>=1.40"]
# ///
"""Class 12: a supervisor agent that hands customs problems to a worker agent, with a step limit
and a person approving anything that leaves the building."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "class09"))
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "class10"))
from common import ask
from rag import search
from tools import get_shipment

MAX_STEPS = 6


def customs_worker(shipment_id: str) -> str:
    """Worker: look the shipment up, find the runbook step, draft the email. Never sends it."""
    ship = get_shipment(shipment_id)
    steps = search(f"customs documents {ship.get('reason', '')}", k=2)
    notes = "\n".join(c["text"] for _, c in steps)
    return ask(f"Shipment: {ship}\nRunbook:\n{notes}\n\nDraft a short email to the customer's logistics lead "
               "saying what's missing and what we need from them. Don't promise dates.", temperature=0.3)


def supervisor(ticket: str) -> str:
    for step in range(MAX_STEPS):
        decision = ask("You route LOL tickets. Reply with exactly one word: CUSTOMS if it's a customs hold "
                       f"on a shipment, otherwise HUMAN.\n\n{ticket}", temperature=0).strip().upper()
        if decision == "CUSTOMS":
            shipment = next((w for w in ticket.split() if w.startswith("LOL-SH-")), None)
            if not shipment:
                return "handed to a person: no shipment ID in the ticket"
            draft = customs_worker(shipment.strip(".,"))
            ok = input(f"\n--- draft ---\n{draft}\n--- send? [y/N] ")
            return "sent" if ok.lower() == "y" else "held for a person"
        return "handed to a person"
    return "stopped: step limit"


if __name__ == "__main__":
    print(supervisor("Bill of entry rejected at Nhava Sheva for LOL-SH-4472190, consignee GST number missing on invoice."))
