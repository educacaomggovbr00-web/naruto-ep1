extends RefCounted

const PACK_PATH := "res://assets/user_pack/user_assets.json.gz"

var entries: Dictionary = {}
var texture_cache: Dictionary = {}

func _init() -> void:
	var compressed: PackedByteArray = FileAccess.get_file_as_bytes(PACK_PATH)
	if compressed.is_empty():
		push_warning("User asset pack is missing or empty.")
		return
	var decoded: PackedByteArray = compressed.decompress_dynamic(8 * 1024 * 1024, FileAccess.COMPRESSION_GZIP)
	if decoded.is_empty():
		push_warning("Could not decompress user asset pack.")
		return
	var parsed = JSON.parse_string(decoded.get_string_from_utf8())
	if typeof(parsed) == TYPE_DICTIONARY:
		entries = parsed

func has_asset(key: String) -> bool:
	return entries.has(key)

func texture(key: String) -> Texture2D:
	if texture_cache.has(key):
		return texture_cache[key]
	if not entries.has(key):
		return null
	var entry: Dictionary = entries[key]
	var width: int = int(entry.get("w", 0))
	var height: int = int(entry.get("h", 0))
	var palette: Array = entry.get("p", [])
	var runs: Array = entry.get("r", [])
	if width <= 0 or height <= 0 or palette.is_empty() or runs.is_empty():
		return null
	var bytes := PackedByteArray()
	bytes.resize(width * height * 4)
	var pixel_index := 0
	for i in range(0, runs.size(), 2):
		var count: int = int(runs[i])
		var palette_index: int = int(runs[i + 1])
		if palette_index < 0 or palette_index >= palette.size():
			pixel_index += count
			continue
		var color_data: Array = palette[palette_index]
		var rr: int = int(color_data[0])
		var gg: int = int(color_data[1])
		var bb: int = int(color_data[2])
		var aa: int = int(color_data[3])
		for _n in range(count):
			if pixel_index >= width * height:
				break
			var byte_index: int = pixel_index * 4
			bytes[byte_index] = rr
			bytes[byte_index + 1] = gg
			bytes[byte_index + 2] = bb
			bytes[byte_index + 3] = aa
			pixel_index += 1
	var image := Image.create_from_data(width, height, false, Image.FORMAT_RGBA8, bytes)
	var result := ImageTexture.create_from_image(image)
	texture_cache[key] = result
	return result

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
