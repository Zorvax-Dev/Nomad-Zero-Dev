from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
TERRAIN = ROOT / "assets" / "map" / "desert_world_rebuild.webp"
OUT = ROOT / "build" / "visual-rebuild-preview"
OUT.mkdir(parents=True, exist_ok=True)

items = [
    ("CampNorthWest","assets/decor/v46_1_camp_nomad.png",(500,500),0.440859,False,[((0,60),(225,150)),((-150,-35),(92,110)),((110,-32),(120,92))]),
    ("RefineryNorthEast","assets/decor/v46_1_refinery.png",(2520,520),0.465352,True,[((5,35),(265,170)),((-195,20),(95,90)),((160,-50),(120,115))]),
    ("WreckSouth","assets/decor/v46_1_wreck.png",(1620,1485),0.538828,False,[((-20,25),(295,128)),((140,-120),(110,105)),((-300,-15),(90,70)),((250,25),(92,70))]),
    ("OutpostSouthEast","assets/decor/v48_salvage_rig.png",(2460,1480),0.31,False,[((0,42),(168,112)),((82,-30),(58,64))]),
    ("RockWest","assets/decor/v46_1_rock_main.png",(650,1205),0.52,False,[((0,45),(135,92))]),
    ("RockEast","assets/decor/v46_1_rock_mirror.png",(2250,1150),0.49,False,[((0,40),(130,90))]),
    ("RockCenterLeft","assets/decor/v46_1_rock_main.png",(1120,850),0.32,False,[((0,30),(88,60))]),
    ("RockCenterRight","assets/decor/v46_1_rock_mirror.png",(1950,860),0.34,False,[((0,32),(92,62))]),
    ("RockSouthWest","assets/decor/v46_1_rock_mirror.png",(1080,1660),0.28,False,[((0,32),(76,54))]),
    ("RockSouthEast","assets/decor/v46_1_rock_main.png",(2085,1690),0.30,False,[((0,35),(82,56))]),
    ("CanyonGateNorth","assets/decor/v47_canyon_rock.png",(3275,515),0.36,False,[((0,30),(105,72))]),
    ("CanyonGateSouth","assets/decor/v47_canyon_rock.png",(3290,1540),0.34,True,[((0,30),(100,70))]),
    ("CanyonRockNorth","assets/decor/v47_canyon_rock.png",(3540,610),0.31,True,[((0,32),(90,62))]),
    ("CanyonRockSouth","assets/decor/v47_canyon_rock.png",(3490,1515),0.29,False,[((0,33),(86,60))]),
    ("EchoRuins","assets/decor/v47_canyon_rock.png",(3630,1310),0.36,False,[((0,34),(104,72))]),
    ("EchoSpire","assets/decor/v47_canyon_rock.png",(3920,820),0.30,True,[((0,30),(86,62))]),
    ("CanyonRockEast","assets/decor/v47_canyon_rock.png",(3870,1570),0.24,True,[((0,30),(68,48))]),
    ("LeviathanWreck","assets/decor/v48_leviathan.png",(2150,2670),0.62,False,[((-10,95),(158,92)),((-135,190),(96,58)),((155,-85),(76,66))]),
    ("SalvageStation","assets/decor/v48_salvage_rig.png",(900,2620),0.46,True,[((5,120),(132,68)),((-100,-2),(58,56))]),
    ("IronPit","assets/decor/v48_iron_pit.png",(3070,2480),0.60,False,[((0,70),(102,76))]),
    ("ScrapHeapEast","assets/decor/v48_scrap_heap.png",(2660,2860),0.42,False,[((5,60),(91,58))]),
    ("ScrapHeapWest","assets/decor/v48_scrap_heap.png",(1380,2840),0.30,True,[((5,40),(65,45))]),
    ("ScrapHeapNorth","assets/decor/v48_scrap_heap.png",(2700,2260),0.25,True,[((5,35),(55,39))]),
]

terrain = Image.open(TERRAIN).convert("RGBA")
assert terrain.size == (4096,3072), terrain.size
world = terrain.copy()

# Draw back-to-front using approximate feet Y order.
render = []
for name, rel, pos, scale, flip, blockers in items:
    path = ROOT / rel
    img = Image.open(path).convert("RGBA")
    size = (max(1, round(img.width*scale)), max(1, round(img.height*scale)))
    img = img.resize(size, Image.Resampling.LANCZOS)
    if flip:
        img = img.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    render.append((pos[1],name,img,pos,blockers))

for _,name,img,pos,blockers in sorted(render):
    x = round(pos[0]-img.width/2)
    y = round(pos[1]-img.height/2)
    world.alpha_composite(img,(x,y))

preview = world.resize((2048,1536), Image.Resampling.LANCZOS)
preview.save(OUT/"world.png")

collision = preview.copy()
draw = ImageDraw.Draw(collision,"RGBA")
for _,name,img,pos,blockers in render:
    for offset,radius in blockers:
        cx=(pos[0]+offset[0])/2
        cy=(pos[1]+offset[1])/2
        rx=radius[0]/2
        ry=radius[1]/2
        draw.ellipse((cx-rx,cy-ry,cx+rx,cy+ry),fill=(255,40,40,55),outline=(255,75,75,220),width=2)
draw.text((20,20),"VISUAL REBUILD — RED = BLOCKED",fill=(255,255,255,255),stroke_width=2,stroke_fill=(0,0,0,255))
collision.save(OUT/"collisions.png")
print("rendered", len(items), "landmarks")
