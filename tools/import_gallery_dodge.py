"""Extract the reviewed dodge row; never modify the source gallery image.

Usage: python3 tools/import_gallery_dodge.py /path/to/gallery-sheet.png
Requires Pillow, numpy and opencv-python-headless (development only).
"""
import hashlib
import json
import sys
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
RECTS = [(462, 570, 73, 76), (613, 573, 74, 73),
         (733, 572, 80, 74), (844, 573, 83, 73)]
HEADS = [(55, 18, 13, 11), (53, 17, 13, 11),
         (59, 17, 13, 11), (60, 22, 13, 11)]


def main():
    source = Path(sys.argv[1])
    digest = hashlib.sha256(source.read_bytes()).hexdigest()
    manifest_path = ROOT / 'assets/characters/gallery-dodge.json'
    if manifest_path.exists():
        expected = json.loads(manifest_path.read_text())['source_sha256']
        if digest != expected:
            raise SystemExit('Wrong source image: expected SHA256 ' + expected)
    image = np.array(Image.open(source).convert('RGB'))
    assert image.shape == (1024, 1536, 3), 'Expected original 1536x1024 sheet'
    atlas = Image.new('RGBA', (384, 96))
    frames = []
    for i, ((x, y, w, h), head) in enumerate(zip(RECTS, HEADS)):
        crop = image[y-3:y+h+3, x-3:x+w+3].copy()
        mask = np.zeros(crop.shape[:2], np.uint8)
        mask[3:-3, 3:-3] = cv2.GC_PR_FGD
        a, b, rx, ry = head
        # Explicit dark-hair seeds prevent the background model erasing heads.
        cv2.ellipse(mask, (a, b), (rx, ry), 0, 0, 360, cv2.GC_FGD, -1)
        cv2.setRNGSeed(1)
        cv2.grabCut(crop, mask, None, np.zeros((1, 65)),
                    np.zeros((1, 65)), 8, cv2.GC_INIT_WITH_MASK)
        alpha = np.where((mask == 1) | (mask == 3), 255, 0).astype('uint8')
        _, labels, stats, _ = cv2.connectedComponentsWithStats(alpha)
        alpha[labels != 1 + np.argmax(stats[1:, cv2.CC_STAT_AREA])] = 0
        rgba = Image.fromarray(np.dstack((crop, alpha)))
        bounds = rgba.getbbox()
        rgba = rgba.crop(bounds)
        # Fixed canvas and common sole baseline; no per-frame height scaling.
        atlas.alpha_composite(rgba, (i*96 + (96-rgba.width)//2, 94-rgba.height))
        frames.append({'rect': [i*96, 0, 96, 96], 'origin': [48, 94],
                       'source_rect': [x, y, w, h], 'mask_bounds': list(bounds)})
    atlas.save(ROOT / 'assets/characters/henrique-gallery-dodge.png')
    manifest_path.write_text(json.dumps({
        'source': source.name, 'source_sha256': digest,
        'texture': 'henrique-gallery-dodge.png', 'duration': 0.16,
        'scale': 0.96, 'frames': frames,
    }, indent=2) + '\n')


if __name__ == '__main__':
    main()
