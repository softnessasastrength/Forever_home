namespace ForeverHome.Pilot.Core;

/// <summary>
/// Typed, UI-neutral inputs for the current M-06 disposable coordination study.
/// These are owner-directed preferences, not a room assignment or code result.
/// </summary>
public sealed record M06CoordinationStudySpec(
    string Assignment,
    string[] ProtectedSearchWindows,
    string ApproachPreference,
    string DoorSwingPreference,
    string FixtureRelationshipPreference,
    string ServiceRouteTarget,
    string LavatoryDirection,
    string ToiletGeometry,
    bool ProductGeometryVerified,
    bool FinishedFaceClearanceVerified,
    bool DoorApproachVerified,
    bool ServiceRouteVerified,
    bool RoomAssignmentAuthorized)
{
    public static M06CoordinationStudySpec OwnerDraft { get; } = new(
        Assignment: "unassigned",
        ProtectedSearchWindows: ["west-A", "east-B"],
        ApproachPreference: "entry-hall-edge",
        DoorSwingPreference: "into-bath",
        FixtureRelationshipPreference: "same-wet-wall",
        ServiceRouteTarget: "lower-MEP-reservation",
        LavatoryDirection: "Kohler Tresham K-2844-4",
        ToiletGeometry: "labelled-current-SKU-plan-proxy",
        ProductGeometryVerified: false,
        FinishedFaceClearanceVerified: false,
        DoorApproachVerified: false,
        ServiceRouteVerified: false,
        RoomAssignmentAuthorized: false);

    public bool FitGatesClosed =>
        !ProductGeometryVerified &&
        !FinishedFaceClearanceVerified &&
        !DoorApproachVerified &&
        !ServiceRouteVerified &&
        !RoomAssignmentAuthorized;
}
