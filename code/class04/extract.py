# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Class 4: pull fixed-shape fields out of ticket text with regular expressions."""
import re

PATTERNS = {
    "ticket":   re.compile(r"\bTKT-\d{6}\b"),
    "shipment": re.compile(r"\bLOL-SH-\d{7}\b"),
    "po":       re.compile(r"\bPO-4500\d{6}\b"),
    "batch":    re.compile(r"\bIH-\d{6}-\d{2}\b"),
    "worker":   re.compile(r"\bCW-\d{5}\b"),
    "error":    re.compile(r"\bERR-[A-Z]{2}-\d{4}\b"),
    "account":  re.compile(r"\b\d{4}-\d{2}\b"),
}


def extract(text: str) -> dict[str, list[str]]:
    return {name: p.findall(text) for name, p in PATTERNS.items()}


if __name__ == "__main__":
    sample = "Re TKT-204117: batch IH-260301-07 for PO-4500318822 failed with ERR-IH-0413; contractor CW-48213 raised it about LOL-SH-4472190."
    for k, v in extract(sample).items():
        print(f"{k:<8} {v}")
