# /// script
# requires-python = ">=3.11"
# dependencies = ["pandas>=2.2", "scikit-learn>=1.5"]
# ///
"""Class 3: train on the generated tickets, then score on the handwritten ones.

The handwritten set is how people actually write: one word, typos, two problems
in one ticket, the coffee machine. It shows how far a clean test score travels.
"""
import sys
from pathlib import Path

import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import make_pipeline

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import DATA, tickets

train = tickets()
real = pd.read_csv(DATA / "tickets_handwritten.csv")
real["text"] = real.short_description + ". " + real.description

model = make_pipeline(TfidfVectorizer(ngram_range=(1, 2), min_df=2),
                      LogisticRegression(max_iter=1000)).fit(train.text, train.queue)
real["pred"] = model.predict(real.text)
known = real[real.queue != "other"]
print(f"handwritten, known queues: {(known.queue == known.pred).mean():.3f} on {len(known)} tickets")
print(f"'other' tickets it still put in a queue: {(real.queue == 'other').sum()}")
print(real[real.queue != real.pred][["ticket_id", "queue", "pred", "short_description"]].head(12).to_string(index=False))
