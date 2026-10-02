extends RefCounted

var character_art = preload("res://scripts/character_art.gd").new()
const NARUTO = preload("res://assets/art/naruto.svg")
const SASUKE = preload("res://assets/art/sasuke.svg")
const SAKURA = preload("res://assets/art/sakura.svg")
const KONOHAMARU = preload("res://assets/art/konohamaru.svg")
const EBISU = preload("res://assets/art/ebisu.svg")
const IRUKA = preload("res://assets/art/iruka.svg")
const MIZUKI = preload("res://assets/art/mizuki.svg")
const TARGET = preload("res://assets/art/target.svg")
const KUNAI = preload("res://assets/art/kunai.svg")

func actor(host: Node2D, at: Vector2, texture: Texture2D, direction: Vector2, moving: bool, clock: float, name_text: String, night: bool) -> void:
	var frame := int(clock * 9.0) % 3 if moving else 0
	var row := 0
	if direction.y < -0.4:
		row = 1
	elif absf(direction.x) > 0.4:
		row = 2
	var bob := -2.0 if moving and frame == 1 else 0.0
	host.draw_set_transform(at + Vector2(0, 12), 0, Vector2(1, 0.3))
	host.draw_circle(Vector2.ZERO, 17, Color(0.07, 0.13, 0.17, 0.38))
	host.draw_set_transform(at + Vector2(0, bob), 0, Vector2(-1 if row == 2 and direction.x < 0 else 1, 1))
	host.draw_texture_rect_region(texture, Rect2(-30, -64, 60, 70), Rect2((row * 3 + frame) * 24, 0, 24, 28), Color("b1bbd2") if night else Color.WHITE)
	host.draw_set_transform(Vector2.ZERO)
	host.draw_string(ThemeDB.fallback_font, at + Vector2(-28, -78), name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("f6e9c8"))

func marker(host: Node2D, at: Vector2, clock: float) -> void:
	var y := at.y - 82 + sin(clock * 3.5) * 3
	host.draw_colored_polygon(PackedVector2Array([Vector2(at.x - 6, y), Vector2(at.x + 6, y), Vector2(at.x, y + 7)]), Color("f4d085"))

