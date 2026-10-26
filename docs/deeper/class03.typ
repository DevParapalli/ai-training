// Class 3 deeper reading. Build:
//   typst compile --root . docs/deeper/class03.typ build/deeper-class03.pdf
#import "handout.typ": *

#show: handout.with(n: 3, title: [Classical ML and text: what the class skipped, with code to run and where to read more.],
  covered: [Baselines, test splits, precision and recall, regex, TF-IDF, embeddings, and the mistakes that make a bad model look good.])

= How to use this

Class 3 covered the starting point and the mistakes. This handout covers the rest. Each section says why the topic matters at #co.short, what to run, what to try, and what to read, in order: the first link is the one to read if you only read one.

Everything runs from the repository root with `uv run`. Generate the data first with `uv run data/generate.py`. Nothing in this handout needs a model key except the LLM comparison in section 5.

= The mistakes, as a checklist

Before you believe any score, yours or a vendor's:

+ Was the test set split off before anyone looked at the data, and never trained on?
+ Is there anything in the input that wasn't known at the moment of prediction? (Leakage.)
+ What does "always guess the most common answer" score on the same test set?
+ What is recall on the class that matters, not overall accuracy?
+ Which class is weakest, and by how much?
+ Was it tested on input written the way people really write?
+ What happens when it doesn't know? Is there a threshold and a person?
+ Was every cutoff picked on labelled data, not by eye?

= Measuring honestly

*Why it matters.* Most bad models look excellent on the data they were built with. The class showed two ways: "never P1" at 98.9%, and the same classifier dropping from 90% on generated tickets to 71% on handwritten ones.

*Run.*
#run("uv run code/class03/classify.py      # baseline, rules, TF-IDF, full report
uv run code/class03/handwritten.py   # the same model on tickets people wrote")

*Try.* Change the split in `classify.py` to time-based: train on tickets opened before 2026, test on the rest. Then go through the columns of `data/tickets.csv` and mark which ones were known when the ticket arrived. `minutes_to_resolve` wasn't: using it as a feature is leakage, however much it helps the score.

*Read.*
#source("https://scikit-learn.org/stable/common_pitfalls.html", [Common pitfalls and recommended practices], kind: "docs", by: [scikit-learn])[Leakage and inconsistent preprocessing, with code. Read this first.]
#source("https://developers.google.com/machine-learning/crash-course/classification/accuracy-precision-recall", [Accuracy, recall, precision and related metrics], kind: "course", by: [Google ML Crash Course])[Short, interactive, and clear on why accuracy misleads on uneven classes.]
#source("https://scikit-learn.org/stable/modules/cross_validation.html", [Cross-validation: evaluating estimator performance], kind: "docs", by: [scikit-learn])[Including `TimeSeriesSplit`, for when time matters.]
#source("https://scikit-learn.org/stable/modules/model_evaluation.html", [Metrics and scoring], kind: "docs", by: [scikit-learn])[Every metric in one place. Use as reference, not reading.]
#source("https://reproducible.cs.princeton.edu/", [Leakage and the reproducibility crisis in ML-based science], kind: "paper", by: [Kapoor and Narayanan, Princeton])[A taxonomy of eight kinds of leakage found across hundreds of published papers.]
#source("https://developers.google.com/machine-learning/guides/rules-of-ml", [Rules of Machine Learning], kind: "guide", by: [Martin Zinkevich, Google])[43 rules from production. Rule 1: don't be afraid to launch without machine learning.]

= Saying "I don't know"

*Why it matters.* A classifier always picks a queue. The phishing report and the fake bank-change email went into real queues. A threshold on the model's confidence sends uncertain tickets to a person.

*Run.*
#run("uv run code/class03/threshold.py")

*Try.* Pick the threshold you'd ship and write one sentence on why. Then ask whether the confidence numbers mean what they say: does "0.8 confident" come true 80% of the time? Read the calibration link below and check with `CalibratedClassifierCV`.

*Read.*
#source("https://scikit-learn.org/stable/modules/classification_threshold.html", [Tuning the decision threshold for class prediction], kind: "docs", by: [scikit-learn])[Choosing a threshold on a metric you care about, not 0.5 by default.]
#source("https://scikit-learn.org/stable/modules/calibration.html", [Probability calibration], kind: "docs", by: [scikit-learn])[Why a model's confidence and its accuracy can disagree, and how to fix it.]

= Forecasting and anomaly detection

*Why it matters.* Not everything is classification. Ticket volume around period close is a forecast; odd readings on the integration hosts are anomaly detection. Both are classical ML jobs with cheap, explainable answers.

*Run.*
#run("uv run code/class03/forecast.py   # average day, same day last week, weekday + period end
uv run code/class03/signals.py    # isolation forest over host CPU, memory and latency")

