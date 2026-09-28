# /// script
# requires-python = ">=3.11"
# dependencies = ["pandas>=2.2", "scikit-learn>=1.5"]
# ///
"""Class 3: find the odd hosts in the integration signal feed with an isolation forest."""
from pathlib import Path

import pandas as pd
from sklearn.ensemble import IsolationForest

DATA = Path(__file__).resolve().parent.parent.parent / "data"
df = pd.read_csv(DATA / "signals.csv", parse_dates=["ts"])
X = df[["cpu_pct", "mem_pct", "job_latency_ms"]]
df["flag"] = IsolationForest(contamination=0.005, random_state=7).fit_predict(X) == -1

hit = (df.flag & (df.injected_fault == 1)).sum()
print(f"flagged {df.flag.sum()} readings; {hit} of {df.injected_fault.sum()} injected faults caught")
print(df[df.flag].groupby("host").size().sort_values(ascending=False).head(6))
