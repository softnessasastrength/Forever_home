using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.DB.Architecture;
using Autodesk.Revit.DB.Structure;
using Autodesk.Revit.UI;
using System.IO;
using System.Reflection;
using System.Text.Json;

namespace ForeverHome.Pilot;

public class App : IExternalApplication
{
    public Result OnStartup(UIControlledApplication app)
    {
        var panel = app.CreateRibbonPanel("Forever Home Pilot");
        panel.AddItem(new PushButtonData("FHCompatibilityPilot", "Run compatibility\npilot",
            Assembly.GetExecutingAssembly().Location, typeof(Command).FullName!));
        panel.AddItem(new PushButtonData("FHCompactCoreStudy", "Build compact core\nstudy",
            Assembly.GetExecutingAssembly().Location, typeof(CompactCoreCommand).FullName!));
        return Result.Succeeded;
    }
    public Result OnShutdown(UIControlledApplication app) => Result.Succeeded;
}

public class CompactApp : IExternalApplication
{
    public Result OnStartup(UIControlledApplication app)
    {
        var panel = app.CreateRibbonPanel("Forever Home Compact Study");
        panel.AddItem(new PushButtonData("FHCompactCoreStudyStandalone", "Build compact core\nstudy",
            Assembly.GetExecutingAssembly().Location, typeof(CompactCoreCommand).FullName!));
        return Result.Succeeded;
    }
    public Result OnShutdown(UIControlledApplication app) => Result.Succeeded;
}

