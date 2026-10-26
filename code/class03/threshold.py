# /// script
# requires-python = ">=3.11"
# dependencies = ["pandas>=2.2", "scikit-learn>=1.5"]
# ///
"""Class 3: let the classifier say "I don't know". Route only when it's confident; send the rest to a person.
Trained on the generated tickets, scored on the handwritten ones."""
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
proba = model.predict_proba(real.text)
real["pred"] = model.classes_[proba.argmax(axis=1)]
real["confidence"] = proba.max(axis=1)

print(f"{'threshold':>9}  {'auto-routed':>11}  {'right when routed':>17}  {'not-ours caught':>15}")
for t in (0.0, 0.2, 0.25, 0.3, 0.4, 0.5):
    auto = real[real.confidence >= t]
    right = (auto.queue == auto.pred).mean() if len(auto) else 0
    caught = ((real.queue == "other") & (real.confidence < t)).sum()
    print(f"{t:>9.2f}  {len(auto) / len(real):>10.0%}  {right:>17.0%}  {caught:>9} of {(real.queue == 'other').sum()}")
