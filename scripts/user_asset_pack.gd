extends RefCounted

# Stable/mobile mode:
# The compressed chat-image pack is intentionally disabled at runtime.
# It caused an expensive startup path: gzip -> JSON -> RGBA reconstruction -> ImageTexture.
# All callers already have bundled SVG/PNG/MUGEN fallbacks, so returning null is safe.
const PACK_PATH := "res://assets/user_pack/user_assets.json.gz"

func _init() -> void:
	pass

func has_asset(_key: String) -> bool:
	return false

func texture(_key: String) -> Texture2D:
	return null

func overworld(_name: String) -> Texture2D:
	return null

func battle(_name: String) -> Texture2D:
	return null

func naruto_action(_name: String) -> Texture2D:
	return null

func world(_name: String) -> Texture2D:
	return null

func stage_texture(_name: String) -> Texture2D:
	return null

func character_panel(_name: String) -> Texture2D:
	return null
