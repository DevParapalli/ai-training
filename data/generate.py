#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Generate the synthetic ticket and host-signal data used in classes 3 to 5.

Tickets cover the whole company, not one department.

Everything here is invented. Lafayette O'Reilly Logistics (LOL), its systems,
people, suppliers and numbers do not exist. The generator is seeded, so every
run produces the same files.

Usage:
    uv run data/generate.py            # writes data/tickets.csv and data/signals.csv
    uv run data/generate.py --rows 5000
"""

from __future__ import annotations

import argparse
import csv
import random
from datetime import datetime, timedelta, timezone
from pathlib import Path

SEED = 20260928
HERE = Path(__file__).resolve().parent
START = datetime(2024, 10, 1, tzinfo=timezone.utc)

# Queues and their share of volume, across the whole company. Some are easy for
# keyword rules (password-reset, catering); some need judgement.
QUEUES = {
    "access-request": 0.11, "password-reset": 0.08, "hardware": 0.07, "device-enrolment": 0.05,
    "network-vpn": 0.05, "email-collab": 0.06, "report-export": 0.05, "invoice-import": 0.07,
    "purchase-order": 0.05, "ledger-close": 0.04, "payroll": 0.04, "customer-payments": 0.04,
    "shipment-ops": 0.07, "warehouse-devices": 0.05, "facilities": 0.05, "catering": 0.03,
    "security-access": 0.05, "hr-query": 0.04,
}

DEPARTMENTS = {
    "access-request": ["Finance", "Operations", "Sales", "Customer Service"],
    "password-reset": ["Finance", "Operations", "Sales", "HR", "Customer Service", "Warehouse"],
    "hardware": ["Finance", "Operations", "Sales", "HR", "Legal"],
    "device-enrolment": ["Finance", "Operations", "IT"],
    "network-vpn": ["Sales", "Operations", "Finance", "Customer Service"],
    "email-collab": ["Sales", "HR", "Legal", "Finance", "Customer Service"],
    "report-export": ["Finance", "Operations", "Sales"],
    "invoice-import": ["Finance"], "purchase-order": ["Finance", "Operations", "Facilities"],
    "ledger-close": ["Finance"], "payroll": ["Finance", "HR", "Warehouse"],
    "customer-payments": ["Finance", "Customer Service"],
    "shipment-ops": ["Operations", "Customer Service", "Sales"],
    "warehouse-devices": ["Warehouse"], "facilities": ["Finance", "Sales", "HR", "Legal", "Operations"],
    "catering": ["HR", "Sales", "Operations"], "security-access": ["Warehouse", "Operations", "HR", "Sales"],
    "hr-query": ["Warehouse", "Operations", "Finance", "Sales"],
}

SYSTEMS = {
    "access-request": ["Gatehouse", "Ledgerline", "Procura", "Datadock", "Tracklane"],
    "password-reset": ["Gatehouse", "Ledgerline", "Procura", "PayGrid", "Tracklane"],
    "hardware": ["laptop", "dock", "headset", "monitor", "phone"],
    "device-enrolment": ["Intune", "Harbor MDM"],
    "network-vpn": ["VPN", "office Wi-Fi", "warehouse Wi-Fi"],
    "email-collab": ["Outlook", "Teams", "shared mailbox", "SharePoint"],
    "report-export": ["Datadock", "Ledgerline", "Tracklane"],
    "invoice-import": ["InvoiceHub"], "purchase-order": ["Procura"], "ledger-close": ["Ledgerline"],
    "payroll": ["PayGrid"], "customer-payments": ["Ledgerline"], "shipment-ops": ["Tracklane"],
    "warehouse-devices": ["handheld scanner", "label printer", "dock terminal"],
    "facilities": ["office"], "catering": ["canteen"], "security-access": ["badge system"],
    "hr-query": ["HR portal"],
}

# LOL's suppliers: they send invoices into InvoiceHub. Bayerische Unfug Maschinen
# is a customer (LOL ships its machinery), so it appears in receivables instead.
SUPPLIERS = ["Armadillo Security Services", "Drymark Institutional Handling", "Gastro Alliance Group",
             "Stratocumulus Cloud", "Quayside Pallets", "Northbank Fuel Cards"]
CUSTOMERS = ["Bayerische Unfug Maschinen", "Kestrel Agritech", "Monsoon Textiles"]
ROLES = ["AP clerk", "GL accountant", "buyer", "payroll analyst", "controller", "FP&A analyst"]
EXPORTS = ["trial balance", "open PO report", "accruals extract", "vendor ageing", "headcount cost export",
           "customs invoice export"]
REGIONS = ["EMEA", "Americas", "APAC"]

# Templates per queue. Each has several phrasings so the same problem is written
# different ways, which is what breaks keyword rules.
T = {
    "access-request": [
        ("Need {role} access in {system}", "Joined the {region} team this week. Please grant the standard {role} role in {system}. Manager approval attached."),
        ("{system} role for new joiner", "New starter needs {system} access matching {peer}'s profile. Cost centre {cc}."),
        ("Can't see the {module} screen", "I moved teams. The {module} screen isn't there for me in {system}. I think my role wasn't updated."),
        ("Contractor access for {cw}", "{cw} starts Monday through their agency. Needs {system} read access. Sponsor is {peer}."),
    ],
    "password-reset": [
        ("Password reset for {system}", "Locked out of {system} after the password change. Please reset."),
        ("Forgot {system} password", "Forgot my {system} password. Need a reset link."),
        ("Account locked", "Account locked in {system} after too many attempts."),
    ],
    "hardware": [
        ("{system} not working", "My {system} stopped working this morning. Tried another port. Asset {asset}."),
        ("Replacement {system} needed", "{system} is damaged. Need a replacement. Asset {asset}."),
    ],
    "device-enrolment": [
        ("Device enrolment for contractor {cw}", "{cw} received the laptop from their agency. It needs the LOL image and Harbor MDM enrolment before first login."),
        ("Harbor MDM enrolment stuck", "Laptop for {cw} shows enrolment pending in Harbor for two days. Can't access anything until it completes."),
        ("Laptop says not compliant", "New laptop says device not compliant when opening {app}. Intune shows it enrolled. Asset {asset}."),
        ("Contractor sent to Intune by mistake", "{cw} followed the employee guide, installed Company Portal and tried Entra sign-in. Contractors go through Harbor MDM."),
    ],
    "network-vpn": [
        ("VPN keeps dropping", "VPN disconnects every 10 minutes from home. Can't stay on calls."),
        ("No Wi-Fi in {site}", "{system} down in {site} since morning. Scanners and laptops both affected."),
        ("Can't connect to VPN", "VPN says authentication failed. Password works everywhere else."),
    ],
    "email-collab": [
        ("Shared mailbox access", "Need access to the {mailbox} shared mailbox. My manager {peer} approved."),
        ("Teams meeting recordings missing", "Recordings from yesterday's calls aren't showing in Teams."),
        ("Emails to {customer} bouncing", "Every email to {customer} bounces back since this morning."),
        ("Outlook calendar not syncing", "Outlook calendar on my phone stopped syncing with the laptop."),
    ],
    "report-export": [
        ("{export} export failed", "The {export} export from {system} failed at {time} with {err}. Needed today."),
        ("Report stuck at 99%", "Exporting the {export} from {system} sits at 99% and then times out."),
        ("Extract is empty", "The scheduled {export} extract landed with 0 rows. It had data yesterday."),
    ],
    "invoice-import": [
        ("Status of invoice import from {supplier}", "Can you check the InvoiceHub import for {supplier}? Batch {batch} was sent at {time}."),
        ("Invoices from {supplier} not showing", "{supplier} says they sent {n} invoices on {date}. None are in InvoiceHub yet."),
        ("InvoiceHub batch {batch} status", "Batch {batch} shows processing since {time}. Is it stuck?"),
        ("{supplier} bill missing cost centres", "{supplier} invoice for {period} has {n} lines without cost centres, so it can't be posted."),
    ],
    "purchase-order": [
        ("Reopen PO {po}", "Please reopen {po}. {supplier} delivered late and the receipt couldn't be posted before closure."),
        ("PO approval limit", "My Procura approval limit shows 0. I can't approve anything."),
        ("Need a PO for {supplier}", "Need a new PO raised for {supplier} for {period}. Quote attached."),
    ],
    "ledger-close": [
        ("Account {acct} not reconciling", "GL account {acct} is off by {amount} against the sub-ledger for {period}. Close is on BD3."),
        ("Intercompany break {period}", "Intercompany between {entity_a} and {entity_b} doesn't match for {period}. Difference {amount}."),
        ("Suspense account not clearing", "Suspense account {acct} still holds {amount} after the {period} run."),
    ],
    "payroll": [
        ("Payroll totals don't match GL", "PayGrid gross pay for {region} is {amount} higher than what posted for {period}. Need RCA."),
        ("My payslip is wrong", "My {period} payslip is missing the overtime from the night shifts. Employee {emp}."),
        ("Employee paid twice", "One employee in {region} appears twice in the PayGrid run for {period}."),
    ],
    "customer-payments": [
        ("{customer} payment short", "{customer} paid in EUR but the receipt is short by bank charges. Account {acct} won't reconcile."),
        ("Unapplied cash from {customer}", "{customer} paid {n} invoices in one transfer and it all landed in suspense."),
        ("Remittance missing for {customer}", "Payment from {customer} arrived with no remittance. Can't tell which invoices it covers."),
    ],
    "shipment-ops": [
        ("Shipment {shp} stuck in customs", "Shipment {shp} for {customer} held at {port} customs. Missing commercial invoice?"),
        ("Tracking not updating for {shp}", "Tracklane shows {shp} at {port} for 3 days. Customer is asking."),
        ("Wrong weight on {shp}", "Booked weight for {shp} is wrong in Tracklane, so the freight charge is off."),
    ],
    "warehouse-devices": [
        ("Scanner not syncing", "Handheld scanner {asset} at {site} doesn't sync picks. Pickers writing on paper."),
        ("Label printer offline", "Label printer on dock {dock} at {site} is offline. Outbound is stuck."),
        ("Dock terminal frozen", "Dock terminal {dock} at {site} frozen on the login screen."),
    ],
    "facilities": [
        ("AC not working", "Air conditioning on floor {floor} at {site} isn't working. It's very hot."),
        ("Meeting room booking", "Meeting room display on floor {floor} shows the wrong bookings."),
        ("Parking badge", "Need a parking spot at {site} from next month."),
    ],
    "catering": [
        ("Coffee machine broken", "Coffee machine on floor {floor} at {site} is leaking."),
        ("Catering for meeting", "Need lunch for {n} people on {date}, room {floor}01. Two vegetarian."),
    ],
    "security-access": [
        ("Badge not working", "My badge stopped opening the {site} warehouse gate."),
        ("Visitor pass for {customer}", "Visitors from {customer} coming on {date}. Need passes for {n} people."),
        ("Background check status for {cw}", "Driver {cw} can't start until the Armadillo background check clears. Any update?"),
    ],
    "hr-query": [
        ("Leave balance wrong", "My leave balance in the HR portal shows {n} days but I should have more."),
        ("Employment letter", "Need an employment letter for a visa application."),
        ("Benefits enrolment", "Missed the benefits enrolment window. Can I still add my family?"),
    ],
}

# Vague tickets: real queues get plenty of these. Only the system name, if
# anything, hints at the queue, so neither rules nor models get them all.
VAGUE = [
    ("Issue with {system}", "Having trouble with {system} since this morning. Please call me."),
    ("Urgent: close is tomorrow", "Can't finish my work in {system} and the close is tomorrow. Please help."),
    ("{system} not behaving", "Something is off in {system}. Numbers look wrong and I don't know why."),
    ("Follow-up on my earlier ticket", "Still waiting on this. Same problem as before in {system}."),
    ("Help needed", "Colleague said to raise a ticket. It's about {system}."),
]

SITES = ["Hamburg", "Rotterdam", "Memphis", "Chennai", "Singapore", "Felixstowe"]
PORTS = ["Santos", "Rotterdam", "Jebel Ali", "Nhava Sheva", "Long Beach"]

MODULES = ["journal entry", "PO approval", "invoice matching", "cost centre report", "payroll register"]
NAMES = ["A. Rao", "M. Fischer", "J. Okafor", "L. Moreau", "S. Tanaka", "P. Kowalski", "R. Mendes", "K. Iyer"]
ENTITIES = ["LOL US Freight Inc.", "LOL Logistik GmbH", "LOL India Pvt Ltd", "LOL UK Ltd", "LOL Singapore Pte"]
ERRORS = ["ERR-DD-0412", "ERR-LL-2201", "ERR-PR-0087", "ERR-IH-0413", "ERR-HB-0015", "TIMEOUT-504"]


def values_for(rng: random.Random, queue: str, when: datetime) -> dict[str, str]:
    """One set of values per ticket, so the title and the body agree."""
    period = when.strftime("%b %Y")
    return {
        "role": rng.choice(ROLES), "system": rng.choice(SYSTEMS[queue]), "region": rng.choice(REGIONS),
        "peer": rng.choice(NAMES), "cc": f"CC-{rng.randint(1000, 9999)}", "module": rng.choice(MODULES),
        "cw": f"CW-{rng.randint(10000, 99999)}", "date": (when + timedelta(days=rng.randint(1, 60))).strftime("%d %b"),
        "req": f"CWR-{rng.randint(100000, 999999)}", "asset": f"LT-{rng.randint(10000, 99999)}",
        "err": rng.choice(ERRORS), "export": rng.choice(EXPORTS), "time": f"{rng.randint(0, 23):02d}:{rng.choice(['00', '15', '30', '45'])}",
        "supplier": rng.choice(SUPPLIERS), "customer": rng.choice(CUSTOMERS), "batch": f"IH-{when:%y%m%d}-{rng.randint(1, 40):02d}",
        "n": rng.randint(3, 400), "po": f"PO-4500{rng.randint(100000, 999999)}",
        "amount": f"USD {rng.randint(120, 480000):,}", "acct": f"{rng.choice(['1400', '2100', '2150', '6100', '6420'])}-{rng.randint(10, 99)}",
        "period": period, "entity_a": rng.choice(ENTITIES), "entity_b": rng.choice(ENTITIES),
        "site": rng.choice(SITES), "port": rng.choice(PORTS), "shp": f"LOL-SH-{rng.randint(1000000, 9999999)}",
        "dock": rng.randint(1, 24), "floor": rng.randint(1, 6), "emp": f"E{rng.randint(100000, 999999)}",
        "mailbox": rng.choice(["ap-queries", "customs-docs", "sales-emea", "hr-help"]),
        "app": rng.choice(["Ledgerline", "Tracklane", "Outlook", "Procura"]),
    }


def is_period_end(day: datetime) -> bool:
    """Last two calendar days of a month and the first three of the next (BD1 to BD3, roughly)."""
    nxt = day + timedelta(days=2)
    return nxt.month != day.month or day.day <= 3


def daily_volume(rng: random.Random, day: datetime) -> int:
    base = 6 if day.weekday() < 5 else 1
    if is_period_end(day):
        base *= 2.2
    return max(0, int(rng.gauss(base, base * 0.25)))


def queue_weights(day: datetime) -> dict[str, float]:
    w = dict(QUEUES)
    if is_period_end(day):
        for q, k in (("ledger-close", 3.0), ("payroll", 1.8), ("invoice-import", 1.6), ("report-export", 1.6)):
            w[q] *= k
    return w


def priority(rng: random.Random, queue: str) -> str:
    if queue == "payroll" and rng.random() < 0.15:
        return "P1"
    if queue in ("warehouse-devices", "network-vpn", "shipment-ops") and rng.random() < 0.05:
        return "P1"
    return rng.choices(["P2", "P3", "P4"], weights=[0.2, 0.55, 0.25])[0]


MINUTES = {"access-request": 240, "password-reset": 12, "hardware": 1400, "device-enrolment": 1900,
           "network-vpn": 180, "email-collab": 150, "report-export": 140, "invoice-import": 60,
           "purchase-order": 300, "ledger-close": 900, "payroll": 2400, "customer-payments": 600,
           "shipment-ops": 480, "warehouse-devices": 90, "facilities": 1200, "catering": 600,
           "security-access": 300, "hr-query": 1500}


def tickets(rows: int, rng: random.Random) -> list[dict]:
    out: list[dict] = []
    n = 204000
    day = START
    while len(out) < rows:
        for _ in range(daily_volume(rng, day)):
            w = queue_weights(day)
            queue = rng.choices(list(w), weights=list(w.values()))[0]
            when = day + timedelta(hours=rng.uniform(1, 22))
            short, long = rng.choice(VAGUE) if rng.random() < 0.14 else rng.choice(T[queue])
            v = values_for(rng, queue, when)
            label = queue if rng.random() > 0.05 else rng.choice(list(QUEUES))  # 5% mislabelled, as in real history
            out.append({
                "ticket_id": f"TKT-{n}",
                "opened_at": when.strftime("%Y-%m-%dT%H:%M:%SZ"),
                "department": rng.choice(DEPARTMENTS[queue]),
                "requester_type": "contingent" if "{cw}" in long or rng.random() < 0.08 else "employee",
                "channel": rng.choice(["portal", "portal", "email", "chat"]),
                "priority": priority(rng, queue),
                "period_end": int(is_period_end(day)),
                "short_description": short.format(**v),
                "description": long.format(**v),
                "queue": label,
                "minutes_to_resolve": max(3, int(rng.lognormvariate(0, 0.6) * MINUTES[queue])),
            })
            n += 1
            if len(out) >= rows:
                break
        day += timedelta(days=1)
    return out


def signals(rng: random.Random) -> list[dict]:
    """Hourly signals from 60 integration hosts over 14 days, with a few injected faults."""
    rows = []
    hosts = [f"{kind}-{i:02d}" for kind in ("ih-batch", "ll-close", "dd-export", "pg-calc") for i in range(1, 16)]
    faulty = set(rng.sample(hosts, 4))
    for h in hosts:
        for hour in range(14 * 24):
            ts = START + timedelta(hours=hour)
            busy = 1.0 + 0.6 * (8 <= ts.hour <= 18)
            cpu = rng.gauss(35 * busy, 6)
            mem = rng.gauss(58, 5)
            lat = rng.gauss(220 * busy, 30)
            anomaly = 0
            if h in faulty and 200 <= hour <= 212:
                cpu, lat, anomaly = rng.gauss(92, 3), rng.gauss(2400, 300), 1
            rows.append({"host": h, "ts": ts.strftime("%Y-%m-%dT%H:%M:%SZ"), "cpu_pct": round(max(0, cpu), 1),
                         "mem_pct": round(max(0, mem), 1), "job_latency_ms": int(max(20, lat)), "injected_fault": anomaly})
    return rows


def write(path: Path, rows: list[dict]) -> None:
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)
    print(f"wrote {path.name}: {len(rows)} rows")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--rows", type=int, default=3000)
    args = parser.parse_args()
    rng = random.Random(SEED)
    write(HERE / "tickets.csv", tickets(args.rows, rng))
    write(HERE / "signals.csv", signals(rng))


if __name__ == "__main__":
    main()
