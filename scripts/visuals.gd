extends RefCounted

var HENRIQUE: Texture2D = null
var npc_art = preload("res://scripts/npc_art.gd").new()
var character_art = preload("res://scripts/character_art.gd").new()
const IRUKA = preload("res://assets/art/iruka.svg")
const MIZUKI = preload("res://assets/art/mizuki.svg")
const TARGET = preload("res://assets/art/target.svg")
const KUNAI = preload("res://assets/art/kunai.svg")

func _init() -> void:
	# Keep the compatibility reference for desktop checks without forcing mobile to load it.
	HENRIQUE = character_art.henrique_texture

func actor(host: Node2D, at: Vector2, texture: Texture2D, direction: Vector2, moving: bool, clock: float, name_text: String, night: bool) -> void:
	character_art.draw_cast_actor(host,name_text,at,moving,night)

func marker(host: Node2D, at: Vector2, clock: float) -> void:
	var y := at.y - 100 + sin(clock * 3.5) * 3
	host.draw_colored_polygon(PackedVector2Array([Vector2(at.x - 6, y), Vector2(at.x + 6, y), Vector2(at.x, y + 7)]), Color("f4d085"))

func render(host: Node2D) -> void:
	if host.room != "outside":
		var data: Dictionary = host.layout.interiors.config(host.room)
		var actors: Array[Dictionary] = [{"name":"player","at":host.player}]
		for name_text in data["actors"]:
			actors.append({"name":name_text,"at":data["actors"][name_text]})
		actors.sort_custom(func(a,b):return a["at"].y < b["at"].y)
		for person in actors:
			if person["name"] == "player": character_art.draw_henrique(host)
			else: character_art.draw_cast_actor(host,person["name"],person["at"])
		host.draw_string(ThemeDB.fallback_font,Vector2(413,495),"PORTA · E / AÇÃO",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("ead3a4"))
		host.polish.render(host)
		return
	var night: bool = host.stage >= 3
	if host.stage <= 1:
		host.draw_texture_rect(TARGET, Rect2(host.target - Vector2(28, 37), Vector2(56, 64)), false)
		marker(host, host.target + Vector2(0, 55), host.visual_clock)
		host.draw_string(ThemeDB.fallback_font, host.target + Vector2(-16, 45), "%d / 3" % host.hits, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("fcdfa2"))
	elif host.stage == 2:
		for name_text in host.layout.VILLAGE_CAST:
			character_art.draw_cast_actor(host,name_text,host.layout.VILLAGE_CAST[name_text])
		character_art.draw_naruto(host, host.layout.NARUTO)
		marker(host, host.layout.NARUTO, host.visual_clock)
		host.draw_string(ThemeDB.fallback_font,Vector2(304,221),"ACADEMIA",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("ffe4aa"))
	if host.stage in [2,5]:
		host.draw_string(ThemeDB.fallback_font,Vector2(77,221),"SUA CASA",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("ffe4aa"))
	if host.stage == 3:
		actor(host, host.mizuki, MIZUKI, Vector2.RIGHT, host.lines.is_empty(), host.visual_clock, "Mizuki", true)
	elif host.stage == 4:
		host.draw_texture_rect(KUNAI, Rect2(host.target - Vector2(16, 8), Vector2(32, 16)), false)
		marker(host, host.target + Vector2(0, 70), host.visual_clock)
	if host.stage == 5:
		marker(host, host.layout.HOME + Vector2(0, 80), host.visual_clock)
	character_art.draw_henrique(host)
	if host.attack_flash > 0:
		var progress: float = 1.0 - host.attack_flash / (0.5 if host.effect_kind == "katon" else 0.2)
		var at: Vector2 = host.effect_origin + host.effect_direction * progress * 125
		if host.effect_kind == "katon":
			for radius in [24, 18, 11]:
				host.draw_circle(at, radius, Color(1, 0.38, 0.12, 0.11), true)
			for i in range(18):
				var shift := Vector2(-host.effect_direction.x * i * 2, sin(i * 2.3 + host.visual_clock * 23) * 12)
				var size := 6 + (i % 3) * 4
				host.draw_circle(at + shift, size * 0.65, Color("e47735"), true)
			for i in range(9):
				var shift := Vector2(cos(i * 1.7) * 12, sin(i * 2.8) * 10)
				host.draw_circle(at + shift, 4, Color("ffcf69"), true)
			host.draw_circle(at, 7, Color("fff1b0"), true)
		else:
			host.draw_set_transform(at, host.effect_direction.angle())
			host.draw_texture_rect(KUNAI, Rect2(-16, -8, 32, 16), false)
			host.draw_line(Vector2(-28, 0), Vector2(-48, 0), Color(0.85, 0.92, 0.95, 0.55), 2)
			host.draw_set_transform(Vector2.ZERO)
	# Sparse ambient leaves/fireflies. No particle nodes or heavy post-processing.
	for i in range(12):
		var x := fmod(i * 89.0 + host.visual_clock * (5 if night else 11), 940.0)
		var y := 216 + (i % 5) * 33 + sin(host.visual_clock + i) * 13
		host.draw_rect(Rect2(x, y, 3 if night else 5, 2), Color(0.85, 0.9, 0.54, 0.5) if night else Color(0.72, 0.76, 0.43, 0.6))
	host.polish.render(host)

func draw_hud(canvas: Node2D, host: Node2D) -> void:
	# Compact HUD frees the center and bottom for the world.
	canvas.draw_rect(Rect2(0, 0, 960, 62), Color("142a32"))
	canvas.draw_rect(Rect2(0, 60, 960, 2), Color("b69b65"))
	canvas.draw_rect(Rect2(12, 5, 46, 50), Color("2c4246"))
	character_art.portrait(canvas)
	canvas.draw_string(ThemeDB.fallback_font, Vector2(586, 20), "CHAKRA", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("adc3be"))
	canvas.draw_rect(Rect2(640, 10, 218, 12), Color("2e4850"))
	canvas.draw_rect(Rect2(642, 12, 214 * host.chakra / 100.0, 8), Color("69bfce"))
	canvas.draw_rect(Rect2(640, 26, 218, 3), Color("374b4e"))
	canvas.draw_rect(Rect2(640, 26, 218 * host.stamina / 100.0, 3), Color("d8b879"))
	canvas.draw_string(ThemeDB.fallback_font, Vector2(869, 21), "%d / 100" % int(host.chakra), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("e3dcc0"))
	var place := "CAMPO DE TREINO" if host.stage <= 1 else "KONOHA · PRAÇA" if host.stage == 2 else "FLORESTA · NOITE" if host.stage <= 4 else "KONOHA · CASA"
	if host.room != "outside": place=host.layout.interiors.config(host.room)["title"]
	canvas.draw_style_box(host.polish.panel(), Rect2(16, 74, 205, 26))
	canvas.draw_string(ThemeDB.fallback_font, Vector2(29, 92), place, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("ead3a4"))
	if host.lines.is_empty():
		canvas.draw_string(ThemeDB.fallback_font, Vector2(382, 517), "PRÓLOGO  /  %02d DE 07" % (host.stage + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("ecdfb8"))
