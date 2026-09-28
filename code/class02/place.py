# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Class 2: the six questions as a function that suggests a place on the card."""
from dataclasses import dataclass

PLACES = ["A script", "A rule", "Classical ML", "A small trained model",
          "An LLM with a prompt", "An LLM plus retrieval, tools or agents", "Not yet"]


@dataclass
class Problem:
    name: str
    rule_known: bool = False
    steps_only: bool = False
    input: str = "text"            # "table", "text" or "media"
    has_labels: bool = False
    high_volume: bool = False
    has_ground_truth: bool = True
    needs_guarantee: bool = False
    needs_private_knowledge: bool = False
    must_act: bool = False


def place(p: Problem) -> int:
    if p.needs_guarantee or not p.has_ground_truth: return 7
    if p.rule_known: return 1 if p.steps_only else 2
    if p.input == "table" and p.has_labels: return 3
    if p.input == "text" and p.has_labels and p.high_volume: return 3
    if p.input == "media" and p.has_labels and p.high_volume: return 4
    if p.needs_private_knowledge or p.must_act: return 6
    return 5


EXAMPLES = [
    Problem("Restart the InvoiceHub import after three failed health checks", rule_known=True, steps_only=True),
    Problem("Route Gatehouse requests that already carry an access type", rule_known=True),
    Problem("Route free-text service desk tickets using two years of history", has_labels=True, high_volume=True),
    Problem("Summarise a payroll mismatch thread for the RCA"),
    Problem("Answer 'how do I reopen a PO' from Procura runbooks", needs_private_knowledge=True),
    Problem("Predict which GL account fails reconciliation next close", has_ground_truth=False),
]

if __name__ == "__main__":
    for p in EXAMPLES:
        print(f"{PLACES[place(p) - 1]:<40} {p.name}")
