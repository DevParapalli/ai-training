# /// script
# requires-python = ">=3.11"
# dependencies = ["scikit-learn>=1.5"]
# ///
"""Class 5: check the search before blaming the model. Questions worded the way people ask, each with the
runbook that answers it. Counts how often the right runbook is in the top 1 and the top 3. No model calls."""
from rag import search

# (question, runbook that answers it). Worded differently from the runbooks on purpose.
QUESTIONS = [
    ("Armadillo says our bank details changed, can I update them from their email?", "supplier-bank-change.md"),
    ("Scanner shows yesterday's pick list", "scanner-resync.md"),
    ("The invoices from the security supplier still haven't shown up since 6am", "invoicehub-batch-status.md"),
    ("What does ERR-IH-0413 mean?", "invoicehub-batch-status.md"),
    ("Customs at Nhava Sheva rejected the bill of entry, GST number missing", "tracklane-customs-docs.md"),
    ("PO got closed before the supplier invoiced, can we get it back?", "procura-reopen-po.md"),
    ("New agency contractor's laptop needs to be set up", "harbor-contractor-enrolment.md"),
    ("A visitor from BUM is coming on Thursday, what do I need to do?", "visitor-and-badges.md"),
    ("my pass doesn't open the warehouse door anymore", "visitor-and-badges.md"),
    ("Is it ok to approve a supplier's new account number on my own?", "supplier-bank-change.md"),
]


def check(search_fn=search, k: int = 3) -> None:
    top1 = top3 = 0
    for question, expected in QUESTIONS:
        sources = [c["source"] for _, c in search_fn(question, k=k)]
        top1 += sources[0] == expected
        top3 += expected in sources
        if expected not in sources:
            print(f"MISS  {question}\n      wanted {expected}, got {sources}")
    print(f"right runbook first: {top1}/{len(QUESTIONS)}   in top {k}: {top3}/{len(QUESTIONS)}")


if __name__ == "__main__":
    check()
