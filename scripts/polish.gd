extends RefCounted

# Procedural accents preserve the original atlas, MUGEN sprites and map layout.
var dust: Array[Dictionary] = []
var step_timer := 0.0
var hit_timer := 0.0
var last_hits := 0
var cached_panel: StyleBoxFlat = null

func update(game: Node2D, delta: float) -> void:
	step_timer += delta
	hit_timer = maxf(0.0, hit_timer - delta)
	if game.hits > last_hits:
		hit_timer = 0.35
	last_hits = game.hits
	if game.movement != Vector2.ZERO and step_timer > (0.16 if game.sprinting else 0.36 if game.down("sneak",KEY_SHIFT) else 0.25):
		step_timer = 0.0
		game.audio.play("step")
		if game.room=="outside": dust.append({"at": game.player + Vector2(0, 13), "life": 0.4})
	for particle in dust:
		particle.life -= delta
		particle.at += Vector2(-8, -10) * delta
	dust = dust.filter(func(p): return p.life > 0.0)

func render(game: Node2D) -> void:
	if game.stage < 3 and game.room == "outside":
		for i in range(3):
			var x := 80.0 + i * 320.0
			game.draw_colored_polygon(PackedVector2Array([Vector2(x, 130), Vector2(x + 45, 130), Vector2(x + 230, 445), Vector2(x + 130, 445)]), Color(1.0, 0.84, 0.54, 0.045))
	if game.dash_time > 0:
		for i in range(4):
			var at: Vector2 = game.player - game.dash_direction * (20 + i * 12) + game.dash_direction.orthogonal() * (i % 2 * 14 - 7)
			game.draw_line(at, at - game.dash_direction * 16, Color(0.6, 0.83, 0.9, 0.6 - i * 0.1), 2, true)
	for particle in dust:
		game.draw_circle(particle.at, 2.0 + (0.4 - particle.life) * 8, Color(0.8, 0.72, 0.51, particle.life * 0.5))
	if game.attack_flash > 0 and game.effect_kind == "katon":
		for i in range(10):
			var angle: float = i * TAU / 10.0 + game.visual_clock * 4
			var at: Vector2 = game.player + Vector2(cos(angle) * 22, -28 + sin(angle) * 30)
			game.draw_circle(at, 2, Color(0.39, 0.8, 0.96, 0.65), true)
	if hit_timer > 0 and game.stage <= 1:
		var radius := 15.0 + (0.35 - hit_timer) * 80
		game.draw_arc(game.target, radius, 0, TAU, 32, Color(1, 0.83, 0.43, hit_timer * 2), 2, true)
		game.draw_string(ThemeDB.fallback_font, game.target + Vector2(-28, -48 - radius * 0.25), "ACERTO!", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("ffda83"))
	if not game.lines.is_empty() or game.stage >= 6 or game.ui.settings_panel.visible:
		return
	if game.room != "outside":
		var point: Dictionary = game.layout.interiors.nearby(game.player,game.room)
		if not point.is_empty(): interaction_prompt(game,point["label"])
		return
	if game.stage in [2,5] and game.player.distance_to(game.layout.HOME)<48:
		interaction_prompt(game,"Entrar em casa")
		return
	if game.stage == 2 and game.player.distance_to(game.layout.interiors.ACADEMY_DOOR)<48:
		interaction_prompt(game,"Entrar na Academia")
		return
	var destination: Vector2 = game.target
	var can_talk := false
	if game.stage == 2:
		destination = game.layout.NARUTO
		can_talk = game.player.distance_to(destination) < 95
	elif game.stage == 4:
		can_talk = game.player.distance_to(destination) < 85
	elif game.stage == 5:
		destination = game.layout.HOME
		can_talk = game.player.distance_to(destination) < 58
	game.draw_arc(game.player + Vector2(0, 13), 20, 0, TAU, 32, Color(0.95, 0.76, 0.4, 0.6), 1, true)
	if game.stage != 3:
		var offset: Vector2 = destination - game.player
		if offset.length() > 105:
			var tip: Vector2 = game.player + offset.normalized() * 53
			var wing := offset.normalized().orthogonal() * 5
			game.draw_colored_polygon(PackedVector2Array([tip + offset.normalized() * 7, tip - wing, tip + wing]), Color("e8c47e"))
	if can_talk:
		game.draw_style_box(panel(), Rect2(game.player + Vector2(-67, 30), Vector2(134, 28)))
		game.draw_string(ThemeDB.fallback_font, game.player + Vector2(-55, 49), "E / AÇÃO · Interagir", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("ffe4aa"))
	if game.stage == 3:
		var distance: float = game.player.distance_to(game.mizuki)
		var safe: bool = distance >= 70 and distance <= 230 and (distance >= 160 or game.down("sneak", KEY_SHIFT) or game.movement == Vector2.ZERO)
		game.draw_style_box(panel(), Rect2(300, 393, 360, 44))
		game.draw_string(ThemeDB.fallback_font, Vector2(314, 411), "FURTIVIDADE · %d passos · %s" % [int(distance), "OCULTO" if safe else "ATENÇÃO"], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("b2dbba") if safe else Color("efad7a"))
		game.draw_rect(Rect2(314, 421, 332, 4), Color("304550"))
		game.draw_rect(Rect2(314, 421, 332 * clampf(game.trail_progress / 12, 0, 1), 4), Color("b8c98b"))

func panel() -> StyleBoxFlat:
	if cached_panel != null:
		return cached_panel
	var box := StyleBoxFlat.new()
	box.bg_color = Color("172d38")
	box.border_color = Color("8b805d")
	box.set_border_width_all(1)
	box.set_corner_radius_all(6)
	cached_panel = box
	return box

func interaction_prompt(game: Node2D, text: String) -> void:
	var at := Vector2(clampf(game.player.x-123,16,698),minf(game.player.y+30,468))
	game.draw_style_box(panel(),Rect2(at,Vector2(246,28)))
	game.draw_string(ThemeDB.fallback_font,at+Vector2(9,19),"E / AÇÃO · "+text,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("ffe4aa"))
