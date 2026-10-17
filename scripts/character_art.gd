extends RefCounted

const PALETTE = preload("res://scripts/ui_palette.gd")
var name_style:StyleBoxFlat=PALETTE.name_box()

const COMPACT_HENRIQUE = preload("res://assets/art/henrique.svg")
const HENRIQUE_SCALE := 0.32
# Keep the reference appearance on every platform. Compact art is opt-in.
var compact_mode: bool = OS.get_environment("NARUTO_LOW_MEMORY") == "1"
var henrique_texture: Texture2D = null
var henrique_frames: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/henrique-frames.json"))["frames"]
var mugen_actions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/mugen/naruto/animations.json"))
var texture_cache := {}
var dodge_manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/gallery-dodge.json"))
var dodge_texture: Texture2D = null
var naruto_gallery: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/naruto-gallery.json"))
var naruto_gallery_texture: Texture2D = null
var attached_cast: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/attached-cast.json"))
var attached_player: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/attached-henrique.json"))
var cast_texture: Texture2D = null
var player_texture: Texture2D = null

func _init() -> void:
	# Use the original detailed atlas by default, including on Android.
	# Naruto MUGEN frames remain lazy-loaded.
	if not compact_mode:
		henrique_texture = load("res://assets/characters/henrique-detailed.png") as Texture2D
		dodge_texture = load("res://assets/characters/henrique-gallery-dodge.png") as Texture2D
		player_texture = load("res://assets/characters/attached-henrique.png") as Texture2D

func get_cast_texture() -> Texture2D:
	if cast_texture == null:
		cast_texture = load("res://assets/characters/attached-cast.png") as Texture2D
	return cast_texture

func attached_action(host: Node2D) -> String:
	if host.dash_time > 0 and host.lines.is_empty(): return "dodge"
	if host.attack_flash > 0: return "katon" if host.effect_kind == "katon" else "kunai"
	if host.movement != Vector2.ZERO and host.lines.is_empty(): return "run" if host.sprinting else "walk"
	return "idle"

func attached_frame(host: Node2D, action: String) -> Dictionary:
	var frames: Array = attached_player["actions"][action]
	var index := 0
	if action in ["dodge", "kunai", "katon"]:
		var duration := 0.16 if action == "dodge" else 0.5 if action == "katon" else 0.2
		var remaining: float = host.dash_time if action == "dodge" else host.attack_flash
		index = int(clampf(1.0 - remaining / duration, 0, 0.999) * frames.size())
	else:
		index = (int(host.gait_distance/(18.0 if action=="run" else 30.0)) if action in ["walk","run"] else int(host.visual_clock*float(attached_player["fps"][action]))) % frames.size()
	return frames[index]

func draw_attached_player(host: Node2D) -> void:
	var frame := attached_frame(host, attached_action(host))
	var rect: Array = frame["rect"]
	var origin: Array = frame["origin"]
	var factor := float(attached_player["scale"])
	var mirror: bool = (host.dash_direction.x if host.dash_time > 0 else host.facing.x) < 0
	shadow(host, host.player)
	host.draw_set_transform(host.player + Vector2(0, 14), 0, Vector2(-1 if mirror else 1, 1))
	host.draw_texture_rect_region(player_texture,
		Rect2(-Vector2(origin[0],origin[1])*factor,Vector2(rect[2],rect[3])*factor),
		Rect2(rect[0],rect[1],rect[2],rect[3]),Color("b7c1d8") if host.stage >= 3 and host.room == "outside" else Color.WHITE)
	host.draw_set_transform(Vector2.ZERO)

func draw_cast_actor(host: Node2D, name_text: String, at: Vector2, moving: bool = false, night: bool = false) -> void:
	var actor: Dictionary = attached_cast["actors"][name_text]
	var frames: Array = actor["frames"]
	# These source groups are labeled four directions, not an idle gait. Keep
	# the reviewed frontal pose instead of rotating standing NPCs every tick.
	var frame: Dictionary = frames[0]
	var rect: Array = frame["rect"]
	var origin: Array = frame["origin"]
	var factor := float(actor["scale"])
	shadow(host, at)
	var breathing:=1.0+sin(host.day_cycle.elapsed*2.0+float(name_text.hash()%17))*0.007
	var reaction:float=host.ambient.reaction(name_text)
	var greeting_lean:=sin((1.4-reaction)*TAU*1.5)*minf(reaction,0.4)*0.07 if reaction>0 else 0.0
	var wind_lean:float=sin(host.day_cycle.elapsed*1.35+float(name_text.hash()%17))*host.day_cycle.wind_strength()*0.004 if host.room=="outside" else 0.0
	var bob:=absf(sin(host.day_cycle.elapsed*9.0))*1.2 if moving else 0.0
	host.draw_set_transform(at+Vector2(0,14-bob),greeting_lean+wind_lean+(sin(host.day_cycle.elapsed*9.0)*0.014 if moving else 0.0),Vector2(1,breathing))
	host.draw_texture_rect_region(get_cast_texture(),
		Rect2(-Vector2(origin[0],origin[1])*factor,Vector2(rect[2],rect[3])*factor),
		Rect2(rect[0],rect[1],rect[2],rect[3]),Color("b7c1d8") if night else Color.WHITE)
	host.draw_set_transform(Vector2.ZERO)
	host.ambient.draw_reaction(host,name_text,at)
	PALETTE.name_tag(host,Vector2(at.x,maxf(at.y-90,137.0)),"Terceiro Hokage" if name_text=="Hiruzen" else name_text,name_style)

