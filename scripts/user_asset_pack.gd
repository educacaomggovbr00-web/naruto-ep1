extends RefCounted

# Mobile-safe runtime asset loader.
# Gameplay never loads the large source boards from assets/references.
const RUNTIME_ROOT: String = "res://assets/runtime"

var texture_cache: Dictionary = {}

func _safe_path(key: String) -> String:
	if key.is_empty() or key.contains(".."):
		return ""
	return "%s/%s" % [RUNTIME_ROOT, key.trim_prefix("/")]

func runtime_root() -> String:
	return RUNTIME_ROOT

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

func overworld(name: String) -> Texture2D:
	return texture("overworld/%s.png" % name)

func battle(name: String) -> Texture2D:
	return texture("battle/%s.png" % name)

func naruto_action(name: String) -> Texture2D:
	return texture("naruto_actions/%s.png" % name)

func world(name: String) -> Texture2D:
	return texture("world/%s.png" % name)

func stage_texture(name: String) -> Texture2D:
	return texture("stages/%s.png" % name)

func character_panel(name: String) -> Texture2D:
	return texture("characters/%s.png" % name)
