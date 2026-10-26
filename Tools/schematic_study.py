"""Reproducible room-block studies, not BIM, engineering or code certification."""
import csv
import html
import json
import textwrap
from pathlib import Path
from xml.etree import ElementTree

from shapely.geometry import Point, box

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / 'Architecture/Schematic_Study_2026-10-25'
DRAW = ROOT / 'Exports/Schematic_Study_2026-10-25'
WALL = 2 / 3  # assumed exterior wall reservation, not an assembly selection


def rect(id_, name, x, y, w, d, kind='room'):
    return dict(id=id_, name=name, x=x, y=y, w=w, d=d, kind=kind)


def upper():
    # Identical private-room geometry for both alternatives.
    return [
        rect('U-01', 'Primary bedroom', WALL, WALL, 16, 10),
        rect('U-05', 'Primary bath', WALL, 67/6, 9, 10),
        rect('C-PRIVATE', 'Private connector', 61/6, 67/6, 6.5, 10, 'circulation'),
        rect('U-02', 'Boutique', WALL, 65/3, 16, 29/3),
        rect('C-UPPER', '4 ft suite / public hall', 103/6, WALL, 4, 92/3, 'circulation'),
        rect('U-04', 'Guest bedroom', 65/3, WALL, 41/3, 8.5),
        rect('U-06', 'Jack and Jill bath', 76/3, 29/3, 10, 12),
        rect('U-03', 'Hybrid bedroom / office', 65/3, 133/6, 41/3, 55/6),
    ]


def lower(option):
    rooms = [
        rect('L-03', 'Lower full bath', WALL, WALL, 9, 10),
        rect('L-04', 'Enclosed laundry', WALL, 67/6, 9, 8),
        rect('L-05', 'MEP equipment reservation', WALL, 59/3, 9, 35/3),
        rect('L-07', 'Arrival + dry storage', 79/3, WALL, 9, 11.5),
        rect('L-06', 'Ventilated technology room', 82/3, 38/3, 8, 8),
        rect('L-01', 'Lower flexible living', 61/6, 13, 41/3, 55/3),
        rect('S-01', 'Conditioned storage reserve*', 52/3, WALL, 5, 6),
        rect('C-LOWER', 'Lower arrival / circulation', 61/6, WALL, 20/3, 71/6, 'circulation'),
    ]
    rooms.append(rect('L-02' if option == 'A' else 'ALLOW-01',
                      'Bedroom-capable flex' if option == 'A' else 'Unassigned lower allowance',
                      73/3, 127/6, 11, 10, 'room' if option == 'A' else 'unassigned'))
    return rooms


def main(option):
    depth = 36 if option == 'A' else 42
    living_depth = 16 if option == 'A' else 15
    dining_y = 103/6 if option == 'A' else 97/6
    rooms = [
        rect('M-01', 'Living room', WALL, WALL, 16, living_depth),
        rect('M-02', 'Kitchen', 22, WALL, 52/3, 16),
        rect('M-03', 'Dining', WALL, dining_y, 34/3, 14),
        rect('M-04', 'Pantry', 103/3, 103/6, 5, 7),
        rect('M-05', 'Front arrival / hall', 103/6, WALL, 13/3, 12),
        rect('M-06', 'PROPOSED main full bath', 91/3, depth-32/3, 9, 10),
    ]
    if option == 'B':
        rooms.append(rect('L-02', 'Flex sleeping room (relocated)', WALL, 92/3, 11, 10))
    return rooms


def core(option):
    depth, risers, rise, assembly = (36, 7, 4.5, 1) if option == 'A' else (42, 8, 5, 1.25)
    run = (risers-1)*11/12
    return dict(main_depth=depth, risers=risers, half_rise_ft=rise,
                riser_inches=rise*12/risers, tread_inches=11, run_ft=run,
                landing_depth_ft=4, flight_width_reservation_ft=4,
                floor_assembly_ft=assembly, lower_clear_height_ft=2*rise-assembly,
                main_ceiling_ft=9, upper_ceiling_ft=9,
                stair_front_y=depth-8-run, stair_run_y=depth-4-run,
                lift=rect('C-LIFT', '8 x 8 lift RESERVATION', 21.5, depth-8, 8, 8, 'core'))


