# /// script
# requires-python = ">=3.11"
# dependencies = ["pandas>=2.2", "scikit-learn>=1.5", "openai>=1.40", "pydantic>=2.7"]
# ///
"""Class 13: evaluate the class 7 triage on a fixed test set drawn from the handwritten tickets.
Same set every run, so a change to the prompt or the model shows up as a number."""
import sys
from pathlib import Path

import pandas as pd
from sklearn.metrics import classification_report

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "class07"))
from common import DATA
from extract_json import triage

TEST = pd.read_csv(DATA / "tickets_handwritten.csv").sample(60, random_state=13)   # fixed: same 60 every time

preds, failures = [], 0
for _, row in TEST.iterrows():
    try:
        preds.append(triage(f"{row.short_description}. {row.description}").queue)
    except RuntimeError:
        preds.append("to-a-person")
        failures += 1

print(classification_report(TEST.queue, preds, zero_division=0))
print(f"sent to a person: {failures} of {len(TEST)}")
