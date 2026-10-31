# M180 - Trace the social route into the living block and shell

**Status:** passed as an unapproved coordinate-overlay test. No layout, opening, porch connection or room assignment is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\audit_m180_living_shell_route.ps1 -OutputDirectory .local\revalidation\M180-replay-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\audit_m180_living_shell_route.ps1 -OutputDirectory .local\revalidation\M180-replay-b
```

Both runs passed **12/12** checks. JSON, checks JSON and CSV match byte-for-byte (SHA256 respectively `AD8F179FC78F572CE8BE3DAEA8C62F2EDE31F8793194A08C87AC1F9D6FFE3D18`, `1B4F3CB6BC4BD85DA819101444598583EF709BD9E2D12D1C802264CC9EAC56A8`, `A9F6C3A84BCADE800D646C9C112BBFA5F8E7884CBEB9C458424947A83DBA397C`).

## Finding

The M179 origin `(14.5, 10)` in candidate-local feet is outside the source M-01 living block. M180 extends the proposed centerline to `(19.5, 10)`, which is inside that block after translation to the bath-first source origin. The translated M-02 candidate ends 4 ft 4 in west of M-01, so the route crosses an unassigned band. The 36-in route crosses the proposed 6-ft opening with 18-in margins, avoids modeled M-04/M-05, furniture and wall rectangles, and has a derived 6-in gap below the pantry. It reaches the nominal porch-door span and extends 3 ft into the porch; both porch rectangle and route bounding extents fit the hypothetical 40 x 42 ft comparison shell.

## Limits

The bath-first room blocks, kitchen candidate, furniture proxies, half-wall, opening and porch are unapproved schematic inputs. No physical shell wall, door leaf/swing/clear width, threshold, exterior connection, chair movement, appliance-open envelope, services or room assignment is verified. The 4 ft 4 in inter-room band remains unresolved. M-06/B remains unassigned; this does not establish code compliance, accessibility, structural safety, professional certification, permit approval or construction readiness.
