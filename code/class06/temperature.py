# /// script
# requires-python = ">=3.11"
# dependencies = ["openai>=1.40"]
# ///
"""Class 6: the same prompt at three temperatures, three times each."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import ask

PROMPT = "Write a one-line subject for a ticket about Rotterdam scanners not syncing."
for t in (0.0, 0.7, 1.5):
    print(f"--- temperature {t}")
    for _ in range(3):
        print(" ", ask(PROMPT, temperature=t).strip())
