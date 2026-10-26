# /// script
# requires-python = ">=3.11"
# dependencies = ["openai>=1.40"]
# ///
"""Class 6: an LLM grading draft replies, checked against grades a person gave the same drafts.
The drafts include the traps: a long reply that's wrong, a short one that's right, an invented date."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import ask

RUNBOOK = ("ERR-IH-0413 means the file failed validation, usually a missing PO number or a wrong supplier ID. "
           "Fix the file and re-import. 'Processing' for more than 2 hours is stuck: retry from Imports > Actions.")

# (draft reply to "Armadillo batch IH-260301-07 shows ERR-IH-0413", the grade a person gave it)
DRAFTS = [
    ("The batch failed validation, usually a missing PO number. Fix the file and re-import it.", "pass"),
    ("Thanks for raising this. ERR-IH-0413 is a validation failure. Please check the PO numbers and supplier "
     "ID in the file, correct them, and re-import. If it still fails, reply here and we'll look.", "pass"),
    ("ERR-IH-0413 means the batch is stuck in processing. Retry it from Imports > Actions and it will clear.", "fail"),
    ("We've escalated this to InvoiceHub support, who have confirmed a fix will be deployed on 14 June. "
     "In the meantime, there is nothing you need to do. We appreciate your patience and will keep you "
     "updated on progress through this ticket as more information becomes available.", "fail"),
    ("Re-import it.", "fail"),
    ("Validation failed. Check the PO number and supplier ID, fix the file, re-import.", "pass"),
]

agree = 0
for draft, human in DRAFTS:
    verdict = ask(f"Runbook:\n{RUNBOOK}\n\nDraft reply to a ticket about ERR-IH-0413:\n{draft}\n\n"
                  "Is the draft correct according to the runbook, with nothing invented? "
                  "Answer with one word: pass or fail.", temperature=0).strip().lower().rstrip(".")
    agree += verdict == human
    flag = "" if verdict == human else "   <- disagrees with the person"
    print(f"{human:<5} {verdict:<5} {draft[:60]}...{flag}")
print(f"judge agrees with the person on {agree} of {len(DRAFTS)}")
