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
	game.toggle_konoha_map()
	assert(game.map_panel.visible, "Konoha map must open")
	game.toggle_konoha_map()
	assert(not game.map_panel.visible, "Konoha map must close")

	close_dialogue(game)
	game.player = game.naruto_pos
	game.act("interact")
	assert(game.stage == 8, "Academy scene must trigger the scroll alarm")
	close_dialogue(game)

	assert(game.naruto_world.all_konoha_locations().size() == 30, "Konoha overworld must expose all 30 connected areas")
	assert(game.naruto_world.neighbor("academy", "south") == "central_plaza", "Academy must connect south into central Konoha")
	game.travel_to_location("hospital")
	assert(game.current_location_id == "hospital", "Konoha map must travel to Hospital")
	game.travel_to_location("village_gate")
	game.player = Vector2(885, 275)
	game._process(0.1)
	assert(game.stage == 9, "Village Gate must lead to Naruto in the forest during the scroll incident")
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
	assert(game.stage == 18 and game.episode_3_started, "Closing Episode 2 must begin Episode 3")

	# Episode 3: Team 7 is formed while Henrique earns his own advancement through actual tests.
	close_dialogue(game)
	game.player = Vector2(360, 265)
	game.act("interact")
	assert(game.stage == 19, "Iruka must introduce the Team 7 orientation beat")
	close_dialogue(game)

	game.player = game.sasuke_pos
	game.act("interact")
	assert(game.stage == 20, "Talking to Sasuke must open Henrique's real evaluation")
	assert(int(game.rpg.real_stats["restraint_choices"]) == 1, "Calm Sasuke interaction must shape Henrique's personality")
	close_dialogue(game)

	for i in range(3):
		game.player = game.target - Vector2(100, 0)
		game.facing = Vector2.RIGHT
		game.cooldown = 0.0
		game.action_timer = 0.0
		game.action_state = ""
		game.act("shuriken")
	assert(game.stage == 21, "Three real shuriken hits must advance the evaluation")
	assert(int(game.rpg.technique_mastery["shuriken"]) >= 3, "Only successful hits must raise shuriken mastery")
	close_dialogue(game)

	game.player = game.target - Vector2(70, 0)
	game.cooldown = 0.0
	game.action_timer = 0.0
	game.action_state = ""
	game.chakra = 100
	game.act("substitution")
	assert(game.stage == 22, "Successful substitution near the target must pass the control test")
	assert(game.rpg.mission_rank == "Genin", "Henrique becomes Genin only after completing both gameplay tests")
	assert(int(game.rpg.technique_mastery["substitution"]) >= 1, "Successful substitution must raise mastery")
	close_dialogue(game)

	game.player = game.kakashi_pos
	game.act("interact")
	assert(game.stage == 23, "Talking to Kakashi must conclude Episode 3")
	assert(game.rpg.completed_missions.has("episode3_real_evaluation"), "Episode 3 must record the completed evaluation mission")
	assert(game.rpg.total_xp > 0, "Real progression must record earned total XP")
	close_dialogue(game)
	assert(game.restart.visible, "Episode 3 ending must expose replay")

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
	assert(game.art.KAKASHI.get_width() == 216, "Kakashi overworld atlas must load")

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

	print("PASS: Episodes 1-3, 30-zone Konoha overworld, real progression, Team 7 cast and Henrique animation catalog")
	game.queue_free()
	await process_frame
	quit()