func render(host: Node2D) -> void:
	var night: bool = host.stage == 3 or host.stage == 4 or host.stage == 5 or host.stage == 6 or (host.stage >= 8 and host.stage <= 12)
	if host.stage <= 1:
		host.draw_texture_rect(TARGET, Rect2(host.target - Vector2(28, 37), Vector2(56, 64)), false)
		marker(host, host.target, host.visual_clock)
		host.draw_string(ThemeDB.fallback_font, host.target + Vector2(-16, 45), "%d / 3" % host.hits, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("fcdfa2"))
	elif host.stage == 2:
		actor(host, host.naruto_pos, NARUTO, Vector2.LEFT, true, host.visual_clock, "Naruto", false)
		actor(host, Vector2(730, 260), IRUKA, Vector2.DOWN, false, host.visual_clock, "Iruka", false)
		marker(host, host.naruto_pos, host.visual_clock)
	elif host.stage == 3:
		actor(host, host.mizuki, MIZUKI, Vector2.RIGHT, host.lines.is_empty(), host.visual_clock, "Mizuki", true)
	elif host.stage == 4:
		host.draw_texture_rect(KUNAI, Rect2(host.target - Vector2(16, 8), Vector2(32, 16)), false)
		marker(host, host.target + Vector2(0, 36), host.visual_clock)
	elif host.stage == 7:
		actor(host, host.naruto_pos, NARUTO, Vector2.LEFT, true, host.visual_clock, "Naruto", false)
		actor(host, Vector2(360, 260), IRUKA, Vector2.DOWN, false, host.visual_clock, "Iruka", false)
		actor(host, Vector2(520, 245), SASUKE, Vector2.DOWN, false, host.visual_clock, "Sasuke", false)
		actor(host, Vector2(455, 305), SAKURA, Vector2.RIGHT, true, host.visual_clock, "Sakura", false)
		marker(host, host.naruto_pos, host.visual_clock)
	elif host.stage == 8:
		marker(host, Vector2(885, 275), host.visual_clock)
	elif host.stage == 9:
		actor(host, host.naruto_pos, NARUTO, Vector2.DOWN, false, host.visual_clock, "Naruto", true)
		host.draw_rect(Rect2(host.naruto_pos + Vector2(-32, 18), Vector2(30, 20)), Color("d9c89a"))
		host.draw_line(host.naruto_pos + Vector2(-27, 23), host.naruto_pos + Vector2(-8, 23), Color("735f45"), 2)
		marker(host, host.naruto_pos, host.visual_clock)
	elif host.stage == 10:
		actor(host, host.naruto_pos, NARUTO, Vector2.RIGHT, false, host.visual_clock, "Naruto", true)
		actor(host, Vector2(430, 265), IRUKA, Vector2.RIGHT, false, host.visual_clock, "Iruka", true)
		actor(host, host.mizuki, MIZUKI, Vector2.LEFT, false, host.visual_clock, "Mizuki", true)
		marker(host, host.mizuki, host.visual_clock)
	elif host.stage == 11 or host.stage == 12:
		actor(host, host.naruto_pos, NARUTO, Vector2.RIGHT, false, host.visual_clock, "Naruto", true)
		actor(host, Vector2(430, 265), IRUKA, Vector2.RIGHT, false, host.visual_clock, "Iruka", true)
		if host.stage == 11:
			marker(host, host.naruto_pos, host.visual_clock)

	if host.stage == 5:
		marker(host, Vector2(110, 240), host.visual_clock)
	elif host.stage == 13:
		actor(host, host.naruto_pos, NARUTO, Vector2.LEFT, false, host.visual_clock, "Naruto", false)
		actor(host, host.konohamaru_pos, KONOHAMARU, Vector2.RIGHT, true, host.visual_clock, "Konohamaru", false)
		marker(host, host.naruto_pos, host.visual_clock)
	elif host.stage == 14:
		actor(host, host.naruto_pos, NARUTO, Vector2.RIGHT, false, host.visual_clock, "Naruto", false)
		actor(host, host.konohamaru_pos, KONOHAMARU, Vector2.LEFT, true, host.visual_clock, "Konohamaru", false)
		marker(host, host.konohamaru_pos, host.visual_clock)
	elif host.stage == 15:
		actor(host, host.naruto_pos, NARUTO, Vector2.DOWN, false, host.visual_clock, "Naruto", false)
		actor(host, host.konohamaru_pos, KONOHAMARU, Vector2.LEFT, false, host.visual_clock, "Konohamaru", false)
		marker(host, host.konohamaru_pos, host.visual_clock)
	elif host.stage == 16:
		actor(host, host.naruto_pos, NARUTO, Vector2.RIGHT, false, host.visual_clock, "Naruto", false)
		actor(host, host.konohamaru_pos, KONOHAMARU, Vector2.RIGHT, false, host.visual_clock, "Konohamaru", false)
		actor(host, host.ebisu_pos, EBISU, Vector2.LEFT, false, host.visual_clock, "Ebisu", false)
		marker(host, host.ebisu_pos, host.visual_clock)
	elif host.stage == 17:
		actor(host, host.naruto_pos, NARUTO, Vector2.RIGHT, true, host.visual_clock, "Naruto", false)
		actor(host, host.konohamaru_pos, KONOHAMARU, Vector2.RIGHT, true, host.visual_clock, "Konohamaru", false)
		actor(host, host.ebisu_pos, EBISU, Vector2.LEFT, false, host.visual_clock, "Ebisu", false)

	character_art.draw_henrique(host)

	if host.clone_flash > 0.0:
		var alpha: float = clampf(float(host.clone_flash), 0.0, 1.0)
		var player_pos: Vector2 = host.player
		for side in [-1, 1]:
			var clone_at: Vector2 = player_pos + Vector2(float(42 * int(side)), 0.0)
			host.draw_circle(clone_at + Vector2(0, -28), 15, Color(0.75, 0.82, 0.86, 0.16 * alpha))
			host.draw_rect(Rect2(clone_at + Vector2(-12, -16), Vector2(24, 38)), Color(0.70, 0.78, 0.84, 0.13 * alpha))
		for i in range(8):
			var smoke: Vector2 = player_pos + Vector2(float((i - 4) * 12), -8.0 + sin(float(i) * 1.4 + float(host.visual_clock) * 7.0) * 12.0)
			host.draw_circle(smoke, 8 + (i % 3) * 3, Color(0.82, 0.86, 0.88, 0.22 * alpha))
	if host.substitution_flash > 0.0:
		var alpha: float = clampf(float(host.substitution_flash), 0.0, 1.0)
		var player_pos: Vector2 = host.player
		for i in range(7):
			var smoke: Vector2 = player_pos + Vector2(cos(float(i) * 1.7) * 30.0, sin(float(i) * 2.1) * 20.0 - 15.0)
			host.draw_circle(smoke, 9 + (i % 2) * 5, Color(0.86, 0.88, 0.90, 0.25 * alpha))
		host.draw_rect(Rect2(player_pos + Vector2(-10, -24), Vector2(20, 44)), Color(0.42, 0.27, 0.16, 0.65 * alpha))
		host.draw_line(player_pos + Vector2(-8, -12), player_pos + Vector2(8, -8), Color(0.66, 0.46, 0.28, 0.8 * alpha), 3)

	if host.naruto_battle_flash > 0.0:
		var action := "run" if host.naruto_battle_flash > 0.8 else "idle"
		character_art.draw_naruto_mugen(host, Vector2(790, 374), action, 0.48)

	if host.attack_flash > 0:
		var progress: float = 1.0 - host.attack_flash / (0.5 if host.effect_kind == "katon" else 0.2)
		var at: Vector2 = host.effect_origin + host.effect_direction * progress * 125
		if host.effect_kind == "katon":
			for i in range(18):
				var shift := Vector2(-host.effect_direction.x * i * 2, sin(i * 2.3 + host.visual_clock * 23) * 12)
				var size := 6 + (i % 3) * 4
				host.draw_rect(Rect2(at + shift - Vector2(size, size) / 2, Vector2(size, size)), Color("df653e"))
			for i in range(9):
				var shift := Vector2(cos(i * 1.7) * 12, sin(i * 2.8) * 10)
				host.draw_rect(Rect2(at + shift - Vector2(4, 4), Vector2(8, 8)), Color("ffcf69"))
			host.draw_rect(Rect2(at - Vector2(5, 5), Vector2(10, 10)), Color("fff1b0"))
		elif host.effect_kind == "shuriken":
			host.draw_set_transform(at, host.visual_clock * 14.0)
			var star := PackedVector2Array([Vector2(0,-14),Vector2(4,-4),Vector2(14,0),Vector2(4,4),Vector2(0,14),Vector2(-4,4),Vector2(-14,0),Vector2(-4,-4)])
			host.draw_colored_polygon(star, Color("b7c5cf"))
			host.draw_circle(Vector2.ZERO, 4, Color("38434b"))
			host.draw_set_transform(Vector2.ZERO)
		else:
			host.draw_set_transform(at, host.effect_direction.angle())
			host.draw_texture_rect(KUNAI, Rect2(-16, -8, 32, 16), false)
			host.draw_line(Vector2(-28, 0), Vector2(-48, 0), Color(0.85, 0.92, 0.95, 0.55), 2)
			host.draw_set_transform(Vector2.ZERO)

	for i in range(12):
		var x := fmod(i * 89.0 + host.visual_clock * (5 if night else 11), 940.0)
		var y := 216 + (i % 5) * 33 + sin(host.visual_clock + i) * 13
		host.draw_rect(Rect2(x, y, 3 if night else 5, 2), Color(0.85, 0.9, 0.54, 0.5) if night else Color(0.72, 0.76, 0.43, 0.6))

	host.draw_rect(Rect2(0, 0, 960, 78), Color("142c35"))
	host.draw_rect(Rect2(0, 76, 960, 2), Color("9e885c"))
	host.draw_rect(Rect2(13, 9, 48, 55), Color("29414b"))
	character_art.portrait(host)
	if host.sharingan_awakened:
		host.draw_circle(Vector2(585, 21), 11, Color("a92f2f"))
		host.draw_circle(Vector2(585, 21), 4, Color("1b1719"))
		host.draw_circle(Vector2(591, 17), 2, Color("1b1719"))
		host.draw_string(ThemeDB.fallback_font, Vector2(566, 45), "1 TOMOE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("e7c7b2"))
	host.draw_rect(Rect2(610, 16, 166, 10), Color("314952"))
	host.draw_rect(Rect2(612, 18, 162 * host.chakra / 100.0, 6), Color("66b8bd"))
	var place := "CAMPO DE TREINO"
	if host.stage == 2:
		place = "KONOHA • PRAÇA"
	elif host.stage == 3 or host.stage == 4:
		place = "FLORESTA • NOITE"
	elif host.stage == 5 or host.stage == 6:
		place = "KONOHA • CASA"
	elif host.stage == 7:
		place = "ACADEMIA • EP 1"
	elif host.stage == 8:
		place = "KONOHA • ALARME"
	elif host.stage >= 9 and host.stage <= 12:
		place = "FLORESTA • PERGAMINHO"
	elif host.stage == 13:
		place = "GABINETE • EP 2"
	elif host.stage >= 14:
		place = "KONOHA • EP 2"
	host.draw_string(ThemeDB.fallback_font, Vector2(790, 26), place, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("d6c89f"))
	host.draw_rect(Rect2(0, 445, 960, 95), Color(0.045, 0.10, 0.15, 0.70))