[Transaction(TransactionMode.Manual)]
public class CompactCoreCommand : IExternalCommand
{
    static void Tag(Element e, string id)
    {
        var p = e.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS);
        if (p is not null && !p.IsReadOnly) p.Set(id);
    }

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        try
        {
            var doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            string root = File.ReadAllText(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!, "workspace.txt")).Trim();
            string output = Path.Combine(root, ".local", "revit-pilot", "compact-core", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            var door = Command.MakeFamily(data.Application.Application, doc, output, "Door.rft", "FH_C_Nominal_Door", 3, .15, 7);
            Level lower, main, upper;
            using (var t = new Transaction(doc, "C compact core study; proposal only"))
            {
                t.Start();
                lower = Level.Create(doc, -5); lower.Name = "C Lower -5 ft";
                main = Level.Create(doc, 0); main.Name = "C Main 0 ft";
                upper = Level.Create(doc, 5); upper.Name = "C Upper +5 ft";
                var wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>()
                    .First(w => w.Kind == WallKind.Basic);
                void WallAtLevel(Level level, XYZ a, XYZ b, string id) { var w = Wall.Create(doc, Line.CreateBound(a,b), wallType.Id, level.Id, 10, 0, false, false); Tag(w,id); }
                void WallAt(XYZ a, XYZ b, string id) => WallAtLevel(main,a,b,id);
                void RoomBoxAt(Level level, string id, double x, double y, double width, double depth)
                {
                    var pts = new[] { new XYZ(x,y,0), new XYZ(x+width,y,0), new XYZ(x+width,y+depth,0), new XYZ(x,y+depth,0) };
                    for (int i=0;i<4;i++) WallAtLevel(level,pts[i],pts[(i+1)%4],$"FH-C-{id}-{i+1:00}");
                }
                var shell = new[] { new XYZ(0,0,0), new XYZ(40,0,0), new XYZ(40,40,0), new XYZ(0,40,0) };
                for (int i=0;i<4;i++) WallAt(shell[i],shell[(i+1)%4],$"FH-C-SHELL-{i+1:00}");
                var core = new[] { new XYZ(21.5,30.5,0), new XYZ(29.5,30.5,0), new XYZ(29.5,38.5,0), new XYZ(21.5,38.5,0) };
                for (int i=0;i<4;i++) WallAt(core[i],core[(i+1)%4],$"FH-C-LIFT-RES-{i+1:00}");
                void RoomBox(string id, double x, double y, double width, double depth)
                {
                    var pts = new[] { new XYZ(x,y,0), new XYZ(x+width,y,0), new XYZ(x+width,y+depth,0), new XYZ(x,y+depth,0) };
                    for (int i=0;i<4;i++) WallAt(pts[i],pts[(i+1)%4],$"FH-C-{id}-{i+1:00}");
                }
                RoomBox("M-01-LIVING", 1, 1, 16, 15);
                RoomBox("M-02-KITCHEN", 22, 1, 17, 16);
                RoomBox("M-03-DINING", 1, 17, 11, 13.5);
                RoomBox("M-06-MAIN-BATH", 30.5, 27, 8, 10);
                RoomBox("L-02-MAIN-FLEX", 1, 31.5, 11, 7.5);
                var upperShell = new[] { new XYZ(0,40,0), new XYZ(36,40,0), new XYZ(36,72,0), new XYZ(0,72,0) };
                var lowerShell = new[] { new XYZ(0,40,0), new XYZ(36,40,0), new XYZ(36,72,0), new XYZ(0,72,0) };
                for (int i=0;i<4;i++) { WallAtLevel(upper,upperShell[i],upperShell[(i+1)%4],$"FH-C-UPPER-SHELL-{i+1:00}"); WallAtLevel(lower,lowerShell[i],lowerShell[(i+1)%4],$"FH-C-LOWER-SHELL-{i+1:00}"); }
                RoomBoxAt(upper,"U-01-PRIMARY", 1,41,16,10);
                RoomBoxAt(upper,"U-05-PRIMARY-BATH", 1,52,9,10);
                RoomBoxAt(upper,"U-02-BOUTIQUE", 1,63,16,8);
                RoomBoxAt(upper,"U-04-GUEST", 18,41,12,8.5);
                RoomBoxAt(upper,"U-06-JACK-JILL", 25,50.5,10,12);
                RoomBoxAt(upper,"U-03-HYBRID", 18,63,13,8);
                RoomBoxAt(lower,"L-03-LOWER-BATH", 1,41,9,10);
                RoomBoxAt(lower,"L-04-LAUNDRY", 1,52,9,8);
                RoomBoxAt(lower,"L-05-MEP", 1,61,9,9);
                RoomBoxAt(lower,"L-07-ARRIVAL", 26,41,9,11.5);
                RoomBoxAt(lower,"L-01-FLEX-LIVING", 11,53,13,18);
                RoomBoxAt(lower,"L-06-TECH-RELOCATED", 26,63,8,8);
                var viewType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(v => v.ViewFamily == ViewFamily.ThreeDimensional);
                var view = View3D.CreateIsometric(doc, viewType.Id); view.Name = "C Compact Core 3D";
                var planType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(v => v.ViewFamily == ViewFamily.FloorPlan);
                var mainPlan = ViewPlan.Create(doc, planType.Id, main.Id); mainPlan.Name = "C Main Room Blocks";
                var upperPlan = ViewPlan.Create(doc, planType.Id, upper.Id); upperPlan.Name = "C Upper Room Blocks";
                var lowerPlan = ViewPlan.Create(doc, planType.Id, lower.Id); lowerPlan.Name = "C Lower Room Blocks";
                void RoomAt(Level level, string id, string name, double x, double y)
                {
                    var room = doc.Create.NewRoom(level, new UV(x,y));
                    room.Number = id; room.Name = name; Tag(room,id);
                }
                RoomAt(main,"M-01","Living room",9,8);
                RoomAt(main,"M-02","Kitchen",30,9);
                RoomAt(main,"M-03","Dining",6,23);
                RoomAt(main,"M-06","Proposed main full bath",34,32);
                RoomAt(main,"L-02","Main flex sleeping room",6,35);
                RoomAt(upper,"U-01","Primary bedroom",9,46);
                RoomAt(upper,"U-05","Primary bath",5,57);
                RoomAt(upper,"U-02","Boutique",9,67);
                RoomAt(upper,"U-04","Guest bedroom",24,45);
                RoomAt(upper,"U-06","Jack and Jill bath",30,56);
                RoomAt(upper,"U-03","Hybrid bedroom office",24,67);
                RoomAt(lower,"L-03","Lower full bath",5,46);
                RoomAt(lower,"L-04","Laundry",5,56);
                RoomAt(lower,"L-05","MEP reservation",5,65);
                RoomAt(lower,"L-07","Arrival and dry storage",30,46);
                RoomAt(lower,"L-01","Lower flexible living",17,62);
                RoomAt(lower,"L-06","Relocated technology room",30,67);
                door.Activate(); doc.Regenerate();
                Wall FindWall(string marker)
                {
                    var wall = new FilteredElementCollector(doc).OfClass(typeof(Wall)).Cast<Wall>()
                        .FirstOrDefault(w => w.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.AsString() == marker);
                    if (wall is null) throw new InvalidOperationException("Door host wall not found: " + marker);
                    return wall;
                }
                void PlaceDoor(string marker, XYZ point, Level level, string id)
                {
                    var instance = doc.Create.NewFamilyInstance(point, door, FindWall(marker), level, StructuralType.NonStructural);
                    Tag(instance,id);
                }
                PlaceDoor("FH-C-SHELL-01", new XYZ(6,0,0), main, "D-MAIN-ENTRY");
                PlaceDoor("FH-C-M-06-MAIN-BATH-01", new XYZ(34,27,0), main, "D-MAIN-BATH");
                PlaceDoor("FH-C-L-02-MAIN-FLEX-01", new XYZ(6,31.5,0), main, "D-MAIN-FLEX");
                PlaceDoor("FH-C-U-05-PRIMARY-BATH-01", new XYZ(5,52,0), upper, "D-PRIMARY-BATH");
                PlaceDoor("FH-C-L-06-TECH-RELOCATED-01", new XYZ(30,63,0), lower, "D-TECH-SERVICE");
                var schedule = ViewSchedule.CreateSchedule(doc, new ElementId(BuiltInCategory.OST_Rooms)); schedule.Name = "C Room Area Schedule";
                var textType = new FilteredElementCollector(doc).OfClass(typeof(TextNoteType)).FirstElementId();
                TextNote.Create(doc, mainPlan.Id, new XYZ(14,20,0), "C route test: entry > living > kitchen > dining > main bath > main flex\nNominal doors only; clearances, swings and accessibility remain unverified.", textType);
                var sketchPlane = SketchPlane.Create(doc, Plane.CreateByNormalAndOrigin(XYZ.BasisZ, XYZ.Zero));
                void StudyLine(double x1, double y1, double x2, double y2)
                { doc.Create.NewModelCurve(Line.CreateBound(new XYZ(x1,y1,0), new XYZ(x2,y2,0)), sketchPlane); }
                void StudyBox(double x, double y, double width, double depth)
                { StudyLine(x,y,x+width,y); StudyLine(x+width,y,x+width,y+depth); StudyLine(x+width,y+depth,x,y+depth); StudyLine(x,y+depth,x,y); }
                StudyBox(26.5,7,8,4);     // appliance-free island
                StudyLine(22,2,39,2);      // perimeter counter run
                StudyBox(4,20,5,3);        // dining table
                StudyBox(2,3,4,7);         // TV/service envelope
                StudyBox(12,2,5,5);        // hearth envelope
                StudyBox(7,10,6,3);        // loveseat envelope
                StudyBox(31,28,5,1.8);     // main-bath vanity
                StudyBox(30.5,35,5,3);     // main-bath shower
                StudyBox(36,35,1.5,2.5);   // main-bath toilet
                TextNote.Create(doc, mainPlan.Id, new XYZ(23,6,0), "8 x 4 island | appliance-free", textType);
                TextNote.Create(doc, mainPlan.Id, new XYZ(2,19,0), "5 x 3 dining table | 4 ft porch lane target", textType);
                TextNote.Create(doc, mainPlan.Id, new XYZ(2,2,0), "TV/service 4 x 7 | hearth 5 x 5 | furniture placeholders", textType);
                TextNote.Create(doc, mainPlan.Id, new XYZ(30,27,0), "M-06 nominal fixtures | turn/approach/door checks pending", textType);
                Tag(lower,"FH-C-LEVEL-LOWER"); Tag(main,"FH-C-LEVEL-MAIN"); Tag(upper,"FH-C-LEVEL-UPPER");
                t.Commit();
            }
            using (var scope = new StairsEditScope(doc, "C compact core native stairs"))
            {
                var stairsId = scope.Start(lower.Id, main.Id);
                using (var t = new Transaction(doc, "C lower-to-main stair run"))
                { t.Start(); StairsRun.CreateStraightRun(doc, stairsId, Line.CreateBound(new XYZ(12.5,27,0), new XYZ(12.5,34,0)), StairsRunJustification.Center); t.Commit(); }
                scope.Commit(new FailureRecorder());
                using (var t = new Transaction(doc, "Tag C lower stair")) { t.Start(); Tag(doc.GetElement(stairsId),"FH-C-STAIR-LOWER-MAIN"); t.Commit(); }
            }
            using (var scope = new StairsEditScope(doc, "C compact core upper stairs"))
            {
                var stairsId = scope.Start(main.Id, upper.Id);
                using (var t = new Transaction(doc, "C main-to-upper stair run"))
                { t.Start(); StairsRun.CreateStraightRun(doc, stairsId, Line.CreateBound(new XYZ(17,27,0), new XYZ(17,34,0)), StairsRunJustification.Center); t.Commit(); }
                scope.Commit(new FailureRecorder());
                using (var t = new Transaction(doc, "Tag C upper stair")) { t.Start(); Tag(doc.GetElement(stairsId),"FH-C-STAIR-MAIN-UPPER"); t.Commit(); }
            }
            string path = Path.Combine(output, "FH_Compact_Core_Study.rvt");
            doc.SaveAs(path, new SaveAsOptions());
            var manifest = new {
                status = "generated by Revit 2027 command; native verification required",
                study = "C compact core",
                levels = new[] { new { id="FH-C-LEVEL-LOWER", elevation_ft=-5 }, new { id="FH-C-LEVEL-MAIN", elevation_ft=0 }, new { id="FH-C-LEVEL-UPPER", elevation_ft=5 } },
                shell = new { main_width_ft=40, main_depth_ft=40, rear_width_ft=36, rear_depth_ft=32 },
                lift_reservation = new { width_ft=8, depth_ft=8, product_selected=false },
                rooms = new[] { "M-01","M-02","M-03","M-06","L-02","U-01","U-02","U-03","U-04","U-05","U-06","L-01","L-03","L-04","L-05","L-06","L-07" },
                doors = new[] { "D-MAIN-ENTRY","D-MAIN-BATH","D-MAIN-FLEX","D-PRIMARY-BATH","D-TECH-SERVICE" },
                unresolved = new[] { "wall overlap warnings", "door openings and swings", "stair headroom", "lift product fit", "full accessibility route", "structure and MEP coordination", "code review" },
                source_rvt = path
            };
            File.WriteAllText(Path.Combine(output, "study-manifest.json"), JsonSerializer.Serialize(manifest, new JsonSerializerOptions { WriteIndented=true }));
            doc.Close(false);
            data.Application.OpenAndActivateDocument(path);
            TaskDialog.Show("Forever Home compact core", "C study saved separately. Levels, shell/core reservations and native stair runs only.\n" + path);
            return Result.Succeeded;
        }
        catch (Exception ex) { message = ex.Message; return Result.Failed; }
    }
}

