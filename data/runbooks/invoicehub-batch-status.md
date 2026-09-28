# Check an InvoiceHub import batch

Owner: AP systems. Class: LOL Internal. Last reviewed: 2026-05-02.

Suppliers send invoices in batches. Batch IDs look like IH-YYMMDD-NN.

1. Search the batch in InvoiceHub → Imports. Status is one of: received, processing, loaded, rejected.
2. "Processing" for more than 2 hours is stuck. Restart it from Imports → Actions → Retry. Retrying twice is fine; after that, raise to AP systems.
3. "Rejected" shows a reason. ERR-IH-0413 means the file failed validation, usually a missing PO number or a wrong currency. Send the reason back to the supplier through AP, not directly.
4. "Loaded" but the requester can't see invoices: check they're looking at the right company code.

Never re-upload a supplier's file yourself. Duplicates are hard to undo and have caused double payments.
