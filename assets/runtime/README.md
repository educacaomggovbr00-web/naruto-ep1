# Runtime assets

This folder contains the mobile-safe final visual pack used by the game.

- `runtime_full_atlas.png`: one transparent atlas with overworld sprites, action strips, portraits, stages and world panels.
- `manifest.json`: regions and animation metadata used to expose every sprite as a lightweight AtlasTexture.

The original large boards remain in `assets/references/` only as source/reference material and are ignored by Godot.

Runtime rules:
- no HTTP downloads;
- no gzip/base64 pixel reconstruction;
- no decoding of the large reference boards during gameplay;
- nearest-neighbor filtering for pixel art;
- SVG/MUGEN assets remain only as fallback if a region is missing.
