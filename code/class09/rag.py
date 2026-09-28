# /// script
# requires-python = ">=3.11"
# dependencies = ["scikit-learn>=1.5", "openai>=1.40"]
# ///
"""Class 9: answer from our runbooks, with citations. Keyword search here so it runs anywhere;
swap in embeddings (class 5) for the vector version."""
import re
import sys
from pathlib import Path

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from common import DATA

RUNBOOKS = DATA / "runbooks"
CEILING = {"LOL Public": 0, "LOL Internal": 1, "LOL Confidential": 2, "LOL Highly Confidential": 3, "LOL Restricted": 4}


def chunks(tool_limit: str = "LOL Confidential"):
    """One chunk per paragraph or numbered step, tagged with its source. Skips runbooks above the tool's ceiling."""
    out = []
    for path in sorted(RUNBOOKS.glob("*.md")):
        text = path.read_text(encoding="utf-8")
        cls = re.search(r"Class: (LOL [A-Za-z ]+?)\.", text).group(1)
        if CEILING[cls] > CEILING[tool_limit]:
            continue
        title = text.splitlines()[0].lstrip("# ")
        for part in re.split(r"\n\s*\n|\n(?=\d+\. )", text):
            part = part.strip()
            if part and not part.startswith("#"):
                out.append({"source": path.name, "title": title, "text": part})
    return out


def search(question: str, k: int = 3, tool_limit: str = "LOL Confidential"):
    cs = chunks(tool_limit)
    vec = TfidfVectorizer(ngram_range=(1, 2)).fit([c["text"] for c in cs] + [question])
    sims = cosine_similarity(vec.transform([question]), vec.transform([c["text"] for c in cs]))[0]
    ranked = sorted(zip(sims, cs), key=lambda x: -x[0])[:k]
    return [(round(float(s), 2), c) for s, c in ranked]


def answer(question: str) -> str:
    from common import ask
    hits = search(question)
    context = "\n\n".join(f"[{i + 1}] ({c['source']}) {c['text']}" for i, (_, c) in enumerate(hits))
    return ask("Answer only from the numbered runbook extracts. Cite them like [1]. "
               "If they don't answer the question, say so.\n\n"
               f"{context}\n\nQuestion: {question}", temperature=0)


if __name__ == "__main__":
    q = "Armadillo says our bank details changed, can I update them from their email?"
    for score, c in search(q):
        print(score, c["source"], "|", c["text"][:90])