func gallery_dodge_frame(host: Node2D) -> int:
	var progress := clampf(1.0 - host.dash_time / float(dodge_manifest["duration"]), 0.0, 0.999)
	return int(progress * dodge_manifest["frames"].size())

func shadow(host: Node2D, at: Vector2) -> void:
	host.draw_set_transform(at + Vector2(0, 14), 0, Vector2(1, 0.27))
	for layer in [[23,0.06],[17,0.11],[11,0.20]]:
		host.draw_circle(Vector2.ZERO,layer[0],Color(0.04,0.065,0.08,layer[1]))
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
	if not compact_mode:
		draw_attached_player(host)
		return
	var dodging: bool = host.dash_time > 0 and host.lines.is_empty()
	var mirror: bool = (host.dash_direction.x if dodging else host.facing.x) < 0
	shadow(host, host.player)
	host.draw_set_transform(host.player + Vector2(0, 14), 0, Vector2(-1 if mirror else 1, 1))
	if compact_mode:
		# Optional nine-frame fallback for explicitly requested low-memory runs.
		var direction_row := 2 if absf(host.facing.x) > 0.4 else 1 if host.facing.y < -0.4 else 0
		var step := int(host.visual_clock * (13.0 if host.sprinting else 9.0)) % 3 if host.movement != Vector2.ZERO and host.lines.is_empty() else 0
		var region := Rect2((direction_row * 3 + step) * 24, 0, 24, 28)
		host.draw_texture_rect_region(COMPACT_HENRIQUE, Rect2(-36, -70, 72, 84), region, Color("b7c1d8") if host.stage >= 3 and host.room == "outside" else Color.WHITE)
	elif dodging:
		var frame: Dictionary = dodge_manifest["frames"][gallery_dodge_frame(host)]
		var bounds: Array = frame["rect"]
		var origin: Array = frame["origin"]
		var factor := float(dodge_manifest["scale"])
		host.draw_texture_rect_region(dodge_texture,
			Rect2(Vector2(-origin[0], -origin[1]) * factor, Vector2(bounds[2], bounds[3]) * factor),
			Rect2(bounds[0], bounds[1], bounds[2], bounds[3]),
			Color("b7c1d8") if host.stage >= 3 and host.room == "outside" else Color.WHITE)
	else:
		var frame: Dictionary = henrique_frames[henrique_frame(host)]
		var bounds: Array = frame["rect"]
		var region := Rect2(bounds[0], bounds[1], bounds[2], bounds[3])
		var size := region.size * HENRIQUE_SCALE
		host.draw_texture_rect_region(henrique_texture, Rect2(Vector2(-size.x / 2, -size.y), size), region, Color("b7c1d8") if host.stage >= 3 and host.room == "outside" else Color.WHITE)
	host.draw_set_transform(Vector2.ZERO)

func get_naruto_gallery_texture() -> Texture2D:
	if naruto_gallery_texture == null:
		naruto_gallery_texture = load("res://assets/characters/naruto-gallery-idle.png") as Texture2D
	return naruto_gallery_texture

func draw_naruto(host: Node2D, at: Vector2) -> void:
	var frames: Array = naruto_gallery["frames"]
	var frame: Dictionary = frames[int(host.visual_clock * 5) % frames.size()]
	var bounds: Array = frame["rect"]
	var origin: Array = frame["origin"]
	var factor := float(naruto_gallery["scale"])
	shadow(host, at)
	host.draw_texture_rect_region(get_naruto_gallery_texture(),
		Rect2(at + Vector2(0, 14) - Vector2(origin[0], origin[1]) * factor,
			Vector2(bounds[2], bounds[3]) * factor),
		Rect2(bounds[0], bounds[1], bounds[2], bounds[3]))
	PALETTE.name_tag(host,at+Vector2(0,-90),"Naruto",name_style)

# Original AIR playback retained together with every MUGEN source frame.
func draw_naruto_mugen(host: Node2D, at: Vector2) -> void:
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
	# Import/decode a frame once, on demand, instead of every MUGEN action at startup.
	var path: String = "res://assets/mugen/naruto/" + str(selected["file"])
	if not texture_cache.has(path):
		var loaded: Texture2D = load(path) as Texture2D
		if loaded == null:
			return
		texture_cache[path] = loaded
	var texture: Texture2D = texture_cache[path]
	var axis: Array = selected["axis"]
	var offset: Array = selected["offset"]
	var scale_factor := 0.7
	shadow(host, at)
	host.draw_texture_rect(texture, Rect2(at + Vector2((offset[0] - axis[0]) * scale_factor, (offset[1] - axis[1]) * scale_factor + 14), texture.get_size() * scale_factor), false)
	PALETTE.name_tag(host,at+Vector2(0,-90),"Naruto",name_style)

func portrait(host: Node2D) -> void:
	if compact_mode:
		host.draw_texture_rect_region(COMPACT_HENRIQUE, Rect2(18,14,46,52), Rect2(0, 0, 24, 28))
		return
	var crop: Array = attached_player["portrait"]
	host.draw_texture_rect_region(player_texture, Rect2(18,14,46,52),Rect2(crop[0],crop[1],crop[2],crop[3]))
