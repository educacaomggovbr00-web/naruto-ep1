# Runtime assets

This folder is reserved for lightweight assets that the game may load during play.

Expected layout:

- overworld/<character>.png
- battle/<character>.png
- naruto_actions/<action>.png
- characters/<character>.png
- stages/<stage>.png
- world/<asset>.png

Large source boards belong in `assets/references/` and are intentionally ignored by Godot.
The game must fall back to bundled lightweight SVG/MUGEN assets when a runtime PNG is absent.