[Transaction(TransactionMode.Manual)]
public class Command : IExternalCommand
{
    // The adjacent marker is generated by build.ps1; no machine path is committed.
    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        string root = File.ReadAllText(Path.Combine(Path.GetDirectoryName(
            Assembly.GetExecutingAssembly().Location)!, "workspace.txt")).Trim();
        string output = Path.Combine(root, ".local", "revit-pilot", "runs",
            DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
        Directory.CreateDirectory(output);
        try
        {
            Run(data.Application, output);
            TaskDialog.Show("Forever Home pilot", "Pilot finished. See run.json and exports under:\n" + output);
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            File.WriteAllText(Path.Combine(output, "failure.txt"), ex.ToString());
            message = "Pilot failed; diagnostic saved under " + output + "\n" + ex.Message;
            return Result.Failed;
        }
    }

    static void Tag(Element e, string id)
    {
        var p = e.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS);
        if (p is null || p.IsReadOnly) throw new InvalidOperationException("Cannot tag " + id);
        p.Set(id);
    }

    internal static FamilySymbol MakeFamily(Autodesk.Revit.ApplicationServices.Application app,
        Document project, string output, string template, string name, double w, double d, double h)
    {
        string templates = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData),
            "Autodesk", "RVT 2027", "Family Templates", "English-Imperial");
        var familyDoc = app.NewFamilyDocument(Path.Combine(templates, template));
        try
        {
            using (var t = new Transaction(familyDoc, "Pilot fixture geometry"))
            {
                t.Start();
                familyDoc.FamilyManager.NewType("Pilot fixture only");
                var profile = new CurveArray();
                var pts = new[] {new XYZ(-w/2, -d/2, 0), new XYZ(w/2, -d/2, 0),
                    new XYZ(w/2, d/2, 0), new XYZ(-w/2, d/2, 0)};
                for (int i = 0; i < 4; i++) profile.Append(Line.CreateBound(pts[i], pts[(i+1)%4]));
                var loops = new CurveArrArray(); loops.Append(profile);
                var plane = SketchPlane.Create(familyDoc, Plane.CreateByNormalAndOrigin(XYZ.BasisZ, XYZ.Zero));
                familyDoc.FamilyCreate.NewExtrusion(true, loops, plane, h);
                t.Commit();
            }
            familyDoc.SaveAs(Path.Combine(output, name + ".rfa"), new SaveAsOptions());
            Family family = familyDoc.LoadFamily(project);
            return (FamilySymbol)project.GetElement(family.GetFamilySymbolIds().First());
        }
        finally { familyDoc.Close(false); }
    }

    static void Run(UIApplication ui, string output)
    {
        var app = ui.Application;
        var doc = app.NewProjectDocument(UnitSystem.Imperial);
        var exportResults = new Dictionary<string, object>();
        var tagged = new List<(string id, Element element)>();
        Level lower, upper;
        ViewPlan plan;
        View3D view3d;
        try
        {
            var door = MakeFamily(app, doc, output, "Door.rft", "FH_Pilot_Door", 3, .15, 7);
            var window = MakeFamily(app, doc, output, "Window.rft", "FH_Pilot_Window", 3, .15, 3);
            var equipment = MakeFamily(app, doc, output, "Mechanical Equipment.rft", "FH_Pilot_Equipment", 2, 2, 3);
            using (var t = new Transaction(doc, "Build compatibility fixture; not house design"))
            {
                t.Start();
                lower = Level.Create(doc, 0); lower.Name = "PILOT Lower 0 ft";
                upper = Level.Create(doc, 10); upper.Name = "PILOT Upper 10 ft";
                var floorPlanType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType))
                    .Cast<ViewFamilyType>().First(v => v.ViewFamily == ViewFamily.FloorPlan);
                plan = ViewPlan.Create(doc, floorPlanType.Id, lower.Id); plan.Name = "PILOT Fixture Plan";
                plan.Scale = 48;
                var viewType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType))
                    .Cast<ViewFamilyType>().First(v => v.ViewFamily == ViewFamily.ThreeDimensional);
                view3d = View3D.CreateIsometric(doc, viewType.Id); view3d.Name = "PILOT Fixture 3D";
                // Default level datums otherwise dominate the uncropped PDF extents.
                view3d.SetCategoryHidden(new ElementId(BuiltInCategory.OST_Levels), true);
                view3d.SetSectionBox(new BoundingBoxXYZ { Min=new XYZ(-1,-1,-1),Max=new XYZ(34,20,14) });
                view3d.IsSectionBoxActive=true;
                view3d.SetCategoryHidden(new ElementId(BuiltInCategory.OST_SectionBox), true);
                var wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>()
                    .First(w => w.Kind == WallKind.Basic);
                var pts = new[] {XYZ.Zero, new XYZ(24,0,0),new XYZ(24,18,0),new XYZ(0,18,0)};
                var walls = new List<Wall>();
                for (int i=0;i<4;i++)
                {
                    var wall = Wall.Create(doc,Line.CreateBound(pts[i],pts[(i+1)%4]),wallType.Id,lower.Id,10,0,false,false);
                    string id = $"FH-PILOT-WALL-{i+1:00}"; Tag(wall,id); tagged.Add((id,wall)); walls.Add(wall);
                }
                door.Activate(); window.Activate(); equipment.Activate(); doc.Regenerate();
                var doorInstance = doc.Create.NewFamilyInstance(new XYZ(6,0,0),door,walls[0],lower,StructuralType.NonStructural);
                var windowInstance = doc.Create.NewFamilyInstance(new XYZ(16,0,3),window,walls[0],lower,StructuralType.NonStructural);
                var equipInstance = doc.Create.NewFamilyInstance(new XYZ(4,5,0),equipment,lower,StructuralType.NonStructural);
                foreach (var item in new[] {("FH-PILOT-DOOR-01",doorInstance), ("FH-PILOT-WINDOW-01",windowInstance),
                    ("FH-PILOT-EQUIPMENT-01",equipInstance)})
                { Tag(item.Item2,item.Item1); tagged.Add((item.Item1,item.Item2)); }
                doc.Regenerate();
                var room = doc.Create.NewRoom(lower,new UV(12,9)); room.Number="FH-PILOT-ROOM-01"; room.Name="Compatibility fixture";
                Tag(room,room.Number); tagged.Add((room.Number,room));
                var textType = new FilteredElementCollector(doc).OfClass(typeof(TextNoteType)).FirstElementId();
                TextNote.Create(doc,plan.Id,new XYZ(0,21,0),
                    "COMPATIBILITY FIXTURE ONLY - NOT HOUSE DESIGN\n24 x 18 ft wall centerlines; 10 ft level rise; separate stair\nDoor, window, room and equipment are test objects",textType);
                doc.Regenerate();
                if (room.Area <= 0) throw new InvalidOperationException("Pilot room not enclosed");
                if (doorInstance.Host.Id != walls[0].Id || windowInstance.Host.Id != walls[0].Id)
                    throw new InvalidOperationException("Opening fixtures lost host");
                t.Commit();
            }
            var warnings = new FailureRecorder();
            using (var scope = new StairsEditScope(doc,"Pilot stair"))
            {
                var stairsId = scope.Start(lower.Id,upper.Id);
                using(var t = new Transaction(doc,"Pilot stair run"))
                {
                    t.Start();
                    StairsRun.CreateStraightRun(doc,stairsId,
                        Line.CreateBound(new XYZ(30,0,0),new XYZ(30,16,0)),StairsRunJustification.Center);
                    t.Commit();
                }
                scope.Commit(warnings);
                using(var t = new Transaction(doc,"Tag pilot stair"))
                {
                    t.Start(); var stair = doc.GetElement(stairsId); Tag(stair,"FH-PILOT-STAIR-01");
                    tagged.Add(("FH-PILOT-STAIR-01",stair)); t.Commit();
                }
            }
            var records = tagged.Select(x => new {
                id=x.id, unique_id=x.element.UniqueId, category=x.element.Category?.Name,
                name=x.element.Name, host_unique_id=(x.element as FamilyInstance)?.Host?.UniqueId,
                room_area_sf=(x.element as Room)?.Area
            }).ToList();
            string source = Path.Combine(output,"FH_Compatibility_Pilot.rvt");
            doc.SaveAs(source,new SaveAsOptions());
            // Export failures are independent and explicit; a partial run never means all exports passed.
            void Export(string name, Func<bool> action)
            {
                try { exportResults[name] = new { success=action() }; }
                catch(Exception ex) { exportResults[name] = new { success=false,error=ex.Message }; }
            }
            Export("ifc2x3", () => {
                using var t = new Transaction(doc,"IFC export"); t.Start();
                var options = new IFCExportOptions { FileVersion=IFCVersion.IFC2x3CV2,ExportBaseQuantities=true };
                options.AddOption("ExportInternalRevitPropertySets","true");
                bool ok=doc.Export(output,"FH_Compatibility_Pilot",options); t.RollBack(); return ok;
            });
            Export("dwg", () => doc.Export(output,"FH_Compatibility_Pilot",new List<ElementId>{plan.Id},
                new DWGExportOptions { FileVersion=ACADVersion.R2010,MergedViews=true }));
            Export("pdf", () => doc.Export(output,new List<ElementId>{plan.Id,view3d.Id},
                new PDFExportOptions { Combine=true,FileName="FH_Compatibility_Pilot" }));
            File.WriteAllText(Path.Combine(output,"elements.json"),JsonSerializer.Serialize(records,JsonOptions));
            static string Csv(string? value) => "\""+(value??"").Replace("\"","\"\"")+"\"";
            File.WriteAllLines(Path.Combine(output,"elements.csv"),new[]{"id,unique_id,category,name,host_unique_id,room_area_sf"}
                .Concat(records.Select(r=>string.Join(",",Csv(r.id),Csv(r.unique_id),Csv(r.category),Csv(r.name),
                    Csv(r.host_unique_id),Csv(r.room_area_sf?.ToString(System.Globalization.CultureInfo.InvariantCulture))))));
            exportResults["csv"] = new {success=true};
            string backup = Path.Combine(output,"backup","FH_Compatibility_Pilot.rvt");
            Directory.CreateDirectory(Path.GetDirectoryName(backup)!);
            doc.SaveAs(backup,new SaveAsOptions());
            doc.Close(false);
            // Reopen both archives and confirm every fixture's stable identity survived.
            var reopen = new Dictionary<string,bool>();
            foreach(var path in new[]{source,backup})
            {
                var check=app.OpenDocumentFile(path);
                try { reopen[path==source?"source":"backup"] = records.All(r=>check.GetElement(r.unique_id)!=null); }
                finally { check.Close(false); }
            }
            File.WriteAllText(Path.Combine(output,"run.json"),JsonSerializer.Serialize(new {
                status="executed; review per-export results", utc=DateTime.UtcNow,
                revit_version=app.VersionNumber,revit_build=app.VersionBuild,
                fixture_only=true, element_count=records.Count, exports=exportResults,
                reopen_checks=reopen, warnings=warnings.Messages,
                compatibility_2018="not tested", design_or_code_validation="not performed"
            },JsonOptions));
            ui.OpenAndActivateDocument(source);
        }
        catch { if(doc.IsValidObject && !doc.IsLinked) { try { doc.Close(false); } catch { } } throw; }
    }
    static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented=true };
}

class FailureRecorder : IFailuresPreprocessor
{
    public List<string> Messages {get;} = new();
    public FailureProcessingResult PreprocessFailures(FailuresAccessor failures)
    {
        foreach(var failure in failures.GetFailureMessages())
        {
            Messages.Add(failure.GetDescriptionText());
            if(failure.GetSeverity()==FailureSeverity.Warning) failures.DeleteWarning(failure);
        }
        return FailureProcessingResult.Continue;
    }
}
