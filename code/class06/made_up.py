# /// script
# requires-python = ">=3.11"
# dependencies = ["openai>=1.40"]
# ///
"""Class 6: ask about something the model can't know. Watch it answer anyway."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import ask

print(ask("What is the current status of LOL shipment LOL-SH-4472190 at Nhava Sheva?"))
print("---")
print(ask("What is the current status of LOL shipment LOL-SH-4472190 at Nhava Sheva? "
          "If you don't have access to that data, say so and stop."))
