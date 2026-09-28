# /// script
# requires-python = ">=3.11"
# dependencies = ["openai>=1.40", "pydantic>=2.7"]
# ///
"""Class 7: get output a program can trust. A schema, validation, and a retry that feeds the error back."""
import json
import sys
from pathlib import Path
from typing import Literal

from pydantic import BaseModel, ValidationError

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import ask

Queue = Literal["access-request", "password-reset", "hardware", "device-enrolment", "network-vpn",
                "email-collab", "report-export", "invoice-import", "purchase-order", "ledger-close",
                "payroll", "customer-payments", "shipment-ops", "warehouse-devices", "facilities",
                "catering", "security-access", "hr-query", "other"]


class Triage(BaseModel):
    queue: Queue
    shipment_id: str | None       # LOL-SH-1234567, if the ticket names one
    site: str | None              # Hamburg, Rotterdam, Memphis, Chennai, Singapore, Felixstowe
    blocking: bool                # is someone unable to work right now?
    summary: str                  # one sentence, plain English


SYSTEM = ("You triage tickets for Lafayette O'Reilly Logistics. Reply with JSON only, matching this schema: "
          + json.dumps(Triage.model_json_schema()))

TICKET = ("Bill of entry rejected at Nhava Sheva for LOL-SH-4472190, consignee GST number missing on invoice. "
          "Raised by Rajesh Pillai, Operations, Chennai.")


def triage(ticket: str, attempts: int = 3) -> Triage:
    prompt = f"{SYSTEM}\n\nTicket:\n{ticket}"
    for _ in range(attempts):
        raw = ask(prompt, temperature=0)
        try:
            return Triage.model_validate_json(raw)
        except ValidationError as err:            # tell the model exactly what was wrong, then try again
            prompt += f"\n\nYour last reply was invalid:\n{err}\nReply again with valid JSON only."
    raise RuntimeError("no valid reply after retries; send to a person")


if __name__ == "__main__":
    print(triage(TICKET).model_dump_json(indent=2))
