"""Extract source RGB pixels from the user's supplied sheets; add alpha only.

python3 tools/import_attached_sheets.py /path/to/upload
Development dependencies: Pillow, numpy, opencv-python-headless.
"""
import hashlib
import json
import sys
from pathlib import Path
import cv2
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1] / 'assets/characters'
SOURCES = {
    'cast': ('07-1000214535.png', 'ddc20bee719d0a58ae484017274dfb98cf0695847a53fb7336bbd9461bf9f0b3'),
    'player': ('08-1000214536.png', '3b1fb9f1f68c923a8cefb76f9d17153e68833caef78dabb48f1f8a301dfab9cf'),
}


def cut(image, rect, head=None):
    x, y, w, h = rect
    rgb = image[y:y+h, x:x+w].copy()
    mask = np.full((h,w), cv2.GC_PR_FGD, np.uint8)
    mask[:2,:] = mask[-2:,:] = cv2.GC_BGD
    mask[:,:2] = mask[:,-2:] = cv2.GC_BGD
    # Protect bright source clothing and sandals as well as dark hair. Without
    # these seeds GrabCut can classify navy uniforms as the navy sheet backdrop.
    channels = rgb.astype('int16')
    bright = rgb.max(axis=2) > 65
    bright[:2,:] = bright[-2:,:] = False
    bright[:,:2] = bright[:,-2:] = False
    mask[bright] = cv2.GC_FGD
    if head:
        a,b,rx,ry = head
        cv2.ellipse(mask,(a,b),(min(rx,6),min(ry,6)),0,0,360,cv2.GC_FGD,-1)
        head_area=np.zeros((h,w),np.uint8)
        cv2.ellipse(head_area,(a,b),(rx+3,ry+4),0,0,360,1,-1)
        hair=(head_area>0) & (channels[:,:,0]>9) & (channels[:,:,0]*3>channels[:,:,2])
        mask[hair]=cv2.GC_FGD
    cv2.setRNGSeed(1)
    cv2.grabCut(rgb,mask,None,np.zeros((1,65)),np.zeros((1,65)),8,cv2.GC_INIT_WITH_MASK)
    alpha = np.where((mask==1)|(mask==3),255,0).astype('uint8')
    # Keep nearby detached sandals/hands, excluding fragments of adjacent poses.
    count, labels, stats, _ = cv2.connectedComponentsWithStats(alpha)
    main = 1 + np.argmax(stats[1:, cv2.CC_STAT_AREA])
    nearby = cv2.dilate((labels == main).astype('uint8'),np.ones((9,9),np.uint8))
    for component in range(1,count):
        if not np.any(nearby[labels==component]): alpha[labels==component]=0
    rgba = Image.fromarray(np.dstack((rgb,alpha)))
    box = rgba.getbbox()
    assert box and box[3] - box[1] > 20, rect
    # No scaling, resampling, paint or replacement RGB values.
    assert np.array_equal(np.array(rgba)[:,:,:3],rgb)
    return rgba.crop(box), box


