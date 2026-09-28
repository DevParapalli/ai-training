# /// script
# requires-python = ">=3.11"
# dependencies = ["openai>=1.40"]
# ///
"""Class 1: streaming. The same call, with the answer printed as it arrives."""
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import client

messages = [{"role": "user", "content": "In three sentences: why might an invoice import stay in 'processing' overnight?"}]
stream = client().chat.completions.create(model=os.environ["LLM_MODEL"], messages=messages, stream=True)
for chunk in stream:
    print(chunk.choices[0].delta.content or "", end="", flush=True)
print()
