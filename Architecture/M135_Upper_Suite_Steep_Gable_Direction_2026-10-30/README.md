# M135 - Upper-suite steep-gable direction screen

**Status:** comparative design guidance only. The owner selected the 38 1/3 x 40 ft hypothetical shell for continued exploration and asked to test a steep traditional roof with Connecticut as the code-research jurisdiction. Neither the shell nor roof is an approved house dimension or selected design.

## Finding

Use **12:12, ridge axis X** as the lead case for the next upper-suite section study, with 12:12 ridge Y and 10:12 ridge X retained as comparisons. This is a study priority, not a roof selection.

The source-bound M103 sloped-ceiling threshold screen evaluates the four M78 sleeping-room blocks against the 2022 Connecticut code's generic sloped-ceiling arithmetic, assuming each full room-block rectangle is the required floor area. At 12:12/ridge X, minimum relative roof-plane rise over U-01 through U-04 is 8.1667, 12.5, 8.1667 and 8.5 ft. Its most demanding algebraic effective-eave threshold is -3.167 ft (U-03). At 12:12/ridge Y, U-01 and U-04 touch the relative eave plane; its most demanding effective-eave threshold is 5 ft (U-04). The M103 method defines this threshold as an unknown finished eave-ceiling height above finished floor, not as a selected or buildable elevation. Negative values are algebraic outputs, not construction recommendations.

The independent M79 test preserves the nominal 3.5 ft U-02 north-edge contact reservation centered on its sampled direct-hall approach. M78's candidate retains U-03 private-only sampled topology. M133's bath fit keeps both M130 primary-bath block orientations and their nominal south-edge entry reservation as comparison cases. These studies provide useful plan constraints, but none contains a physical door, roof assembly or finished ceiling.

## Reproduction evidence

Windows PowerShell 5.1 replays were written only under ignored `.local/revalidation/M135-*` directories:

- M79 hall-approach reservation: **10/10** checks; output JSON and SVG match the checked-in package byte-for-byte.
- M83 gable options: **13/13** checks; all four outputs match the checked-in package byte-for-byte. Six surfaces cover 8:12, 10:12 and 12:12 on ridge axes X/Y.
- M103 sloped-ceiling thresholds: **10/10** checks and 24 room/roof rows; JSON SHA256 `4B74367B5F111271B6B171FFBF3AF8B2F0438024A8EF87C2428F8C0AEDC3391C`; CSV SHA256 `F7D70A521EAD5934B15D85C5B603389014BBF1C2D75FEC79FBEE852E66FB5910`.
- M133 primary-bath product-envelope fit: **12/12** checks; all four outputs match the checked-in package byte-for-byte.
- All three replayed SVG files parse as XML.
- Selected-D source remains SHA256 `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`. No RVT, IFC, selected-D source or incoming RFA was modified.

## Connecticut research status and limits

Connecticut DAS's current adoption page was checked on 2026-10-30. It reports that the expected 2026 code effective date of July 1, 2026 is delayed while Legislative Regulation Review Committee approval is pending. The 2022 Connecticut State Building Code remains the published current statewide basis for permits filed from October 1, 2022. This does not establish which code will govern a future project; municipality, classification, permit timing and authority-having-jurisdiction review remain unknown.

The R305.1 comparison is a preliminary arithmetic screen, not a code-compliance finding. It omits room classification, code-defined required floor area, the bath fixture-height exception, roof/wall thickness, framing, eave and floor elevations, ceiling build-down, dormers and actual finished geometry. Structural design, loads, drainage, insulation, ventilation, egress, services and professional review are outside scope.

## Next milestone

M136 should turn the leading roof case into a parametric section comparison only after explicitly varying the still-unknown finished eave-ceiling height and build-down rather than assigning either a design value. Compare all four sleeping-room blocks at 12:12/ridge X against retained 12:12/ridge Y and 10:12/ridge X cases; include a separate fixture-height screen only after the bath and shower geometry is verified. Preserve the private U-03 route and direct U-02 hall arrival assumptions. Do not edit selected-D or represent any case as compliant.

Current sources: [Connecticut DAS code-adoption status](https://portal.ct.gov/en/DAS/Office-of-State-Building-Inspector/Building-and-Fire-Code-Adoption-Process); see `Research/Connecticut_Roof_Code_Research_2026-10-28.md` for the official 2022 CSBC R305.1 source and limits.
