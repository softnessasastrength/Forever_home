# Revit version strategy

Date: 2026-10-25
Status: owner-approved

- **Revit 2027 is the authoritative modeling environment** to use current capabilities during the trial and in any later authorized Flex sessions.
- Owner has tested a working licensed Revit 2018 installation. **Revit 2018 is a fallback**, not the master and not a native continuation of 2027 RVT/RFA files.
- Never overwrite the authoritative 2027 model with reconstructed 2018 output.
- Maintain native RVT/RFA archives, tested IFC2x3 exports, compatible DWG, PDF, schedules/CSV, and a version-neutral structured design specification.
- Test the 2027 → IFC → 2018 path early with representative walls, hosted openings, stairs, rooms, and a family. Record lost geometry, semantics and editability.
- Revit 2018 may use linked/reference geometry or selective reconstruction; do not promise native parametric editability from IFC.
- Prioritize full-featured 2027 design while using disciplined backups, export validation and documented assumptions to prevent vendor lock-in.
- Continue investigating education eligibility and Flex only as optional legitimate access routes; spending requires owner approval.
