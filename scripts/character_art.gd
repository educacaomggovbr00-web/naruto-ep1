extends RefCounted

const HENRIQUE_TEXTURE = preload("res://assets/characters/henrique-detailed.png")
const HENRIQUE_SCALE := 0.36
var henrique_frames: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/henrique-frames.json"))["frames"]
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

func henrique_frame(host: Node2D) -> int:
	if host.attack_flash > 0:
		var duration := 0.5 if host.effect_kind == "katon" else 0.2
		var progress: float = clampf(1.0 - host.attack_flash / duration, 0.0, 0.999)
		return (21 if host.effect_kind == "katon" else 18) + int(progress * 3.0)
	if host.movement != Vector2.ZERO and host.lines.is_empty():
		return (12 if host.sprinting else 6) + int(host.visual_clock * (13 if host.sprinting else 9)) % 6
	return (3 if host.facing.y < -0.4 else 0) + int(host.visual_clock * 2) % 3

func draw_henrique(host: Node2D) -> void:
	var frame: Dictionary = henrique_frames[henrique_frame(host)]
	var bounds: Array = frame["rect"]
	var region := Rect2(bounds[0], bounds[1], bounds[2], bounds[3])
	var size := region.size * HENRIQUE_SCALE
	var mirror: bool = host.facing.x < 0
	shadow(host, host.player)
	host.draw_set_transform(host.player + Vector2(0, 14), 0, Vector2(-1 if mirror else 1, 1))
	host.draw_texture_rect_region(HENRIQUE_TEXTURE, Rect2(Vector2(-size.x / 2, -size.y), size), region, Color("b7c1d8") if host.stage >= 3 else Color.WHITE)
	host.draw_set_transform(Vector2.ZERO)
	host.draw_string(ThemeDB.fallback_font, host.player + Vector2(-28, -90), "Henrique", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("f6e9c8"))

func draw_naruto(host: Node2D, at: Vector2) -> void:
	var frames: Array = mugen_actions["idle"]
	var cycle := 0
	for frame in frames:
		cycle += int(frame["ticks"])
	var tick := int(host.visual_clock * 60) % cycle
	var selected: Dictionary = frames[0]
	for frame in frames:
		selected = frame
		tick -= int(frame["ticks"])
		if tick < 0:
			break
	var texture: Texture2D = selected["texture"]
	var axis: Array = selected["axis"]
	var offset: Array = selected["offset"]
	var scale_factor := 0.7
	shadow(host, at)
	host.draw_texture_rect(texture, Rect2(at + Vector2((offset[0] - axis[0]) * scale_factor, (offset[1] - axis[1]) * scale_factor + 14), texture.get_size() * scale_factor), false)
	host.draw_string(ThemeDB.fallback_font, at + Vector2(-23, -90), "Naruto", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("f6e9c8"))

func portrait(host: Node2D) -> void:
	var bounds: Array = henrique_frames[0]["rect"]
	# Region of the original texture; no baked crops or background removal.
	host.draw_texture_rect_region(HENRIQUE_TEXTURE, Rect2(16, 10, 44, 54), Rect2(bounds[0] + 10, bounds[1], bounds[2] - 20, 135))
