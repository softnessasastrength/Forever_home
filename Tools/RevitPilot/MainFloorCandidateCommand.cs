using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;
[Transaction(TransactionMode.Manual)]
public sealed class MainFloorCandidateCommand:IExternalCommand
{
 const string Input="Architecture/Main_Floor_Front_Entry_Coordination_2026-11-01/artifacts/main-floor-candidate-input.json";
 static double N(JsonElement e,string k)=>e.GetProperty(k).GetDouble();
 static string Hash(string p)=>Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(p)));
 public Result Execute(ExternalCommandData data,ref string message,ElementSet elements){
  Document? doc=null;
  try{
   string root=File.ReadAllText(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!,"workspace.txt")).Trim();
   string source=Path.Combine(root,Input);using var json=JsonDocument.Parse(File.ReadAllText(source));var input=json.RootElement;
   foreach(var pin in input.GetProperty("source_sha256").EnumerateObject()){
    string path=Path.GetFullPath(Path.Combine(root,pin.Name));if(!path.StartsWith(root+Path.DirectorySeparatorChar,StringComparison.OrdinalIgnoreCase)||!Hash(path).Equals(pin.Value.GetString(),StringComparison.OrdinalIgnoreCase))throw new InvalidDataException("Candidate source fingerprint mismatch: "+pin.Name);
   }
   if(input.GetProperty("candidate").GetInt32()!=21)throw new InvalidDataException("Unreviewed candidate");
   var rooms=input.GetProperty("room_blocks").EnumerateArray().ToArray();var entry=rooms.Single(r=>r.GetProperty("id").GetString()=="M-05");var pantry=rooms.Single(r=>r.GetProperty("id").GetString()=="M-04");
   var porch=input.GetProperty("porch");var spur=input.GetProperty("pantry_spur").GetProperty("to_pantry_ft");double routeWidth=N(input,"route_width_ft");
   string output=Path.Combine(root,".local","revit-pilot","main-floor-candidate",DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));Directory.CreateDirectory(output);
   doc=data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
   var records=new List<object>();int outlines=0;
   string typeName;double typeWidth;
   using(var tx=new Transaction(doc,"Build unselected main-floor comparison")){
    tx.Start();var levels=new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().ToArray();if(levels.Length!=1)throw new InvalidDataException("Expected one template level");var level=levels[0];level.Name="Local zero — building elevations unresolved";level.Elevation=0;
    var type=new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>().Where(t=>t.Kind==WallKind.Basic).OrderBy(t=>t.Name,StringComparer.Ordinal).First();typeName=type.Name;typeWidth=type.Width;
    var plane=SketchPlane.Create(doc,Plane.CreateByNormalAndOrigin(XYZ.BasisZ,XYZ.Zero));
    foreach(double height in new[]{8.0,9.0,10.0}){
     double offset=(height-8)*60;
     void WallSeg(double x1,double y1,double x2,double y2,string label){var a=new XYZ(x1+offset,y1,0);var b=new XYZ(x2+offset,y2,0);var wall=Wall.Create(doc,Line.CreateBound(a,b),type.Id,level.Id,height,0,false,false);wall.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.Set("PROPOSAL; "+label+"; assembly unselected");records.Add(new{element_id=wall.Id.Value,height_proxy_ft=height,label,start_ft=new[]{a.X,a.Y,a.Z},end_ft=new[]{b.X,b.Y,b.Z}});}
     double front=(N(entry,"x")+N(entry,"w")/2),half=routeWidth/2;var door=input.GetProperty("porch_nominal_door_reservation_ft");double dl=door[0].GetDouble(),dr=door[1].GetDouble();
     WallSeg(0,0,front-half,0,"front route-reservation gap, not selected door");WallSeg(front+half,0,40,0,"main south");WallSeg(40,0,40,42,"main east");WallSeg(40,42,dr,42,"rear nominal porch-door reservation");WallSeg(dl,42,0,42,"rear nominal porch-door reservation");WallSeg(0,42,0,0,"main west");
     double px=N(porch,"X"),py=N(porch,"Y"),pw=N(porch,"W"),pd=N(porch,"D");WallSeg(px,py,px,py+pd,"porch west");WallSeg(px,py+pd,px+pw,py+pd,"porch north");WallSeg(px+pw,py+pd,px+pw,py,"porch east");
     double x=N(pantry,"x"),y=N(pantry,"y"),w=N(pantry,"w"),d=N(pantry,"d"),centre=spur[1].GetDouble();WallSeg(x,y,x+w,y,"pantry south");WallSeg(x+w,y,x+w,y+d,"pantry east");WallSeg(x+w,y+d,x,y+d,"pantry north");if(centre+half<y+d-1e-7)WallSeg(x,y+d,x,centre+half,"pantry west, 36-in study gap; nominal30-in door unresolved");if(centre-half>y+1e-7)WallSeg(x,centre-half,x,y,"pantry west study gap");
     void Outline(double ox,double oy,double ow,double od){XYZ[] pts={new(ox+offset,oy,0),new(ox+ow+offset,oy,0),new(ox+ow+offset,oy+od,0),new(ox+offset,oy+od,0)};for(int i=0;i<4;i++){doc.Create.NewModelCurve(Line.CreateBound(pts[i],pts[(i+1)%4]),plane);outlines++;}}
     foreach(var room in rooms)Outline(N(room,"x"),N(room,"y"),N(room,"w"),N(room,"d"));
     foreach(string key in new[]{"kitchen_proxies","dining_proxies","living_proxies"})foreach(var r in input.GetProperty(key).EnumerateArray()){bool upper=r.TryGetProperty("X",out _);Outline(N(r,upper?"X":"x"),N(r,upper?"Y":"y"),N(r,upper?"W":"w"),N(r,upper?"D":"d"));}
    }
    var vt=new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(t=>t.ViewFamily==ViewFamily.ThreeDimensional);var view=View3D.CreateIsometric(doc,vt.Id);view.Name="Unselected main floor — 8-9-10 ft height proxies";tx.Commit();
   }
   var nativeWalls=new FilteredElementCollector(doc).OfClass(typeof(Wall)).Cast<Wall>().ToArray();
   int count=nativeWalls.Length;if(count!=records.Count||count!=42)throw new InvalidDataException("Wall inventory mismatch; expected 14 walls in each of three cases");
   var nativeInventory=nativeWalls.Select(w=>{
    if(w.Location is not LocationCurve location)throw new InvalidDataException("Wall missing native location curve");
    var a=location.Curve.GetEndPoint(0);var b=location.Curve.GetEndPoint(1);var box=w.get_BoundingBox(null)??throw new InvalidDataException("Wall missing native bounds");
    return new{element_id=w.Id.Value,label=w.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.AsString(),start_ft=new[]{a.X,a.Y,a.Z},end_ft=new[]{b.X,b.Y,b.Z},unconnected_height_ft=w.get_Parameter(BuiltInParameter.WALL_USER_HEIGHT_PARAM).AsDouble(),width_ft=w.Width,bounds_min_ft=new[]{box.Min.X,box.Min.Y,box.Min.Z},bounds_max_ft=new[]{box.Max.X,box.Max.Y,box.Max.Z}};
   }).ToArray();
   string file=Path.Combine(output,"FH_Main_Floor_Candidate_21.rvt");doc.SaveAs(file,new SaveAsOptions());doc.Close(false);doc=null;
   File.WriteAllText(Path.Combine(output,"manifest.json"),JsonSerializer.Serialize(new{schema="forever-home-main-floor-candidate-revit-v1",status="disposable unselected native wall comparison; no coordinated wall-face fit established",input=Input,input_sha256=Hash(source),saved_rvt=Path.GetFileName(file),saved_rvt_sha256=Hash(file),wall_count=count,model_curve_count=outlines,wall_type=typeName,template_width_ft=typeWidth,wall_type_selected=false,records,native_wall_inventory=nativeInventory,limitations=new[]{"Walls follow schematic centre lines; actual face clearances and opening dimensions must be audited in Revit.","Route-reservation gaps are not selected doors; porch nominal width is not actual clear opening.","No floors, ceilings, physical furniture, stairs, roof, structure or MEP; all three cases use a local zero datum.","No code, structural, professional or construction approval."}},new JsonSerializerOptions{WriteIndented=true}));
   TaskDialog.Show("Forever Home","Disposable main-floor candidate saved: "+file);return Result.Succeeded;
  }catch(Exception ex){message=ex.ToString();if(doc is not null&&doc.IsValidObject)doc.Close(false);TaskDialog.Show("Main floor candidate failed",ex.Message);return Result.Failed;}
 }
}
