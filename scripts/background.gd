extends Node2D

# Retained drawing: scenery is rebuilt only when the story changes area.
var area := -1
var night := false
const INK = Color("354b45")

func set_area(stage: int) -> void:
	var next_area := 0 if stage <= 1 else 1 if stage == 2 or stage >= 5 else 2
	var next_night := stage >= 3
	if next_area != area or next_night != night:
		area = next_area
		night = next_night
		queue_redraw()

func box(rect: Rect2, color: Color, radius: int = 0) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	draw_style_box(style, rect)

func shadow(at: Vector2, size: Vector2) -> void:
	for i in range(4):
		draw_set_transform(at, 0, size / 2)
		draw_circle(Vector2.ZERO, 1.0 + i * 0.08, Color(0.1, 0.2, 0.16, 0.045), true)
	draw_set_transform(Vector2.ZERO)

func tree(at: Vector2, scale_factor: float = 1.0) -> void:
	shadow(at + Vector2(5, 8), Vector2(82, 25) * scale_factor)
	draw_set_transform(at, 0, Vector2.ONE * scale_factor)
	box(Rect2(-7, -48, 14, 50), Color("544b38"), 3)
	draw_line(Vector2(-2, -42), Vector2(2, -3), Color("8b7651"), 3, true)
	for p in [Vector2(-22, -57), Vector2(18, -61), Vector2(0, -83)]:
		draw_circle(p, 29, Color("2e5041"), true)
		draw_circle(p + Vector2(-3, -5), 26, Color("426b4a"), true)
		draw_circle(p + Vector2(-8, -11), 19, Color("62834f"), true)
		draw_arc(p + Vector2(-6, -10), 19, 3.4, 5.6, 12, Color("879957"), 2, true)
	draw_set_transform(Vector2.ZERO)

func window_at(at: Vector2, width: float = 27) -> void:
	box(Rect2(at - Vector2(3, 3), Vector2(width + 6, 39)), Color("9a855c"), 2)
	box(Rect2(at, Vector2(width, 33)), Color("375b65"), 1)
	draw_colored_polygon(PackedVector2Array([at, at + Vector2(width, 0), at + Vector2(0, 27)]), Color("739995"))
	draw_line(at + Vector2(width / 2, 0), at + Vector2(width / 2, 33), Color("e2cc98"), 2)
	draw_line(at + Vector2(0, 16), at + Vector2(width, 16), Color("e2cc98"), 2)
	box(Rect2(at + Vector2(-4, 34), Vector2(width + 8, 5)), Color("9a7850"), 1)

