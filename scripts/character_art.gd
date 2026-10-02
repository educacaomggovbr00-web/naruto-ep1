extends RefCounted

var user_assets = preload("res://scripts/user_asset_pack.gd").new()

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
	var dirs: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
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

func _naruto_user_rects(action_name: String) -> Array:
	var frames: Dictionary = {
		"idle":[[31,0,39,98],[98,0,39,98],[167,0,39,98],[232,0,38,98]],
		"walk":[[1,0,25,98],[78,0,44,98],[147,0,42,98],[209,0,47,98],[280,0,51,98]],
		"run":[[1,0,49,98],[107,0,76,98],[198,0,70,98],[282,0,65,98],[355,0,18,98]],
		"jump":[[30,0,132,123],[179,0,123,123],[319,0,56,123]],
		"fall":[[1,0,44,123],[84,0,54,123],[158,0,29,123],[212,0,60,123],[300,0,24,123]],
		"crouch":[[14,0,44,123],[100,0,150,123],[273,0,20,123]],
		"punch_combo":[[20,0,52,94],[88,0,86,94],[193,0,45,94],[270,0,56,94],[354,0,60,94],[446,0,73,94],[553,0,48,94],[619,0,64,94]],
		"kick":[[4,0,34,94],[83,0,83,94],[184,0,65,94],[280,0,79,94],[384,0,101,94],[501,0,78,94],[603,0,45,94]],
		"kunai":[[20,0,61,75],[127,0,30,75],[215,0,28,75],[295,0,28,75],[391,0,28,75]],
		"shuriken":[[2,0,30,75],[79,0,93,75],[206,0,29,75],[308,0,29,75],[408,0,29,75]],
		"shadow_clone":[[20,0,58,83],[91,0,36,83],[140,0,85,83],[263,0,21,83],[334,0,22,83],[367,0,22,83],[404,0,107,83],[544,0,29,83],[603,0,30,83],[660,0,29,83]],
		"substitution":[[12,0,35,83],[94,0,139,83],[241,0,22,83],[312,0,146,83]],
		"rasengan_charge":[[14,0,199,105],[242,0,308,105],[562,0,15,105],[584,0,20,105]],
		"rasengan_attack":[[1,0,23,105],[36,0,134,105],[180,0,186,105],[434,0,51,105],[515,0,62,105],[593,0,63,105],[676,0,87,105]],
		"hurt":[[13,0,157,87],[182,0,78,87],[279,0,167,87]],
		"down":[[1,0,178,87],[244,0,129,87],[385,0,25,87]],
		"get_up":[[1,0,73,87],[83,0,21,87],[112,0,188,87],[319,0,14,87],[340,0,113,87]]
	}
	return frames.get(action_name, frames["idle"])

func _draw_user_naruto_action(host: Node2D, at: Vector2, action_name: String) -> bool:
	var resolved: String = action_name
	if resolved == "attack":
		resolved = "punch_combo"
	elif resolved == "clone":
		resolved = "shadow_clone"
	elif resolved == "rasengan":
		resolved = "rasengan_attack"
	if not user_assets.has_asset("naruto_actions/%s.png" % resolved):
		resolved = "idle" if action_name == "idle" else "run"
	var texture: Texture2D = user_assets.naruto_action(resolved)
	if texture == null:
		return false
	var rects: Array = _naruto_user_rects(resolved)
	if rects.is_empty():
		return false
	var fps: float = 8.0 if resolved == "idle" else 11.0
	var frame_index: int = int(float(host.visual_clock) * fps) % rects.size()
	var data: Array = rects[frame_index]
	var region := Rect2(float(data[0]), float(data[1]), float(data[2]), float(data[3]))
	var max_size := Vector2(126, 108)
	var scale_value: float = min(max_size.x / region.size.x, max_size.y / region.size.y)
	var draw_size: Vector2 = region.size * scale_value
	host.draw_texture_rect_region(texture, Rect2(at + Vector2(-draw_size.x / 2.0, -draw_size.y + 8.0), draw_size), region)
	return true

func draw_naruto_mugen(host: Node2D, at: Vector2, action_name: String = "run", scale_factor: float = 0.52) -> void:
	host.draw_rect(Rect2(at + Vector2(-92, -138), Vector2(184, 158)), Color(0.035, 0.08, 0.11, 0.78))
	host.draw_rect(Rect2(at + Vector2(-92, -138), Vector2(184, 4)), Color("d4a54f"))
	host.draw_string(ThemeDB.fallback_font, at + Vector2(-78, -112), "NARUTO • BATALHA 2D", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("f6e4bc"))

	# First choice: frames cropped from the exact Naruto sheet supplied by the user.
	if _draw_user_naruto_action(host, at, action_name):
		host.draw_string(ThemeDB.fallback_font, at + Vector2(-78, 10), "SPRITE DA SUA IMAGEM", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("9ed4c9"))
		return

	# Secondary fallback: researched fan-sprite pack when available.
	if host.external_sprites != null:
		var external_action: String = "idle" if action_name == "idle" else "walk"
		var external_texture: Texture2D = host.external_sprites.naruto_texture(external_action, host.visual_clock)
		if external_texture != null:
			var max_size: Vector2 = Vector2(118, 112)
			var tex_size: Vector2 = external_texture.get_size()
			var fit_scale: float = min(max_size.x / tex_size.x, max_size.y / tex_size.y)
			var draw_size: Vector2 = tex_size * fit_scale
			host.draw_texture_rect(external_texture, Rect2(at + Vector2(-draw_size.x / 2.0, -draw_size.y + 8), draw_size), false)
			return

	# Final offline fallback: bundled MUGEN frames already in the project.
	var selected: Dictionary = select_mugen_frame(action_name, host.visual_clock)
	var texture: Texture2D = selected["texture"]
	var axis: Array = selected["axis"]
	var offset: Array = selected["offset"]
	host.draw_set_transform(at + Vector2(0, 12), 0, Vector2(1, 1))
	host.draw_texture_rect(texture, Rect2(Vector2((offset[0] - axis[0]) * scale_factor, (offset[1] - axis[1]) * scale_factor), texture.get_size() * scale_factor), false)
	host.draw_set_transform(Vector2.ZERO)

func portrait(host: Node2D) -> void:
	# Portrait also comes from the exact user-provided PNG, not the old generated atlas.
	host.draw_texture_rect_region(HENRIQUE_SOURCE, Rect2(16, 10, 44, 54), Rect2(8, 6, 190, 235))
