extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func close_dialogue(game: Node) -> void:
	while not game.lines.is_empty():
		game.next_line()

func run_checks() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	assert(game.art.character_art.compact_mode == (OS.get_environment("NARUTO_LOW_MEMORY") == "1"), "Detailed reference art must be default; compact mode is explicit")
	# MUGEN frames should not be decoded before Naruto is on screen.
	assert(game.art.character_art.texture_cache.is_empty(), "MUGEN images must be loaded lazily")
	close_dialogue(game)
	# Dialogues and app switching must release touch input.
	game.held["right"] = true
	game.movement = Vector2.RIGHT
	var regression_lines: Array[String] = ["Input regression check"]
	game.say(regression_lines)
	assert(game.held.is_empty() and game.movement == Vector2.ZERO, "Dialogue must release held movement")
	close_dialogue(game)
	game.held["run"] = true
	game._notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert(game.held.is_empty(), "Leaving the app must release touch controls")
	game.player = game.target - Vector2(80, 0)
	game.facing = Vector2.RIGHT
	for i in range(3):
		game.cooldown = 0.0
		game.act("kunai")
	assert(game.stage == 1, "Three kunai hits must unlock Katon")
	close_dialogue(game)
	game.cooldown = 0.0
	game.act("katon")
	assert(game.stage == 2, "Katon must unlock the village")
	assert(game.chakra < 100, "Katon must consume chakra")
	close_dialogue(game)
	game.player = Vector2(620, 260)
	game.act("interact")
	assert(game.stage == 3, "Naruto dialogue must unlock stealth")
	close_dialogue(game)
	game.player = game.mizuki - Vector2(180, 0)
	game.held["sneak"] = true
	game.trail_progress = 11.9
	game._process(0.2)
	assert(game.stage == 4, "Stealth must unlock the dropped kunai")
	close_dialogue(game)
	game.player = game.target
	game.act("interact")
	assert(game.stage == 5, "Investigating must unlock the return home")
	close_dialogue(game)
	game.player = Vector2(110, 240)
	game.act("interact")
	assert(game.stage == 6, "Resting at home must complete the prologue")
	close_dialogue(game)
	# Exercise every graphical branch and load every imported resource.
	for area in range(7):
		game.stage = area
		game.background.set_area(area)
		await process_frame
	if game.art.character_art.compact_mode:
		assert(game.art.HENRIQUE == null, "Low-memory mode must not load the huge atlas")
		assert(Engine.max_fps == 30, "Mobile mode must limit its frame rate")
	else:
		assert(game.art.HENRIQUE != null and game.art.HENRIQUE.get_width() == 1536, "Detailed character atlas must import correctly")
	assert(game.art.character_art.henrique_frames.size() == 24, "All Henrique poses must be mapped")
	assert(game.art.character_art.mugen_actions["idle"].size() == 4, "Original MUGEN AIR idle cycle must be loaded")
	game.attack_flash = 0.0
	game.movement = Vector2.RIGHT
	game.lines.clear()
	game.sprinting = true
	assert(game.art.character_art.henrique_frame(game) >= 12, "Sprint must select running frames")
	game.effect_kind = "katon"
	game.attack_flash = 0.5
	assert(game.art.character_art.henrique_frame(game) == 21, "Katon must select jutsu poses")
	print("PASS: complete prologue progression, chakra, area transitions and SVG atlas import")
	game.queue_free()
	await process_frame
	quit()