func building(at: Vector2, kind: int) -> void:
	# Footprints match the collision boxes of the original prototype.
	var wall: Color = [Color("d8c4a1"), Color("e3d4b2"), Color("c8c8af"), Color("d5b38c")][kind]
	var roof: Color = [Color("97524b"), Color("b85c43"), Color("4c7173"), Color("845647")][kind]
	shadow(at + Vector2(83, 125), Vector2(166, 25))
	box(Rect2(at + Vector2(8, 28), Vector2(138, 94)), INK, 3)
	box(Rect2(at + Vector2(12, 31), Vector2(130, 87)), wall, 2)
	box(Rect2(at + Vector2(12, 100), Vector2(130, 18)), wall.darkened(0.15))
	for x in [16, 133]:
		box(Rect2(at + Vector2(x, 31), Vector2(5, 87)), Color("8c7655"))
	box(Rect2(at + Vector2(56, 69), Vector2(36, 49)), Color("4b5147"), 2)
	box(Rect2(at + Vector2(61, 74), Vector2(26, 44)), Color("756146"), 2)
	draw_line(at + Vector2(66, 77), at + Vector2(66, 115), Color("9b8259"), 2)
	draw_circle(at + Vector2(82, 96), 2, Color("e5bd71"))
	window_at(at + Vector2(25, 49))
	window_at(at + Vector2(103, 49))
	draw_colored_polygon(PackedVector2Array([at + Vector2(-4, 29), at + Vector2(17, 0), at + Vector2(134, 0), at + Vector2(157, 29), at + Vector2(157, 37), at + Vector2(-4, 37)]), roof.darkened(0.3))
	for row in range(4):
		var inset := 15.0 - row * 5
		box(Rect2(at + Vector2(inset, 3 + row * 7), Vector2(152 - inset * 2, 5)), roof.lightened(0.07 * (3 - row)), 1)
		for col in range(8):
			var x := inset + 6 + col * 17
			if x < 147 - inset:
				draw_line(at + Vector2(x, 4 + row * 7), at + Vector2(x - 2, 8 + row * 7), roof.darkened(0.22), 1)
	box(Rect2(at + Vector2(16, -3), Vector2(118, 5)), roof.lightened(0.25), 2)
	box(Rect2(at + Vector2(50, 119), Vector2(48, 6)), Color("d8c69e"), 2)
	if kind == 0:
		box(Rect2(at + Vector2(18, 86), Vector2(30, 10)), Color("82654a"), 2)
		for j in range(4):
			draw_circle(at + Vector2(23 + j * 7, 84), 5, Color("698556"))
			draw_circle(at + Vector2(24 + j * 7, 81), 2, Color("d29474"))
	elif kind == 1:
		box(Rect2(at + Vector2(28, 45), Vector2(96, 20)), Color("354a43"), 3)
		draw_string(ThemeDB.fallback_font, at + Vector2(38, 60), "ACADEMIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("ffe2a1"))
		for x in [4, 143]:
			box(Rect2(at + Vector2(x, 58), Vector2(6, 44)), Color("b75240"), 1)
	elif kind == 2:
		box(Rect2(at + Vector2(91, -16), Vector2(20, 27)), Color("7c7962"), 2)
		box(Rect2(at + Vector2(87, -20), Vector2(28, 7)), Color("c2b38f"), 2)
		box(Rect2(at + Vector2(46, 46), Vector2(61, 16)), Color("746344"), 2)
		draw_string(ThemeDB.fallback_font, at + Vector2(51, 58), "ARMAZÉM", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("f8dfab"))
	else:
		box(Rect2(at + Vector2(-1, 66), Vector2(155, 16)), Color("a34435"), 2)
		for i in range(9):
			box(Rect2(at + Vector2(i * 17, 66), Vector2(9, 16)), Color("ead4a6"))
		draw_string(ThemeDB.fallback_font, at + Vector2(45, 100), "ICHIRAKU", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("fff0c8"))

func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color("78965f"))
	# Large quiet color masses replace the repeated speckled tiles.
	draw_colored_polygon(PackedVector2Array([Vector2(0, 212), Vector2(170, 198), Vector2(370, 215), Vector2(620, 203), Vector2(960, 218), Vector2(960, 390), Vector2(735, 378), Vector2(515, 395), Vector2(270, 382), Vector2(0, 398)]), Color("627e52"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, 221), Vector2(170, 209), Vector2(370, 224), Vector2(620, 213), Vector2(960, 228), Vector2(960, 380), Vector2(735, 368), Vector2(515, 385), Vector2(270, 372), Vector2(0, 388)]), Color("c6ad7e"))
	# Broad worn paths, a few stones and grass clumps instead of noise.
	for i in range(22):
		var p := Vector2(22 + i * 43, 245 + (i * 37 % 113))
		draw_line(p, p + Vector2(12 + i % 4 * 3, -1), Color(0.96, 0.86, 0.65, 0.3), 2, true)
	for i in range(19):
		var p := Vector2(i * 53 + 9, 402 + i % 4 * 19)
		draw_line(p, p + Vector2(-4, -9), Color("53754c"), 2, true)
		draw_line(p, p + Vector2(4, -7), Color("a1b375"), 2, true)
	# Distant ridge and soft clouds.
	draw_rect(Rect2(0, 61, 960, 65), Color("b4c5a4"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, 110), Vector2(130, 73), Vector2(245, 102), Vector2(400, 69), Vector2(580, 100), Vector2(730, 75), Vector2(960, 99), Vector2(960, 145), Vector2(0, 145)]), Color("8f9f7f"))
	if area == 1:
		for i in range(4):
			building(Vector2([36, 268, 460, 714][i], [91, 85, 91, 82][i]), i)
		for at in [Vector2(218, 220), Vector2(665, 212), Vector2(930, 215)]:
			tree(at, 0.68 if at.x < 900 else 0.95)
		box(Rect2(428, 341, 296, 46), Color("527b7d"), 8)
		box(Rect2(435, 347, 280, 32), Color("6a9691"), 5)
		for i in range(15):
			draw_line(Vector2(442 + i * 18, 356 + i % 3 * 7), Vector2(452 + i * 18, 356 + i % 3 * 7), Color("a2b9a0"), 1, true)
		shadow(Vector2(582, 393), Vector2(108, 13))
		for i in range(10):
			box(Rect2(535 + i * 9, 332, 8, 61), Color("a18055"), 1)
			draw_line(Vector2(537 + i * 9, 335), Vector2(537 + i * 9, 389), Color("c8a779"), 1)
		for y in [335, 384]:
			box(Rect2(531, y, 100, 4), Color("5b5340"), 1)
		for at in [Vector2(230, 310), Vector2(810, 315)]:
			shadow(at + Vector2(24, 10), Vector2(70, 12))
			box(Rect2(at, Vector2(55, 8)), Color("795e43"), 2)
			for x in [5, 45]:
				box(Rect2(at + Vector2(x, 8), Vector2(5, 12)), Color("564c3a"))
	else:
		for i in range(13):
			tree(Vector2(20 + i * 79, 190 + i % 3 * 9), 0.8 + (i % 4) * 0.12)
		for i in range(30):
			box(Rect2(i * 33, 194, 5, 26), Color("75654a"), 1)
		box(Rect2(0, 202, 960, 4), Color("ac8e5e"))
		if area == 0:
			draw_arc(Vector2(390, 280), 88, 0, TAU, 64, Color(0.96, 0.85, 0.6, 0.3), 2, true)
			for at in [Vector2(280, 352), Vector2(515, 352), Vector2(523, 240)]:
				shadow(at + Vector2(9, 20), Vector2(32, 10))
				box(Rect2(at, Vector2(17, 24)), Color("856744"), 3)
				box(Rect2(at + Vector2(-2, -2), Vector2(21, 5)), Color("c7ab77"), 2)
	for i in range(9):
		tree(Vector2(-10 + i * 124, 552 + i % 2 * 10), 0.78 + i % 3 * 0.11)
	if night:
		draw_rect(Rect2(0, 62, 960, 478), Color(0.02, 0.065, 0.16, 0.47))
	for at in [Vector2(234, 204), Vector2(677, 205), Vector2(908, 366)]:
		box(Rect2(at - Vector2(2, 30), Vector2(4, 31)), Color("63563e"), 1)
		if night:
			for radius in [32, 23, 14]:
				draw_circle(at - Vector2(0, 37), radius, Color(1, 0.72, 0.35, 0.065), true)
		box(Rect2(at - Vector2(7, 45), Vector2(14, 18)), Color("64543d"), 3)
		box(Rect2(at - Vector2(4, 42), Vector2(8, 12)), Color("f5cd83"), 2)
