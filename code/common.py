"""Shared helpers for the class code. Reads provider settings from the environment.

    LLM_API_KEY   key for an OpenAI-compatible endpoint
    LLM_BASE_URL  endpoint URL
    LLM_MODEL     model name
"""
import os
from pathlib import Path

DATA = Path(__file__).resolve().parent.parent / "data"


def client():
    from openai import OpenAI
    return OpenAI(api_key=os.environ["LLM_API_KEY"], base_url=os.environ["LLM_BASE_URL"])


def ask(prompt: str, temperature: float = 0.2) -> str:
    reply = client().chat.completions.create(
        model=os.environ["LLM_MODEL"], temperature=temperature,
        messages=[{"role": "user", "content": prompt}])
    return reply.choices[0].message.content


def tickets():
    import pandas as pd
    df = pd.read_csv(DATA / "tickets.csv", parse_dates=["opened_at"])
    df["text"] = df.short_description + ". " + df.description
    return df
