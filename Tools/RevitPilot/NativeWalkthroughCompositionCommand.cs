using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.DB.Structure;
using Autodesk.Revit.UI;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class NativeWalkthroughCompositionCommand : IExternalCommand
{
    private const string Input = "Architecture/Main_Floor_Front_Entry_Coordination_2026-11-01/artifacts/main-floor-candidate-input.json";
    private const string SelectedD = "Architecture/Selected_Design_Iteration_2026-10-27/study.json";
    private static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path))).ToLowerInvariant();
    private static double N(JsonElement e, string key) => e.GetProperty(key).GetDouble();
    private static void Tag(Element e, string text) => e.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.Set(text);

    private static Floor AddFloor(Document doc, ElementId typeId, ElementId levelId, double ox, double oy, double width, double depth, double z, string tag)
    {
        var loop = new CurveLoop();
        var p = new[] { new XYZ(ox, oy, z), new XYZ(ox + width, oy, z), new XYZ(ox + width, oy + depth, z), new XYZ(ox, oy + depth, z) };
        for (int i = 0; i < p.Length; i++) loop.Append(Line.CreateBound(p[i], p[(i + 1) % p.Length]));
        var floor = Floor.Create(doc, new List<CurveLoop> { loop }, typeId, levelId);
        Tag(floor, tag); return floor;
    }

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            string root = WorkspaceLocator.Find(Assembly.GetExecutingAssembly());
            string inputPath = Path.Combine(root, Input.Replace('/', Path.DirectorySeparatorChar));
            string selectedPath = Path.Combine(root, SelectedD.Replace('/', Path.DirectorySeparatorChar));
            using var json = JsonDocument.Parse(File.ReadAllText(inputPath));
            var input = json.RootElement;
            foreach (var pin in input.GetProperty("source_sha256").EnumerateObject())
            {
                string path = Path.Combine(root, pin.Name.Replace('/', Path.DirectorySeparatorChar));
                if (!Hash(path).Equals(pin.Value.GetString(), StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException("Input lineage mismatch: " + pin.Name);
            }
            string selectedHash = Hash(selectedPath);
            if (!selectedHash.Equals("516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb", StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException("Selected-D changed.");

            string output = Path.Combine(root, ".local", "revit-pilot", "walkthrough-composition", DateTime.UtcNow.ToString("yyyyMMdd'T'HHmmssfff'Z'", CultureInfo.InvariantCulture));
            Directory.CreateDirectory(output);
            doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            var d01 = Command.MakeFamily(data.Application.Application, doc, output, "Door.rft", "FH_WALK_D01_French_5ft", 5.0, .15, 6.6667);
            var d02 = Command.MakeFamily(data.Application.Application, doc, output, "Door.rft", "FH_WALK_D02_Exterior_3ft", 3.0, .15, 6.6667);
            var d03 = Command.MakeFamily(data.Application.Application, doc, output, "Door.rft", "FH_WALK_D03_Pantry_30in", 2.5, .15, 6.6667);
            var records = new List<object>();
            int walls = 0, doors = 0, floors = 0, roofs = 0, landings = 0;
            using (var tx = new Transaction(doc, "Build disposable walkthrough composition"))
            {
                tx.Start();
                var levels = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().OrderBy(x => x.Elevation).ToArray();
                var main = levels.First(); main.Name = "Main FF — composition comparison";
                var upper = Level.Create(doc, 5.0); upper.Name = "Upper comparison +5 ft — floor-to-floor unresolved";
                var wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>().Where(x => x.Kind == WallKind.Basic).OrderBy(x => x.Name, StringComparer.Ordinal).First();
                var floorTypeId = Floor.GetDefaultFloorType(doc, false); if (floorTypeId == ElementId.InvalidElementId) throw new InvalidOperationException("No default floor type.");
                var roofType = new FilteredElementCollector(doc).OfClass(typeof(RoofType)).Cast<RoofType>().OrderBy(x => x.Name, StringComparer.OrdinalIgnoreCase).First();
                foreach (var s in new[] { d01, d02, d03 }) if (!s.IsActive) s.Activate();
                doc.Regenerate();
                var rooms = input.GetProperty("room_blocks").EnumerateArray().ToArray();
                var entry = rooms.Single(r => r.GetProperty("id").GetString() == "M-05");
                var porch = input.GetProperty("porch");
                double front = N(entry, "x") + N(entry, "w") / 2.0, half = N(input, "route_width_ft") / 2.0;
                var rearDoor = input.GetProperty("porch_nominal_door_reservation_ft");
                double rearLeft = rearDoor[0].GetDouble(), rearRight = rearDoor[1].GetDouble();
                double pantryCentre = input.GetProperty("pantry_spur").GetProperty("to_pantry_ft")[1].GetDouble();
                var roofCases = new[] { (label: "8:12", rise: 8.0, run: 12.0), (label: "10:12", rise: 10.0, run: 12.0), (label: "12:12", rise: 12.0, run: 12.0) };
                for (int ci = 0; ci < roofCases.Length; ci++)
                {
                    double offset = ci * 52.0, height = 8.0 + ci;
                    Wall AddWall(double x1, double y1, double x2, double y2, string label)
                    {
                        var w = Wall.Create(doc, Line.CreateBound(new XYZ(offset + x1, y1, 0), new XYZ(offset + x2, y2, 0)), wallType.Id, main.Id, height, 0, false, false);
                        WallUtils.DisallowWallJoinAtEnd(w, 0); WallUtils.DisallowWallJoinAtEnd(w, 1); Tag(w, $"PROPOSAL; walkthrough composition; {roofCases[ci].label}; {label}; unselected"); walls++; return w;
                    }
                    void Door(string id, FamilySymbol sym, double x, double y, Wall host)
                    { var i = doc.Create.NewFamilyInstance(new XYZ(offset + x, y, 0), sym, host, main, StructuralType.NonStructural); Tag(i, $"{id}; walkthrough comparison; unselected"); doors++; }
                    AddWall(0,0,front-half-.5,0,"front west jamb"); var fh=AddWall(front-half-.5,0,front+half+.5,0,"front D-04 host"); AddWall(front+half+.5,0,40,0,"front east jamb"); Door("D-04",d02,front,0,fh);
                    AddWall(40,0,40,42,"east"); AddWall(0,42,rearLeft-.5,42,"rear west jamb"); var rh=AddWall(rearLeft-.5,42,rearRight+.5,42,"rear D-01 host"); AddWall(rearRight+.5,42,40,42,"rear east jamb"); Door("D-01",d01,(rearLeft+rearRight)/2,42,rh); AddWall(0,0,0,42,"west");
                    double px=N(porch,"X"), py=N(porch,"Y"), pw=N(porch,"W"), pd=N(porch,"D"); AddWall(px,py,px,py+pd,"porch west"); AddWall(px+pw,py+pd,px+pw,py,"porch east"); AddWall(px,py+pd,px+5.5,py+pd,"porch west jamb"); var ph=AddWall(px+5.5,py+pd,px+8.5,py+pd,"porch D-02 host"); AddWall(px+8.5,py+pd,px+pw,py+pd,"porch east jamb"); Door("D-02",d02,px+7,py+pd,ph);
                    var pantry=rooms.Single(r=>r.GetProperty("id").GetString()=="M-04"); double x=N(pantry,"x"), y=N(pantry,"y"), w=N(pantry,"w"), d=N(pantry,"d"), hh=1.75; AddWall(x,y,x+w,y,"pantry south"); AddWall(x+w,y,x+w,y+d,"pantry east"); AddWall(x+w,y+d,x,y+d,"pantry north"); AddWall(x,y+d,x,pantryCentre-hh,"pantry lower jamb"); var pwh=AddWall(x,pantryCentre-hh,x,pantryCentre+hh,"pantry D-03 host"); AddWall(x,pantryCentre+hh,x,y+d,"pantry upper jamb"); Door("D-03",d03,x,pantryCentre,pwh);
                    AddFloor(doc, floorTypeId, main.Id, offset, 0, 40, 42, 0, $"PROPOSAL; F-01 finish proxy; {roofCases[ci].label}; substrate/type unselected"); floors++;
                    AddFloor(doc, floorTypeId, main.Id, offset + px, py, pw, pd, 0, $"PROPOSAL; F-02 porch finish proxy; {roofCases[ci].label}; substrate/type unselected"); floors++;
                    AddFloor(doc, floorTypeId, upper.Id, offset + 3, 18, 5.625, 3.3333333, 5, $"PROPOSAL; M328 landing bridge marker; {roofCases[ci].label}; stair/floor-to-floor unresolved"); floors++; landings++;
                    var fp = doc.Application.Create.NewCurveArray(); XYZ[] rp={new(offset,0,0),new(offset+40,0,0),new(offset+40,42,0),new(offset,42,0)}; for(int i=0;i<4;i++) fp.Append(Line.CreateBound(rp[i],rp[(i+1)%4])); ModelCurveArray curves = new(); var roof=doc.Create.NewFootPrintRoof(fp,main,roofType,out curves); int idx=0; foreach(ModelCurve c in curves){bool slope=idx is 0 or 2; roof.set_DefinesSlope(c,slope); if(slope) roof.set_SlopeAngle(c,Math.Atan(roofCases[ci].rise/roofCases[ci].run)); idx++;} Tag(roof,$"PROPOSAL; roof option {roofCases[ci].label}; no pitch selected"); roofs++;
                    records.Add(new { option=roofCases[ci].label, clear_height_ft=height, offset_ft=offset, wall_count=19, door_count=4, floor_count=3, landing_count=1, roof_count=1, selected=false });
                }
                var vt = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(x=>x.ViewFamily==ViewFamily.ThreeDimensional); var view=View3D.CreateIsometric(doc,vt.Id); view.Name="Walkthrough composition — unselected comparison"; tx.Commit();
            }
            if (walls!=57||doors!=12||floors!=9||roofs!=3||landings!=3) throw new InvalidDataException($"Inventory mismatch walls={walls} doors={doors} floors={floors} roofs={roofs} landings={landings}");
            string rvt=Path.Combine(output,"FH_Walkthrough_Composition.rvt"), ifc=Path.Combine(output,"FH_Walkthrough_Composition.ifc"); doc.SaveAs(rvt,new SaveAsOptions()); bool ifcOk; using(var et=new Transaction(doc,"Export walkthrough composition IFC2x3")){et.Start(); try{using var o=new IFCExportOptions{FileVersion=IFCVersion.IFC2x3CV2,ExportBaseQuantities=true}; ifcOk=doc.Export(output,"FH_Walkthrough_Composition",o);}finally{if(et.GetStatus()==TransactionStatus.Started)et.RollBack();}} doc.Close(false); doc=null;
            var manifest=new {schema="forever-home-walkthrough-composition-v1",status="disposable composed walkthrough comparison; not selected-D",selected_d_sha256=selectedHash,input_sha256=Hash(inputPath),cases=records,wall_count=walls,door_count=doors,floor_count=floors,roof_count=roofs,landing_count=landings,saved_rvt=Path.GetFileName(rvt),saved_rvt_sha256=Hash(rvt),ifc=Path.GetFileName(ifc),ifc_sha256=File.Exists(ifc)?Hash(ifc):null,ifc2x3=ifcOk,limitations=new[]{"All geometry is disposable comparison geometry; no roof pitch, floor-to-floor datum, wall/floor assembly, structure, MEP, code, accessibility or M-06 assignment is selected."}}; File.WriteAllText(Path.Combine(output,"walkthrough-composition-manifest.json"),JsonSerializer.Serialize(manifest,new JsonSerializerOptions{WriteIndented=true})); TaskDialog.Show("Forever Home walkthrough",$"Disposable walkthrough composition saved:\n{output}"); return Result.Succeeded;
        }
        catch(Exception ex){message=ex.ToString(); if(doc is not null&&doc.IsValidObject)doc.Close(false); return Result.Failed;}
    }
}
