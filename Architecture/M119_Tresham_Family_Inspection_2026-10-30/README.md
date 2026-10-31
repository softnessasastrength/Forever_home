# M119 - KOHLER Tresham family inspection

Date: 2026-10-30

## Scope

Read-only inspection of the exact, hash-pinned Tresham RFA already quarantined under ignored `.local/`. The family was opened in Revit 2027.3 Family Editor, its 3D Preview and Family Types dialog were reviewed, and Family Category and Parameters was opened. The source was closed with `Ctrl+W` without saving. No family was loaded into a project, placed, or tested in a room.

## Source identity

- Product association: KOHLER Tresham K-2844-4 / K-2844-4-0, 24-inch pedestal lavatory, four-inch centerset.
- Source file: `.local/revit-pilot/family-intake/candidates/kohler-tresham-k-2844-4-0.rfa`.
- Public source URL: <https://techcomm.kohler.com/techcomm/cad/Sink-Pedestal_Lavatory_4in_cc-Kohler-Tresham-2844-4.rfa>.
- Sidecar: `.local/revit-pilot/family-intake/candidates/kohler-tresham-k-2844-4-0.rfa.source.json`.
- Bytes: 659,456.
- SHA256 before/after inspection: `3B1CBDAA844D35BD462F6E59A828B82F7870FDE4EE7397BAC09F4CA0C2F9B949`.
- Revit identified the source as Revit 2011 and upgraded it in memory to Revit 2027.3. No save or source-file upgrade was written.

## Observations

- 3D Preview visibly contains a basin and pedestal as one family representation.
- Family Category and Parameters shows category `Plumbing Fixtures` selected. The displayed family parameters include `Part Type = Normal`; no host type was established in this UI inspection.
- Family Types lists ten finish/color type names. The inspected type is `Fireclay-C-White`.
- Its displayed report parameters are Width `2 ft 0 1/128 in`, Length `1 ft 7 1/2 in`, and Height `2 ft 10 5/8 in` (24.0078125 x 19.5 x 34.625 in). These are family type parameters, not independently measured solid bounds or installed clearances.
- Displayed plumbing parameters include Waste Connection enabled, Sanitary Radius `5/8 in`, and Sanitary Diameter `1 1/4 in` with formula `Sanitary Radius * 2`. Vent, cold-water and hot-water connection checkboxes appear disabled/grey in the dialog; actual connector geometry and routeability were not tested.
- The measured type values closely reproduce the KOHLER specification's nominal overall 24 x 19-1/2 x 34-5/8 in envelope. Width differs by 1/128 in, consistent with parameter display precision, but this is not a geometric-bounds comparison.

## Decision and limitations

This is a materially better geometry lead than the prior unmeasured Tresham proposal: the downloaded family visibly contains the pedestal assembly and carries overall parameters matching the published nominal size. It remains a research candidate, not a product selection. KOHLER's specification identifies this product as not ADA compliant; applicability of any accessibility provisions to this project is not established here. The family host behavior, positive-solid bounds, faucet/connection placement, actual water/sanitary connector objects, use zones, door and approach, and service route remain unverified. Do not assign or place M-06 B based on this inspection. Preserve the selected-D baseline.

## Reproduction

1. Verify the source hash with Windows PowerShell: `Get-FileHash -Algorithm SHA256 <source-path>`.
2. In Revit 2027.3, open that exact quarantined file in Family Editor.
3. Review the 3D Preview, Family Types, and Family Category and Parameters dialogs without editing values.
4. Close the source without saving; recompute its hash and require the recorded digest.

This is a manual read-only inspection record, not a scripted geometry or room-fit validation.

## M120 disposable positive-solid intake follow-up (2026-10-30)

A separate disposable Revit 2027.3 intake run at `.local/revit-pilot/family-intake/20261031T012424079Z/` measured the same source RFA without saving it. The manifest reports ten finish types, category `Plumbing Fixtures`, placement type `WorkPlaneBased`, and three positive-volume solids per type. `Fireclay-0-White` bounds are 24.0063 × 19.4998 × 34.625 in in family-symbol coordinates. This is more specific than the earlier Family Editor parameter display, but still does not establish the placed host/orientation, actual connector objects or installation clearances. The exact source digest remained `3B1CBDAA844D35BD462F6E59A828B82F7870FDE4EE7397BAC09F4CA0C2F9B949`. Intake passed 155/155 automated integrity checks. M-06 remains unassigned; see [M120](../M120_M06_Current_Product_Envelope_Screen_2026-10-30/README.md).
