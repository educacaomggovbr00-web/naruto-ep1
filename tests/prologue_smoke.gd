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
	assert(game.stage == 7, "The game must boot directly into Naruto Classic Episode 1")
	assert(game.episode_1_started, "Episode 1 flag must be enabled on boot")
	assert(game.story_era == 1, "Classic Episode 1 content must be active")
	assert(not game.sharingan_awakened, "Advanced dojutsu must not start awakened")
	assert(game.rpg.unlocked_jutsu.has("shuriken"), "Starter progression must include shuriken")

	game.toggle_progression()
	assert(game.progress_panel.visible, "Progression menu must open")
	game.toggle_progression()
	assert(not game.progress_panel.visible, "Progression menu must close")

	close_dialogue(game)
	game.player = game.naruto_pos
	game.act("interact")
	assert(game.stage == 8, "Academy scene must trigger the scroll alarm")
	close_dialogue(game)

	game.player = Vector2(885, 275)
	game._process(0.1)
	assert(game.stage == 9, "Village exit must lead to Naruto in the forest")
	close_dialogue(game)

	game.player = game.naruto_pos
	game.act("interact")
	assert(game.stage == 10, "Talking to Naruto must begin the Mizuki confrontation")
	close_dialogue(game)

	for i in range(3):
		game.player = game.mizuki - Vector2(80, 0)
		game.facing = Vector2.RIGHT
		game.cooldown = 0.0
		game.act("kunai")
	assert(game.stage == 11, "Three kunai hits must open Naruto's decisive moment")
	assert(game.naruto_battle_flash > 0.0, "The MUGEN battle presentation must trigger")
	close_dialogue(game)

	game.player = game.naruto_pos
	game.act("interact")
	assert(game.stage == 12, "Talking after the fight must complete Episode 1")
	assert(game.rpg.completed_missions.has("academy_day"), "Episode 1 completion must reward progression")
	close_dialogue(game)
	assert(game.restart.visible, "Episode 1 ending must expose replay")

	for area in range(7, 13):
		game.stage = area
		game.background.set_area(area)
		await process_frame

	assert(game.art.character_art.henrique_frames.size() == 24, "All Henrique poses must stay mapped")
	assert(game.art.character_art.henrique_actions.has("double_jump"), "Henrique full animation catalog must stay available")
	assert(game.art.character_art.henrique_actions.has("amaterasu"), "Future animation references remain registered but locked")
	assert(game.art.character_art.mugen_actions["idle"].size() == 4, "Imported fan-MUGEN idle cycle must load")
	assert(game.art.NARUTO.get_width() == 216, "Top-down Naruto overworld atlas must load")
	assert(game.art.SASUKE.get_width() == 216, "Sasuke overworld atlas must load")
	assert(game.art.SAKURA.get_width() == 216, "Sakura overworld atlas must load")

	print("PASS: Naruto Classic EP1 start, coherent overworld cast, progression and MUGEN battle presentation")
	game.queue_free()
	await process_frame
	quit()
