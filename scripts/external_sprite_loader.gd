extends Node

var textures: Dictionary = {}
var urls: Dictionary = {}
var queue: Array[String] = []
var current_key := ""
var request: HTTPRequest
var cache_dir := "user://external_sprites"

func _ready() -> void:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://assets/external/naruto_fan_sources.json"))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	urls = parsed.get("files", {})
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(cache_dir))
	for key in urls.keys():
		var cache_path := cache_dir + "/" + String(key) + ".png"
		if FileAccess.file_exists(cache_path):
			var image := Image.load_from_file(cache_path)
			if not image.is_empty():
				textures[key] = ImageTexture.create_from_image(image)
		else:
			queue.append(String(key))
	request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_request_completed)
	_fetch_next()

func _fetch_next() -> void:
	if queue.is_empty():
		current_key = ""
		return
	current_key = queue.pop_front()
	var url: String = String(urls.get(current_key, ""))
	if url.is_empty():
		_fetch_next()
		return
	var error := request.request(url)
	if error != OK:
		_fetch_next()

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300 and not body.is_empty():
		var image := Image.new()
		if image.load_png_from_buffer(body) == OK:
			textures[current_key] = ImageTexture.create_from_image(image)
			var cache_path := cache_dir + "/" + current_key + ".png"
			image.save_png(cache_path)
	_fetch_next()

func has_texture(key: String) -> bool:
	return textures.has(key)

func get_texture(key: String) -> Texture2D:
	return textures.get(key, null)

func naruto_texture(action: String, clock: float) -> Texture2D:
	if action == "idle":
		var key := "idle_%d" % (1 + int(clock * 2.0) % 2)
		return get_texture(key)
	var walk_key := "walk_%d" % (1 + int(clock * 8.0) % 4)
	return get_texture(walk_key)
