# /// script
# requires-python = ">=3.11"
# dependencies = ["pandas>=2.2", "openai>=1.40"]
# ///
"""Class 4: zero-shot against few-shot on the handwritten tickets. The examples are hard cases, not easy ones."""
import sys
from pathlib import Path

import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import DATA, ask

QUEUES = ["access-request", "password-reset", "hardware", "device-enrolment", "network-vpn", "email-collab",
          "report-export", "invoice-import", "purchase-order", "ledger-close", "payroll", "customer-payments",
          "shipment-ops", "warehouse-devices", "facilities", "catering", "security-access", "hr-query", "other"]

# Vague, two-in-one and not-ours tickets: the cases a model gets wrong without being shown.
EXAMPLES = [
    ("Account locked. Can't get in since this morning.", "password-reset"),
    ("numbers look wrong in PayGrid for the Leeds depot", "payroll"),
    ("Coffee machine on 3rd floor broken again", "catering"),
    ("Supplier emailed new bank details from a gmail address, please update before Friday's run", "other"),
    ("Harbor says pending for CW-48213, two days now", "device-enrolment"),
]

real = pd.read_csv(DATA / "tickets_handwritten.csv").sample(40, random_state=4)   # small, to keep the bill small
real["text"] = real.short_description + ". " + real.description


def route(text: str, shots: bool) -> str:
    shown = "".join(f"Ticket: {t}\nQueue: {q}\n\n" for t, q in EXAMPLES) if shots else ""
    prompt = (f"Route LOL service desk tickets to exactly one of {QUEUES}. Reply with the queue name only.\n\n"
              f"{shown}Ticket: {text}\nQueue:")
    return ask(prompt, temperature=0).strip().lower()


for shots in (False, True):
    preds = [route(t, shots) for t in real.text]
    print(f"{'few-shot' if shots else 'zero-shot':<9} {(real.queue == preds).mean():.0%} on {len(real)} tickets")
