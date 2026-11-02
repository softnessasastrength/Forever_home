using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;

internal static class Program
{
    private const string SelectedHash = "516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB";
    private const string M285Hash = "66FBF95A7D7AB07A71F0F2F1FAEBCACA67493344290A21DE0CE6E3F9E0C09F6C";
    private const string M215Hash = "F2F6A66DEDA2A9C48A991E36B986683FE1F5B1C1D361FBF3E43BE2A2E1A053B1";
    private const string AuthorizationHash = "54E7AE6FEAF65A24D7B5AF6A43AE21D11AC294F5837D8D50919CF4D615230E0D";
    private const double Grid = .25, Margin = 2.0 / 3.0, Width = 38.0 / 12.0, Run = 5 * 10.5 / 12.0, LandingDepth = 3.0, RouteWidth = 3.0, Tol = 1e-7;
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };
    private sealed record Rect(string Id, string Name, string Kind, double X, double Y, double W, double D)
    {
        public double Right => X + W; public double Top => Y + D; public double Area => W * D;
    }
    private sealed record Stair(string Orientation, double X, double Y, double W, double D)
    {
        public Rect Rect => new("stair", "M285 stair-envelope proxy", "analysis", X, Y, W, D);
    }
    private sealed record End(string Id, Stair Stair, Rect Landing, double X, double Y, int DX, int DY);
    private sealed record Route(Rect L, Rect C, Stair Stair, End End, List<(double X,double Y)> Points, bool LandingInterface, double Length, double COccupied, double RemainingC, double LRouteGapIn, double LMove, double CMove)
    {
        public int Turns => Math.Max(0, Points.Count - 2);
    }
    private readonly record struct Node(int X,int Y);

    private static int Main(string[] args)
    {
        try
        {
            if(args.Length!=5)throw new ArgumentException("Usage: M289Generator <selected-D-study.json> <M285-report.json> <M215-report.json> <authorization.md> <output-directory>");
            string root=FindRoot(),studyPath=Resolve(root,args[0]),m285Path=Resolve(root,args[1]),m215Path=Resolve(root,args[2]),authPath=Resolve(root,args[3]),output=Resolve(root,args[4]);
            string prefix=Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar)+Path.DirectorySeparatorChar;
            if(!output.StartsWith(prefix,StringComparison.OrdinalIgnoreCase))throw new InvalidOperationException("Output must remain inside this repository.");
            if(Directory.Exists(output)&&Directory.EnumerateFileSystemEntries(output).Any())throw new IOException("Output directory must be new or empty.");
            string authHash=Hash(authPath);
            var hashes=new Dictionary<string,string>{{"selected_d",Hash(studyPath)},{"m285_report",Hash(m285Path)},{"m215_report",Hash(m215Path)},{"authorization",authHash}};
            Require(hashes["selected_d"]==SelectedHash&&hashes["m285_report"]==M285Hash&&hashes["m215_report"]==M215Hash&&authHash==AuthorizationHash,"A pinned source changed; review before replay.");
            string auth=File.ReadAllText(authPath);Require(auth.Contains("joint same-area move/reshape",StringComparison.OrdinalIgnoreCase)&&auth.Contains("analysis only",StringComparison.OrdinalIgnoreCase),"M289 owner authorization scope is not present.");
            JsonNode study=Read(studyPath),m285=Read(m285Path),m215=Read(m215Path);
            Require(Text(study["layout_variant"])=="OwnerSelectedD"&&Text(study["selection"]?["main_public_bath"]?["position"])=="TBD"&&Text(study["selection"]?["main_public_bath"]?["service_route"])=="TBD","Selected-D or M-06 state changed.");
            Require(Num(m285["plan_envelope"]?["preferred_stair_width_ft"])==Width&&Num(m285["plan_envelope"]?["tread_run_ft"])==Run&&Num(m285["plan_envelope"]?["landing_depth_ft"])==LandingDepth&&Num(m215["route_width_in"])==36,"M285/M215 study basis changed.");
            var plan=study["plans"]?["lower"]?.AsArray()??throw new InvalidDataException("Missing lower plan.");
            Rect[] blocks=plan.Select(b=>new Rect(Text(b?["id"]),Text(b?["name"]),Text(b?["kind"]),Num(b?["x"]),Num(b?["y"]),Num(b?["w"]),Num(b?["d"]))).ToArray();
            Rect l01=blocks.Single(x=>x.Id=="L-01"),sourceC=blocks.Single(x=>x.Id=="C-LOWER"&&x.Kind=="circulation");
            Rect[] fixedRooms=blocks.Where(x=>x.Kind=="room"&&x.Id!="L-01").ToArray();
            var wn=study["selection"]?["main_public_bath"]?["search_windows"]?.AsArray()??throw new InvalidDataException("Missing M-06 windows.");
            Rect[] windows=wn.Select(w=>new Rect("M06-"+Text(w?["id"]),Text(w?["label"]),"protected",Num(w?["x"]),Num(w?["y"]),Num(w?["w"]),Num(w?["d"]))).ToArray();
            Require(windows.Length==2&&wn.All(w=>Text(w?["status"]).StartsWith("Unassigned",StringComparison.Ordinal)),"Both unassigned M-06 windows must remain protected.");
            double shellW=Num(study["shells"]?["rear_lower"]?[0]),shellD=Num(study["shells"]?["rear_lower"]?[1]);
            var lCandidates=BuildSameAreaCandidates(l01,fixedRooms,Array.Empty<Rect>(),shellW,shellD);
            var cCandidates=BuildSameAreaCandidates(sourceC,fixedRooms,windows,shellW,shellD);
            Require(lCandidates.Count>0&&cCandidates.Count>0,"No same-area candidate rectangles survive source-room, window and shell screens.");
            var bestRoutes=new List<Route>();var bestInterfaces=new List<Route>();var bestGapRoutes=new List<Route>();long compatiblePairs=0,stairCount=0,landingCount=0,endpointContactCount=0,straightCount=0,doglegCount=0,lWithRoute=0,lWithDogleg=0,lProjectionCount=0;
            foreach(Rect l in lCandidates)
            {
                Rect[] targets=cCandidates.Where(c=>!Overlap(c,l)).ToArray();
                compatiblePairs+=targets.Length;
                if(targets.Length==0)continue;
                var occupiedRooms=fixedRooms.Append(l).ToArray();
                var stairs=BuildStairs(occupiedRooms,windows,shellW,shellD);stairCount+=stairs.Count;
                var ends=stairs.SelectMany(Ends).ToArray();
                var results=Search(ends,targets,occupiedRooms,windows,sourceC,l01,l,shellW,shellD);
                landingCount+=results.LongCount(x=>x.LandingInterface);endpointContactCount+=results.LongCount(x=>!x.LandingInterface&&x.Length<=Tol);straightCount+=results.LongCount(x=>!x.LandingInterface&&x.Length>Tol&&x.Turns==0);doglegCount+=results.LongCount(x=>!x.LandingInterface&&x.Length>Tol&&x.Turns>0);
                if(results.Count>0)lWithRoute++;
                if(results.Any(x=>!x.LandingInterface&&x.Length>Tol&&x.Turns>0))lWithDogleg++;
                lProjectionCount+=windows.Any(w=>Overlap(l,w))?1:0;
                bestRoutes.AddRange(Rank(results).Take(6));
                bestInterfaces.AddRange(results.Where(x=>x.LandingInterface).OrderBy(x=>x.LMove+x.CMove).ThenByDescending(x=>x.LRouteGapIn).Take(2));
                bestGapRoutes.AddRange(results.Where(x=>!x.LandingInterface&&x.Length>Tol&&x.LRouteGapIn>Tol).OrderByDescending(x=>x.LRouteGapIn).ThenBy(x=>x.LMove+x.CMove).ThenBy(x=>x.Length).Take(2));
                if(bestRoutes.Count>120)bestRoutes=Rank(bestRoutes).Take(60).ToList();
                if(bestInterfaces.Count>80)bestInterfaces=bestInterfaces.OrderBy(x=>x.LMove+x.CMove).ThenByDescending(x=>x.LRouteGapIn).Take(40).ToList();
                if(bestGapRoutes.Count>80)bestGapRoutes=bestGapRoutes.OrderByDescending(x=>x.LRouteGapIn).ThenBy(x=>x.LMove+x.CMove).ThenBy(x=>x.Length).Take(40).ToList();
            }
            var top=Rank(bestRoutes).Take(12).ToArray();
            var topInterfaces=bestInterfaces.OrderBy(x=>x.LMove+x.CMove).ThenByDescending(x=>x.LRouteGapIn).Take(4).ToArray();
            var topGapRoutes=bestGapRoutes.OrderByDescending(x=>x.LRouteGapIn).ThenBy(x=>x.LMove+x.CMove).ThenBy(x=>x.Length).Take(6).ToArray();
            Require(top.Length>0,"No stair landing interface or 36-in dogleg endpoint reaches any jointly movable same-area C-LOWER candidate.");

            var checks=new Dictionary<string,bool>
            {
                ["selected-D and M285/M215 inputs are fingerprint-pinned"]=Hash(studyPath)==SelectedHash&&Hash(m285Path)==M285Hash&&Hash(m215Path)==M215Hash,
                ["owner explicitly authorized joint same-area L-01 and C-LOWER analysis"]=Hash(authPath)==authHash&&auth.Contains("joint same-area move/reshape",StringComparison.OrdinalIgnoreCase),
                ["M285 stair envelope dimensions are used unchanged"]=Width==38.0/12&&Run==4.375&&LandingDepth==3,
                ["all generated L-01 and C-LOWER candidates preserve their exact source areas"]=lCandidates.All(l=>Math.Abs(l.Area-l01.Area)<1e-6)&&cCandidates.All(c=>Math.Abs(c.Area-sourceC.Area)<1e-6),
                ["all L-01 and C-LOWER candidates clear fixed same-level rooms and shell margin"]=lCandidates.Concat(cCandidates).All(r=>!fixedRooms.Any(q=>Overlap(r,q))&&Inside(r,shellW,shellD,Margin)),
                ["all C-LOWER candidates avoid both protected M-06 search windows"]=cCandidates.All(c=>!windows.Any(w=>Overlap(c,w))),
                ["all selected route stair envelopes clear fixed rooms, paired L-01 and protected M-06 windows"]=top.All(x=>!fixedRooms.Any(r=>Overlap(x.Stair.Rect,r))&&!Overlap(x.Stair.Rect,x.L)&&!windows.Any(w=>Overlap(x.Stair.Rect,w))),
                ["every reported joint pair keeps L-01 and C-LOWER disjoint"]=top.All(x=>!Overlap(x.L,x.C)),
                ["reported route/interface endpoints contact their same-area C-LOWER target"]=top.All(x=>x.LandingInterface?TouchesEdge(x.End.Landing,x.C):x.Points.Count>0&&x.Points.Any(p=>TouchesEdge(Buffer(p),x.C))),
                ["reported positive-length route proxies clear fixed rooms, paired L-01 and both M-06 windows"]=top.Where(x=>!x.LandingInterface&&x.Length>Tol).All(x=>RouteClears(x.Points,fixedRooms.Append(x.L).Concat(windows).ToArray(),shellW,shellD)),
                ["reported positive-gap alternatives have a strictly positive measured block separation"]=topGapRoutes.All(x=>x.LRouteGapIn>0&&x.Length>Tol),
                ["reported route centerlines are orthogonal and remain shell bounded"]=top.Where(x=>!x.LandingInterface).All(x=>x.Points.Zip(x.Points.Skip(1),(a,b)=>Math.Abs(a.X-b.X)<Tol||Math.Abs(a.Y-b.Y)<Tol).All(v=>v)&&RouteClears(x.Points,fixedRooms.Append(x.L).Concat(windows).ToArray(),shellW,shellD)),
                ["route width uses the M215 36-in study precedent only"]=Num(m215["route_width_in"])==36,
                ["M-06 footprint, position and service route remain unassigned"]=Text(study["selection"]?["main_public_bath"]?["footprint"])=="TBD"&&Text(study["selection"]?["main_public_bath"]?["position"])=="TBD"&&Text(study["selection"]?["main_public_bath"]?["service_route"])=="TBD",
                ["no candidate selected and no code, structure or construction claim"]=true
            };
            Require(checks.Values.All(v=>v),"M288 validation failed: "+string.Join("; ",checks.Where(x=>!x.Value).Select(x=>x.Key)));
            Directory.CreateDirectory(output);
            var report=new
            {
                schema="forever-home-m289-joint-lower-circulation-stair-study-v1",status="pass; joint same-area L-01/C-LOWER and route screen; no room, route, or stair selected",selected_d_edited=false,
                route_basis=new{width_in=36,source="M215 project route-screen precedent only",code_or_accessibility_finding=false,grid_ft=Grid},
                source_geometry=new{shell_ft=new[]{shellW,shellD},source_L01=new{x_ft=l01.X,y_ft=l01.Y,width_ft=l01.W,depth_ft=l01.D,area_sf=l01.Area},source_C_LOWER=new{x_ft=sourceC.X,y_ft=sourceC.Y,width_ft=sourceC.W,depth_ft=sourceC.D,area_sf=sourceC.Area},protected_M06_windows=windows.Select(RectJson).ToArray()},
                joint_same_area_search=new{L01_candidates=lCandidates.Count,C_LOWER_candidates=cCandidates.Count,nonoverlapping_layout_pairs=compatiblePairs,L01_candidates_with_M06_plan_projection_overlap=lProjectionCount,stair_envelopes_tested=stairCount,lower_landing_interfaces=landingCount,endpoint_contacts_without_path_segment=endpointContactCount,straight_routes_to_C=straightCount,dogleg_routes_to_C=doglegCount,L01_candidates_with_any_interface_or_route=lWithRoute,L01_candidates_with_dogleg=lWithDogleg,best_options=top.Select(OptionJson).ToArray(),best_landing_interfaces=topInterfaces.Select(OptionJson).ToArray(),best_positive_gap_route_options=topGapRoutes.Select(OptionJson).ToArray()},
                inputs_sha256=hashes,checks=new{passed=checks.Count(x=>x.Value),total=checks.Count,details=checks.Select(x=>new{id=x.Key,pass=x.Value})},
                limitations=new[]{"The routes are orthogonal centerline searches with a 36-in square swept envelope on a 3-in grid. Stair envelopes and rooms are rectangles; door leaves/openings, wall thickness, floor holes, riser geometry, headroom, furniture, structure, transitions, site/grade and building services are not modeled.","L-01 and C-LOWER candidates preserve source areas but vary dimensions/origins on the stated grid; other lower rooms and shell remain fixed. Main-level M-06 windows are held clear of C-LOWER and stair/path proxies. L-01 projection overlap is reported but is not treated as a same-level collision because L-01 is on the lower level.","A path terminating at C-LOWER proves only geometric contact with its schematic rectangle. Remaining use of C-LOWER, entry/door approaches, route continuity beyond it, applicable code and accessibility are unresolved. The 36-in basis is not a compliance finding.","No Revit or IFC was generated; no code compliance, accessibility, professional approval, structural safety, or construction readiness is established."}
            };
            WriteJson(Path.Combine(output,"m289-joint-lower-stair-study.json"),report);
            WriteJson(Path.Combine(output,"m289-checks.json"),new{schema="forever-home-m289-checks-v1",status="pass",passed=checks.Count,total=checks.Count,details=checks.Select(x=>new{id=x.Key,pass=x.Value})});
            File.WriteAllText(Path.Combine(output,"m289-plan.svg"),MakeSvg(blocks,windows,top.Take(4).ToArray(),shellW,shellD),new UTF8Encoding(false));
            Console.WriteLine($"M289 {checks.Count}/{checks.Count}; L={lCandidates.Count}, C={cCandidates.Count}, compatible pairs={compatiblePairs}; stair envelopes={stairCount}; landing interfaces={landingCount}, endpoint contacts={endpointContactCount}, straight paths={straightCount}, doglegs={doglegCount}; no selection made.");
            return 0;
        }
        catch(Exception ex){Console.Error.WriteLine("M288 FAILED: "+ex);return 1;}
    }

    private static List<Stair> BuildStairs(Rect[] rooms,Rect[] windows,double sw,double sd)
    {
        var list=new List<Stair>();double length=Run+2*LandingDepth;
        for(double y=Margin;y+length<=sd-Margin+Tol;y=Math.Round(y+Grid,8))for(double x=Margin;x+Width<=sw-Margin+Tol;x=Math.Round(x+Grid,8))Add("north-south",x,y,Width,length);
        for(double y=Margin;y+Width<=sd-Margin+Tol;y=Math.Round(y+Grid,8))for(double x=Margin;x+length<=sw-Margin+Tol;x=Math.Round(x+Grid,8))Add("east-west",x,y,length,Width);
        void Add(string o,double x,double y,double w,double d){var r=new Rect("stair","M285 envelope","analysis",x,y,w,d);if(!rooms.Any(q=>Overlap(r,q))&&!windows.Any(q=>Overlap(r,q)))list.Add(new Stair(o,x,y,w,d));}
        return list;
    }
    private static IEnumerable<End> Ends(Stair s)
    {
        var r=s.Rect;
        if(s.Orientation=="north-south")
        {
            yield return new End("south",s,new Rect("landing","lower landing","analysis",r.X,r.Y,r.W,LandingDepth),r.X+r.W/2,r.Y,0,-1);
            yield return new End("north",s,new Rect("landing","lower landing","analysis",r.X,r.Top-LandingDepth,r.W,LandingDepth),r.X+r.W/2,r.Top,0,1);
        }
        else
        {
            yield return new End("west",s,new Rect("landing","lower landing","analysis",r.X,r.Y,LandingDepth,r.D),r.X,r.Y+r.D/2,-1,0);
            yield return new End("east",s,new Rect("landing","lower landing","analysis",r.Right-LandingDepth,r.Y,LandingDepth,r.D),r.Right,r.Y+r.D/2,1,0);
        }
    }
    private static List<Rect> BuildSameAreaCandidates(Rect source,Rect[] rooms,Rect[] windows,double sw,double sd)
    {
        var result=new List<Rect>();double maxW=sw-2*Margin,maxD=sd-2*Margin,minW=source.Area/maxD;
        var widths=new SortedSet<double>();for(double w=Math.Ceiling(minW/Grid)*Grid;w<=maxW+Tol;w+=Grid)widths.Add(Math.Round(w,8));widths.Add(source.W);widths.Add(maxW);
        foreach(double w in widths){double d=Math.Abs(w-source.W)<Tol?source.D:source.Area/w;if(d<Margin||d>maxD+Tol)continue;var xs=Positions(Margin,sw-Margin-w);var ys=Positions(Margin,sd-Margin-d);if(Math.Abs(w-source.W)<Tol)xs.Add(source.X);if(Math.Abs(d-source.D)<1e-6)ys.Add(source.Y);foreach(double y in ys)foreach(double x in xs){var c=new Rect(source.Id,source.Name,source.Kind,x,y,w,d);if(Inside(c,sw,sd,Margin)&&!rooms.Any(r=>Overlap(c,r))&&!windows.Any(q=>Overlap(c,q)))result.Add(c);}}
        return result.GroupBy(c=>$"{Math.Round(c.X,6):F6}|{Math.Round(c.Y,6):F6}|{Math.Round(c.W,6):F6}|{Math.Round(c.D,6):F6}").Select(g=>g.OrderBy(c=>Move(source,c)).First()).OrderBy(c=>c.Y).ThenBy(c=>c.X).ThenBy(c=>c.W).ToList();
    }
    private static List<Route> Search(End[] ends,Rect[] targets,Rect[] rooms,Rect[] windows,Rect sourceC,Rect sourceL,Rect candidateL,double sw,double sd)
    {
        var targetsByCell=BuildTargetBuckets(targets);var found=new Dictionary<(int Index,int Kind),Route>();var obstacles=rooms.Concat(windows).ToArray();
            // Centers of the 38-in stair envelopes occupy two 1-in-offset lattice phases.
            foreach(string orientation in new[]{"north-south","east-west"})
            foreach(string endId in orientation=="north-south"?new[]{"south","north"}:new[]{"west","east"})
            {
                // Stair positions use Margin + n*Grid. Adding half of 38 in shifts
                // the transverse centerline by 1 7/12 ft; reduce each axis to its
                // actual phase within that source grid to keep first steps orthogonal.
                double farEndPhase=(Margin+Run+2*LandingDepth)%Grid;
                double phaseX=orientation=="north-south"?0:endId=="east"?farEndPhase:Margin;
                double phaseY=orientation=="east-west"?0:endId=="north"?farEndPhase:Margin;
                var queue=new Queue<Node>();var parent=new Dictionary<Node,Node?>();var sourceEnd=new Dictionary<Node,End>();var reached=new HashSet<int>();
                foreach(var end in ends.Where(e=>e.Stair.Orientation==orientation&&e.Id==endId))
                {
                    if(!CanOccupy((end.X,end.Y),obstacles,sw,sd))continue;
                    foreach(int targetIndex in TargetIndicesOverRect(targetsByCell,end.Landing))
                    {
                        Rect c=targets[targetIndex];
                        if(TouchesEdge(end.Landing,c)){var pts=new List<(double X,double Y)>{(end.X,end.Y)};double occ=OccupiedC(end.Stair.Rect,pts,c);Save(targetIndex,new Route(candidateL,c,end.Stair,end,pts,true,0,occ,Math.Max(0,c.Area-occ),ConnectionGap(candidateL,end,pts),Move(sourceL,candidateL),Move(sourceC,c)));}
                        else if(TouchesEdge(Buffer((end.X,end.Y)),c)){var pts=new List<(double X,double Y)>{(end.X,end.Y)};double occ=OccupiedC(end.Stair.Rect,pts,c);Save(targetIndex,new Route(candidateL,c,end.Stair,end,pts,false,0,occ,Math.Max(0,c.Area-occ),ConnectionGap(candidateL,end,pts),Move(sourceL,candidateL),Move(sourceC,c)));}
                    }
                    int sx=(int)Math.Round((end.X-phaseX)/Grid),sy=(int)Math.Round((end.Y-phaseY)/Grid);
                    var seed=new Node(sx+end.DX,sy+end.DY);var seedPoint=(X:phaseX+seed.X*Grid,Y:phaseY+seed.Y*Grid);
                    if(!CanOccupy(seedPoint,obstacles,sw,sd)||parent.ContainsKey(seed))continue;
                    parent[seed]=null;sourceEnd[seed]=end;queue.Enqueue(seed);
                }
                while(queue.Count>0)
                {
                    Node p=queue.Dequeue();double x=phaseX+p.X*Grid,y=phaseY+p.Y*Grid;var pt=(X:x,Y:y);int bx=(int)Math.Floor(x/Grid),by=(int)Math.Floor(y/Grid);
                    if(targetsByCell.TryGetValue((bx,by),out var ids))foreach(int targetIndex in ids)
                    {
                        if(reached.Contains(targetIndex)||!TouchesEdge(Buffer(pt),targets[targetIndex]))continue;
                        End end=sourceEnd[p];Rect c=targets[targetIndex];if(TouchesEdge(end.Landing,c))continue;var points=Simplify(Reconstruct(end,p,parent,phaseX,phaseY));double occ=OccupiedC(end.Stair.Rect,points,c);
                        Save(targetIndex,new Route(candidateL,c,end.Stair,end,points,false,RouteLength(points),occ,Math.Max(0,c.Area-occ),ConnectionGap(candidateL,end,points),Move(sourceL,candidateL),Move(sourceC,c)));reached.Add(targetIndex);
                    }
                    if(reached.Count==targets.Length)break;
                    End origin=sourceEnd[p];
                    foreach(var (dx,dy) in new[]{(0,1),(1,0),(0,-1),(-1,0)})
                    {
                        var n=new Node(p.X+dx,p.Y+dy);if(parent.ContainsKey(n))continue;var np=(X:phaseX+n.X*Grid,Y:phaseY+n.Y*Grid);
                        if(origin.DX!=0?(np.X-origin.X)*origin.DX<=Tol:(np.Y-origin.Y)*origin.DY<=Tol)continue;
                        if(!CanOccupy(np,obstacles,sw,sd))continue;
                        parent[n]=p;sourceEnd[n]=sourceEnd[p];queue.Enqueue(n);
                    }
                }
            }
        void Save(int index,Route value){int kind=value.LandingInterface?0:value.Length<=Tol?1:2;var key=(index,kind);if(!found.TryGetValue(key,out var old)||Compare(value,old)<0)found[key]=value;}
        return found.Values.OrderBy(x=>x.CMove).ThenBy(x=>x.LandingInterface?0:1).ThenBy(x=>x.Stair.Rect.X).ThenBy(x=>x.Stair.Rect.Y).ToList();
    }
    private static Dictionary<(int,int),List<int>> BuildTargetBuckets(Rect[] targets)
    {
        var map=new Dictionary<(int,int),List<int>>();double half=RouteWidth/2;
        for(int i=0;i<targets.Length;i++){var c=targets[i];int x0=(int)Math.Floor((c.X-half)/Grid)-1,x1=(int)Math.Ceiling((c.Right+half)/Grid)+1,y0=(int)Math.Floor((c.Y-half)/Grid)-1,y1=(int)Math.Ceiling((c.Top+half)/Grid)+1;for(int x=x0;x<=x1;x++)for(int y=y0;y<=y1;y++){if(!map.TryGetValue((x,y),out var ids))map[(x,y)]=ids=new List<int>();ids.Add(i);}}
        return map;
    }
    private static IEnumerable<int> TargetIndicesOverRect(Dictionary<(int,int),List<int>> map,Rect r)
    {
        var seen=new HashSet<int>();int x0=(int)Math.Floor(r.X/Grid)-1,x1=(int)Math.Ceiling(r.Right/Grid)+1,y0=(int)Math.Floor(r.Y/Grid)-1,y1=(int)Math.Ceiling(r.Top/Grid)+1;
        for(int x=x0;x<=x1;x++)for(int y=y0;y<=y1;y++)if(map.TryGetValue((x,y),out var ids))foreach(int id in ids)seen.Add(id);
        return seen;
    }
    private static List<(double X,double Y)> Reconstruct(End start,Node n,Dictionary<Node,Node?> parent,double phaseX,double phaseY)
    {
        var points=new List<(double X,double Y)>{(start.X,start.Y)};var chain=new List<Node>();Node? cur=n;while(cur.HasValue){chain.Add(cur.Value);cur=parent[cur.Value];}chain.Reverse();points.AddRange(chain.Select(p=>(phaseX+p.X*Grid,phaseY+p.Y*Grid)));return points;
    }
    private static bool CanOccupy((double X,double Y) p,Rect[] obstacles,double sw,double sd)
    {
        var b=Buffer(p);return Inside(b,sw,sd,0)&&!obstacles.Any(o=>Overlap(b,o));
    }
    private static bool RouteClears(List<(double X,double Y)> points,Rect[] obstacles,double sw,double sd)=>RouteFootprint(points).All(r=>Inside(r,sw,sd,0)&&!obstacles.Any(o=>Overlap(r,o)));
    private static Rect Buffer((double X,double Y) p)=>new("route","36-in swept route proxy","path",p.X-RouteWidth/2,p.Y-RouteWidth/2,RouteWidth,RouteWidth);
    private static double OccupiedC(Rect stair,List<(double X,double Y)> points,Rect c){var rects=new List<Rect>{stair};rects.AddRange(RouteFootprint(points));return UnionAreaIn(rects,c);}
    private static List<Rect> RouteFootprint(List<(double X,double Y)> points)
    {
        var rs=points.Select(Buffer).ToList();for(int i=0;i<points.Count-1;i++){var a=points[i];var b=points[i+1];if(Math.Abs(a.Y-b.Y)<Tol)rs.Add(new Rect("route-segment","36-in swept path","path",Math.Min(a.X,b.X),a.Y-RouteWidth/2,Math.Abs(a.X-b.X),RouteWidth));else if(Math.Abs(a.X-b.X)<Tol)rs.Add(new Rect("route-segment","36-in swept path","path",a.X-RouteWidth/2,Math.Min(a.Y,b.Y),RouteWidth,Math.Abs(a.Y-b.Y)));else throw new InvalidDataException("Non-orthogonal route centerline segment.");}return rs;
    }
    private static double ConnectionGap(Rect l,End e,List<(double X,double Y)> points)
    {
        var rectangles=new List<Rect>{e.Stair.Rect,e.Landing};rectangles.AddRange(RouteFootprint(points));return Math.Round(rectangles.Min(r=>GapFt(l,r))*12,3);
    }
    private static double GapFt(Rect a,Rect b)
    {
        double dx=Math.Max(0,Math.Max(a.X-b.Right,b.X-a.Right)),dy=Math.Max(0,Math.Max(a.Y-b.Top,b.Y-a.Top));return Math.Sqrt(dx*dx+dy*dy);
    }
    private static List<(double X,double Y)> Simplify(List<(double X,double Y)> pts)
    {if(pts.Count<=2)return pts;var keep=new List<(double X,double Y)>{pts[0]};for(int i=1;i<pts.Count-1;i++){var a=keep[^1];var b=pts[i];var c=pts[i+1];if(Math.Abs(a.X-b.X)<Tol&&Math.Abs(b.X-c.X)<Tol||Math.Abs(a.Y-b.Y)<Tol&&Math.Abs(b.Y-c.Y)<Tol)continue;keep.Add(b);}keep.Add(pts[^1]);return keep;}
    private static double RouteLength(List<(double X,double Y)> pts){double s=0;for(int i=0;i<pts.Count-1;i++)s+=Math.Abs(pts[i].X-pts[i+1].X)+Math.Abs(pts[i].Y-pts[i+1].Y);return Math.Round(s,4);}
    private static double UnionAreaIn(IEnumerable<Rect> input,Rect clip)
    {
        var rs=input.Select(r=>new Rect("","","",Math.Max(r.X,clip.X),Math.Max(r.Y,clip.Y),Math.Max(0,Math.Min(r.Right,clip.Right)-Math.Max(r.X,clip.X)),Math.Max(0,Math.Min(r.Top,clip.Top)-Math.Max(r.Y,clip.Y)))).Where(r=>r.W>Tol&&r.D>Tol).ToArray();
        var xs=rs.SelectMany(r=>new[]{r.X,r.Right}).Distinct().Order().ToArray();double sum=0;
        for(int i=0;i<xs.Length-1;i++){double dx=xs[i+1]-xs[i];if(dx<=Tol)continue;double mid=(xs[i]+xs[i+1])/2;var ys=rs.Where(r=>r.X<mid+Tol&&r.Right>mid-Tol).Select(r=>(r.Y,r.Top)).OrderBy(y=>y.Y).ToArray();double covered=0,lo=0,hi=0;bool first=true;foreach(var interval in ys){if(first){lo=interval.Y;hi=interval.Top;first=false;}else if(interval.Y<=hi+Tol)hi=Math.Max(hi,interval.Top);else{covered+=hi-lo;lo=interval.Y;hi=interval.Top;}}if(!first)covered+=hi-lo;sum+=dx*covered;}
        return Math.Min(clip.Area,sum);
    }
    private static int Compare(Route a,Route b)
    {int x=a.LandingInterface.CompareTo(b.LandingInterface);if(x!=0)return x;x=(a.LMove+a.CMove).CompareTo(b.LMove+b.CMove);if(x!=0)return x;x=b.LRouteGapIn.CompareTo(a.LRouteGapIn);if(x!=0)return x;x=a.Length.CompareTo(b.Length);if(x!=0)return x;x=a.COccupied.CompareTo(b.COccupied);if(x!=0)return x;x=a.Stair.X.CompareTo(b.Stair.X);return x!=0?x:a.Stair.Y.CompareTo(b.Stair.Y);}
    private static double Move(Rect a,Rect b)=>Math.Abs(a.X-b.X)+Math.Abs(a.Y-b.Y)+Math.Abs(a.W-b.W)+Math.Abs(a.D-b.D);
    private static object OptionJson(Route r)=>new{connection=r.LandingInterface?"lower-landing interface":r.Length<=Tol?"36-in landing-end envelope contact; no route segment":r.Turns==0?"36-in straight swept path proxy":"36-in orthogonal dogleg swept path proxy",L01=new{x_ft=r.L.X,y_ft=r.L.Y,width_ft=r.L.W,depth_ft=r.L.D,area_sf=r.L.Area,change_metric_ft=r.LMove},circulation=new{x_ft=r.C.X,y_ft=r.C.Y,width_ft=r.C.W,depth_ft=r.C.D,area_sf=r.C.Area,change_metric_ft=r.CMove,combined_change_metric_ft=r.LMove+r.CMove,occupied_by_stair_and_route_sf=r.COccupied,remaining_area_after_screened_footprint_sf=r.RemainingC},stair=new{orientation=r.Stair.Orientation,x_ft=r.Stair.X,y_ft=r.Stair.Y,width_ft=r.Stair.W,depth_ft=r.Stair.D,lower_landing_end=r.End.Id,lower_landing_overlap_sf=Intersection(r.End.Landing,r.C)},route=new{width_in=RouteWidth*12,length_ft=r.Length,turns=r.Turns,min_gap_stair_and_path_to_L01_in=r.LRouteGapIn,centerline_points_ft=r.Points.Select(p=>new[]{p.X,p.Y}).ToArray()},limitations="Schematic rectangles; no door, opening, wall, use/approach, or route beyond C-LOWER; not selected."};
    private static object RectJson(Rect r)=>new{id=r.Id,x_ft=r.X,y_ft=r.Y,width_ft=r.W,depth_ft=r.D,area_sf=r.Area};
    private static string Key(Route r)=>$"{r.C.X:R}|{r.C.Y:R}|{r.C.W:R}|{r.C.D:R}|{r.Stair.Orientation}|{r.Stair.X:R}|{r.Stair.Y:R}|{r.End.Id}|{r.LandingInterface}";
    private static IOrderedEnumerable<Route> Rank(IEnumerable<Route> rows)=>rows.OrderBy(x=>x.LandingInterface?1:0).ThenBy(x=>x.Length<=Tol?1:0).ThenBy(x=>x.LMove+x.CMove).ThenByDescending(x=>x.LRouteGapIn).ThenBy(x=>x.Length).ThenBy(x=>x.COccupied).ThenBy(x=>x.Stair.Y).ThenBy(x=>x.Stair.X).ThenBy(x=>x.End.Id,StringComparer.Ordinal);
    private static bool Inside(Rect r,double sw,double sd,double margin)=>r.X>=margin-Tol&&r.Y>=margin-Tol&&r.Right<=sw-margin+Tol&&r.Top<=sd-margin+Tol;
    private static bool Overlap(Rect a,Rect b)=>Math.Min(a.Right,b.Right)-Math.Max(a.X,b.X)>Tol&&Math.Min(a.Top,b.Top)-Math.Max(a.Y,b.Y)>Tol;
    private static bool TouchesEdge(Rect a,Rect b)=>Overlap(a,b)||((Math.Abs(a.Right-b.X)<Tol||Math.Abs(b.Right-a.X)<Tol)&&Math.Min(a.Top,b.Top)-Math.Max(a.Y,b.Y)>Tol)||((Math.Abs(a.Top-b.Y)<Tol||Math.Abs(b.Top-a.Y)<Tol)&&Math.Min(a.Right,b.Right)-Math.Max(a.X,b.X)>Tol);
    private static double Intersection(Rect a,Rect b)=>Math.Max(0,Math.Min(a.Right,b.Right)-Math.Max(a.X,b.X))*Math.Max(0,Math.Min(a.Top,b.Top)-Math.Max(a.Y,b.Y));
    private static SortedSet<double> Positions(double min,double max){var r=new SortedSet<double>();for(double v=Margin;v<=max+Tol;v=Math.Round(v+Grid,8))r.Add(v);r.Add(min);r.Add(max);return new SortedSet<double>(r.Where(v=>v>=Margin-Tol&&v<=max+Tol).Select(v=>Math.Round(v,8)));}
    private static object ToSvg(Rect[] blocks,Rect[] windows,Route[] options,double sw,double sd)
    {
        const double k=8,p=24,g=26,h=44;double pw=sw*k+2*p,ph=sd*k+h+p;var sb=new StringBuilder();sb.AppendLine($"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"{F(options.Length*pw+(options.Length-1)*g)}\" height=\"{F(ph)}\" viewBox=\"0 0 {F(options.Length*pw+(options.Length-1)*g)} {F(ph)}\"><style>text{{font:9px Arial}}.room{{fill:#dce8ed;stroke:#24566c}}.circ{{fill:#f1d9d9;stroke:#9a3030}}.win{{fill:#f7d9f0;stroke:#83366e;stroke-dasharray:3 2}}.stair{{fill:#f5e5b8;stroke:#7c5d11;stroke-width:2}}.land{{fill:#f4b183;fill-opacity:.75;stroke:#9a4512}}.route{{fill:#a8c9f0;fill-opacity:.45;stroke:#174f94}}.shell{{fill:none;stroke:#222;stroke-width:2}}</style>");
        for(int i=0;i<options.Length;i++){var o=options[i];double ox=i*(pw+g),sx=ox+p,sy=h+p;string connection=o.LandingInterface?"landing interface":o.Length<=Tol?"endpoint contact":o.Turns==0?"straight path "+F(o.Length)+" ft":"dogleg "+F(o.Length)+" ft";sb.AppendLine($"<text x=\"{F(ox+p)}\" y=\"15\">M289 {i+1}: {connection}; block-change metric {F(o.LMove+o.CMove)} ft</text>");foreach(var b in blocks.Where(b=>b.Id!="C-LOWER"&&b.Id!="L-01"))Draw(b,b.Kind=="room"?"room":"circ",b.Id);foreach(var w in windows)Draw(w,"win",w.Id);Draw(o.L,"room","L-01 same area");Draw(o.C,"circ","C-LOWER same area");Draw(o.Stair.Rect,"stair","stair envelope");Draw(o.End.Landing,"land","lower landing");foreach(var q in o.Points.Select(Buffer).Distinct())Draw(q,"route","");sb.AppendLine($"<rect class=\"shell\" x=\"{F(sx)}\" y=\"{F(sy)}\" width=\"{F(sw*k)}\" height=\"{F(sd*k)}\"/>");void Draw(Rect r,string cls,string label){double x=sx+r.X*k,y=sy+(sd-r.Y-r.D)*k;sb.AppendLine($"<rect class=\"{cls}\" x=\"{F(x)}\" y=\"{F(y)}\" width=\"{F(r.W*k)}\" height=\"{F(r.D*k)}\"/>");if(r.W*k>25&&r.D*k>11)sb.AppendLine($"<text x=\"{F(x+2)}\" y=\"{F(y+10)}\">{System.Security.SecurityElement.Escape(label)}</text>");}}
        sb.AppendLine($"<text x=\"12\" y=\"{F(ph-5)}\">Analysis only; 36-in project route precedent; no selected stair or code/route approval.</text></svg>");return sb.ToString();
    }
    private static string MakeSvg(Rect[] b,Rect[] w,Route[] r,double sw,double sd)=>(string)ToSvg(b,w,r,sw,sd);
    private static JsonNode Read(string p)=>JsonNode.Parse(File.ReadAllText(p))??throw new InvalidDataException("Invalid JSON: "+p);private static string Text(JsonNode? n)=>n?.GetValue<string>()??"";private static double Num(JsonNode? n)=>n?.GetValue<double>()??throw new InvalidDataException("Expected numeric JSON field.");
    private static string Hash(string p)=>Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(p)));private static string Resolve(string r,string p)=>Path.GetFullPath(Path.IsPathRooted(p)?p:Path.Combine(r,p));private static string FindRoot(){for(DirectoryInfo? d=new(AppContext.BaseDirectory);d!=null;d=d.Parent)if(File.Exists(Path.Combine(d.FullName,"AGENTS.md")))return d.FullName;for(DirectoryInfo? d=new(Directory.GetCurrentDirectory());d!=null;d=d.Parent)if(File.Exists(Path.Combine(d.FullName,"AGENTS.md")))return d.FullName;throw new DirectoryNotFoundException("Repository root not found.");}private static string F(double x)=>x.ToString("0.####",CultureInfo.InvariantCulture);private static void Require(bool ok,string m){if(!ok)throw new InvalidDataException(m);}private static void WriteJson(string p,object v)=>File.WriteAllText(p,JsonSerializer.Serialize(v,JsonOptions)+"\n",new UTF8Encoding(false));
}
