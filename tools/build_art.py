"""Rebuild original, code-native pixel SVG assets. No downloaded game assets."""
from pathlib import Path
import random
ROOT=Path(__file__).resolve().parents[1]/'assets/art'
ROOT.mkdir(parents=True,exist_ok=True)

def save(name,w,h,rects):
    parts=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">']
    for x,y,rw,rh,c in rects:
        parts.append(f'<rect x="{x}" y="{y}" width="{rw}" height="{rh}" fill="#{c}"/>')
    parts.append('</svg>')
    (ROOT/(name+'.svg')).write_text(''.join(parts))

def tile(name,base,colors):
    rng=random.Random(27)
    r=[(0,0,32,32,base)]
    for i in range(28):
        x=rng.randrange(0,15)*2;y=rng.randrange(0,15)*2
        r.append((x,y,rng.choice([2,4]),2,rng.choice(colors)))
    save(name,32,32,r)
tile('grass','61734a',['718452','536944','8b9657'])
tile('earth','bda377',['cbb68a','a58d67','d6c39a'])
tile('stone','9c9c87',['aeae96','8a8e7d','bfc1a7'])

r=[(28,58,10,32,'4a382f'),(32,59,4,27,'866447'),(12,62,44,8,'364e36')]
for x,y,w,h,c in [(14,8,36,48,'233e37'),(6,20,54,34,'233e37'),(12,12,42,38,'365341'),(8,26,46,26,'436548'),(18,6,26,18,'4c7050'),(20,2,18,14,'587d53'),(14,20,20,8,'65845b'),(8,34,14,8,'557851'),(24,42,24,8,'557851'),(32,18,20,10,'4e7450'),(18,52,18,8,'365341')]:r.append((x,y,w,h,c))
for x,y in [(22,10),(16,25),(38,24),(12,38),(28,45),(44,37),(26,5)]:r.extend([(x,y,6,2,'78925b'),(x+2,y+2,4,2,'668955')])
save('tree',64,96,r)
r=[(2,16,44,18,'2c4937'),(6,8,34,24,'3f6543'),(12,4,22,26,'52784a'),(8,10,12,4,'75945a'),(26,8,8,4,'75945a'),(16,24,18,4,'325239'),(10,32,30,3,'263f36')]
save('bush',48,40,r)

r=[(10,26,116,82,'473a38'),(14,30,108,72,'d6c29a'),(16,74,104,28,'b49673'),(20,32,4,68,'755848'),(112,32,4,68,'755848'),(14,58,108,4,'a78b66'),(52,65,30,39,'403939'),(56,68,22,34,'6a4b39'),(72,83,3,3,'edce87'),(48,104,40,4,'96866d'),(44,108,48,4,'c5b899')]
for x in [28,90]:
    r.extend([(x,46,20,22,'5c554f'),(x+2,48,16,18,'344e58'),(x+4,50,6,6,'6e9591'),(x+9,48,2,18,'c7b68b'),(x+2,56,16,2,'c7b68b')])
for y,width,x,c in [(4,80,28,'4a3739'),(8,96,20,'a44f42'),(12,112,12,'b96149'),(16,128,4,'ad5344'),(20,136,0,'87483d'),(24,136,0,'4c3938')]:
    r.append((x,y,width,4,c))
    for xx in range(x+6,x+width-3,14):r.append((xx,y,2,4,'75413a'))
r.extend([(30,32,76,6,'edd5a1'),(38,34,60,2,'bda074')])
save('house',136,116,r)
r=[(7,5,4,48,'674f3a'),(9,8,2,44,'af8651'),(0,4,18,4,'433c35'),(2,10,14,18,'6b4934'),(4,12,10,14,'f5b965'),(6,14,6,10,'ffe7a0'),(2,28,14,3,'433c35'),(5,53,10,3,'423b35')]
save('lantern',18,58,r)
r=[(24,22,7,34,'755437'),(5,4,45,6,'513b32'),(1,10,53,26,'715440'),(5,12,45,22,'d6bd87'),(13,15,29,16,'a75242'),(20,18,15,10,'e5c997'),(25,20,5,6,'87493b'),(16,56,22,4,'483c30')]
save('target',56,64,r)
save('kunai',32,16,[(2,6,9,4,'3d4c58'),(11,4,11,8,'b7cad1'),(22,6,8,4,'ecede0'),(15,6,9,2,'edf0de'),(3,4,2,8,'738d98')])

# Four directions and three walking poses. Pixel rows are merged into rectangles.
rows=[
'........oo.o............',
'.......ohhoohoo..........',
'......ohhhhhhhho.........',
'.....ohhHhhhHhhho........',
'....ohhHHhhhhhhho........',
'....ohhhhhhhhhhho........',
'....ohhhhshhshhho........',
'.....ohsssssssho.........',
'.....ossEssEssso.........',
'......osssssso..........',
'.......osssso...........',
'......otttttto..........',
'.....otTTTTTtto.........',
'....otttTTTTttto........',
'....osttTTTTttso........',
'....ossTTTTTTsso........',
'.....ootTTTTtoo.........',
'......otttttto..........',
'......obbbbbbo..........',
'......oppppppo..........',
'......oppooppo..........',
'......opp..ppo..........',
'......oww..wwo..........',
'......off..ffo..........',
'.....offf..fffo.........',
'.....oooo..oooo.........']
for name,hair,shirt,light,pants in [('henrique','202431','24354c','405471','c1b79b'),('naruto','e8be56','d57836','edaa4d','d6813d'),('iruka','403536','49634b','68875c','344657'),('mizuki','abb7bc','646d84','969cb0','495269'),('sasuke','182433','344b72','52698e','e8e2d5'),('sakura','d98aa4','b94e62','d96f7f','e4d8d0'),('konohamaru','3b2b25','d9ad45','e7c86c','6d7c89'),('ebisu','26252b','2f3442','555d70','363b48'),('kakashi','d9dde5','4d6b4e','6f8b68','27313c')]:
    palette={'o':'182733','h':hair,'H':'58606b' if name=='henrique' else 'f4d878' if name=='naruto' else '75868b','s':'dfad87','E':'262633','t':shirt,'T':light,'b':'393a43','p':pants,'w':'eee4c9','f':'293c50'}
    atlas=[]
    for direction_index,direction in enumerate(['front','back','side']):
        for frame in range(3):
            rects=[]
            for y,row in enumerate(rows):
                row=row.ljust(24,'.')[:24]
                if direction=='back' and 6<=y<=10: row=row.replace('s','h').replace('E','H')
                if direction=='side' and 6<=y<=10: row=row[:11]+row[11:].replace('E','s')
                x=0
                while x<24:
                    char=row[x];end=x+1
                    while end<24 and row[end]==char:end+=1
                    if char!='.':
                        shift=0
                        if y>=20 and frame: shift=(1 if x<11 else -1)*(1 if frame==1 else -1)
                        rects.append((x+shift,y+(1 if frame==2 and y<18 else 0),end-x,1,palette[char]))
                    x=end
            if direction=='back' and name=='henrique':rects.extend([(9,13,5,2,'b84a45'),(9,15,5,2,'e2dfcb'),(11,17,1,1,'e2dfcb')])
            atlas.extend((x+(direction_index*3+frame)*24,y,w,h,c) for x,y,w,h,c in rects)
    save(name,216,28,atlas)
print('Built',len(list(ROOT.glob('*.svg'))),'original SVG resources')
