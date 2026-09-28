# /// script
# requires-python = ">=3.11"
# dependencies = ["pandas>=2.2", "scikit-learn>=1.5", "sentence-transformers>=3.0"]
# ///
"""Class 5: local sentence embeddings plus logistic regression. No data leaves the machine."""
import sys
import time
from pathlib import Path

from sentence_transformers import SentenceTransformer
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import tickets

df = tickets()
train, test = train_test_split(df, test_size=0.2, stratify=df.queue, random_state=7)
enc = SentenceTransformer("Qwen/Qwen3-Embedding-0.6B")
start = time.perf_counter()
X_train, X_test = enc.encode(list(train.text)), enc.encode(list(test.text))
per_ticket = (time.perf_counter() - start) / (len(train) + len(test)) * 1000
clf = LogisticRegression(max_iter=1000).fit(X_train, train.queue)
print(f"accuracy {clf.score(X_test, test.queue):.3f}  ·  {per_ticket:.0f} ms per ticket to embed")
