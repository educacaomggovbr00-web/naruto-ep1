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
	game.toggle_techniques()
	assert(game.techniques_panel.visible, "Technique menu must open")
	game.toggle_techniques()
	assert(not game.techniques_panel.visible, "Technique menu must close")

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
	assert(game.stage == 13, "Closing Episode 1 must begin Episode 2")
	assert(game.episode_2_started, "Episode 2 flag must be enabled")

	# Episode 2: Naruto meets Konohamaru, then the player demonstrates movement/combat basics.
	close_dialogue(game)
	game.player = game.naruto_pos
	game.act("interact")
	assert(game.stage == 14, "Meeting Naruto must introduce Konohamaru")
	close_dialogue(game)
	game.player = game.konohamaru_pos
	game.act("interact")
	assert(game.stage == 15, "Talking to Konohamaru must start the small training beat")
	close_dialogue(game)

	game.player = game.konohamaru_pos - Vector2(70, 0)
	game.facing = Vector2.RIGHT
	game.cooldown = 0.0
	game.act("dodge")
	assert(game.ep2_dodge_done, "Episode 2 training must register dodge")
	game.action_timer = 0.0
	game.action_state = ""
	game.cooldown = 0.0
	game.player = game.konohamaru_pos - Vector2(70, 0)
	game.act("punch")
	assert(game.ep2_punch_done, "Episode 2 training must register punch")
	assert(game.stage == 16, "Completing both training actions must bring Ebisu")
	close_dialogue(game)

	game.player = game.ebisu_pos
	game.act("interact")
	assert(game.stage == 17, "Talking to Ebisu must conclude Episode 2")
	assert(game.rpg.completed_missions.has("konohamaru_first_meeting"), "Episode 2 completion must reward progression")
	close_dialogue(game)
	assert(game.restart.visible, "Episode 2 ending must expose replay")

	# Every requested basic/classic action must resolve through the animation manifest.
	var required_actions := [
		"idle","walk","run","jump","fall","crouch","dodge_roll","slide",
		"punch_combo","kunai_attack","shuriken_throw","katon_fireball",
		"shadow_clone","substitution","hurt","down","get_up","death"
	]
	for action in required_actions:
		assert(game.art.character_art.henrique_actions.has(action), "Missing Henrique action: " + action)
		var frame_id: int = game.art.character_art.frame_for_action(action, 0.25)
		assert(frame_id >= 0 and frame_id < game.art.character_art.henrique_frames.size(), "Animation frame out of range: " + action)

	assert(game.art.character_art.henrique_frames.size() == 86, "Exact Henrique board must expose all 86 runtime frames")
	assert(game.art.character_art.henrique_manifest["source_git_blob"] == "265335ebcdd1d4a16052f968c4c2fb7a21e86b49", "Henrique runtime must use the exact uploaded PNG")
	assert(game.art.character_art.mugen_actions["idle"].size() == 4, "Imported fan-MUGEN idle cycle must load")
	assert(game.art.NARUTO.get_width() == 216, "Top-down Naruto overworld atlas must load")
	assert(game.art.SASUKE.get_width() == 216, "Sasuke overworld atlas must load")
	assert(game.art.SAKURA.get_width() == 216, "Sakura overworld atlas must load")
	assert(game.art.KONOHAMARU.get_width() == 216, "Konohamaru overworld atlas must load")
	assert(game.art.EBISU.get_width() == 216, "Ebisu overworld atlas must load")

	# Exercise action effects without requiring combat targets.
	game.stage = 15
	game.lines.clear()
	game.chakra = 100
	game.cooldown = 0.0
	game.act("clone")
	assert(game.action_state == "shadow_clone" and game.clone_flash > 0.0, "Shadow clone animation/effect must trigger")
	game.action_timer = 0.0
	game.action_state = ""
	game.cooldown = 0.0
	game.act("substitution")
	assert(game.action_state == "substitution" and game.substitution_flash > 0.0, "Substitution animation/effect must trigger")

	print("PASS: Episodes 1-2, progression, top-down cast, MUGEN battle art and Henrique basic animation catalog")
	game.queue_free()
	await process_frame
	quit()
