extends RefCounted

const HENRIQUE_SOURCE = preload("res://assets/characters/file_000000003c88820e930f366203f13d4e.png")
const HENRIQUE_SCALE := 0.82
var henrique_manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/henrique-board-frames.json"))
var henrique_frames: Array = henrique_manifest["frames"]
var henrique_actions: Dictionary = henrique_manifest["actions"]
var henrique_source_image: Image
var henrique_frame_cache := {}
var mugen_actions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/mugen/naruto/animations.json"))
var texture_cache := {}

func _init() -> void:
	henrique_source_image = HENRIQUE_SOURCE.get_image()
	if henrique_source_image.get_format() != Image.FORMAT_RGBA8:
		henrique_source_image.convert(Image.FORMAT_RGBA8)
	for action in mugen_actions.values():
		for frame in action:
			var path: String = "res://assets/mugen/naruto/" + frame["file"]
			if not texture_cache.has(path):
				texture_cache[path] = load(path)
			frame["texture"] = texture_cache[path]

func _color_distance_sq(a: Color, b: Color) -> float:
	var dr := a.r - b.r
	var dg := a.g - b.g
	var db := a.b - b.b
	return dr * dr + dg * dg + db * db

func _henrique_frame_texture(frame_id: int) -> Texture2D:
	if henrique_frame_cache.has(frame_id):
		return henrique_frame_cache[frame_id]
	if frame_id < 0 or frame_id >= henrique_frames.size():
		return null
	var frame_data: Dictionary = henrique_frames[frame_id]
	var b: Array = frame_data["source_box"]
	var rect := Rect2i(int(b[0]), int(b[1]), int(b[2]) - int(b[0]), int(b[3]) - int(b[1]))
	var crop: Image = henrique_source_image.get_region(rect)
	if crop.get_format() != Image.FORMAT_RGBA8:
		crop.convert(Image.FORMAT_RGBA8)
	var w := crop.get_width()
	var h := crop.get_height()
	var background := PackedByteArray()
	background.resize(w * h)
	var queue: Array[Vector2i] = []
	for x in range(w):
		var top_i := x
		if background[top_i] == 0:
			background[top_i] = 1
			queue.append(Vector2i(x, 0))
		var bottom_i := (h - 1) * w + x
		if background[bottom_i] == 0:
			background[bottom_i] = 1
			queue.append(Vector2i(x, h - 1))
	for y in range(h):
		var left_i := y * w
		if background[left_i] == 0:
			background[left_i] = 1
			queue.append(Vector2i(0, y))
		var right_i := y * w + (w - 1)
		if background[right_i] == 0:
			background[right_i] = 1
			queue.append(Vector2i(w - 1, y))
	var threshold := float(henrique_manifest.get("background_flood_step_threshold", 7)) / 255.0
	var threshold_sq := threshold * threshold
	var head := 0
	var dirs := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	while head < queue.size():
		var p: Vector2i = queue[head]
		head += 1
		var current := crop.get_pixel(p.x, p.y)
		for dir in dirs:
			var n: Vector2i = p + dir
			if n.x < 0 or n.y < 0 or n.x >= w or n.y >= h:
				continue
			var ni := n.y * w + n.x
			if background[ni] != 0:
				continue
			var neighbor := crop.get_pixel(n.x, n.y)
			if _color_distance_sq(current, neighbor) <= threshold_sq:
				background[ni] = 1
				queue.append(n)
	var output := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in range(h):
		for x in range(w):
			var color := crop.get_pixel(x, y)
			color.a = 0.0 if background[y * w + x] != 0 else 1.0
			output.set_pixel(x, y, color)
	var texture := ImageTexture.create_from_image(output)
	henrique_frame_cache[frame_id] = texture
	return texture

func shadow(host: Node2D, at: Vector2) -> void:
	host.draw_set_transform(at + Vector2(0, 14), 0, Vector2(1, 0.27))
	host.draw_circle(Vector2.ZERO, 23, Color(0.06, 0.10, 0.14, 0.38))
	host.draw_set_transform(Vector2.ZERO)

func frame_for_action(action_name: String, clock: float) -> int:
	var entry: Dictionary = henrique_actions.get(action_name, henrique_actions["idle"])
	var frames: Array = entry.get("frames", [0])
	if frames.is_empty():
		return 0
	var fps := float(entry.get("fps", 8.0))
	return int(frames[int(clock * fps) % frames.size()])

