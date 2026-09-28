# /// script
# requires-python = ">=3.11"
# dependencies = ["openai>=1.40"]
# ///
"""Class 1: the first call. One request, one reply."""
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import client

TICKET = "TKT-204117: InvoiceHub import for Armadillo Security Services shows ERR-IH-0413 since 02:00. Batch IH-260301-07."

reply = client().chat.completions.create(
    model=os.environ["LLM_MODEL"],
    messages=[{"role": "user", "content": f"Which support queue should handle this ticket? {TICKET}"}],
)
print(reply.choices[0].message.content)
print("tokens used:", reply.usage.total_tokens)