def main():
    folder = Path(sys.argv[1]); images = {}
    for key,(name,digest) in SOURCES.items():
        path=folder/name
        assert hashlib.sha256(path.read_bytes()).hexdigest()==digest, name
        images[key]=np.array(Image.open(path).convert('RGB'))
    atlas=Image.new('RGBA',(1024,640)); index=0
    manifest={'sources':{k:{'file':v[0], 'sha256':v[1]} for k,v in SOURCES.items()},
              'texture':'attached-cast.png','actors':{}}
    definitions={
        'Iruka': {'xs':[17,49,80,110], 'y':531, 'w':29,'h':71,'head':(14,17,8,10), 'portrait':[17,397,60,123],'scale':1.18},
        'Mizuki': {'xs':[151,183,215,246], 'y':531, 'w':30,'h':71,'head':(15,17,8,10), 'portrait':[153,398,61,124],'scale':1.18},
        'Sasuke': {'xs':[764,800,834,868], 'y':100, 'w':33,'h':80,'head':(17,20,8,11), 'portrait':[647,48,106,134],'scale':1.1},
        'Sakura': {'xs':[1024,1062,1100,1138], 'y':100, 'w':35,'h':80,'head':(17,20,8,11), 'portrait':[914,48,105,134],'scale':1.1},
        'Hiruzen': {'xs':[849,891,936,979], 'y':531, 'w':43,'h':71,'head':(21,19,10,10), 'portrait':[846,402,96,120],'scale':1.18},
        'Teuchi': {'xs':[559,593,626,659], 'y':531, 'w':34,'h':71,'head':(17,18,9,10), 'portrait':[558,403,67,119],'scale':1.18},
    }
    for name,d in definitions.items():
        if name in ['Iruka','Mizuki','Hiruzen','Teuchi']: d['scale']=1.3
        actor={'frames':[], 'scale':d['scale'],'fps':3}
        for x in d['xs']:
            rect=[x,d['y'],d['w'],d['h']]
            sprite,box=cut(images['cast'],rect,d['head'])
            cx,cy=(index%8)*128,(index//8)*160
            atlas.paste(sprite,(cx+(128-sprite.width)//2,cy+150-sprite.height))
            actor['frames'].append({'rect':[cx,cy,128,160],'origin':[64,150],
                                    'source_rect':rect,'mask_bounds':list(box)})
            index+=1
        x,y,w,h=d['portrait'];cx,cy=(index%8)*128,(index//8)*160
        atlas.paste(Image.fromarray(images['cast'][y:y+h,x:x+w]).convert('RGBA'),(cx,cy))
        actor['portrait']=[cx,cy,w,h];index+=1
        manifest['actors'][name]=actor
    atlas.save(ROOT/'attached-cast.png')
    (ROOT/'attached-cast.json').write_text(json.dumps(manifest,indent=2)+'\n')
    # The dedicated Henrique sheet supplies only actions already in the prologue.
    rows={
        'idle': [[x,201,75,102] for x in [30,109,187,267,344,421]],
        'walk': [[x,201,w,102] for x,w in [(530,65),(598,64),(665,65),(730,70),(800,68),(864,69),(934,70)]],
        'run': [[x,201,78,102] for x in [1030,1110,1190,1267,1345,1425]],
        'dodge': [[x,513,w,85] for x,w in [(24,98),(127,98),(230,110),(346,110),(467,121),(594,121),(720,103)]],
        'kunai': [[801,658,68,94],[872,658,64,94],[939,658,69,94]],
        'katon': [[23,820,78,85],[106,820,96,85],[208,820,89,85]],
    }
    # Later walk poses overlap neighboring capes on the illustrated sheet.
    # Only the two clean, independent walk poses are used; nothing is redrawn.
    rows['walk']=rows['walk'][:2]
    heads={
        'idle':[(37,29,15,17)]*6,
        'walk':[(34,29,14,17)]*7,
        'run':[(54,32,14,17)]*6,
        'dodge':[(70,26,17,16),(64,27,17,16),(75,35,16,15),(54,37,16,15),(83,36,16,15),(78,34,16,15),(65,27,16,16)],
        'kunai':[(40,30,14,16)]*3,
        'katon':[(43,33,15,16),(43,33,15,16),(49,32,15,16)],
    }
    player=Image.new('RGBA',(1024,640));index=0
    pm={'source':manifest['sources']['player'],'texture':'attached-henrique.png',
        'scale':0.88,'actions':{}, 'fps':{'idle':3,'walk':6,'run':13}}
    for action,rects in rows.items():
        pm['actions'][action]=[]
        for rect,head in zip(rects,heads[action]):
            sprite,box=cut(images['player'],rect,head)
            cx,cy=(index%8)*128,(index//8)*128
            player.paste(sprite,(cx+(128-sprite.width)//2,cy+124-sprite.height))
            pm['actions'][action].append({'rect':[cx,cy,128,128],'origin':[64,124],
                'source_rect':rect,'mask_bounds':list(box)})
            index+=1
    x,y,w,h=56,4,220,145
    player.paste(Image.fromarray(images['player'][y:y+h,x:x+w]).convert('RGBA'),(0,512))
    pm['portrait']=[0,512,w,h]
    # Extend once for a full, unscaled source portrait.
    expanded=Image.new('RGBA',(1024,672));expanded.paste(player,(0,0))
    expanded.paste(Image.fromarray(images['player'][y:y+h,x:x+w]).convert('RGBA'),(0,512))
    expanded.save(ROOT/'attached-henrique.png')
    (ROOT/'attached-henrique.json').write_text(json.dumps(pm,indent=2)+'\n')
    from calibrate_locomotion import main as calibrate_locomotion
    calibrate_locomotion()


if __name__=='__main__':main()
