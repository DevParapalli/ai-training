# /// script
# requires-python = ">=3.11"
# dependencies = ["openai>=1.40", "pandas>=2.2"]
# ///
"""Class 6: overflow the context window on purpose and see what the provider does."""
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import client, tickets

history = "\n".join(tickets().text)          # every generated ticket, far too much
prompt = f"Here is our ticket history:\n{history}\n\nWhich queue gets the most tickets at period end?"
try:
    reply = client().chat.completions.create(model=os.environ["LLM_MODEL"], messages=[{"role": "user", "content": prompt}])
    print(reply.choices[0].message.content)
except Exception as err:                     # most providers refuse; some silently cut the start off
    print(type(err).__name__, str(err)[:300])
