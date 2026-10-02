extends RefCounted

# Mobile-safe rendering from separate user-provided PNG sprite strips.
# Large source boards under assets/references are never decoded during gameplay.
var user_assets = preload("res://scripts/user_asset_pack.gd").new()

const HENRIQUE_FALLBACK: Texture2D = preload("res://assets/art/henrique.svg")

# Keep the old mapping only as story/action metadata; visuals come from PNGs under assets/runtime/.
var henrique_manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/henrique-board-frames.json"))
var henrique_frames: Array = henrique_manifest["frames"]
var henrique_actions: Dictionary = henrique_manifest["actions"]
var mugen_actions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/mugen/naruto/animations.json"))
var texture_cache: Dictionary = {}

func shadow(host: Node2D, at: Vector2) -> void:
	host.draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(1, 0.27))
	host.draw_circle(Vector2.ZERO, 23, Color(0.06, 0.10, 0.14, 0.38))
	host.draw_set_transform(Vector2.ZERO)

func frame_for_action(action_name: String, clock: float) -> int:
	var entry: Dictionary = henrique_actions.get(action_name, henrique_actions["idle"])
	var frames: Array = entry.get("frames", [0])
	if frames.is_empty():
		return 0
	var fps: float = float(entry.get("fps", 8.0))
	return int(frames[int(clock * fps) % frames.size()])

func current_henrique_action(host: Node2D) -> String:
	if String(host.action_state) != "":
		return String(host.action_state)
	if float(host.attack_flash) > 0.0:
		return "katon_fireball" if String(host.effect_kind) == "katon" else "kunai_attack"
	if host.movement != Vector2.ZERO and host.lines.is_empty():
		return "run" if bool(host.sprinting) else "walk"
	return "idle"

func henrique_frame(host: Node2D) -> int:
	return frame_for_action(current_henrique_action(host), float(host.visual_clock))

func _draw_strip_frame(
	host: Node2D,
	texture: Texture2D,
	meta: Dictionary,
	at: Vector2,
	target_max: Vector2,
	mirror: bool,
	tint: Color
) -> bool:
	if texture == null or meta.is_empty():
		return false
	var frames: int = maxi(int(meta.get("frames", 1)), 1)
	var cell_w: float = float(meta.get("cell_w", texture.get_width()))
	var cell_h: float = float(meta.get("cell_h", texture.get_height()))
	var fps: float = float(meta.get("fps", 10.0))
	if cell_w <= 0.0 or cell_h <= 0.0:
		return false
	var frame_index: int = int(float(host.visual_clock) * fps) % frames
	var source: Rect2 = Rect2(float(frame_index) * cell_w, 0.0, cell_w, cell_h)
	var fit_scale: float = min(target_max.x / cell_w, target_max.y / cell_h)
	var draw_size: Vector2 = Vector2(cell_w, cell_h) * fit_scale
	host.draw_set_transform(at + Vector2(0, 12), 0.0, Vector2(-1.0 if mirror else 1.0, 1.0))
	host.draw_texture_rect_region(
		texture,
		Rect2(Vector2(-draw_size.x / 2.0, -draw_size.y), draw_size),
		source,
		tint
	)
	host.draw_set_transform(Vector2.ZERO)
	return true

func _draw_henrique_runtime_overworld(host: Node2D) -> bool:
	var texture: Texture2D = user_assets.overworld("henrique")
	if texture == null:
		return false
	var meta: Dictionary = user_assets.overworld_meta()
	var frame_count: int = maxi(int(meta.get("frames", 4)), 1)
	var frame_width: float = float(meta.get("cell_w", float(texture.get_width()) / float(frame_count)))
	var frame_height: float = float(meta.get("cell_h", texture.get_height()))
	if frame_width <= 0.0 or frame_height <= 0.0:
		return false
	var frame_index: int = 0
	if host.facing.y < -0.4:
		frame_index = 1
	elif host.facing.x < -0.4:
		frame_index = 2
	elif host.facing.x > 0.4:
		frame_index = 3
	var source_rect: Rect2 = Rect2(frame_width * float(frame_index), 0.0, frame_width, frame_height)
	var target_height: float = 72.0
	var target_width: float = frame_width * (target_height / frame_height)
	var moving: bool = host.movement != Vector2.ZERO
	var bob: float = -2.0 if moving and int(float(host.visual_clock) * 9.0) % 2 == 1 else 0.0
	var tint: Color = Color("b7c1d8") if int(host.stage) >= 8 and int(host.stage) <= 12 else Color.WHITE
	shadow(host, host.player)
	host.draw_texture_rect_region(
		texture,
		Rect2(host.player + Vector2(-target_width / 2.0, -64.0 + bob), Vector2(target_width, target_height)),
		source_rect,
		tint
	)
	host.draw_string(ThemeDB.fallback_font, host.player + Vector2(-28, -90), "Henrique", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("f6e9c8"))
	return true

func _draw_henrique_runtime_action(host: Node2D) -> bool:
	var action_name: String = current_henrique_action(host)
	var texture: Texture2D = user_assets.henrique_action(action_name)
	var meta: Dictionary = user_assets.action_meta("henrique_actions", action_name)
	if texture == null or meta.is_empty():
		return false
	var tint: Color = Color("b7c1d8") if int(host.stage) >= 8 and int(host.stage) <= 12 else Color.WHITE
	shadow(host, host.player)
	if not _draw_strip_frame(host, texture, meta, host.player, Vector2(124, 100), host.facing.x < 0.0, tint):
		return false
	host.draw_string(ThemeDB.fallback_font, host.player + Vector2(-28, -90), "Henrique", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("f6e9c8"))
	return true

