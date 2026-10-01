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
	close_dialogue(game)
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
	assert(game.art.HENRIQUE.get_width() == 216, "Character atlas must contain nine frames")
	print("PASS: complete prologue progression, chakra, area transitions and SVG atlas import")
	game.queue_free()
	await process_frame
	quit()