UPPER_DOORS = [
    ('D-U01', 'C-UPPER', 'U-01', 101/6, 5, 'v'),
    ('D-U02', 'U-01', 'U-05', 5, 131/12, 'h'),
    ('D-U03', 'U-01', 'C-PRIVATE', 13, 131/12, 'h'),
    ('D-U04', 'C-PRIVATE', 'U-02', 13, 257/12, 'h'),
    ('D-U05', 'U-02', 'C-UPPER', 101/6, 27, 'v'),
    ('D-U06', 'U-03', 'C-UPPER', 257/12, 27, 'v'),
    ('D-U07', 'U-04', 'C-UPPER', 257/12, 5, 'v'),
    ('D-U08', 'U-04', 'U-06', 30, 113/12, 'h'),
    ('D-U09', 'U-03', 'U-06', 30, 263/12, 'h'),
]


def validate(study):
    checks = {}
    for name, option in study['alternatives'].items():
        rear_y=option['frames']['upper']['origin_ft'][1]
        checks[f'{name}_main_and_stacked_rear_room_wings_do_not_overlap'] = box(
            0,0,40,option['core']['main_depth']).intersection(box(0,rear_y,36,rear_y+32)).area < 1e-7
        for level, rooms in option['plans'].items():
            width, depth = (40, option['core']['main_depth']) if level == 'main' else (36, 32)
            inside = box(WALL-1e-8, WALL-1e-8, width-WALL+1e-8, depth-WALL+1e-8)
            checks[f'{name}_{level}_net_blocks_inside_shell'] = all(
                inside.covers(box(r['x'],r['y'],r['x']+r['w'],r['y']+r['d'])) for r in rooms)
            overlaps = [(a['id'],b['id']) for i,a in enumerate(rooms) for b in rooms[i+1:]
                        if box(a['x'],a['y'],a['x']+a['w'],a['y']+a['d']).intersection(
                            box(b['x'],b['y'],b['x']+b['w'],b['y']+b['d'])).area > 1e-7]
            checks[f'{name}_{level}_no_net_block_overlap'] = not overlaps
            if overlaps:
                raise AssertionError((name, level, overlaps))
        c = option['core']
        checks[f'{name}_lower_height_arithmetic'] = abs(c['lower_clear_height_ft'] + c['floor_assembly_ft'] - 2*c['half_rise_ft']) < 1e-8
        checks[f'{name}_stair_rise_arithmetic'] = abs(c['risers']*c['riser_inches']/12-c['half_rise_ft']) < 1e-8
        checks[f'{name}_not_historical_six_riser_section'] = c['lower_clear_height_ft'] >= 8
        # All retained rooms appear once; L-02 changes levels only in B.
        room_ids = [r['id'] for rooms in option['plans'].values() for r in rooms if r['kind']=='room']
        expected = {f'U-{i:02}' for i in range(1,7)} | {f'M-{i:02}' for i in range(1,7)} | {f'L-{i:02}' for i in range(1,8)} | {'S-01'}
        checks[f'{name}_program_ids_preserved_once'] = set(room_ids)==expected and len(room_ids)==len(expected)
        # Main floor occupation must not fill the reserved stair/lift core.
        core_boxes = [box(12.5,c['stair_front_y'],21,c['main_depth']),
                      box(21.5,c['main_depth']-8,29.5,c['main_depth'])]
        checks[f'{name}_main_rooms_avoid_core'] = all(
            box(r['x'],r['y'],r['x']+r['w'],r['y']+r['d']).intersection(cb).area < 1e-7
            for r in option['plans']['main'] for cb in core_boxes)
    # Analytic kitchen and dining tests are separate from construction clearance approval.
    checks['old_kitchen_12_ft_short_axis_fails_13_ft_counter_aisle_island_aisle_chain'] = 12 < 2+3.5+4+3.5
    kitchen=study['kitchen_test']; island=kitchen['island']; counter=kitchen['counter']
    checks['new_kitchen_has_4_ft_work_aisle'] = island['y']-(counter['y']+counter['d']) >= 4
    checks['new_kitchen_8_ft_island_has_end_clearances'] = min(island['x'],kitchen['width']-island['x']-island['w']) >= 4
    checks['kitchen_has_seat_allowance_plus_4_ft_route'] = kitchen['depth']-island['y']-island['d']-2 >= 4
    checks['dining_14_ft_depth_has_separate_4_ft_route'] = 3+3+3+4 <= 14
    graph = {}
    for _,a,b,*_ in UPPER_DOORS:
        graph.setdefault(a,set()).add(b); graph.setdefault(b,set()).add(a)
    for room in ['U-01','U-03','U-04']:
        checks[f'{room}_has_hall_access_without_bath'] = 'C-UPPER' in graph[room]
    checks['primary_bath_has_only_primary_entry'] = graph['U-05']=={'U-01'}
    checks['jack_jill_entries_remain_hybrid_and_guest'] = graph['U-06']=={'U-03','U-04'}
    fixtures=study['living_test']['fixtures']; lane=box(0,11,16,15)
    checks['living_route_avoids_fixture_reservations'] = all(
        box(r['x'],r['y'],r['x']+r['w'],r['y']+r['d']).intersection(lane).area < 1e-7 for r in fixtures)
    checks['living_fixture_reservations_do_not_overlap'] = all(
        box(a['x'],a['y'],a['x']+a['w'],a['y']+a['d']).intersection(
            box(b['x'],b['y'],b['x']+b['w'],b['y']+b['d'])).area < 1e-7
        for i,a in enumerate(fixtures) for b in fixtures[i+1:])
    circle=Point(4,4.5).buffer(2.5)
    checks['main_bath_5_ft_turn_reserve_avoids_fixture_footprints'] = all(
        circle.intersection(box(r['x'],r['y'],r['x']+r['w'],r['y']+r['d'])).area < 1e-7
        for r in study['bath_test']['fixtures'])
    assert all(checks.values()), checks
    return dict(status='limited geometric checks passed; unresolved items remain',checks=checks,
                exclusions=['Door swings and actual clear openings','Furniture-complete accessible routes',
                            'Stair headroom / guards / exact floor-edge clashes','Lift product feasibility',
                            'Structural design, site, code, MEP and roof','Native Revit house model'])