func current_henrique_action(host: Node2D) -> String:
	if host.action_state != "":
		return host.action_state
	if host.attack_flash > 0:
		return "katon_fireball" if host.effect_kind == "katon" else "kunai"
	if host.movement != Vector2.ZERO and host.lines.is_empty():
		return "run" if host.sprinting else "walk"
	if host.facing.y < -0.4:
		return "idle_back"
	return "idle"

func henrique_frame(host: Node2D) -> int:
	return frame_for_action(current_henrique_action(host), host.visual_clock)

func draw_henrique(host: Node2D) -> void:
	var frame_id := henrique_frame(host)
	var texture := _henrique_frame_texture(frame_id)
	if texture == null:
		return
	var size := texture.get_size() * HENRIQUE_SCALE
	var mirror: bool = host.facing.x < 0
	shadow(host, host.player)
	host.draw_set_transform(host.player + Vector2(0, 14), 0, Vector2(-1 if mirror else 1, 1))
	host.draw_texture_rect(texture, Rect2(Vector2(-size.x / 2, -size.y), size), false, Color("b7c1d8") if host.stage >= 8 and host.stage <= 12 else Color.WHITE)
	host.draw_set_transform(Vector2.ZERO)
	host.draw_string(ThemeDB.fallback_font, host.player + Vector2(-28, -90), "Henrique", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("f6e9c8"))

func select_mugen_frame(action_name: String, clock: float) -> Dictionary:
	var resolved := action_name if mugen_actions.has(action_name) else "idle"
	var frames: Array = mugen_actions[resolved]
	var cycle := 0
	for frame in frames:
		cycle += int(frame["ticks"])
	var tick := int(clock * 60) % maxi(cycle, 1)
	var selected: Dictionary = frames[0]
	for frame in frames:
		selected = frame
		tick -= int(frame["ticks"])
		if tick < 0:
			break
	return selected

func draw_naruto_mugen(host: Node2D, at: Vector2, action_name: String = "run", scale_factor: float = 0.52) -> void:
	host.draw_rect(Rect2(at + Vector2(-92, -138), Vector2(184, 158)), Color(0.035, 0.08, 0.11, 0.78))
	host.draw_rect(Rect2(at + Vector2(-92, -138), Vector2(184, 4)), Color("d4a54f"))
	host.draw_string(ThemeDB.fallback_font, at + Vector2(-78, -112), "NARUTO • BATALHA 2D", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("f6e4bc"))

	# Prefer the researched internet fan-sprite pack when it has finished loading.
	if host.external_sprites != null:
		var external_action := "idle" if action_name == "idle" else "walk"
		var external_texture: Texture2D = host.external_sprites.naruto_texture(external_action, host.visual_clock)
		if external_texture != null:
			var max_size := Vector2(118, 112)
			var tex_size := external_texture.get_size()
			var fit_scale: float = min(max_size.x / tex_size.x, max_size.y / tex_size.y)
			var draw_size := tex_size * fit_scale
			host.draw_texture_rect(external_texture, Rect2(at + Vector2(-draw_size.x / 2.0, -draw_size.y + 8), draw_size), false)
			host.draw_string(ThemeDB.fallback_font, at + Vector2(-78, 10), "FAN SPRITE • MIT", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("9ed4c9"))
			return

	# Offline fallback: bundled classic Naruto MUGEN frames already in the project.
	var selected := select_mugen_frame(action_name, host.visual_clock)
	var texture: Texture2D = selected["texture"]
	var axis: Array = selected["axis"]
	var offset: Array = selected["offset"]
	host.draw_set_transform(at + Vector2(0, 12), 0, Vector2(1, 1))
	host.draw_texture_rect(texture, Rect2(Vector2((offset[0] - axis[0]) * scale_factor, (offset[1] - axis[1]) * scale_factor), texture.get_size() * scale_factor), false)
	host.draw_set_transform(Vector2.ZERO)

func portrait(host: Node2D) -> void:
	# Portrait also comes from the exact user-provided PNG, not the old generated atlas.
	host.draw_texture_rect_region(HENRIQUE_SOURCE, Rect2(16, 10, 44, 54), Rect2(8, 6, 190, 235))
