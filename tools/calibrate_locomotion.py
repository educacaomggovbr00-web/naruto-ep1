"""Register existing sprites without changing image bytes or synthesizing poses.

The atlas already aligns the bottom alpha pixel. Register the torso horizontally
rather than alternating support feet (which would move the body every step).
"""
import hashlib
import json
from pathlib import Path
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1] / 'assets' / 'characters'

def main():
    path = ROOT / 'attached-henrique.png'
    before = hashlib.sha256(path.read_bytes()).hexdigest()
    atlas = np.array(Image.open(path).convert('RGBA'))
    manifest_path = ROOT / 'attached-henrique.json'
    data = json.loads(manifest_path.read_text())
    masks = {}
    for action in ['idle', 'walk', 'run']:
        masks[action] = []
        for frame in data['actions'][action]:
            x,y,w,h = frame['rect']
            alpha = atlas[y:y+h,x:x+w,3] > 128
            bottom = int(np.where(alpha)[0].max())
            torso_x = int(round(float(np.median(np.where(alpha[bottom-45:bottom-28])[1]))))
            # Guard the reviewed atlas: only small registration corrections.
            assert abs(torso_x-64) <= 6
            assert bottom == 123
            frame['origin'] = [torso_x,bottom+1]
            aligned = np.zeros_like(alpha)
            shift = 64-torso_x
            if shift>=0: aligned[:,shift:] = alpha[:,:w-shift]
            else: aligned[:,:w+shift] = alpha[:,-shift:]
            masks[action].append(aligned)
    for action in ['walk','run']:
        for frame,mask in zip(data['actions'][action],masks[action]):
            scores = [int(np.logical_xor(mask[64:],rest[64:]).sum()) for rest in masks['idle']]
            frame['rest_frame'] = min(range(len(scores)),key=scores.__getitem__)
    data['locomotion'] = {
        'atlas_sha256': before,
        'registration': 'bottom alpha pixel plus one; median lower torso x',
        'walk_directions': ['source three-quarter pose; mirrored for left'],
        'missing': ['front walk cycle','back walk cycle','additional clean walk in-between frames'],
        'image_pixels_modified': False,
    }
    manifest_path.write_text(json.dumps(data,indent=2,ensure_ascii=False)+'\n')
    assert hashlib.sha256(path.read_bytes()).hexdigest() == before
    print('PASS: grounded feet, registered torso and nearest resting poses; atlas bytes unchanged')

if __name__ == '__main__': main()
