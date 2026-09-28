# /// script
# requires-python = ">=3.11"
# dependencies = ["tiktoken>=0.7"]
# ///
"""Class 6: count tokens. Names, IDs and non-English text cost more than you'd guess."""
import tiktoken

enc = tiktoken.get_encoding("o200k_base")
SAMPLES = [
    "Invoices from Armadillo Security Services not showing in InvoiceHub.",
    "Bayerische Unfug Maschinen",
    "LOL-SH-4472190",
    "PO-4500331208",
    "Die Rechnung ist noch nicht angekommen.",
    "the",
]
for s in SAMPLES:
    ids = enc.encode(s)
    print(f"{len(ids):>3} tokens  {s}")
    print("           ", [enc.decode([i]) for i in ids])