`forecast.py` scores three forecasts on the last eight weeks. The calendar-aware one roughly halves the error of "same day last week". `signals.py` catches every injected fault, and flags about as many busy hours that only look odd: precision again.

*Try.* In `signals.py`, change `contamination` from 0.005 to 0.002 and 0.01, and count real faults caught against false alarms. In `forecast.py`, add a feature for the first working day of the month.

*Read.*
#source("https://otexts.com/fpppy/", [Forecasting: Principles and Practice, the Pythonic Way], kind: "book, free online", by: [Hyndman, Athanasopoulos and others])[The standard practical forecasting text, in Python. Start with the chapters on simple methods and evaluating forecast accuracy.]
#source("https://otexts.com/fpp3/", [Forecasting: Principles and Practice, 3rd edition], kind: "book, free online", by: [Hyndman and Athanasopoulos])[The original R edition, if your team uses R.]
#source("https://scikit-learn.org/stable/modules/outlier_detection.html", [Novelty and outlier detection], kind: "docs", by: [scikit-learn])[Isolation forest and its alternatives, with a comparison on toy data.]

= Text: regex, TF-IDF, embeddings and the LLM

*Why it matters.* The class went from regex to embeddings in three slides. These scripts let you see each step on our tickets and compare cost against accuracy yourself.

*Run.*
#run("uv run code/class03/extract.py          # regex for IDs
uv run code/class03/duplicates.py       # TF-IDF and cosine similarity
uv run code/class03/embed_classify.py   # local embeddings, downloads a model once
uv run code/class03/llm_classify.py     # needs LLM_API_KEY, LLM_BASE_URL, LLM_MODEL")

*Try.* Add an invoice-number pattern to `extract.py`. In `duplicates.py`, try cutoffs of 0.4, 0.6 and 0.8 and decide which you'd ship. Run both classifiers and fill in the accuracy, time-per-ticket and cost columns from the class with your own numbers.

*Read.*
#source("https://docs.python.org/3/howto/regex.html", [Regular expression HOWTO], kind: "docs", by: [Python])[Everything `extract.py` uses, explained.]
#source("https://regex101.com/", [regex101], kind: "tool")[Paste a pattern and a ticket; it explains each part. Choose the Python flavour.]
#source("https://scikit-learn.org/stable/tutorial/text_analytics/working_with_text_data.html", [Working with text data], kind: "tutorial", by: [scikit-learn])[Bag of words to TF-IDF to a classifier, step by step.]
#source("https://sbert.net/", [Sentence Transformers documentation], kind: "docs")[The library `embed_classify.py` uses. The quickstart and the semantic search pages are enough.]
#source("https://huggingface.co/spaces/mteb/leaderboard", [MTEB leaderboard], kind: "benchmark", by: [Hugging Face])[How embedding models compare. Filter by size; a small model is often enough.]
#source("https://web.stanford.edu/~jurafsky/slp3/", [Speech and Language Processing, 3rd edition draft], kind: "book, free online", by: [Jurafsky and Martin])[The textbook. Chapters on regular expressions, n-grams, and vector semantics cover this section in depth.]

= How transformers work

*Why it matters.* You don't need this to build anything in the track. It explains why models understand context, why they have a context window, and why encoders (embeddings) and decoders (chat models) are good at different jobs.

*The short version.* Recurrent networks read one word at a time and forget the start. Attention lets every word look at every other word at once, which keeps context and trains in parallel on many GPUs. The cost grows with the square of the text length, hence the context window. Encoders read both ways and produce a vector; decoders read left to right and predict the next token.

*Read, in this order.*
#source("https://jalammar.github.io/illustrated-word2vec/", [The Illustrated Word2vec], kind: "guide", by: [Jay Alammar])[Words as positions, with pictures. Thirty minutes.]
#source("https://colah.github.io/posts/2015-08-Understanding-LSTMs/", [Understanding LSTM networks], kind: "guide", by: [Chris Olah])[What came before attention, and why it fell short.]
#source("https://www.3blue1brown.com/lessons/attention", [Attention in transformers, visually explained], kind: "video", by: [3Blue1Brown])[The best visual explanation of attention. Watch the chapter before it too.]
#source("https://jalammar.github.io/illustrated-transformer/", [The Illustrated Transformer], kind: "guide", by: [Jay Alammar])[The whole architecture, one diagram at a time.]
#source("https://huggingface.co/learn/llm-course", [LLM Course], kind: "course, free", by: [Hugging Face])[Hands-on: encoders, decoders, fine-tuning a small model on your own labels.]
#source("https://www.youtube.com/watch?v=kCc8FmEb1nY", [Let's build GPT: from scratch, in code, spelled out], kind: "video, 2 h", by: [Andrej Karpathy])[For developers who want to write one. Optional.]
#source("https://arxiv.org/abs/1706.03762", [Attention Is All You Need], kind: "paper", by: [Vaswani et al., 2017])[The original. Read after the guides, not before.]
