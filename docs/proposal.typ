// Capstone proposal, worked example. The problem is deliberately not one of the
// capstone draw problems, so no team gets its answer. Fill in the #let block and compile:
//   typst compile --root . docs/proposal.typ build/proposal-team-N.pdf
#import "@local/centauri:0.0.0": *

#let team = [Example]
#let problem = [Reply to "has my InvoiceHub batch finished?" without a person looking it up.]
#let lands = [1: a script. InvoiceHub already knows every batch's status; nothing needs judging.]
#let decided-by = [Question 1: the rule is written down. The runbook says what each status means and when "processing" counts as stuck.]
#let steps = (
  [Pull the batch ID out of the ticket with a regex (`IH-\d{6}-\d{2}`).],
  [Read the batch status from InvoiceHub.],
  [Reply with the status and, if it's rejected, the reason, using the runbook wording.],
  [If there's no batch ID, or it's been processing over 2 hours, route to AP systems as today.],
  [Count how many tickets it closes, and how many get reopened, for a month.],
)
#let error-budget = [A wrong status reply costs a follow-up ticket, not money. Up to 1 in 50 reopened is fine; above that, switch it off and look.]
#let cost = [Build: two to three days of one developer. Run: effectively free; no model calls.]
#let owner = [AP systems lead. Off switch: disable the auto-reply rule; tickets go back to the queue as before.]

#show: centauri.with(kind: "brief", title: "Capstone proposal", accent: "lime", stage: "final", numbering: none,
  header: (left: [Building the Right AI System · capstone example], right: team))

= #problem

#data-table(columns: (auto, 1fr),
  [Where it lands], lands,
  [Decided by], decided-by,
  [Error budget], error-budget,
  [Cost], cost,
  [Owner and off switch], owner,
)

== Steps
#enum(..steps)
