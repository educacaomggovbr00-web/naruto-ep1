"""Copy original gallery pixels, including alpha; no drawing or recoloring.

Usage: python3 tools/import_gallery_naruto.py /path/to/original-sheet.png
Requires Pillow only, for development; no runtime dependency.
"""
import hashlib
import json
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
RECTS = [(14, 13, 61, 133), (87, 13, 66, 133),
         (158, 13, 61, 133), (226, 13, 64, 133)]
SOLES = [143, 142, 143, 142]


def main():
    source = Path(sys.argv[1])
    digest = hashlib.sha256(source.read_bytes()).hexdigest()
    manifest_path = ROOT / 'assets/characters/naruto-gallery.json'
    if manifest_path.exists():
        expected = json.loads(manifest_path.read_text())['source_sha256']
        if digest != expected:
            raise SystemExit('Wrong source image: expected SHA256 ' + expected)
    image = Image.open(source).convert('RGBA')
    assert image.size == (1536, 1024)
    atlas = Image.new('RGBA', (384, 160))
    frames = []
    for i, ((x, y, w, h), sole) in enumerate(zip(RECTS, SOLES)):
        frame = image.crop((x, y, x+w, y+h))
        dx, dy = i*96 + (96-w)//2, 140 - (sole-y)
        # Paste without an alpha mask preserves even partial alpha verbatim.
        atlas.paste(frame, (dx, dy))
        assert atlas.crop((dx, dy, dx+w, dy+h)).tobytes() == frame.tobytes()
        frames.append({'rect': [i*96, 0, 96, 160], 'origin': [48, 140],
                       'source_rect': [x, y, w, h], 'ticks': 12,
                       'rgba_sha256': hashlib.sha256(frame.tobytes()).hexdigest(),
                       'copied_region': [dx, dy, w, h]})
    atlas.save(ROOT / 'assets/characters/naruto-gallery-idle.png')
    manifest_path.write_text(json.dumps({
        'source': source.name, 'source_sha256': digest,
        'texture': 'naruto-gallery-idle.png', 'scale': 0.72,
        'frames': frames,
    }, indent=2) + '\n')


if __name__ == '__main__':
    main()
