extends Node2D

const GRASS = preload("res://assets/art/grass.svg")
const EARTH = preload("res://assets/art/earth.svg")
const STONE = preload("res://assets/art/stone.svg")
const TREE = preload("res://assets/art/tree.svg")
const BUSH = preload("res://assets/art/bush.svg")
const HOUSE = preload("res://assets/art/house.svg")
const LANTERN = preload("res://assets/art/lantern.svg")
var user_assets = preload("res://scripts/user_asset_pack.gd").new()
var area := -1
var night := false
var location_id := "academy"
var location_name := "Academia Ninja"
var location_kind := "academy"

func set_location(info: Dictionary) -> void:
	var next_id := String(info.get("id", "academy"))
	var next_name := String(info.get("name", "Academia Ninja"))
	var next_kind := String(info.get("kind", "academy"))
	if next_id != location_id or next_kind != location_kind:
		location_id = next_id
		location_name = next_name
		location_kind = next_kind
		queue_redraw()

func set_area(stage: int) -> void:
	var next_area := 0 if stage <= 1 or (stage >= 24 and stage <= 28) else 2 if (stage >= 9 and stage <= 12) or stage >= 32 else 1
	var next_night := stage == 3 or stage == 4 or stage == 5 or stage == 6 or (stage >= 8 and stage <= 12)
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
	# Lightweight exact crops from the user boards. Prefer a location-specific panel;
	# fall back to the training/forest crops only for story areas outside normal Konoha roam.
	var exact_background: Texture2D = user_assets.location(location_id)
	if exact_background == null:
		if area == 0:
			exact_background = user_assets.location("training_ground_3")
		elif area == 2:
			exact_background = user_assets.location("forest")
	if exact_background != null:
		draw_rect(Rect2(0, 78, 960, 367), Color("1a2a2f"))
		draw_texture_rect(exact_background, Rect2(0, 78, 960, 367), false)

	# Konoha free-roam location dressing. Same lightweight tile base, different landmark identity.
	if area == 1:
		draw_rect(Rect2(18, 138, 250, 25), Color(0.08, 0.13, 0.15, 0.78))
		draw_string(ThemeDB.fallback_font, Vector2(29, 156), location_name, HORIZONTAL_ALIGNMENT_LEFT, 225, 13, Color("f3d599"))
		if location_kind == "academy":
			draw_rect(Rect2(330, 205, 300, 76), Color("d2c49f"))
			draw_string(ThemeDB.fallback_font, Vector2(408, 250), "ACADEMIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("51463b"))
			draw_circle(Vector2(300, 255), 23, Color("6f8553"))
			draw_line(Vector2(300, 270), Vector2(300, 312), Color("5e4432"), 7)
			draw_line(Vector2(300, 278), Vector2(270, 298), Color("6e543e"), 3)
		elif location_kind == "government":
			draw_rect(Rect2(340, 200, 285, 92), Color("d8cab3"))
			draw_circle(Vector2(482, 200), 92, Color("b46952"))
			draw_string(ThemeDB.fallback_font, Vector2(448, 245), "火", HORIZONTAL_ALIGNMENT_LEFT, -1, 44, Color("efe0b8"))
		elif location_kind == "monument":
			for i in range(4):
				var fx := 340 + i * 72
				draw_circle(Vector2(fx, 220), 28, Color("ad9f80"))
				draw_rect(Rect2(fx - 20, 245, 40, 38), Color("9a8d74"))
		elif location_kind == "hospital":
			draw_rect(Rect2(345, 195, 270, 100), Color("d8dddd"))
			draw_rect(Rect2(465, 212, 30, 62), Color("9a4f4f"))
			draw_rect(Rect2(449, 228, 62, 30), Color("9a4f4f"))
		elif location_kind == "commercial" or location_kind == "ramen":
			for i in range(5):
				var sx := 250 + i * 105
				draw_rect(Rect2(sx, 210, 84, 56), Color("a76e4e"))
				draw_rect(Rect2(sx - 4, 202, 92, 10), Color("d4bd8e"))
			if location_kind == "ramen":
				draw_string(ThemeDB.fallback_font, Vector2(424, 248), "ICHIRAKU", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("ffe1a0"))
		elif location_kind == "cemetery" or location_kind == "memorial":
			for i in range(9):
				var gx := 230 + (i % 5) * 105
				var gy := 220 + int(i / 5) * 58
				draw_rect(Rect2(gx, gy, 24, 37), Color("77796f"))
				draw_rect(Rect2(gx - 4, gy + 34, 32, 5), Color("5e625d"))
			if location_kind == "memorial":
				draw_rect(Rect2(446, 192, 68, 115), Color("4d5351"))
		elif location_kind == "library":
			draw_rect(Rect2(335, 195, 290, 103), Color("c6b995"))
			for i in range(6):
				draw_rect(Rect2(360 + i * 41, 213, 25, 48), Color("5a443a"))
				draw_rect(Rect2(362 + i * 41, 217, 21, 4), Color("d0ac6f"))
		elif location_kind == "uchiha":
			for bx in [360, 480, 600]:
				draw_rect(Rect2(bx, 195, 4, 92), Color("4a3731"))
				draw_circle(Vector2(bx + 2, 210), 18, Color("b54949"))
				draw_rect(Rect2(bx - 16, 210, 36, 14), Color("e1ddd2"))
				draw_circle(Vector2(bx + 2, 224), 18, Color("e1ddd2"))
		elif location_kind == "shrine":
			draw_rect(Rect2(438, 185, 9, 122), Color("8c3d36"))
			draw_rect(Rect2(530, 185, 9, 122), Color("8c3d36"))
			draw_rect(Rect2(420, 185, 137, 12), Color("a9473d"))
			draw_rect(Rect2(432, 205, 112, 8), Color("a9473d"))
		elif location_kind == "river":
			draw_rect(Rect2(0, 245, 960, 110), Color("446c79"))
			for i in range(25):
				draw_rect(Rect2(8 + i * 39, 265 + (i % 4) * 15, 25, 3), Color("7fa0a0"))
			draw_rect(Rect2(420, 228, 124, 145), Color("957456"))
			for i in range(10):
				draw_rect(Rect2(424 + i * 12, 228, 5, 145), Color("bf9d70"))
		elif location_kind == "training":
			for at in [Vector2(330, 245), Vector2(480, 225), Vector2(630, 255)]:
				draw_rect(Rect2(at.x - 4, at.y, 8, 74), Color("6a4d35"))
				draw_circle(at, 28, Color("d6bd86"))
				draw_circle(at, 17, Color("9c5146"))
				draw_circle(at, 7, Color("e4d2a4"))
		elif location_kind == "hotspring":
			draw_rect(Rect2(310, 235, 350, 105), Color("6c8e8d"))
			for i in range(9):
				draw_circle(Vector2(330 + i * 38, 250 + (i % 3) * 19), 11, Color(0.9, 0.95, 0.9, 0.14))
		elif location_kind == "gate":
			draw_rect(Rect2(300, 145, 34, 180), Color("76563b"))
			draw_rect(Rect2(625, 145, 34, 180), Color("76563b"))
			draw_rect(Rect2(270, 145, 420, 34), Color("9b6b45"))
			draw_string(ThemeDB.fallback_font, Vector2(445, 170), "木ノ葉", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("eee0b8"))
		elif location_kind == "plaza":
			draw_circle(Vector2(480, 250), 60, Color("9c947f"))
			draw_circle(Vector2(480, 250), 43, Color("b8aa8a"))
			for at in [Vector2(350, 240), Vector2(610, 240)]:
				draw_rect(Rect2(at.x, at.y, 70, 8), Color("73543b"))
				draw_rect(Rect2(at.x + 5, at.y + 8, 6, 20), Color("5b4938"))
				draw_rect(Rect2(at.x + 58, at.y + 8, 6, 20), Color("5b4938"))
		elif location_kind == "residential":
			for at in [Vector2(250, 195), Vector2(435, 205), Vector2(620, 190)]:
				building(at, Color("ded4c4"))
		elif location_kind == "service":
			for i in range(6):
				var cx := 330 + (i % 3) * 120
				var cy := 210 + int(i / 3) * 62
				draw_rect(Rect2(cx, cy, 75, 45), Color("79664e"))
				draw_line(Vector2(cx, cy), Vector2(cx + 75, cy + 45), Color("ab9772"), 2)
				draw_line(Vector2(cx + 75, cy), Vector2(cx, cy + 45), Color("ab9772"), 2)

	if night:
		draw_rect(Rect2(0, 0, 960, 540), Color(0.025, 0.075, 0.17, 0.53))
		for at in [Vector2(234, 183), Vector2(677, 189), Vector2(908, 355), Vector2(402, 384)]:
			for radius in [24, 17, 10]:
				draw_circle(at, radius, Color(1.0, 0.7, 0.3, 0.06))
			draw_rect(Rect2(at - Vector2(3, 6), Vector2(6, 12)), Color("ffcf7b"))
