# Runtime assets

The game now uses separate PNG files directly from this folder.

Expected folders:
- `overworld/`
- `henrique_actions/`
- `naruto_actions/`
- `battle/`
- `characters/`
- `locations/`
- `stages/`
- `world/`

`manifest.json` stores only animation cell sizes/FPS. It does not contain image pixels and it does not point to a giant atlas.

Runtime rules:
- direct normal PNG loading through Godot;
- nearest-neighbor filtering for pixel art;
- no runtime HTTP downloads;
- no gzip/Base64/JSON pixel reconstruction;
- no loading the large boards under `assets/references/`;
- bundled SVG/MUGEN art stays as a fallback when a PNG is absent.
