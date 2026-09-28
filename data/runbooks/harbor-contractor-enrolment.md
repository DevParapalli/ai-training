# Enrol a contractor laptop in Harbor MDM

Owner: End-user computing. Class: LOL Internal. Last reviewed: 2026-03-20.

Contractors use laptops from their own agency (BYCOD). Employees use LOL laptops in Intune. Contractors never use Company Portal or Entra device sign-in, whatever the employee guide says.

1. Confirm the contractor has an active CW Portal account and a sponsor.
2. The laptop needs the LOL image first. The agency applies it using the image link we send them; we don't image agency hardware.
3. Create an enrolment code in Harbor → Devices → New enrolment, tied to the CW ID. Codes expire after 48 hours.
4. The contractor enters the code at first boot. Enrolment takes up to 30 minutes.
5. After enrolment, second factor is set up with the Harbor authenticator, not the LOL phone app.

If Harbor says "device not recognised", the image wasn't applied. Go back to step 2.
