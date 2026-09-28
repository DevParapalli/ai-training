# Payroll total doesn't match the ledger

Owner: Payroll systems. Class: LOL Highly Confidential. Last reviewed: 2026-06-15.

1. Compare the PayGrid run summary with the payroll journal in Ledgerline, by cost centre.
2. Differences in one cost centre usually mean a mapping problem: a new cost centre in Ledgerline not yet mapped in PayGrid.
3. Duplicated employees in a run mean the run was restarted without clearing the first attempt. Stop the payment file if it hasn't gone to the bank.
4. Any overpayment is corrected in the next run with an adjustment code. Tell HR before it appears on payslips.
5. Write the root cause up the same week. Audit asks for it.

Don't share employee-level payroll data in tickets. Refer to the run ID and cost centre.
