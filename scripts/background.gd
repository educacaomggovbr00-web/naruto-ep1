extends Node2D

const GRASS = preload("res://assets/art/grass.svg")
const EARTH = preload("res://assets/art/earth.svg")
const STONE = preload("res://assets/art/stone.svg")
const TREE = preload("res://assets/art/tree.svg")
const BUSH = preload("res://assets/art/bush.svg")
const HOUSE = preload("res://assets/art/house.svg")
const LANTERN = preload("res://assets/art/lantern.svg")
var area := -1
var night := false

func set_area(stage: int) -> void:
	var next_area := 0 if stage <= 1 else 1 if stage == 2 or stage == 5 or stage == 6 or stage == 7 or stage == 8 else 2
	var next_night := stage == 3 or stage == 4 or stage == 5 or stage == 6 or stage >= 8
	if next_area != area or next_night != night:
		area = next_area
		night = next_night
		queue_redraw()

func tree(at: Vector2, scale_factor: float = 1.0) -> void:
	draw_set_transform(at + Vector2(0, 65 * scale_factor), 0, Vector2(1.0, 0.27))
	draw_circle(Vector2.ZERO, 25 * scale_factor, Color(0.07, 0.14, 0.15, 0.3))
	draw_set_transform(Vector2.ZERO)
	draw_texture_rect(TREE, Rect2(at - Vector2(32, 25) * scale_factor, Vector2(64, 96) * scale_factor), false)

func building(at: Vector2, tint: Color = Color.WHITE) -> void:
	draw_rect(Rect2(at + Vector2(12, 104), Vector2(144, 18)), Color(0.12, 0.19, 0.22, 0.25))
	draw_texture_rect(HOUSE, Rect2(at, Vector2(152, 130)), false, tint)

