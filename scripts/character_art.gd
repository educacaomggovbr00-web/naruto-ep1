extends RefCounted

const HENRIQUE_TEXTURE = preload("res://assets/characters/henrique-detailed.png")
const HENRIQUE_SCALE := 0.36
var henrique_frames: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/henrique-frames.json"))["frames"]
var henrique_actions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/henrique-actions.json"))["actions"]
var mugen_actions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/mugen/naruto/animations.json"))
var texture_cache := {}

func _init() -> void:
	for action in mugen_actions.values():
		for frame in action:
			var path: String = "res://assets/mugen/naruto/" + frame["file"]
			if not texture_cache.has(path):
				texture_cache[path] = load(path)
			frame["texture"] = texture_cache[path]

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
	var frame: Dictionary = henrique_frames[henrique_frame(host)]
	var bounds: Array = frame["rect"]
	var region := Rect2(bounds[0], bounds[1], bounds[2], bounds[3])
	var size := region.size * HENRIQUE_SCALE
	var mirror: bool = host.facing.x < 0
	shadow(host, host.player)
	host.draw_set_transform(host.player + Vector2(0, 14), 0, Vector2(-1 if mirror else 1, 1))
	host.draw_texture_rect_region(HENRIQUE_TEXTURE, Rect2(Vector2(-size.x / 2, -size.y), size), region, Color("b7c1d8") if host.stage >= 8 else Color.WHITE)
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
	var selected := select_mugen_frame(action_name, host.visual_clock)
	var texture: Texture2D = selected["texture"]
	var axis: Array = selected["axis"]
	var offset: Array = selected["offset"]
	host.draw_rect(Rect2(at + Vector2(-92, -138), Vector2(184, 158)), Color(0.035, 0.08, 0.11, 0.78))
	host.draw_rect(Rect2(at + Vector2(-92, -138), Vector2(184, 4)), Color("d4a54f"))
	host.draw_string(ThemeDB.fallback_font, at + Vector2(-78, -112), "NARUTO • BATALHA 2D", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("f6e4bc"))
	host.draw_set_transform(at + Vector2(0, 12), 0, Vector2(1, 1))
	host.draw_texture_rect(texture, Rect2(Vector2((offset[0] - axis[0]) * scale_factor, (offset[1] - axis[1]) * scale_factor), texture.get_size() * scale_factor), false)
	host.draw_set_transform(Vector2.ZERO)

func portrait(host: Node2D) -> void:
	var bounds: Array = henrique_frames[0]["rect"]
	host.draw_texture_rect_region(HENRIQUE_TEXTURE, Rect2(16, 10, 44, 54), Rect2(bounds[0] + 10, bounds[1], bounds[2] - 20, 135))
