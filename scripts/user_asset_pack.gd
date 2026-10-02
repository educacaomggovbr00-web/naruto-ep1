extends RefCounted

# Mobile-safe direct PNG loader.
# The user image pack is kept as normal files under assets/runtime/.
# No atlas, Base64 reconstruction, gzip decoding or runtime HTTP downloads.
const RUNTIME_ROOT: String = "res://assets/runtime"
const MANIFEST_PATH: String = "res://assets/runtime/manifest.json"

var manifest: Dictionary = {}
var texture_cache: Dictionary = {}

func _init() -> void:
	if FileAccess.file_exists(MANIFEST_PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
		if parsed is Dictionary:
			manifest = parsed as Dictionary

func runtime_root() -> String:
	return RUNTIME_ROOT

func _safe_path(key: String) -> String:
	if key.is_empty() or key.contains(".."):
		return ""
	return "%s/%s" % [RUNTIME_ROOT, key.trim_prefix("/")]

func has_asset(key: String) -> bool:
	var path: String = _safe_path(key)
	return not path.is_empty() and ResourceLoader.exists(path)

func texture(key: String) -> Texture2D:
	if texture_cache.has(key):
		return texture_cache[key] as Texture2D

	var path: String = _safe_path(key)
	if path.is_empty() or not ResourceLoader.exists(path):
		return null

	var resource: Resource = ResourceLoader.load(path)
	if resource is Texture2D:
		var result: Texture2D = resource as Texture2D
		texture_cache[key] = result
		return result
	return null

func action_meta(group: String, name: String) -> Dictionary:
	var group_data: Variant = manifest.get(group, {})
	if not group_data is Dictionary:
		return {}
	var data: Variant = (group_data as Dictionary).get(name, {})
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
