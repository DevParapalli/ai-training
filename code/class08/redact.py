# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Class 8: strip what must not leave the machine, before any prompt is built."""
import re

RULES = [
    (re.compile(r"[\w.+-]+@[\w-]+(?:\.[\w-]+)+"), "<email>"),
    (re.compile(r"\b[A-Z]{2}\d{2}(?:\s?[A-Z0-9]{1,4}){3,8}\b"), "<iban>"),
    (re.compile(r"\bE\d{6}\b"), "<employee-id>"),
    (re.compile(r"\bCW-\d{5}\b"), "<contractor-id>"),
    (re.compile(r"\+?\d[\d\s-]{8,}\d"), "<phone>"),
]


def redact(text: str) -> str:
    for pattern, placeholder in RULES:
        text = pattern.sub(placeholder, text)
    return text


if __name__ == "__main__":
    sample = ("Caller says his May payslip is missing overtime. Employee E204518, reach him on +44 7700 900123 "
              "or darnell.brooks@lol-logistics.example. New bank DE89 3704 0044 0532 0130 00.")
    print(redact(sample))