func _draw_henrique_fallback(host: Node2D) -> void:
	var row: int = 0
	if host.facing.y < -0.4:
		row = 1
	elif absf(host.facing.x) > 0.4:
		row = 2
	var moving: bool = host.movement != Vector2.ZERO and host.lines.is_empty()
	var frame: int = int(float(host.visual_clock) * 9.0) % 3 if moving else 0
	var mirror: bool = row == 2 and host.facing.x < 0.0
	var bob: float = -2.0 if moving and frame == 1 else 0.0
	var tint: Color = Color("b7c1d8") if int(host.stage) >= 8 and int(host.stage) <= 12 else Color.WHITE
	shadow(host, host.player)
	host.draw_set_transform(host.player + Vector2(0, bob), 0.0, Vector2(-1.0 if mirror else 1.0, 1.0))
	host.draw_texture_rect_region(
		HENRIQUE_FALLBACK,
		Rect2(-30, -64, 60, 70),
		Rect2(float((row * 3 + frame) * 24), 0.0, 24.0, 28.0),
		tint
	)
	host.draw_set_transform(Vector2.ZERO)
	host.draw_string(ThemeDB.fallback_font, host.player + Vector2(-28, -90), "Henrique", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("f6e9c8"))

func draw_henrique(host: Node2D) -> void:
	if String(host.action_state) == "" and float(host.attack_flash) <= 0.0:
		if _draw_henrique_runtime_overworld(host):
			return
	if _draw_henrique_runtime_action(host):
		return
	_draw_henrique_fallback(host)

func select_mugen_frame(action_name: String, clock: float) -> Dictionary:
	var resolved: String = action_name if mugen_actions.has(action_name) else "idle"
	var frames: Array = mugen_actions.get(resolved, [])
	if frames.is_empty():
		return {}
	var cycle: int = 0
	for frame in frames:
		cycle += int(frame["ticks"])
	var tick: int = int(clock * 60.0) % maxi(cycle, 1)
	var selected: Dictionary = frames[0]
	for frame in frames:
		selected = frame
		tick -= int(frame["ticks"])
		if tick < 0:
			break
	return selected

func _mugen_texture(frame: Dictionary) -> Texture2D:
	if frame.is_empty():
		return null
	var file_name: String = String(frame.get("file", ""))
	if file_name.is_empty():
		return null
	var path: String = "res://assets/mugen/naruto/" + file_name
	if texture_cache.has(path):
		return texture_cache[path] as Texture2D
	var resource: Resource = ResourceLoader.load(path)
	if resource is Texture2D:
		var result: Texture2D = resource as Texture2D
		texture_cache[path] = result
		return result
	return null

func _draw_user_naruto_action(host: Node2D, at: Vector2, action_name: String) -> bool:
	var resolved: String = action_name
	if resolved == "attack":
		resolved = "punch_combo"
	elif resolved == "clone":
		resolved = "shadow_clone"
	elif resolved == "rasengan":
		resolved = "rasengan_attack"
	var texture: Texture2D = user_assets.naruto_action(resolved)
	var meta: Dictionary = user_assets.action_meta("naruto_actions", resolved)
	if texture == null or meta.is_empty():
		return false
	return _draw_strip_frame(host, texture, meta, at, Vector2(132, 112), false, Color.WHITE)

func draw_naruto_mugen(host: Node2D, at: Vector2, action_name: String = "run", scale_factor: float = 0.52) -> void:
	host.draw_rect(Rect2(at + Vector2(-92, -138), Vector2(184, 158)), Color(0.035, 0.08, 0.11, 0.78))
	host.draw_rect(Rect2(at + Vector2(-92, -138), Vector2(184, 4)), Color("d4a54f"))
	host.draw_string(ThemeDB.fallback_font, at + Vector2(-78, -112), "NARUTO • BATALHA 2D", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("f6e4bc"))

	if _draw_user_naruto_action(host, at, action_name):
		return

	if host.external_sprites != null:
		var external_action: String = "idle" if action_name == "idle" else "walk"
		var external_texture: Texture2D = host.external_sprites.naruto_texture(external_action, float(host.visual_clock))
		if external_texture != null:
			var max_size: Vector2 = Vector2(118, 112)
			var tex_size: Vector2 = external_texture.get_size()
			var fit_scale: float = min(max_size.x / tex_size.x, max_size.y / tex_size.y)
			var draw_size: Vector2 = tex_size * fit_scale
			host.draw_texture_rect(external_texture, Rect2(at + Vector2(-draw_size.x / 2.0, -draw_size.y + 8.0), draw_size), false)
			return

	var selected: Dictionary = select_mugen_frame(action_name, float(host.visual_clock))
	var texture: Texture2D = _mugen_texture(selected)
	if texture == null:
		return
	var axis: Array = selected.get("axis", [0, 0])
	var offset: Array = selected.get("offset", [0, 0])
	host.draw_set_transform(at + Vector2(0, 12), 0.0, Vector2.ONE)
	host.draw_texture_rect(
		texture,
		Rect2(
			Vector2((float(offset[0]) - float(axis[0])) * scale_factor, (float(offset[1]) - float(axis[1])) * scale_factor),
			texture.get_size() * scale_factor
		),
		false
	)
	host.draw_set_transform(Vector2.ZERO)

func portrait(host: Node2D) -> void:
	var runtime_portrait: Texture2D = user_assets.character_panel("henrique")
	if runtime_portrait != null:
		host.draw_texture_rect(runtime_portrait, Rect2(8, 6, 44, 54), false)
		return
	host.draw_texture_rect_region(HENRIQUE_FALLBACK, Rect2(8, 6, 44, 54), Rect2(0, 0, 24, 28))
