# /// script
# requires-python = ">=3.11"
# dependencies = ["pandas>=2.2", "scikit-learn>=1.5", "openai>=1.40"]
# ///
"""Class 5: the same tickets classified zero-shot by an LLM. No training, a cost on every call."""
import sys
from pathlib import Path

from sklearn.model_selection import train_test_split

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import ask, tickets

df = tickets()
QUEUES = sorted(df.queue.unique())
_, test = train_test_split(df, test_size=0.2, stratify=df.queue, random_state=7)
sample = test.sample(120, random_state=7)  # keep the bill small in class


def classify(text: str) -> str:
    prompt = f"Route this LOL service desk ticket to exactly one of {QUEUES}. Reply with the queue name only.\n\n{text}"
    return ask(prompt, temperature=0).strip().lower()


preds = [classify(t) for t in sample.text]
print(f"accuracy on {len(sample)} tickets: {(sample.queue == preds).mean():.3f}")