func _draw() -> void:
	# Retained CanvasItem commands: static scenery is redrawn only on area changes.
	for x in range(30):
		for y in range(17):
			var texture: Texture2D = GRASS
			if y >= 6 and y <= 11:
				texture = EARTH
			if area == 1 and y >= 7 and y <= 11:
				texture = STONE
			draw_texture_rect(texture, Rect2(x * 32, y * 32, 32, 32), false)
	# Distant carved mountain silhouette above the village.
	draw_rect(Rect2(0, 68, 960, 62), Color("7d9283"))
	for i in range(16):
		draw_rect(Rect2(i * 64, 94 - (i % 4) * 6, 68, 38 + (i % 4) * 6), Color("738373"))
	for i in range(4):
		var x := 302 + i * 70
		draw_rect(Rect2(x, 79, 40, 42), Color("a3997c"))
		draw_rect(Rect2(x + 6, 82, 28, 30), Color("b5a98a"))
		draw_rect(Rect2(x + 8, 94, 7, 4), Color("797863"))
		draw_rect(Rect2(x + 24, 94, 7, 4), Color("797863"))
		draw_rect(Rect2(x + 18, 94, 4, 11), Color("928a6e"))
		draw_rect(Rect2(x + 13, 109, 16, 3), Color("8c7d67"))
	if area == 1:
		building(Vector2(36, 91), Color("dbd5dc"))
		building(Vector2(268, 85))
		building(Vector2(460, 91), Color("e0d2b8"))
		building(Vector2(714, 82))
		# Village signage, ramen stall, mission board, clan banners and small bridge over canal.
		draw_rect(Rect2(286, 167, 116, 19), Color("4c493f"))
		draw_string(ThemeDB.fallback_font, Vector2(299, 182), "ACADEMIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("f3d599"))
		# Konoha leaf plaques beside the academy and central street.
		for plaque in [Vector2(258, 154), Vector2(674, 154)]:
			draw_circle(plaque, 10, Color("c7b17e"))
			draw_arc(plaque, 5, -1.8, 1.8, 12, Color("46595a"), 2)
			draw_line(plaque + Vector2(4, 3), plaque + Vector2(10, 3), Color("46595a"), 2)
		# Mission board gives the plaza more RPG identity.
		draw_rect(Rect2(470, 226, 76, 50), Color("755638"))
		draw_rect(Rect2(476, 232, 64, 34), Color("d2bd8c"))
		for note in [Rect2(481, 237, 16, 10), Rect2(503, 239, 13, 13), Rect2(520, 236, 15, 11), Rect2(487, 252, 20, 9)]:
			draw_rect(note, Color("eee0b8"))
		draw_rect(Rect2(797, 186, 84, 35), Color("ae734b"))
		draw_rect(Rect2(791, 177, 96, 14), Color("d2c095"))
		for i in range(6):
			draw_rect(Rect2(794 + i * 16, 177, 8, 14), Color("995443"))
		draw_string(ThemeDB.fallback_font, Vector2(808, 207), "RAMEN", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("fce3a3"))
		draw_rect(Rect2(430, 340, 292, 44), Color("466c71"))
		for i in range(22):
			draw_rect(Rect2(436 + i * 13, 348 + (i % 3) * 10, 8, 2), Color("749b97"))
		for i in range(10):
			draw_rect(Rect2(536 + i * 9, 332, 8, 60), Color("967550"))
			draw_rect(Rect2(536 + i * 9, 340, 1, 45), Color("c1a574"))
		draw_rect(Rect2(534, 337, 94, 3), Color("504b3e"))
		draw_rect(Rect2(534, 381, 94, 3), Color("504b3e"))
		# Uchiha district markers: red/white fan motif, kept simple for pixel-art readability.
		for banner in [Vector2(205, 128), Vector2(690, 128)]:
			draw_rect(Rect2(banner.x - 2, banner.y, 4, 45), Color("4d3c34"))
			draw_circle(banner + Vector2(0, 8), 9, Color("b54c48"))
			draw_rect(Rect2(banner.x - 9, banner.y + 8, 18, 8), Color("e6ded0"))
			draw_circle(banner + Vector2(0, 16), 9, Color("e6ded0"))
		# Old-school RPG street dressing: alleys, signs, benches, crates and route markers.
		for x in range(36, 924, 48):
			draw_rect(Rect2(x, 303 + int(x / 48) % 2 * 3, 18, 3), Color("817d70"))
		for at in [Vector2(222, 300), Vector2(650, 304)]:
			draw_rect(Rect2(at.x, at.y, 54, 7), Color("795f45"))
			draw_rect(Rect2(at.x + 4, at.y + 7, 5, 13), Color("5b4938"))
			draw_rect(Rect2(at.x + 45, at.y + 7, 5, 13), Color("5b4938"))
		for at in [Vector2(52, 286), Vector2(878, 288), Vector2(608, 248)]:
			draw_rect(Rect2(at.x, at.y, 22, 18), Color("8a6a45"))
			draw_rect(Rect2(at.x + 3, at.y + 3, 16, 12), Color("a98555"))
			draw_line(at + Vector2(3, 3), at + Vector2(19, 15), Color("684e36"), 2)
		draw_rect(Rect2(575, 286, 5, 35), Color("604a37"))
		draw_rect(Rect2(550, 286, 57, 12), Color("b79c6c"))
		draw_string(ThemeDB.fallback_font, Vector2(555, 296), "ACADEMIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("4c4035"))
		draw_rect(Rect2(559, 300, 48, 12), Color("aa8b61"))
		draw_string(ThemeDB.fallback_font, Vector2(564, 310), "RAMEN >", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("4c4035"))
		for at in [Vector2(150, 322), Vector2(330, 315), Vector2(735, 314)]:
			draw_rect(Rect2(at.x, at.y, 78, 16), Color("62784f"))
			for j in range(6):
				draw_rect(Rect2(at.x + 5 + j * 12, at.y + 4 + (j % 2) * 4, 5, 4), Color("82905b"))
	else:
		for i in range(14):
			tree(Vector2(12 + i * 72, 120 + (i % 3) * 7), 1.3)
		# Fence enclosing the training ground and forest edge.
		for i in range(30):
			draw_rect(Rect2(i * 32 + 8, 182, 5, 29), Color("705a42"))
			draw_rect(Rect2(i * 32 + 8, 184, 2, 25), Color("b59b6b"))
		draw_rect(Rect2(0, 190, 960, 4), Color("967750"))
		if area == 0:
			draw_rect(Rect2(283, 227, 218, 117), Color(0.9, 0.78, 0.56, 0.17))
			for at in [Vector2(280, 352), Vector2(515, 352), Vector2(523, 240)]:
				draw_rect(Rect2(at, Vector2(16, 21)), Color("755b3f"))
				draw_rect(Rect2(at + Vector2(-3, -3), Vector2(22, 5)), Color("c9aa71"))
	for i in range(18):
		var at := Vector2(16 + i * 54, 400 + (i % 2) * 14)
		draw_texture_rect(BUSH, Rect2(at, Vector2(48, 40)), false)
	for at in [Vector2(225, 158), Vector2(668, 164), Vector2(899, 330), Vector2(393, 359)]:
		draw_texture_rect(LANTERN, Rect2(at, Vector2(18, 58)), false)
	for i in range(24):
		var pos := Vector2(22 + i * 39, 384 + (i % 4) * 12)
		draw_rect(Rect2(pos, Vector2(2, 8)), Color("b0aa61"))
		draw_rect(Rect2(pos + Vector2(-2, 1), Vector2(6, 3)), Color("d1b989"))
	if night:
		draw_rect(Rect2(0, 0, 960, 540), Color(0.025, 0.075, 0.17, 0.53))
		for at in [Vector2(234, 183), Vector2(677, 189), Vector2(908, 355), Vector2(402, 384)]:
			for radius in [24, 17, 10]:
				draw_circle(at, radius, Color(1.0, 0.7, 0.3, 0.06))
			draw_rect(Rect2(at - Vector2(3, 6), Vector2(6, 12)), Color("ffcf7b"))