def esc(s):
    return html.escape(str(s))


class Svg:
    def __init__(self,title,subtitle,width=1200,height=980):
        self.parts=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
                    '<rect width="100%" height="100%" fill="#faf8f1"/>',
                    '<style>text{font-family:Arial,sans-serif;fill:#29372d}.small{font-size:12px}.title{font-size:25px;font-weight:bold}.room{font-size:13px}</style>']
        self.text(35,38,title,'title'); self.text(35,64,subtitle,'small')
    def text(self,x,y,text,cls='room',anchor='start'):
        for i,line in enumerate(str(text).split('\n')):
            self.parts.append(f'<text x="{x}" y="{y+i*17}" class="{cls}" text-anchor="{anchor}">{esc(line)}</text>')
    def line(self,x1,y1,x2,y2,color='#53634f',width=2,dash=''):
        self.parts.append(f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{color}" stroke-width="{width}" stroke-dasharray="{dash}"/>')
    def rectangle(self,x,y,w,h,fill='#fff',stroke='#53634f',dash=''):
        self.parts.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{fill}" stroke="{stroke}" stroke-width="1.5" stroke-dasharray="{dash}"/>')
    def save(self,name):
        path=DRAW/name; path.write_text('\n'.join(self.parts+['</svg>']),encoding='utf-8'); ElementTree.parse(path)


def draw_plan(key,level,option):
    width,depth = (40,option['core']['main_depth']) if level=='main' else (36,32)
    s=Svg(f'Option {key} | {level.title()} floor room blocks',
          'PROPOSAL - dimensions in feet; openings are reservations, not tested clear door widths.')
    scale=14 if level=='lower' else 18
    ox=230 if level=='main' else 65; oy=150 if level=='main' else 340
    X=lambda x:ox+x*scale; Y=lambda y:oy+y*scale
    s.rectangle(X(0),Y(0),width*scale,depth*scale,'#e9e4d9')
    palette={'room':'#fffdf7','circulation':'#e2eddf','unassigned':'#f7e1c8'}
    for r in option['plans'][level]:
        s.rectangle(X(r['x']),Y(r['y']),r['w']*scale,r['d']*scale,palette[r['kind']])
        short={'C-UPPER':'Hall','C-PRIVATE':'Private link','C-LOWER':'Arrival hall',
               'M-05':'Entry','S-01':'Reserve*','L-05':'MEP zone','L-06':'Technology',
               'M-06':'Main full bath*','L-02':'Flex sleep'}
        name=short.get(r['id'],r['name'])
        chars=max(7,int((r['w']*scale-12)/7))
        name='\n'.join(textwrap.wrap(name,width=chars))
        dimensions=f"{r['w']:.1f} x {r['d']:.1f} ft" if r['w']>=7 else f"{r['w']:.1f} ft W"
        label=f"{r['id']}\n{name}\n{dimensions}\n{r['w']*r['d']:.1f} sf"
        if r['id']=='M-02':
            continue  # place below the perimeter cabinets after drawing them
        s.text(X(r['x']+.3),Y(r['y']+.9),label)
    if level=='upper':
        for id_,a,b,x,y,axis in UPPER_DOORS:
            dx,dy=(1.75,0) if axis=='h' else (0,1.75)
            s.line(X(x-dx),Y(y-dy),X(x+dx),Y(y+dy),'#aa602c',5)
        s.text(795,230,'Private suite:\nprimary > private connector > boutique\nboutique > rear hall > hybrid\nGuest has its own public hall door.\n\nTwo J+J entries only.\nMain bath serves daytime visitors.\nDoor swings / furniture still to test.')
    if level=='main':
        c=option['core']; run=c['run_ft']; front=c['stair_front_y']
        for x,label in [(12.5,'DOWN'),(17,'UP')]:
            s.rectangle(X(x),Y(front),4*scale,(8+run)*scale,'#e2eddf')
            for i in range(c['risers']):
                y=depth-4-run+i*11/12
                s.line(X(x),Y(y),X(x+4),Y(y),'#70806b',1)
            s.text(X(x+.2),Y(front+.8),label,'small')
        lift=c['lift']; s.rectangle(X(lift['x']),Y(lift['y']),8*scale,8*scale,'#e7dfef',dash='6 3')
        s.text(X(22),Y(depth-6.8),'Lift reserve\n8 x 8 ft\nNOT a selected car')
        dining=next(r for r in option['plans']['main'] if r['id']=='M-03')
        dy=dining['y']; s.rectangle(X(-10),Y(dy+1),10*scale,12*scale,'#f0e6ce')
        s.text(X(-9.5),Y(dy+2.5),'X-01 Porch\n10 x 12 ft\n120 sf')
        s.rectangle(X(4),Y(dy+4),5*scale,3*scale,'#c8b88b')
        s.rectangle(X(1),Y(dy+1),11*scale,9*scale,'none',dash='4 3')
        s.rectangle(X(WALL),Y(dy+10),34/3*scale,4*scale,'none','#2f776d','5 3')
        s.line(X(0),Y(dy+8),X(0),Y(dy+14),'#aa602c',5)
        # One straight perimeter appliance run; no cooking/plumbing in island.
        s.rectangle(X(22),Y(WALL),52/3*scale,2*scale,'#b7c5a7')
        s.text(X(22.3),Y(3.7),'M-02 Kitchen\n17.33 x 16 ft | 277.3 sf')
        s.rectangle(X(80/3),Y(20/3),8*scale,4*scale,'#9cab87')
        s.text(X(27),Y(8),'8 x 4 island','small')
        s.line(X(19.3),Y(8),X(19.3),Y(22),'#2f776d',3,'5 3')
        bath=next(r for r in option['plans']['main'] if r['id']=='M-06')
        s.line(X(bath['x']+.5),Y(bath['y']-.25),X(bath['x']+4),Y(bath['y']-.25),'#aa602c',5)
        if key=='B':
            s.line(X(WALL+6),Y(92/3-.25),X(WALL+9.5),Y(92/3-.25),'#aa602c',5)
        s.text(985,230,'Main entry at 0 ft.\nDashed dining lane: 4 ft.\nChair envelope: dashed box.\nFrench doors swing into porch.\nThreshold remains unresolved.\n\nM-06 full bath is a proposal.\nB relocates L-02 to main;\nA leaves L-02 downstairs.\n\nCore is a volume reservation.\nStair / lift interfaces and\nheadroom require native testing.','small')
    if level=='lower':
        s.rectangle(X(36),Y(WALL),24*scale,24*scale,'#e4e1d9')
        s.text(X(37),Y(3),'X-02 Garage\n24 x 24 ft | 576 sf\nSame test datum as lower floor\nDoor to arrival/storage zone\nUtility / EVSE zones untested')
        s.line(X(36),Y(4),X(36),Y(7.5),'#aa602c',5)
        s.line(X(36),Y(5.75),X(32),Y(5.75),'#2f776d',3,'5 3')
        s.line(X(32),Y(5.75),X(32),Y(9),'#2f776d',3,'5 3')
        s.line(X(10.167),Y(9),X(32),Y(9),'#2f776d',3,'5 3')
        s.line(X(18),Y(32),X(21.5),Y(32),'#aa602c',5)
        s.text(65,840,'Lower route: garage > arrival/storage > hall > stairs or future lift.\nRear walkout is a site-dependent proposal. No site, grade or driveway is selected.\n* S-01 is a movable program reservation, not a selected security location.\nMechanical and technology rooms are separate; actual equipment clearances remain untested.')
    if level in ('upper','lower'):
        c=option['core']; length=8+c['run_ft']
        s.rectangle(X(12.5),Y(-length),17*scale,length*scale,'none','#8a7a95','6 4')
        s.text(X(12.8),Y(-length+.9),'Core in front wing\nStairs / lift / landings\nDo not place habitable rooms\nbelow the main landing.','small')
    s.text(35,935,f'Shell: {width} x {depth} ft. Clear room blocks assume 8 in exterior walls / nominal 6 in partitions; unfilled space is NOT proven usable area.','small')
    s.text(35,957,'Study only. No north/site orientation, structural spans, construction assemblies, code or accessibility approval. Native Revit house geometry not yet authored.','small')
    s.save(f'{key}_{level}.svg')


def draw_section(key,option):
    c=option['core']; rise=c['half_rise_ft']; d=c['main_depth']; scale=13
    s=Svg(f'Option {key} | Coordinated volume section',
          'Longitudinal shell section and separate stair arithmetic diagram; roof / foundation / grade are unresolved.',1200,760)
    X=lambda y:55+y*scale; Z=lambda z:380-z*17
    s.rectangle(X(0),Z(9),d*scale,9*17,'#edf0e5')
    s.rectangle(X(d),Z(rise+9),32*scale,9*17,'#f3e9d8')
    s.rectangle(X(d),Z(rise-c['floor_assembly_ft']),32*scale,c['lower_clear_height_ft']*17,'#e3ecea')
    s.rectangle(X(d),Z(rise),32*scale,c['floor_assembly_ft']*17,'#bfb4a4')
    s.line(X(0),Z(0),X(d),Z(0),'#29372d',3)
    for z in [-rise,rise]: s.line(X(d),Z(z),X(d+32),Z(z),'#29372d',3)
    # Multi-height core is in front wing. Main slab must be opened at runs and shaft.
    s.rectangle(X(d-8-c['run_ft']),Z(rise+9),(8+c['run_ft'])*scale,(2*rise+9)*17,'none','#956c9b','5 4')
    s.text(X(2),Z(5),'MAIN 0 ft\n9 ft ceiling study')
    s.text(X(d+2),Z(rise+6),'UPPER +' + str(rise)+' ft\n9 ft ceiling study')
    s.text(X(d+2),Z(-rise+5),'LOWER -'+str(rise)+' ft\n'+str(c['lower_clear_height_ft'])+' ft clear height')
    s.text(55,490,f"Lower-to-upper: {2*rise:.2f} ft = {c['lower_clear_height_ft']:.2f} ft clear + {c['floor_assembly_ft']:.2f} ft assumed assembly.")
    s.text(55,519,f"Each half flight: {c['risers']} risers x {c['riser_inches']:.4f} in = {rise*12:.1f} in; {c['risers']-1} treads x 11 in = {c['run_ft']:.3f} ft run.")
    s.text(55,548,f"Flight reservation: 4 ft wide; 4 ft landings at both ends. Total straight plan length: {8+c['run_ft']:.3f} ft.")
    s.text(55,590,'Section logic: main and lower/upper rooms occupy different plan zones. The stair/lift core joins the zones.\nCore slab openings, floor edges, beams, pit/overrun and headroom are not resolved by this volume diagram.\nA reserves a future lift-dependent sleeping route; B provides a proposed main-level sleeping/bathing route.\nNo grade line or roof pitch is drawn because site and roof/solar coordination are not selected.')
    s.save(f'{key}_section.svg')


def draw_kitchen():
    s=Svg('Kitchen fit | Preserve the island, test the room',
          'One-wall perimeter appliance run; 8 x 4 ft island stays free of sink, dishwasher and range.',1200,820)
    sc=32; ox=80; oy=140; w=52/3; d=16
    s.rectangle(ox,oy,w*sc,d*sc,'#fffdf7')
    s.rectangle(ox,oy,w*sc,2*sc,'#b7c5a7')
    ix=(w-8)/2; s.rectangle(ox+ix*sc,oy+6*sc,8*sc,4*sc,'#9cab87')
    s.line(ox+(ix+6)*sc,oy+6*sc,ox+(ix+6)*sc,oy+10*sc,'#6e5639',2)
    s.text(ox+(ix+.3)*sc,oy+7.3*sc,'6 ft cream quartz | 2 ft wood')
    s.rectangle(ox+ix*sc,oy+10*sc,8*sc,2*sc,'#eddbc7',dash='5 3')
    s.rectangle(ox,oy+12*sc,w*sc,4*sc,'#dfebe5',dash='5 3')
    s.text(ox+10,oy+sc,'Perimeter sink + DW + 30 in induction + refrigerator (positions provisional)')
    s.text(ox+10,oy+4.2*sc,'4 ft work aisle (closed appliances)')
    s.text(ox+10,oy+13.7*sc,'4 ft through-route behind 2 ft occupied-seat allowance')
    s.text(710,155,'Why 14 x 12 ft is not accepted:\n\n2 ft counter\n+ 3.5 ft work aisle\n+ 4 ft island\n+ 3.5 ft far-side aisle\n= 13 ft, before seated use.\n\nProposed short axis: 16 ft\n= 2 + 4 + 4 + 2 + 4.\nProposed long axis: 17.333 ft\n= 4.667 + 8 + 4.667.\n\nDoor-open appliances still need testing.\nNo end-wall cabinet run is included.\nThis is an area-increasing proposal.')
    s.text(80,730,'Study room 17 ft 4 in x 16 ft = 277.33 sf (older allowance: 168 sf). Increase: 109.33 sf.','room')
    s.text(80,760,'Clearance targets are project study inputs, not a code or universal-accessibility determination.','small')
    s.save('Kitchen_fit.svg')


def draw_fixtures(study):
    s=Svg('Main full bath + flex sleeping room | Nominal fit studies',
          'PROPOSALS - a five-foot circle and nominal openings do not establish a complete accessible design.',1200,780)
    sc=34; ox=70; oy=260
    s.rectangle(ox,oy,9*sc,10*sc,'#fffdf7')
    for r in study['bath_test']['fixtures']:
        s.rectangle(ox+r['x']*sc,oy+r['y']*sc,r['w']*sc,r['d']*sc,'#d4dfcf')
        s.text(ox+(r['x']+.15)*sc,oy+(r['y']+.65)*sc,r['name'],'small')
    s.parts.append(f'<circle cx="{ox+4*sc}" cy="{oy+4.5*sc}" r="{2.5*sc}" fill="none" stroke="#2f776d" stroke-dasharray="6 4"/>')
    s.text(ox+2*sc,oy+4.5*sc,'5 ft turn reserve','small')
    s.line(ox+.5*sc,oy,ox+4*sc,oy,'#aa602c',5)
    s.rectangle(ox+.5*sc,oy-3.5*sc,3.5*sc,3.5*sc,'none','#aa602c','5 4')
    s.text(ox,oy-4*sc,'Door outward-swing reservation; actual leaf/clear opening TBD','small')
    bx=650; by=260
    s.rectangle(bx,by,11*sc,10*sc,'#fffdf7')
    s.rectangle(bx+.5*sc,by+(10-7.167)*sc,5*sc,6.667*sc,'#d6c3a3')
    s.text(bx+.7*sc,by+6*sc,'5 x 6.667 ft\nbed footprint','small')
    s.parts.append(f'<circle cx="{bx+8.25*sc}" cy="{by+5.5*sc}" r="{2.5*sc}" fill="none" stroke="#2f776d" stroke-dasharray="6 4"/>')
    s.line(bx+6*sc,by,bx+9.5*sc,by,'#aa602c',5)
    s.text(bx,by-20,'11 x 10 ft flex bedroom-capable room','room')
    s.text(70,680,'Main bath is 9 x 10 ft in BOTH studies; B brings L-02 to the same main level.\nShower 5 x 3 ft, vanity 5 x 1.833 ft, toilet footprint 1.5 x 2.5 ft are schematic inputs.\nToilet transfer zones, shower approach, door hardware/clear opening, waterproofing, reinforcement and controls remain unresolved.\nB sleeping room opens from the dining-side passage: privacy/acoustics require refinement. No legal-bedroom or accessibility certification.')
    s.save('Bath_and_sleeping_fit.svg')
    s=Svg('Living room | Separate hearth and cabinet TV',
          'Equipment/service envelopes are conservative placeholders, not manufacturer-verified clearances.',1200,820)
    ox=75; oy=145; sc=34
    s.rectangle(ox,oy,16*sc,16*sc,'#fffdf7')
    for r in study['living_test']['fixtures']:
        s.rectangle(ox+r['x']*sc,oy+r['y']*sc,r['w']*sc,r['d']*sc,'#d7dfcc')
        s.text(ox+(r['x']+.15)*sc,oy+(r['y']+.65)*sc,r['name'],'small')
    s.rectangle(ox,oy+11*sc,16*sc,4*sc,'none','#2f776d','5 4')
    s.text(ox+sc,oy+13*sc,'4 ft circulation reservation','small')
    s.line(ox,oy+15*sc,ox+16*sc,oy+15*sc,'#aa602c',2,'6 4')
    s.text(715,180,'A: 16 x 16 ft = 256 sf\nB: 16 x 15 ft = 240 sf\nB rear wall: orange dashed line\n\nTV/service envelope: 4 x 7 ft\nHearth reservation: 5 x 5 ft\nLoveseat: 3 x 6.5 ft\nExtended recliner: 5.5 x 4 ft\n\nNo shared TV/hearth stack.\nNo listed stove clearances assumed.\nDelivery turns, actual TV dimensions,\nfloor loading and heat separation\nremain unverified.')
    s.text(75,750,'Test fit preserves the furniture and separate focal areas by enlarging the earlier 180-220 sf living allowance.','small')
    s.save('Living_fit.svg')


def run():
    DATA.mkdir(parents=True,exist_ok=True); DRAW.mkdir(parents=True,exist_ok=True)
    study=dict(status='PROPOSED room blocks; no alternative selected',units='feet',
               assumptions=dict(exterior_wall_ft=WALL,partition_ft=.5,site='unknown',
                                main_full_bath='proposal replacing optional powder in both alternatives'),
               upper_door_matrix=[dict(id=i,a=a,b=b,x=x,y=y,axis=axis,nominal_reservation_ft=3.5)
                                  for i,a,b,x,y,axis in UPPER_DOORS],
               kitchen_test=dict(width=52/3,depth=16,counter=rect('counter','Perimeter',0,0,52/3,2),
                                 island=rect('island','Island',14/3,6,8,4)),
               bath_test=dict(width=9,depth=10,fixtures=[
                   rect('vanity','Vanity',4,0,5,11/6),rect('shower','Shower',0,7,5,3),
                   rect('toilet','Toilet',6.75,7.25,1.5,2.5)]),
               living_test=dict(fixtures=[rect('tv','TV + service reserve',0,2,4,7),
                   rect('hearth','Hearth reserve',11,0,5,5),rect('sofa','Loveseat',6.5,4.5,3,6.5),
                   rect('chair','Recliner extended',10,7,5.5,4)]),alternatives={})
    rows=[]
    for key in ['A','B']:
        option=dict(core=core(key),plans=dict(main=main(key),upper=upper(),lower=lower(key)))
        depth=option['core']['main_depth']; rise=option['core']['half_rise_ft']
        option['frames'] = dict(
            convention='Local x/y in each plan. Shared study x to right; y toward rear. No georeference/north/site.',
            main=dict(origin_ft=[0,0,0]),upper=dict(origin_ft=[0,depth,rise]),
            lower=dict(origin_ft=[0,depth,-rise]),
            garage=dict(origin_ft=[36,depth+WALL,-rise]),
            porch=dict(origin_ft=[-10,next(r['y'] for r in option['plans']['main'] if r['id']=='M-03')+1,0]))
        study['alternatives'][key]=option
        for level,rooms in option['plans'].items():
            for r in rooms:
                rows.append(dict(option=key,level=level,id=r['id'],name=r['name'],kind=r['kind'],
                                 net_sf=round(r['w']*r['d'],4)))
        option['area_accounting'] = dict(
            main_shell_plate_sf=40*option['core']['main_depth'],upper_shell_plate_sf=1152,
            lower_shell_plate_sf=1152,base_shell_plate_sum_sf=40*option['core']['main_depth']+2304,
            net_room_sf=sum(r['w']*r['d'] for rooms in option['plans'].values() for r in rooms if r['kind']=='room'),
            garage_sf=576,porch_sf=120,conditioned_measured_sf=None,above_below_grade_sf=None,
            caveat='Shell plate sum is a comparison allowance, not certified gross/conditioned area. Core floor projections, voids and wall accounting still need BIM reconciliation.')
    checks=validate(study)
    (DATA/'study.json').write_text(json.dumps(study,indent=2)+'\n',encoding='utf-8')
    (DATA/'checks.json').write_text(json.dumps(checks,indent=2)+'\n',encoding='utf-8')
    with (DATA/'room_areas.csv').open('w',newline='',encoding='utf-8') as stream:
        writer=csv.DictWriter(stream,fieldnames=rows[0].keys());writer.writeheader();writer.writerows(rows)
    for key,option in study['alternatives'].items():
        for level in option['plans']: draw_plan(key,level,option)
        draw_section(key,option)
    draw_kitchen()
    draw_fixtures(study)
    print(json.dumps(dict(implemented_checks=len(checks['checks']),all_passed=all(checks['checks'].values()),
                         areas={key:option['area_accounting'] for key,option in study['alternatives'].items()},
                         native_revit_house_model='not authored'),indent=2))


if __name__=='__main__':
    run()
