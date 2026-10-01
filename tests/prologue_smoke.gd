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
	assert(game.rpg.completed_missions.has("training_kunai"), "Kunai training must reward RPG progression")
	close_dialogue(game)
	game.cooldown = 0.0
	game.act("katon")
	assert(game.stage == 2, "Katon must unlock the village")
	assert(game.sharingan_awakened, "Katon milestone must awaken the one-tomoe Sharingan")
	assert(game.rpg.unlocked_jutsu.has("sharingan"), "Sharingan must enter the unlocked jutsu list")
	assert(game.chakra < 100, "Katon must consume chakra")
	close_dialogue(game)
	game.naruto_pos = Vector2(640, 260)
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
	assert(game.story_era == 1, "Finishing the prologue must unlock the episode-1 era")
	assert(game.rpg.completed_missions.size() == 4, "Prologue must register all four progression milestones")
	close_dialogue(game)
	# Exercise every graphical branch and load every imported resource.
	for area in range(7):
		game.stage = area
		game.background.set_area(area)
		await process_frame
	assert(game.art.HENRIQUE.get_width() == 1536, "Detailed character atlas must import correctly")
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
