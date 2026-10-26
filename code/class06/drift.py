# /// script
# requires-python = ">=3.11"
# dependencies = ["numpy>=1.26", "pandas>=2.2", "scikit-learn>=1.5"]
# ///
"""Class 6: spot drift without waiting for labels. The model is trained on the generated tickets; "this month"
is either more of the same, or the handwritten tickets, which read the way people really write.
Three signals: words the model never saw, how sure it is, and whether the queue mix moved (PSI)."""
import sys
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import DATA, tickets

df = tickets()
train, same = train_test_split(df, test_size=300, random_state=6)
real = pd.read_csv(DATA / "tickets_handwritten.csv")
real["text"] = real.short_description + ". " + real.description

vec = TfidfVectorizer(min_df=2)
model = LogisticRegression(max_iter=1000).fit(vec.fit_transform(train.text), train.queue)
vocab = set(vec.vocabulary_)
analyse = vec.build_analyzer()


def unseen(texts) -> float:
    words = [w for t in texts for w in analyse(t)]
    return sum(w not in vocab for w in words) / len(words)


def psi(expected: pd.Series, actual: pd.Series) -> float:
    """Population stability index over the queue mix. Under 0.1 is stable; over 0.25 needs a look."""
    queues = sorted(set(expected) | set(actual))
    e = expected.value_counts(normalize=True).reindex(queues, fill_value=0).to_numpy() + 1e-4
    a = actual.value_counts(normalize=True).reindex(queues, fill_value=0).to_numpy() + 1e-4
    return float(np.sum((a - e) * np.log(a / e)))


baseline_mix = pd.Series(model.predict(vec.transform(train.text)))
print(f"{'this month':<22} {'unseen words':>12} {'mean confidence':>16} {'PSI, predicted mix':>19}")
for name, batch in (("same as training", same), ("handwritten tickets", real)):
    X = vec.transform(batch.text)
    conf = model.predict_proba(X).max(axis=1).mean()
    mix = pd.Series(model.predict(X))
    print(f"{name:<22} {unseen(batch.text):>12.0%} {conf:>16.2f} {psi(baseline_mix, mix):>19.3f}")
