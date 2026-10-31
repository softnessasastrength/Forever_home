# M154 — Connecticut M-06 clearance-basis status recheck

Status: current statewide research basis rechecked; no code-compliance finding.

## Evidence checked on 2026-10-30

Connecticut DAS continues to list the 2022 Connecticut State Building Code (CSBC) as current for permit applications filed from October 1, 2022. The state lists the 2021 IRC, 2021 IPC and 2017 ICC A117.1 among adopted model codes. DAS's adoption-process page says the 2026 code package was expected to take effect July 1, 2026, but that effective date is delayed pending Legislative Regulation Review Committee approval. This is a statewide publication check; a future permit's governing edition, municipality and building classification remain unknown.

For a detached one-family-dwelling assumption only, the current provisional model-code plan-screen basis in the existing M-06 research note remains 2021 IRC R307.1 / Figure R307.1 and P2705.1. The screen records 15 in from a water-closet centerline to a side obstruction, 30 in between adjacent fixture centerlines, and 21 in clear in front; fixture/piping operation must not interfere with doors or windows. The Connecticut amendment set was checked for these sections; no separate amendment entry was found. Confirm scope and interpretation with the eventual local authority before treating these as project criteria.

## Revalidation

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m120_m06_current_envelope_screen.ps1 -OutputDirectory .local/revalidation/M154-m06-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m120_m06_current_envelope_screen.ps1 -OutputDirectory .local/revalidation/M154-m06-b
```

Both runs pass **14/14 checks**, contain **16/16** research toilet/lavatory body-box pairs in the gross B rectangle, and reproduce the checked-in M120 report and checks byte-for-byte:

- `m120-report.json`: `fb3c9037ed7f2ba468e1a884090a42fcf73e6673e3c913173515574d05180960`
- `m120-checks.json`: `29ab7a8705a3624d189bd280e55dd7e65cda77422a627ba3ea72a5386a9a869`

M06-B remains 124 × 84 in gross and unassigned. The result is a same-wall rectangular envelope calculation, not installed fit. It lacks actual wall faces, door/leaf and approach, privacy, exact current-SKU toilet geometry, selected lavatory geometry, plumbing connections and service route.

## Sources

- [Connecticut DAS current code and adopted editions](https://portal.ct.gov/das/home/office-of-state-building-inspector/connecticut-state-building-code/regulations?language=en_US)
- [Connecticut DAS 2026 code-adoption status](https://portal.ct.gov/DAS/Office-of-State-Building-Inspector/Building-and-Fire-Code-Adoption-Process)
- [2022 Connecticut State Building Code with Errata #1](https://portal.ct.gov/das/-/media/das/office-of-state-building-inspector/2022-state-codes/2022-csbc-final.pdf)
- [2021 IRC R307.1 and Figure R307.1](https://codes.iccsafe.org/content/IRC2021P1/chapter-3-building-planning)
- [2021 IRC P2705.1](https://codes.iccsafe.org/content/IRC2021P1/chapter-27-plumbing-fixtures)

No municipality, site, permit filing date, occupancy determination or accessibility objective has been supplied. Do not call the preliminary screen code compliant or accessible. M-06 remains unassigned.
