# /// script
# requires-python = ">=3.11"
# dependencies = ["pandas>=2.2", "scikit-learn>=1.5"]
# ///
"""Class 3: forecast daily ticket volume. Two naive baselines, then a model that knows the calendar.
Train on everything before the last eight weeks, score on those eight weeks."""
import sys
from pathlib import Path

import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import tickets

df = tickets()
daily = (df.assign(day=df.opened_at.dt.tz_localize(None).dt.normalize())
           .groupby("day").agg(volume=("ticket_id", "size"), period_end=("period_end", "max")))
daily = daily.asfreq("D", fill_value=0)
daily["weekday"] = daily.index.day_of_week
daily["last_week"] = daily.volume.shift(7)

cut = daily.index.max() - pd.Timedelta(weeks=8)
train, test = daily[daily.index <= cut].dropna(), daily[daily.index > cut]

# Baseline 1: the average day. Baseline 2: same weekday last week.
mean_day = [train.volume.mean()] * len(test)
seasonal = test.last_week

# The model: weekday and period-end as features. Nothing it couldn't know in advance.
X = lambda d: pd.get_dummies(d.weekday.astype("category"), prefix="wd").assign(period_end=d.period_end)
model = LinearRegression().fit(X(train), train.volume)
predicted = model.predict(X(test))

print(f"test window: {test.index.min():%Y-%m-%d} to {test.index.max():%Y-%m-%d}, {len(test)} days")
for name, pred in (("average day", mean_day), ("same day last week", seasonal), ("weekday + period end", predicted)):
    print(f"{name:<22} MAE {mean_absolute_error(test.volume, pred):.2f} tickets/day")
close = test.period_end == 1
print(f"on close days only: last week {mean_absolute_error(test.volume[close], seasonal[close]):.2f}, "
      f"model {mean_absolute_error(test.volume[close], predicted[close]):.2f}")
