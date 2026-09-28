# /// script
# requires-python = ">=3.11"
# dependencies = ["openai>=1.40"]
# ///
"""Class 14: log every model call with its prompt version, model, tokens, latency and cost."""
import json
import os
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import client

PRICE = {"input": 0.50, "output": 1.50}   # per million tokens; set from your provider's price list
LOG = Path("calls.jsonl")


def logged_call(messages: list[dict], prompt_version: str) -> str:
    start = time.perf_counter()
    reply = client().chat.completions.create(model=os.environ["LLM_MODEL"], messages=messages, temperature=0)
    u = reply.usage
    record = {
        "at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "prompt_version": prompt_version, "model": reply.model,
        "tokens_in": u.prompt_tokens, "tokens_out": u.completion_tokens,
        "latency_ms": round((time.perf_counter() - start) * 1000),
        "cost_usd": round((u.prompt_tokens * PRICE["input"] + u.completion_tokens * PRICE["output"]) / 1e6, 6),
    }
    with LOG.open("a", encoding="utf-8") as f:
        f.write(json.dumps(record) + "\n")
    return reply.choices[0].message.content
