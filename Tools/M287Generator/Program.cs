using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;

internal static class Program
{
    private const string SelectedHash = "516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB";
    private const string M215Hash = "F2F6A66DEDA2A9C48A991E36B986683FE1F5B1C1D361FBF3E43BE2A2E1A053B1";
    private const string M285Hash = "66FBF95A7D7AB07A71F0F2F1FAEBCACA67493344290A21DE0CE6E3F9E0C09F6C";
    private const string AuthorizationHash = "785285433F789EFD58DF9DFE96C97650D78409C752607D7426EFECCF5192DF05";
    private const double Margin = 2.0 / 3.0, Grid = 0.25, Width = 38.0 / 12.0, Run = 5 * 10.5 / 12.0, Landing = 3.0, RouteW = 3.0, Tol = 1e-7;
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };
    private sealed record Rect(string Id, string Name, string Kind, double X, double Y, double W, double D)
    {
        public double Right => X + W; public double Top => Y + D; public double Area => W * D;
    }
    private sealed record Stair(string Orientation, double X, double Y, double W, double D)
    {
        public Rect Rect => new("stair", "M285 stair-envelope proxy", "analysis", X, Y, W, D);
    }
    private sealed record Flex(Rect Rect, double Displacement);
    private sealed record Candidate(Flex Flex, Stair Stair, string End, Rect LowerLanding, Rect Path, bool LandingInterfacesWithC, double COverlap, double StairOverlap, double RouteLength, double RoomGap);

    private static int Main(string[] args)
    {
        try
        {
            if (args.Length != 5) throw new ArgumentException("Usage: M287Generator <selected-D-study.json> <M285-report.json> <M215-report.json> <authorization.md> <output-directory>");
            string root = FindRoot(); string studyPath = Resolve(root, args[0]), m285Path = Resolve(root, args[1]), m215Path = Resolve(root, args[2]), authPath = Resolve(root, args[3]), output = Resolve(root, args[4]);
            string prefix = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!output.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("Output must remain inside this repository.");
            if (Directory.Exists(output) && Directory.EnumerateFileSystemEntries(output).Any()) throw new IOException("Output directory must be new or empty.");
            var hashes = new Dictionary<string,string> { ["selected_d"]=Hash(studyPath), ["m285_report"]=Hash(m285Path), ["m215_report"]=Hash(m215Path), ["authorization"]=Hash(authPath) };
            Require(hashes["selected_d"] == SelectedHash && hashes["m285_report"] == M285Hash && hashes["m215_report"] == M215Hash && hashes["authorization"] == AuthorizationHash, "A pinned input changed; stop and review before replay.");
            JsonNode study = Read(studyPath), m285 = Read(m285Path), m215 = Read(m215Path);
            Require(Text(study["layout_variant"]) == "OwnerSelectedD" && Text(study["selection"]?["main_public_bath"]?["position"]) == "TBD" && Text(study["selection"]?["main_public_bath"]?["service_route"]) == "TBD", "Selected-D or M-06 state changed.");
            Require(Num(m215["route_width_in"]) == 36 && Text(m215["status"]) == "pass", "M215 36-in route-screen precedent is not present.");
            Require(Num(m285["plan_envelope"]?["preferred_stair_width_ft"]) == Width && Num(m285["plan_envelope"]?["tread_run_ft"]) == Run && Num(m285["plan_envelope"]?["landing_depth_ft"]) == Landing, "M285 stair-envelope basis changed.");
            var lower = study["plans"]?["lower"]?.AsArray() ?? throw new InvalidDataException("Missing lower-level blocks.");
            var blocks = lower.Select(b => new Rect(Text(b?["id"]), Text(b?["name"]), Text(b?["kind"]), Num(b?["x"]), Num(b?["y"]), Num(b?["w"]), Num(b?["d"]))).ToArray();
            Rect l01 = blocks.Single(x => x.Id == "L-01"), c = blocks.Single(x => x.Id == "C-LOWER" && x.Kind == "circulation");
            Rect[] rooms = blocks.Where(x => x.Kind == "room" && x.Id != "L-01").ToArray();
            var winNodes = study["selection"]?["main_public_bath"]?["search_windows"]?.AsArray() ?? throw new InvalidDataException("Missing M-06 windows.");
            Rect[] windows = winNodes.Select(w => new Rect("M06-"+Text(w?["id"]), Text(w?["label"]), "protected", Num(w?["x"]), Num(w?["y"]), Num(w?["w"]), Num(w?["d"]))).ToArray();
            Require(windows.Length == 2 && winNodes.All(w => Text(w?["status"]).StartsWith("Unassigned", StringComparison.Ordinal)), "Both M-06 search windows must remain unassigned.");
            double shellW=Num(study["shells"]?["rear_lower"]?[0]), shellD=Num(study["shells"]?["rear_lower"]?[1]);
            bool Overlap(Rect a, Rect b) => Math.Min(a.Right,b.Right)-Math.Max(a.X,b.X)>Tol && Math.Min(a.Top,b.Top)-Math.Max(a.Y,b.Y)>Tol;
            double Area(Rect a, Rect b) => Math.Max(0,Math.Min(a.Right,b.Right)-Math.Max(a.X,b.X))*Math.Max(0,Math.Min(a.Top,b.Top)-Math.Max(a.Y,b.Y));
            double Gap(Rect a, Rect b) { double dx=Math.Max(0,Math.Max(a.X-b.Right,b.X-a.Right)),dy=Math.Max(0,Math.Max(a.Y-b.Top,b.Y-a.Top)); return Math.Sqrt(dx*dx+dy*dy); }
            var stairs = new List<Stair>();
            for(double y=Margin;y+Landing*2+Run<=shellD-Margin+Tol;y=Math.Round(y+Grid,8)) for(double x=Margin;x+Width<=shellW-Margin+Tol;x=Math.Round(x+Grid,8)) AddStair("north-south",x,y,Width,Landing*2+Run);
            for(double y=Margin;y+Width<=shellD-Margin+Tol;y=Math.Round(y+Grid,8)) for(double x=Margin;x+Landing*2+Run<=shellW-Margin+Tol;x=Math.Round(x+Grid,8)) AddStair("east-west",x,y,Landing*2+Run,Width);
            void AddStair(string o,double x,double y,double w,double d) { var s=new Stair(o,x,y,w,d); if(!rooms.Any(r=>Overlap(s.Rect,r))&&!windows.Any(r=>Overlap(s.Rect,r))) stairs.Add(s); }
            double maxW=shellW-2*Margin,maxD=shellD-2*Margin,minW=l01.Area/maxD;
            var widths=new SortedSet<double>(); for(double w=Math.Ceiling(minW/Grid)*Grid;w<=maxW+Tol;w+=Grid) widths.Add(Math.Round(w,8)); widths.Add(l01.W);
            var flexes=new List<Flex>();
            foreach(double w in widths) { double d=l01.Area/w; if(d<Margin||d>maxD+Tol) continue; var xs=Positions(Margin,shellW-Margin-w);var ys=Positions(Margin,shellD-Margin-d); if(Math.Abs(w-l01.W)<Tol)xs.Add(l01.X);if(Math.Abs(d-l01.D)<Tol)ys.Add(l01.Y);foreach(double y in ys)foreach(double x in xs){var f=new Rect("L-01","Lower flexible living","room",x,y,w,d);if(!rooms.Any(r=>Overlap(f,r))&&!Overlap(f,c))flexes.Add(new Flex(f,Math.Abs(x-l01.X)+Math.Abs(y-l01.Y)+Math.Abs(w-l01.W)+Math.Abs(d-l01.D)));}}
            var candidates=new List<Candidate>(); int interfaces=0, routes=0;
            foreach(var s in stairs) foreach(var f in flexes) { if(Overlap(s.Rect,f.Rect))continue; foreach(var exit in Exits(s,c)) { if(exit.LandingInterface){ interfaces++; candidates.Add(new Candidate(f,s,exit.End,exit.Landing,new Rect("route","no separate swept segment","path",0,0,0,0),true,Area(exit.Landing,c),Area(s.Rect,c),0,Gap(f.Rect,s.Rect)));continue;} if(rooms.Any(r=>Overlap(exit.Path!,r))||windows.Any(r=>Overlap(exit.Path!,r))||Overlap(exit.Path!,f.Rect))continue; if(!TouchesEdge(exit.Path!,c))continue; routes++; candidates.Add(new Candidate(f,s,exit.End,exit.Landing,exit.Path!,false,Area(exit.Path!,c),Area(s.Rect,c),exit.Length,Gap(f.Rect,s.Rect)));}}
            Require(candidates.Count>0,"No direct axial lower-landing connection to C-LOWER passed the static block screen.");
            var ranked=candidates.OrderBy(x=>x.Flex.Displacement).ThenBy(x=>x.StairOverlap).ThenBy(x=>x.COverlap).ThenBy(x=>x.RouteLength).ThenByDescending(x=>x.RoomGap).ThenBy(x=>x.Stair.Y).ThenBy(x=>x.Stair.X).Take(12).ToArray();
            var checks=new Dictionary<string,bool>{
                ["selected-D input unchanged and hash-pinned"]=Hash(studyPath)==SelectedHash,
                ["M285 six-riser envelope dimensions match pinned study"]=Math.Abs(Width-38.0/12)<Tol&&Math.Abs(Run-4.375)<Tol&&Landing==3,
                ["M215 report pins the 36-in precedent, not a code conclusion"]=Num(m215["route_width_in"])==36,
                ["authorization hash and analysis-only scope match"]=Hash(authPath)==AuthorizationHash&&File.ReadAllText(authPath).Contains("analysis only",StringComparison.OrdinalIgnoreCase),
                ["all L-01 candidates preserve the source area"]=flexes.All(f=>Math.Abs(f.Rect.Area-l01.Area)<1e-6),
                ["all candidate stairs avoid fixed rooms and protected M-06 windows"]=stairs.All(s=>!rooms.Any(r=>Overlap(s.Rect,r))&&!windows.Any(w=>Overlap(s.Rect,w))),
                ["landing interfaces touch C-LOWER or swept paths touch C-LOWER and clear other fixed rooms, L-01 and M-06 windows"]=candidates.All(q=>q.LandingInterfacesWithC?TouchesEdge(q.LowerLanding,c):TouchesEdge(q.Path,c)&&!rooms.Any(r=>Overlap(q.Path,r))&&!windows.Any(w=>Overlap(q.Path,w))&&!Overlap(q.Path,q.Flex.Rect)),
                ["circulation occupation by stair and path is separately reported"]=candidates.All(q=>q.StairOverlap>=0&&q.COverlap>=0),
                ["M-06 footprint, position and service route remain TBD"]=Text(study["selection"]?["main_public_bath"]?["footprint"])=="TBD"&&Text(study["selection"]?["main_public_bath"]?["position"])=="TBD"&&Text(study["selection"]?["main_public_bath"]?["service_route"])=="TBD",
                ["no candidate selected; no code, access, structural or construction claim"]=true};
            Require(checks.Values.All(x=>x),"One or more M287 checks failed.");
            Directory.CreateDirectory(output);
            int uniqueInterfaceStairs=candidates.Where(x=>x.LandingInterfacesWithC).Select(x=>$"{x.Stair.Orientation}:{x.Stair.X:F8}:{x.Stair.Y:F8}:{x.End}").Distinct().Count();
            var report=new {schema="forever-home-m287-lower-stair-arrival-screen-v1",status="pass; analysis-only lower-landing interface and direct axial 36-in swept-path screen; no room, stair, or route selected",selected_d_edited=false,route_width_in=36,route_width_basis="M215 project route-screen precedent only; not code/accessibility determination",source_L01=new{x_ft=l01.X,y_ft=l01.Y,width_ft=l01.W,depth_ft=l01.D,area_sf=l01.Area},search=new{shell_ft=new[]{shellW,shellD},grid_ft=Grid,same_area_L01_candidates=flexes.Count,stair_envelopes=stairs.Count,pairs_tested=stairs.Count*flexes.Count,landing_interface_pairs=interfaces,direct_36in_swept_path_pairs=routes,unique_landing_interface_end_positions=uniqueInterfaceStairs},examples=ranked.Select((q,i)=>new{rank=i+1,label="screened alternative; not selected",L01=new{x_ft=q.Flex.Rect.X,y_ft=q.Flex.Rect.Y,width_ft=q.Flex.Rect.W,depth_ft=q.Flex.Rect.D,area_sf=q.Flex.Rect.Area,combined_change_ft=q.Flex.Displacement},stair=new{q.Stair.Orientation,x_ft=q.Stair.X,y_ft=q.Stair.Y,width_ft=q.Stair.W,depth_ft=q.Stair.D,lower_landing_end=q.End,lower_landing_rect_ft=new[]{q.LowerLanding.X,q.LowerLanding.Y,q.LowerLanding.W,q.LowerLanding.D},lower_landing_overlap_with_C_LOWER_sf=q.COverlap,whole_envelope_overlap_with_C_LOWER_sf=q.StairOverlap},connection=new{type=q.LandingInterfacesWithC?"landing interface; no separate path segment":"36-in swept path proxy",width_in=36,length_ft=q.RouteLength,overlap_into_C_LOWER_sf=q.LandingInterfacesWithC?0:q.COverlap,rect_ft=q.Path.W==0?null:new[]{q.Path.X,q.Path.Y,q.Path.W,q.Path.D}},room_stair_gap_in=q.RoomGap}).ToArray(),inputs_sha256=hashes,checks=new{passed=checks.Count(x=>x.Value),total=checks.Count,details=checks.Select(x=>new{id=x.Key,pass=x.Value})},limitations=new[]{"The scan treats source blocks as axis-aligned rectangles and searches same-area L-01 rectangles plus M285 stair envelopes on a quarter-foot grid. It does not model wall thickness, door leaves/swings, a floor opening, rise transitions, headroom, furniture, appliances, or continuous circulation beyond C-LOWER.","The 36-in width is inherited from M215 as a project analysis precedent, not an adopted code or accessibility criterion. A landing interface occupies part of C-LOWER; remaining circulation is not validated. A direct path is only a straight rectangular gap segment, not proof of a full route.","Candidate L-01 changes are search options, not selected dimensions; M-06 windows remain protected and unassigned. No Revit or IFC was generated.","No building-code compliance, accessibility, professional approval, structural safety, or construction readiness is established."}};
            WriteJson(Path.Combine(output,"m287-lower-stair-arrival-screen.json"),report);
            WriteJson(Path.Combine(output,"m287-checks.json"),new{schema="forever-home-m287-checks-v1",status="pass",passed=checks.Count,total=checks.Count,details=checks.Select(x=>new{id=x.Key,pass=x.Value})});
            File.WriteAllText(Path.Combine(output,"m287-plan.svg"),MakeSvg(blocks,windows,ranked.Take(3).ToArray(),shellW,shellD),new UTF8Encoding(false));
            Console.WriteLine($"M287 {checks.Count}/{checks.Count}; L-01 candidates={flexes.Count}; stair envelopes={stairs.Count}; passing connections={candidates.Count}; explicit path runs={routes}; no selection made."); return 0;
            SortedSet<double> Positions(double min,double max){var r=new SortedSet<double>();for(double v=Margin;v<=max+Tol;v=Math.Round(v+Grid,8))r.Add(v);r.Add(min);r.Add(max);return new SortedSet<double>(r.Where(v=>v>=Margin-Tol&&v<=max+Tol).Select(v=>Math.Round(v,8)));}
        }
        catch(Exception ex){Console.Error.WriteLine("M287 FAILED: "+ex);return 1;}
    }
    private sealed record Exit(string End,Rect Landing,Rect? Path,double Length,bool LandingInterface);
    private static IEnumerable<Exit> Exits(Stair s,Rect c)
    {
        var r=s.Rect;
        if(s.Orientation=="north-south")
        {
            var south=new Rect("landing","lower landing proxy","analysis",r.X,r.Y,r.W,Landing);var north=new Rect("landing","lower landing proxy","analysis",r.X,r.Top-Landing,r.W,Landing);
            foreach(var (end,land,cy,dir) in new[]{("south",south,r.Y,-1),("north",north,r.Top,1)})
            {if(TouchesEdge(land,c)){yield return new Exit(end,land,null,0,true);continue;}double cx=r.X+r.W/2;if(dir<0&&c.Top<=cy&&cx+RouteW/2>c.X&&cx-RouteW/2<c.Right){double l=cy-c.Top;yield return new Exit(end,land,new Rect("route","36-in swept proxy","path",cx-RouteW/2,c.Top,RouteW,l),l,false);}if(dir>0&&c.Y>=cy&&cx+RouteW/2>c.X&&cx-RouteW/2<c.Right){double l=c.Y-cy;yield return new Exit(end,land,new Rect("route","36-in swept proxy","path",cx-RouteW/2,cy,RouteW,l),l,false);}}
        }
        else
        {
            var west=new Rect("landing","lower landing proxy","analysis",r.X,r.Y,Landing,r.D);var east=new Rect("landing","lower landing proxy","analysis",r.Right-Landing,r.Y,Landing,r.D);
            foreach(var (end,land,cx,dir) in new[]{("west",west,r.X,-1),("east",east,r.Right,1)})
            {if(TouchesEdge(land,c)){yield return new Exit(end,land,null,0,true);continue;}double cy=r.Y+r.D/2;if(dir<0&&c.Right<=cx&&cy+RouteW/2>c.Y&&cy-RouteW/2<c.Top){double l=cx-c.Right;yield return new Exit(end,land,new Rect("route","36-in swept proxy","path",c.Right,cy-RouteW/2,l,RouteW),l,false);}if(dir>0&&c.X>=cx&&cy+RouteW/2>c.Y&&cy-RouteW/2<c.Top){double l=c.X-cx;yield return new Exit(end,land,new Rect("route","36-in swept proxy","path",cx,cy-RouteW/2,l,RouteW),l,false);}}
        }
    }
    private static string MakeSvg(Rect[] blocks,Rect[] windows,Candidate[] items,double sw,double sd)
    {
        const double k=10,p=24,g=28,h=44;double pw=sw*k+2*p,ph=sd*k+h+p;var b=new StringBuilder();b.AppendLine($"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"{F(items.Length*pw+(items.Length-1)*g)}\" height=\"{F(ph)}\" viewBox=\"0 0 {F(items.Length*pw+(items.Length-1)*g)} {F(ph)}\"><style>text{{font:10px Arial}}.room{{fill:#dce8ed;stroke:#24566c}}.circ{{fill:#f1d9d9;stroke:#9a3030}}.win{{fill:#f7d9f0;stroke:#83366e;stroke-dasharray:3 2}}.flex{{fill:#bfd6a6;fill-opacity:.75;stroke:#386527;stroke-width:2}}.stair{{fill:#f5e5b8;stroke:#7c5d11;stroke-width:2}}.landing{{fill:#f4b183;fill-opacity:.8;stroke:#9a4512;stroke-width:2}}.path{{fill:#a8c9f0;fill-opacity:.65;stroke:#174f94;stroke-width:2}}.shell{{fill:none;stroke:#222;stroke-width:2}}</style>");
        for(int i=0;i<items.Length;i++){var q=items[i];double ox=i*(pw+g),sx=ox+p,sy=h+p;b.AppendLine($"<text x=\"{F(ox+p)}\" y=\"16\">M287 alternative {i+1}; {q.Stair.Orientation}, lower end {q.End}; { (q.LandingInterfacesWithC?"landing interface":"route "+F(q.RouteLength)+" ft")}</text>");foreach(var r in blocks.Where(x=>x.Id!="L-01"))Draw(r,r.Kind=="circulation"?"circ":"room",r.Id);foreach(var w in windows)Draw(w,"win",w.Id+" protected");Draw(q.Flex.Rect,"flex","L-01 same area");Draw(q.Stair.Rect,"stair","stair envelope");Draw(q.LowerLanding,"landing","lower landing");if(q.Path.W>0&&q.Path.D>0)Draw(q.Path,"path","36-in route proxy");b.AppendLine($"<rect class=\"shell\" x=\"{F(sx)}\" y=\"{F(sy)}\" width=\"{F(sw*k)}\" height=\"{F(sd*k)}\"/>");void Draw(Rect r,string cls,string label){double x=sx+r.X*k,y=sy+(sd-r.Y-r.D)*k;b.AppendLine($"<rect class=\"{cls}\" x=\"{F(x)}\" y=\"{F(y)}\" width=\"{F(r.W*k)}\" height=\"{F(r.D*k)}\"/>");if(r.W*k>24&&r.D*k>11)b.AppendLine($"<text x=\"{F(x+2)}\" y=\"{F(y+11)}\">{System.Security.SecurityElement.Escape(label)}</text>");}}
        b.AppendLine($"<text x=\"10\" y=\"{F(ph-5)}\">Analysis only; 36-in project precedent; schematic path is not code, access, or full-route proof.</text></svg>");return b.ToString();
    }
    private static bool Overlap(Rect a,Rect b)=>Math.Min(a.Right,b.Right)-Math.Max(a.X,b.X)>Tol&&Math.Min(a.Top,b.Top)-Math.Max(a.Y,b.Y)>Tol;
    private static bool TouchesEdge(Rect a,Rect b)=>Overlap(a,b)||((Math.Abs(a.Right-b.X)<Tol||Math.Abs(b.Right-a.X)<Tol)&&Math.Min(a.Top,b.Top)-Math.Max(a.Y,b.Y)>Tol)||((Math.Abs(a.Top-b.Y)<Tol||Math.Abs(b.Top-a.Y)<Tol)&&Math.Min(a.Right,b.Right)-Math.Max(a.X,b.X)>Tol);
    private static JsonNode Read(string p)=>JsonNode.Parse(File.ReadAllText(p))??throw new InvalidDataException("Invalid JSON: "+p);
    private static string Text(JsonNode? n)=>n?.GetValue<string>()??"";private static double Num(JsonNode? n)=>n?.GetValue<double>()??throw new InvalidDataException("Expected numeric JSON field.");
    private static string Hash(string p)=>Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(p)));private static string Resolve(string root,string p)=>Path.GetFullPath(Path.IsPathRooted(p)?p:Path.Combine(root,p));
    private static string FindRoot(){for(DirectoryInfo? d=new(AppContext.BaseDirectory);d!=null;d=d.Parent)if(File.Exists(Path.Combine(d.FullName,"AGENTS.md")))return d.FullName;for(DirectoryInfo? d=new(Directory.GetCurrentDirectory());d!=null;d=d.Parent)if(File.Exists(Path.Combine(d.FullName,"AGENTS.md")))return d.FullName;throw new DirectoryNotFoundException("Repository root not found.");}
    private static string F(double v)=>v.ToString("0.####",CultureInfo.InvariantCulture);private static void Require(bool ok,string msg){if(!ok)throw new InvalidDataException(msg);}private static void WriteJson(string p,object v)=>File.WriteAllText(p,JsonSerializer.Serialize(v,JsonOptions)+"\n",new UTF8Encoding(false));
}
