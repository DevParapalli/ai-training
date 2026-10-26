# /// script
# requires-python = ">=3.11"
# dependencies = ["scikit-learn>=1.5", "sentence-transformers>=3.0"]
# ///
"""Class 5: hybrid search. Keyword search and embeddings each rank the chunks; reciprocal rank fusion
merges the two lists. Scored with the same questions as retrieval_check.py."""
from sentence_transformers import SentenceTransformer

from rag import chunks, search
from retrieval_check import check

CHUNKS = chunks()
enc = SentenceTransformer("Qwen/Qwen3-Embedding-0.6B")
VECTORS = enc.encode([c["text"] for c in CHUNKS], normalize_embeddings=True)


def vector_search(question: str, k: int = 3):
    q = enc.encode([question], prompt_name="query", normalize_embeddings=True)[0]
    scores = VECTORS @ q
    ranked = sorted(zip(scores, CHUNKS), key=lambda x: -x[0])[:k]
    return [(round(float(s), 2), c) for s, c in ranked]


def hybrid_search(question: str, k: int = 3, depth: int = 20, rrf_k: int = 60):
    """Reciprocal rank fusion: each list gives 1 / (rrf_k + rank). Scores don't need to be comparable."""
    fused: dict[int, float] = {}
    for results in (search(question, k=depth), vector_search(question, k=depth)):
        for rank, (_, c) in enumerate(results, start=1):
            fused[id(c)] = fused.get(id(c), 0) + 1 / (rrf_k + rank)
    by_id = {id(c): c for c in CHUNKS}
    ranked = sorted(fused.items(), key=lambda x: -x[1])[:k]
    return [(round(s, 4), by_id[i]) for i, s in ranked]


if __name__ == "__main__":
    for name, fn in (("keyword", search), ("vector", vector_search), ("hybrid", hybrid_search)):
        print(f"--- {name}")
        check(fn)
