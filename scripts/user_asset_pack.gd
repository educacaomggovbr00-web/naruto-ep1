extends RefCounted

# Mobile-safe atlas loader.
# The game loads one normal PNG imported by Godot and exposes small AtlasTexture regions.
const RUNTIME_ROOT: String = "res://assets/runtime"
const MANIFEST_PATH: String = "res://assets/runtime/manifest.json"
const ATLAS_PATH: String = "res://assets/runtime/runtime_full_atlas.png"

var manifest: Dictionary = {}
var texture_cache: Dictionary = {}
var atlas_texture: Texture2D

func _init() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	if parsed is Dictionary:
		manifest = parsed as Dictionary

func runtime_root() -> String:
	return RUNTIME_ROOT

func atlas_path() -> String:
	return ATLAS_PATH

func _safe_path(key: String) -> String:
	if key.is_empty() or key.contains(".."):
		return ""
	return "%s/%s" % [RUNTIME_ROOT, key.trim_prefix("/")]

func _ensure_atlas() -> Texture2D:
	if atlas_texture != null:
		return atlas_texture
	if not ResourceLoader.exists(ATLAS_PATH):
		return null
	var resource: Resource = ResourceLoader.load(ATLAS_PATH)
	if resource is Texture2D:
		atlas_texture = resource as Texture2D
	return atlas_texture

func has_asset(key: String) -> bool:
	var path: String = _safe_path(key)
	if not path.is_empty() and ResourceLoader.exists(path):
		return true
	var assets: Dictionary = manifest.get("assets", {})
	return assets.has(key)

func texture(key: String) -> Texture2D:
	if texture_cache.has(key):
		return texture_cache[key] as Texture2D

	var path: String = _safe_path(key)
	if not path.is_empty() and ResourceLoader.exists(path):
		var direct_resource: Resource = ResourceLoader.load(path)
		if direct_resource is Texture2D:
			var direct_texture: Texture2D = direct_resource as Texture2D
			texture_cache[key] = direct_texture
			return direct_texture

	var assets: Dictionary = manifest.get("assets", {})
	if not assets.has(key):
		return null
	var atlas: Texture2D = _ensure_atlas()
	if atlas == null:
		return null
	var data: Dictionary = assets[key]
	var region_texture: AtlasTexture = AtlasTexture.new()
	region_texture.atlas = atlas
	region_texture.region = Rect2(
		float(data.get("x", 0)),
		float(data.get("y", 0)),
		float(data.get("w", 1)),
		float(data.get("h", 1))
	)
	texture_cache[key] = region_texture
	return region_texture

func action_meta(group: String, name: String) -> Dictionary:
	var group_data: Dictionary = manifest.get(group, {})
	var data: Variant = group_data.get(name, {})
	return data as Dictionary if data is Dictionary else {}

func overworld_meta() -> Dictionary:
	var data: Variant = manifest.get("overworld", {})
	return data as Dictionary if data is Dictionary else {}

func battle_meta() -> Dictionary:
	var data: Variant = manifest.get("battle", {})
	return data as Dictionary if data is Dictionary else {}

func overworld(name: String) -> Texture2D:
	return texture("overworld/%s.png" % name)

func battle(name: String) -> Texture2D:
	return texture("battle/%s.png" % name)

func naruto_action(name: String) -> Texture2D:
	return texture("naruto_actions/%s.png" % name)

func henrique_action(name: String) -> Texture2D:
	return texture("henrique_actions/%s.png" % name)

func location(name: String) -> Texture2D:
	return texture("locations/%s.png" % name)

func world(name: String) -> Texture2D:
	return texture("world/%s.png" % name)

func stage_texture(name: String) -> Texture2D:
	return texture("stages/%s.png" % name)

func character_panel(name: String) -> Texture2D:
	return texture("characters/%s.png" % name)
