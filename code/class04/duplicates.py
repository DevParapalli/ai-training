# /// script
# requires-python = ">=3.11"
# dependencies = ["pandas>=2.2", "scikit-learn>=1.5"]
# ///
"""Class 4: find likely duplicates of a new ticket with TF-IDF and cosine similarity."""
import sys
from pathlib import Path

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import tickets

NEW = "Invoices from Armadillo Security Services not showing in InvoiceHub. Batch reference IH-260301-07."
CUTOFF = 0.6

df = tickets()
vec = TfidfVectorizer(ngram_range=(1, 2), min_df=2).fit(df.text)
sims = cosine_similarity(vec.transform([NEW]), vec.transform(df.text))[0]
df["score"] = sims
print(df[df.score > CUTOFF].sort_values("score", ascending=False)[["ticket_id", "queue", "score", "short_description"]].head(8))

weights = dict(zip(vec.get_feature_names_out(), vec.transform([NEW]).toarray()[0]))
print(sorted(((round(w, 2), t) for t, w in weights.items() if w > 0), reverse=True)[:8])
