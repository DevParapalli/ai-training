// Course-wide facts. Anything a deck might need to change at the last minute,
// across all classes, lives here. Per-class facts live in the #let block at the
// top of each class file.
//
// Lafayette O'Reilly Logistics and every company, system, person and figure
// below is made up for this course. The TCS and Cisco entries at the bottom are
// the only real ones; swap them per audience.

#let track = "Building the Right AI System"
#let footer-line = [© 2026 Devansh Parapalli]
#let total-classes = 15

// Us. The whole track is told from inside LOL, looking at the whole company:
// every department raises tickets, and every department has problems AI might or
// might not fix.
#let co = (
  name: [Lafayette O'Reilly Logistics],
  short: [LOL],
  what: [a global freight and logistics company],
  desk: [service desk],
  departments: ([Operations], [Warehouse], [Finance], [Sales], [Customer Service], [HR], [Legal]),
)

// Why logistics finance is hard: money crosses borders on almost every job.
#let business = (
  shipments: [freight moved across 40+ countries],
  currencies: [invoices and receipts in 11 currencies],
  pain: [bank charges, FX differences and short payments on nearly every cross-border receipt],
)

// Our systems, across the company.
#let app = (
  gl: [Ledgerline],            // general ledger and period close
  proc: [Procura],             // procurement and purchase orders
  inv: [InvoiceHub],           // supplier invoice import
  pay: [PayGrid],              // payroll
  iam: [Gatehouse],            // access requests
  cw: [CW Portal],             // contractor accounts
  mdm: [Harbor MDM],           // contractor device management
  dw: [Datadock],              // reporting exports
  track: [Tracklane],          // bookings, tracking, customs documents, driver app
)

// Devices. Employees and contractors take different paths, which confuses everyone.
#let devices = (
  employee: [Employees: LOL laptops, managed in Microsoft Intune, signing in with Entra ID.],
  contractor: [Contractors: laptops from their own agency, re-imaged with LOL's build and enrolled in Harbor MDM. Not self-serve.],
  bycod: [BYCOD: bring your company-owned device. The laptop belongs to the contractor's employer; the image and the enrolment are ours.],
)

// Companies we deal with. All fictional.
#let bum = (
  name: [Bayerische Unfug Maschinen],
  short: [B.U.M.],
  role: [Customer. A German machinery maker that ships its machines to the world through us.],
  money: [Pays in EUR from Munich, usually a little short after bank charges.],
)
#let ass = (
  name: [Armadillo Security Services],
  short: [A.S.S.],
  role: [Supplier. Physical security and background checks for our warehouses and drivers.],
  money: [Invoices through InvoiceHub, one per check or per guard shift.],
)
#let dih = (
  name: [Drymark Institutional Handling],
  short: [D.I.H.],
  role: [Supplier. Admin, facilities and janitorial across our offices.],
)
#let gag = (
  name: [Gastro Alliance Group],
  short: [G.A.G.],
  role: [Supplier. Catering. Owns the coffee machines, which people still raise IT tickets about.],
)
#let sc = (
  name: [Stratocumulus Cloud],
  short: [S.C.],
  role: [Supplier. Our cloud provider. The bill needs cost centres it never has; credits arrive late.],
)

// The ticket that runs through classes 1 to 5.
#let ticket = (
  id: [TKT-204117],
  short: [InvoiceHub import from Armadillo Security Services stuck],
  body: [Batch IH-260301-07 shows ERR-IH-0413 since 02:00. AP can't start matching.],
  queue: [invoice-import-status],
)

// Data the code walkthroughs use.
#let dataset = (
  generated: (rows: 3000, file: "data/tickets.csv", note: [built by data/generate.py]),
  handwritten: (rows: 300, file: "data/tickets_handwritten.csv", note: [written by hand, the way people actually raise tickets]),
)

// AI policies. Ours and our partners' first; the real reference policies after.
#let policies = (
  lol: (
    who: [#co.short],
    stance: [Fairly relaxed. If a tool is in the directory, use it up to its limit.],
    classes: ([LOL Public], [LOL Internal], [LOL Confidential], [LOL Highly Confidential], [LOL Restricted]),
    tools: (
      ([Lighthouse, our internal AI gateway], [up to LOL Restricted]),
      ([ServiceDesk AI, built into the ticketing tool], [up to LOL Highly Confidential]),
      ([Open models running on your own laptop], [up to LOL Confidential]),
      ([Anything else], [LOL Public only]),
    ),
  ),
  bum: (
    who: [#bum.short],
    stance: [No written AI policy. Microsoft 365 Copilot is switched on in Office, and that's the extent of it.],
    note: [Treat anything BUM sends us as LOL Confidential, whatever they did with it before.],
  ),
  ass: (
    who: [#ass.short],
    stance: [Strict. Background check data doesn't leave approved systems, ever.],
    classes: ([ASS Public], [ASS Internal], [ASS Confidential], [ASS Restricted]),
    rules: (
      [Approved AI tools take ASS Confidential at most.],
      [Unapproved AI tools are blocked.],
      [If one gets opened anyway, it runs in browser isolation: nothing copies in or out.],
    ),
  ),
)

// Real reference policies, one slide in class 8. Replace per audience.
#let reference-policies = (
  (
    who: [TCS],
    points: (
      [Four classes: TCS Public, Internal Use, Confidential, Restricted.],
      [Approved AI tools: TCS Confidential at most.],
      [Unapproved AI tools are banned. If opened, they run in Zscaler Browser Isolation, with no data movement.],
    ),
  ),
  (
    who: [Cisco],
    points: (
      [A directory lists every approved tool and the highest class it may receive.],
      [CircuIT: Cisco Restricted. Jira AI services: Cisco Highly Confidential.],
      [Local models on a laptop: Cisco Confidential. Everything else: Cisco Public.],
    ),
  ),
)
