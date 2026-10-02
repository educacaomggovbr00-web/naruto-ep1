# Runtime assets

This folder is reserved for lightweight assets that the game may load during play.

Expected layout:

- overworld/<character>.png
- battle/<character>.png
- naruto_actions/<action>.png
- henrique_actions/<action>.png
- characters/<character>.png
- stages/<stage>.png
- world/<asset>.png

Rules:
- large source boards stay in `assets/references/` and are ignored by Godot;
- no HTTP downloads during gameplay;
- no gzip/base64/JSON pixel reconstruction during gameplay;
- pixel art uses nearest filtering;
- when a runtime PNG is absent, the game falls back to the bundled lightweight SVG/MUGEN assets.

This directory is the only destination for final cropped runtime PNGs.
