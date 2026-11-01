using System.Text.Json.Nodes;
using System.Text.Json;
using System.Security.Cryptography;
record Rect(double X,double Y,double W,double D);
class Program {
 static double N(JsonNode n,string k)=>(double)n[k];
 static Rect R(JsonNode n)=>new(N(n,"x"),N(n,"y"),N(n,"w"),N(n,"d"));
 static bool Hit(Rect a,Rect b)=>Math.Min(a.X+a.W,b.X+b.W)-Math.Max(a.X,b.X)>1e-7&&Math.Min(a.Y+a.D,b.Y+b.D)-Math.Max(a.Y,b.Y)>1e-7;
 static bool Covered(Rect q,Rect[] rooms){
  var xs=new[]{q.X,q.X+q.W}.Concat(rooms.SelectMany(r=>new[]{r.X,r.X+r.W}).Where(x=>x>q.X&&x<q.X+q.W)).Distinct().Order().ToArray();
  var ys=new[]{q.Y,q.Y+q.D}.Concat(rooms.SelectMany(r=>new[]{r.Y,r.Y+r.D}).Where(y=>y>q.Y&&y<q.Y+q.D)).Distinct().Order().ToArray();
  for(int i=1;i<xs.Length;i++)for(int j=1;j<ys.Length;j++){double x=(xs[i-1]+xs[i])/2,y=(ys[j-1]+ys[j])/2;if(!rooms.Any(r=>x>=r.X-1e-7&&x<=r.X+r.W+1e-7&&y>=r.Y-1e-7&&y<=r.Y+r.D+1e-7))return false;}return true;
 }
 static void Main(string[] args){
  if((args.Length<2||args.Length>7)||File.Exists(args[1]))throw new Exception("Require input, new output, optional Selected-D, furniture, rotate-dining, rear-dining and porch-left flags");
  var selected=args.Length>=3?JsonNode.Parse(File.ReadAllText(args[2])):null;
  var furniture=args.Length>=4?JsonNode.Parse(File.ReadAllText(args[3])):null;
  bool rotate=args.Length>=5&&args[4]=="rotate-dining";
  if(args.Length>=5&&!rotate)throw new Exception("Unknown dining transform");
  bool rear=args.Length>=6&&args[5]=="rear-dining";
  if(args.Length>=6&&!rear)throw new Exception("Unknown dining placement");
  bool porchMode=args.Length==7&&args[6]=="porch-left";
  if(args.Length==7&&(!rear||!porchMode))throw new Exception("Unknown porch placement");
  var doc=JsonNode.Parse(File.ReadAllText(args[0]));double width=(double)doc["patch_width_ft"],h=width/2;
  var results=new List<object>();
  foreach(var c in doc["results"].AsArray().Where(c=>(bool)c["both_interfaces_clear"])){
   var rooms=new[]{R(c["entry"]),R(c["living"]),R(c["kitchen"])};var obs=c["obstacles"].AsArray().Select(R).ToArray();var entry=rooms[0];
   Rect bridge=null;Rect dining=null;
   Rect porch=null;double doorLeft=0,doorRight=0;
   Rect[] diningObstacles=Array.Empty<Rect>();
   if(selected!=null){
    var d=selected["plans"]["main"].AsArray().Single(n=>(string)n["id"]=="M-03");dining=R(d);var k=rooms[2];
    if(rear)dining=dining with{Y=(double)selected["shells"]["main"][1]-dining.D};
    double bx=Math.Max(k.X,dining.X),bw=Math.Min(k.X+k.W,dining.X+dining.W)-bx,by=k.Y+k.D,bd=dining.Y-by;
    var protectedRects=selected["selection"]["main_public_bath"]["search_windows"].AsArray().Select(R).ToArray();
    if(bw<width||bd<0){results.Add(new{candidate=(int)c["candidate"],mirrored=(bool)c["mirrored"],route_found=false,reason="no north connector in this bounded topology"});continue;}
    bridge=new(bx,by,bw,bd);
    if(protectedRects.Any(o=>Hit(bridge,o))){results.Add(new{candidate=(int)c["candidate"],mirrored=(bool)c["mirrored"],route_found=false,reason="connector overlaps protected window"});continue;}
    rooms=rooms.Concat(new[]{bridge,dining}).ToArray();
    var pantry=R(selected["plans"]["main"].AsArray().Single(n=>(string)n["id"]=="M-04"));obs=obs.Concat(protectedRects).Append(pantry).ToArray();
    if(furniture!=null){
     double ox=(double)furniture["dining_block_ft"][0],oy=(double)furniture["dining_block_ft"][1];
     var raw=new[]{R(furniture["table_rect_ft"])}.Concat(furniture["chair_body_rectangles_ft"].AsArray().Select(R)).Concat(furniture["pullout_use_rectangles_ft"].AsArray().Select(R));
     diningObstacles=raw.Select(r=>new Rect(r.X-ox+dining.X,r.Y-oy+dining.Y,r.W,r.D)).ToArray();
     if(rotate){
      double cx=dining.X+dining.W/2,cy=dining.Y+dining.D/2;
      // Rotate the complete source set about its bounding-box centre, then centre it in the source room.
      double minX=diningObstacles.Min(r=>r.X),maxX=diningObstacles.Max(r=>r.X+r.W),minY=diningObstacles.Min(r=>r.Y),maxY=diningObstacles.Max(r=>r.Y+r.D);
      double scx=(minX+maxX)/2,scy=(minY+maxY)/2;
      diningObstacles=diningObstacles.Select(r=>new Rect(cx-(r.Y+r.D-scy),cy+(r.X-scx),r.D,r.W)).ToArray();
     }
     if(diningObstacles.Any(r=>!Covered(r,new[]{dining})))throw new Exception("Dining furniture outside source room");
     obs=obs.Concat(diningObstacles).ToArray();
    }
   }
   if(porchMode){
    double pw=(double)selected["shells"]["porch_ft"][0],pd=(double)selected["shells"]["porch_ft"][1];
    porch=new(dining.X+(dining.W-pw)/2,dining.Y+dining.D,pw,pd);
    doorLeft=dining.X;doorRight=doorLeft+5.0; // Nominal 5-ft reservation from Kitchen_Dining_Porch_Specs; actual clear opening unresolved.
    rooms=rooms.Append(porch).ToArray();
   }
   double sx=entry.X+entry.W/2,sy=entry.Y+h;
   var portals=c["living_portals"].AsArray().Select(p=>(x:N(p,"x"),y:N(p,"y"))).ToArray();
   if(dining!=null)portals=Enumerable.Range(0,161).Select(i=>(x:dining.X+h+i*.25,y:dining.Y+h)).Where(p=>p.x<=dining.X+dining.W-h+1e-7).ToArray();
   if(furniture!=null)portals=portals.Select(p=>(p.x,y:dining.Y+dining.D-h)).ToArray();
   if(porchMode)portals=portals.Where(p=>p.x>=doorLeft+h-1e-7&&p.x<=doorRight-h+1e-7).Select(p=>(p.x,y:porch.Y+h)).ToArray();
   var xs=Enumerable.Range(0,161).Select(i=>2.0/3+i*.25).Concat(portals.Select(p=>p.x)).Append(sx).Distinct().Order().ToArray();
   var ys=Enumerable.Range(0,209).Select(i=>entry.Y+i*.25).Concat(portals.Select(p=>p.y)).Append(sy).Distinct().Order().ToArray();
   int nx=xs.Length,ny=ys.Length;var seen=new bool[nx*ny];var parent=Enumerable.Repeat(-1,nx*ny).ToArray();
   bool Clear(Rect q)=>Covered(q,rooms)&&!obs.Any(o=>Hit(q,o))&&(!porchMode||q.Y>=porch.Y-1e-7||q.Y+q.D<=porch.Y+1e-7||(q.X>=doorLeft-1e-7&&q.X+q.W<=doorRight+1e-7));
   int start=Array.IndexOf(xs,sx)+nx*Array.IndexOf(ys,sy);var queue=new Queue<int>();
   if(Clear(new(sx-h,sy-h,width,width))){seen[start]=true;queue.Enqueue(start);}int end=-1,visited=0;
   var goals=portals.Select(p=>Array.IndexOf(xs,p.x)+nx*Array.IndexOf(ys,p.y)).ToHashSet();
   while(queue.Count>0){int id=queue.Dequeue();visited++;if(goals.Contains(id)){end=id;break;}int ix=id%nx,iy=id/nx;
    foreach(var (dx,dy) in new[]{(1,0),(-1,0),(0,1),(0,-1)}){int x=ix+dx,y=iy+dy;if(x<0||x>=nx||y<0||y>=ny)continue;int next=x+nx*y;if(seen[next])continue;
     var sweep=new Rect(Math.Min(xs[ix],xs[x])-h,Math.Min(ys[iy],ys[y])-h,Math.Abs(xs[x]-xs[ix])+width,Math.Abs(ys[y]-ys[iy])+width);
     if(!Clear(sweep))continue;seen[next]=true;parent[next]=id;queue.Enqueue(next);
    }
   }
   var path=new List<double[]>();for(int p=end;p>=0;p=parent[p])path.Add(new[]{xs[p%nx],ys[p/nx]});path.Reverse();
   results.Add(new{candidate=(int)c["candidate"],mirrored=(bool)c["mirrored"],route_found=end>=0,visited,path,bridge,dining,diningObstacles,porch,door_reservation_ft=porchMode?new[]{doorLeft,doorRight}:null,scope=porchMode?"front interior to porch interior through nominal opening reservation; door clear width/swing unresolved":furniture!=null?"front interior to dining rear edge with table/chair/use proxies; porch unresolved":selected==null?"front interior entry proxy to living/kitchen interface; living and entry unfurnished":"front interior to source dining via explicit residual-gap connector; dining unfurnished"});
  }
  Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(args[1]))!);
  File.WriteAllText(args[1],JsonSerializer.Serialize(new{input_sha256=Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(args[0]))),selected_d_sha256=args.Length>=3?Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(args[2]))):null,dining_furniture_sha256=args.Length>=4?Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(args[3]))):null,dining_transform=rotate?"90-degree whole-set rotation, centred in source dining room":"source orientation and placement",width_ft=width,results,limitations="No exterior threshold, door swing, living furniture, appliance-open or porch route; no code/compliance result."},new JsonSerializerOptions{WriteIndented=true}));
  Console.WriteLine($"Tested {results.Count} continuous route cases; inspect route_found values in report");
 }
}
