# /// script
# requires-python = ">=3.11"
# dependencies = ["pandas>=2.2", "scikit-learn>=1.5"]
# ///
"""Class 3: a ticket classifier scored against a baseline and a set of keyword rules."""
import re
import sys
from pathlib import Path

from sklearn.dummy import DummyClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, classification_report
from sklearn.model_selection import train_test_split
from sklearn.pipeline import make_pipeline

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import tickets

RULES = [  # the rules a service desk lead would write on day one
    (r"password|locked out|account locked", "password-reset"),
    (r"invoicehub|invoice import|batch ih-", "invoice-import"),
    (r"reopen|po-4500|approval limit", "purchase-order"),
    (r"harbor|intune|company portal|enrol", "device-enrolment"),
    (r"payroll|paygrid|payslip", "payroll"),
    (r"reconcil|suspense|intercompany", "ledger-close"),
    (r"export|extract|report", "report-export"),
    (r"customs|tracklane|shipment|lol-sh-", "shipment-ops"),
    (r"scanner|label printer|dock terminal", "warehouse-devices"),
    (r"vpn|wi-fi|wifi", "network-vpn"),
    (r"badge|visitor|background check", "security-access"),
    (r"coffee|lunch|catering|canteen", "catering"),
    (r"outlook|teams|mailbox|sharepoint", "email-collab"),
]


def by_rules(text: str) -> str:
    t = text.lower()
    for pattern, queue in RULES:
        if re.search(pattern, t):
            return queue
    return "access-request"  # the biggest queue, as a fallback


def main() -> None:
    df = tickets()
    train, test = train_test_split(df, test_size=0.2, stratify=df.queue, random_state=7)
    baseline = DummyClassifier(strategy="most_frequent").fit(train.text, train.queue)
    model = make_pipeline(TfidfVectorizer(ngram_range=(1, 2), min_df=2),
                          LogisticRegression(max_iter=1000)).fit(train.text, train.queue)
    print(f"baseline {baseline.score(test.text, test.queue):.3f}")
    print(f"rules    {accuracy_score(test.queue, [by_rules(t) for t in test.text]):.3f}")
    print(f"tf-idf   {model.score(test.text, test.queue):.3f}")
    print(classification_report(test.queue, model.predict(test.text), digits=2))


if __name__ == "__main__":
    main()
