# Upper-suite bath product sources — 2026-10-30

## Proposal-only product envelopes

This note supports a bounded geometric fit test for U-05. It does not select a product or room layout and does not establish service routing, accessibility, code compliance or construction suitability.

### KOHLER Tresham K-2844-4-0 pedestal lavatory

KOHLER's current product page identifies K-2844-4-0 as a 24-in square pedestal lavatory. The current manufacturer specification sheet identifies fireclay, 4-in centerset faucet holes, pedestal installation, included K-2757-4 basin and K-2767 pedestal, and nominal overall dimensions of 24 x 19 1/2 x 34 5/8 in (W x D x H). Its dimension drawing shows 3/8-in hot/cold supplies and 1 1/4-in OD waste. The gross fit screen uses the nominal 24 x 19 1/2-in plan envelope only; it does not include a user envelope or establish a service connection route.

KOHLER's public Revit-family URL is `https://techcomm.kohler.com/techcomm/cad/Sink-Pedestal_Lavatory_4in_cc-Kohler-Tresham-2844-4.rfa`. A HEAD request returned HTTP 200 and 659,456 bytes, and the exact file was retrieved without an account or form submission. It is quarantined outside Git at `.local/revit-pilot/family-intake/candidates/kohler-tresham-k-2844-4-0-2026-10-30/`; its source URL, retrieval time, size and SHA256 are recorded in the ignored `source-manifest.json`. A read-only Revit 2027.3 inspection identifies category Plumbing Fixtures and placement type WorkPlaneBased, with ten finish/color types and three positive-volume solids per type. The measured symbol bounds are 24.1319 x 19.5626 x 34.6878 in. In the displayed Fireclay/White type, family-reported width/length are 24.0078 x 19.5 in, slightly smaller than the solid bounds. Its type panel has sanitary radius/diameter values and Waste/Vent/CW/HW flags, but no actual MEP ConnectorElement presence, location or orientation was verified. It remains a research candidate only; it has not been assigned to a room or fit-tested with clearance, door/approach or routing. The source was closed without saving and its SHA256 remains `3B1CBDAA844D35BD462F6E59A828B82F7870FDE4EE7397BAC09F4CA0C2F9B949`.

Quarantined RFA SHA256: `3B1CBDAA844D35BD462F6E59A828B82F7870FDE4EE7397BAC09F4CA0C2F9B949`.

Sources:

- [KOHLER Tresham K-2844-4-0 product page](https://www.kohler.com/en/products/bathroom-sinks/shop-bathroom-sinks/tresham-24-pedestal-bathroom-sink-with-4-centerset-faucet-holes-2844-4)
- [KOHLER current K-2844-4 specification sheet](https://resources.kohler.com/webassets/kpna/catalog/pdf/en/K-2844-4_spec_US-CA_Kohler_en.pdf)
- [KOHLER Tresham specification sheet](https://resources.kohler.com/onlinecatalog/pdf/K-2844-4_spec.pdf)
- [KOHLER Tresham collection sell sheet](https://resources.kohler.com/webassets/kpna/brochures/Tresham_SellSheet.pdf)

### KOHLER Entity K-26108-LA-0 alcove bath

KOHLER's product page lists the left-drain Entity bath at 60 x 32 x 15 3/4 in overall, with an integral apron and integral flange, for alcove installation. The family page lists an RFA/Revit design-file option. The M133 fit screen uses a 60 x 32 in nominal plan envelope only; the flange, wall finish, installation tolerance, access/use envelope, drain connection and exact solids are absent. The right-drain counterpart, opening direction and service routing remain open.

The official page's server-rendered product-file link exposes `https://techcomm.kohler.com/techcomm/cad/Bath-Alcove-KOHLER-Entity-K-26108.rfa`. A HEAD request returned HTTP 200 and 1,187,840 bytes; that exact file has since been retrieved without sign-in into ignored `.local/revit-pilot/family-intake/candidates/kohler-entity-k-26108-2026-10-30/`. SHA256 is `DBE1D03ACD1C4DBB5DF2B670CDF87A2E5ADC74E35EF4FEC46382EE0A7AB5B948`. Its source manifest records the URL, size, retrieval time and the fact that left/right drain type is unverified. It has not been opened or modified in Revit.

- [KOHLER Entity K-26108-LA-0 product page and design files](https://dev.studiokohler.com/products/bathroom/bathing/26108-la)
- [KOHLER specification sheet](https://techcomm.kohler.com/techcomm/#/product/26108-LA)

## Fit-study interpretation

M133 places the three source-dimensioned rectangular envelopes against the west and north edges of both unchanged M130 U-05 room-block alternatives. It screens the selected-D 3 1/2-ft primary-bath interface reservation as an arithmetic opening band, not a door. The water-closet envelope is taken from the selected 610AA product-dimension research already documented in `Research/M06_Toilet_Options_2026-10-27.md`; its Revit solids remain unavailable. The existing preliminary 2021 IRC fixture-spacing screen is applied only as a geometry screen: 15 in from WC centerline to side obstruction and 21 in in front. A 30-in WC-to-sink centerline spacing is retained as an explicit project-study assumption. Local code adoption and applicability are not established.
