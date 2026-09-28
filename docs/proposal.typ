// Capstone proposal, one page. Fill in the #let block and compile:
//   typst compile --root . docs/proposal.typ build/proposal-team-N.pdf
#import "@local/centauri:0.2.0": *

#let team = [Team 1]
#let problem = [Flag supplier emails asking for bank changes before anyone reads them.]
#let lands = [2 and 3: a rule for the obvious cases (free email domain, new bank country), a small classifier for the rest.]
#let decided-by = [Question 4: one missed fraud email can cost more than the whole project.]
#let steps = (
  [Rule: any bank-change email from a domain not on the supplier record goes to security.],
  [Label last year's supplier emails: bank change or not.],
  [Train the class 3 classifier on them; beat the rule on the frozen test set.],
  [Route flagged emails to AP controls, never auto-reply.],
  [Review misses weekly for three months.],
)
#let error-budget = [Misses: zero tolerated on the test set. False alarms: up to 20 a week is fine; AP controls reads them anyway.]
#let cost = [Build: two weeks of one developer. Run: effectively free; no LLM calls.]
#let owner = [Head of AP controls. Off switch: disable the mail rule; emails go to the inbox as before.]

#show: centauri.with(kind: "brief", title: "Capstone proposal", accent: "lime", stage: "final", numbering: none,
  header: (left: [AI Builder Track · capstone], right: team))

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
