"""Extract the user's fire effect without repainting or replacing its RGB."""
import hashlib
import json
import sys
from pathlib import Path
import numpy as np
from PIL import Image
from import_attached_sheets import cut

source=Path(sys.argv[1])
assert hashlib.sha256(source.read_bytes()).hexdigest()=='90b6eade8808491223326c342845afc70eaf5a232e362d5445f5f14a48bd1f26'
rgb=np.array(Image.open(source).convert('RGB'))
rect=[1027,679,92,76]
sprite,box=cut(rgb,rect)
# The effect is luminous; remove the navy sheet still enclosed between flames.
# Only alpha changes. Bright core and orange/red source colors remain intact.
rgba=np.array(sprite)
r,g,b=[rgba[:,:,i].astype(float) for i in range(3)]
coverage=np.clip((r-np.maximum(b*1.3,35))/45,0,1)
rgba[:,:,3]=(rgba[:,:,3]*coverage).astype('uint8')
assert np.array_equal(rgba[:,:,:3],np.array(sprite)[:,:,:3])
sprite=Image.fromarray(rgba)
root=Path(__file__).resolve().parents[1]/'assets/characters'
sprite.save(root/'katon-fire.png')
(root/'katon-fire.json').write_text(json.dumps({'source':source.name,'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'source_rect':rect,'mask_bounds':list(box)},indent=2)+'\n')
