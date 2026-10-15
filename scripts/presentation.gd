extends Node2D

# Small procedural overlay: no downloads, full-screen shaders or extra textures.
var game: Node2D
var clock := 0.0
var step_clock := 0.0
var dust: Array[Dictionary] = []

func _process(delta: float) -> void:
	clock += delta
	if game == null:
		return
	step_clock += delta
	if game.movement != Vector2.ZERO and game.lines.is_empty() and not game.progress_panel.visible and not game.map_panel.visible and step_clock > 0.12:
		step_clock = 0.0
		dust.append({"at": game.player + Vector2(0, 23), "life": 0.45})
	for particle in dust:
		particle.life -= delta
		particle.at += Vector2(-10, -12) * delta
	dust = dust.filter(func(p): return p.life > 0.0)
	queue_redraw()

func _draw() -> void:
	if game == null:
		return
	if not game.background.night:
		for i in range(3):
			var x := 130.0 + i * 310.0 + sin(clock * 0.15) * 12.0
			draw_colored_polygon(PackedVector2Array([Vector2(x, 78), Vector2(x + 70, 78), Vector2(x + 260, 445), Vector2(x + 120, 445)]), Color(1.0, 0.87, 0.59, 0.035))
	# Floating leaves and soft dust give the static scenery some life.
	for i in range(14):
		var at := Vector2(fposmod(i * 79.0 + clock * (9.0 + i % 3), 960.0), 100.0 + fposmod(i * 37.0 + clock * 8.0, 323.0))
		draw_set_transform(at, sin(clock + i) * 0.8)
		draw_colored_polygon(PackedVector2Array([Vector2(-4, 0), Vector2(0, -2), Vector2(5, 0), Vector2(0, 2)]), Color(0.83, 0.72, 0.39, 0.55))
	draw_set_transform(Vector2.ZERO)
	for particle in dust:
		draw_circle(particle.at, 2.0 + (0.45 - particle.life) * 9.0, Color(0.86, 0.78, 0.58, particle.life * 0.5))
	if game.lines.is_empty() and not game.map_panel.visible and not game.progress_panel.visible:
		draw_arc(game.player + Vector2(0, 8), 17, 0, TAU, 32, Color(0.96, 0.73, 0.35, 0.7), 1.5, true)
		if game.stage == 7 and game.current_location_id == "academy":
			var at: Vector2 = game.naruto_pos + Vector2(0, -104 + sin(clock * 3) * 3)
			draw_circle(at, 12, Color("efba66"))
			draw_string(ThemeDB.fallback_font, at + Vector2(-3, 5), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("172a30"))
			if game.player.distance_to(game.naruto_pos) < 90:
				draw_string(ThemeDB.fallback_font, game.player + Vector2(-46, -65), "E / AÇÃO · Falar", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("fff0cc"))
	# Opaque framing keeps controls readable against every location.
	draw_rect(Rect2(0, 0, 960, 78), Color("101f29"))
	draw_rect(Rect2(0, 76, 960, 2), Color("d4aa65"))
	draw_rect(Rect2(0, 445, 960, 95), Color("101f29"))
	draw_rect(Rect2(0, 445, 960, 2), Color("526465"))
	draw_circle(Vector2(37, 33), 24, Color("283d47"))
	draw_arc(Vector2(35, 32), 11, -1.6, 4.8, 24, Color("efba66"), 3, true)
	draw_line(Vector2(45, 35), Vector2(53, 42), Color("efba66"), 3, true)
	draw_rect(Rect2(75, 66, 320, 4), Color("2d4453"))
	draw_rect(Rect2(75, 66, 320 * game.chakra / 100.0, 4), Color("6bc9da"))
	draw_string(ThemeDB.fallback_font, Vector2(742, 26), "KONOHA / EPISÓDIO %02d" % game.current_episode, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("efba66"))
