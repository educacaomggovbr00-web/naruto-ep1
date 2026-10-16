extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func close_dialogue(game: Node) -> void:
	while not game.lines.is_empty(): game.next_line()

func run_checks() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled = false
	root.add_child(game)
	await process_frame
	close_dialogue(game)
	var art = game.art.character_art
	assert(art.attached_cast["actors"].size() == 6)
	assert(art.get_cast_texture().get_size() == Vector2(1024,640))
	for person in art.attached_cast["actors"]:
		assert(art.attached_cast["actors"][person]["frames"].size() == 4)
		game.ui.update_portrait(person)
		assert(game.ui.portrait.texture.atlas == art.cast_texture)
	game.stage = 2
	for person in game.layout.VILLAGE_CAST:
		var at: Vector2 = game.layout.VILLAGE_CAST[person]
		assert(game.blocked(at), "All visible actors must block their feet position")
		game.player = at + Vector2(0,35)
		game.act("interact")
		assert(not game.lines.is_empty() and game.lines[0].begins_with(person+":"))
		close_dialogue(game)
		assert(game.stage == 2 and not game.pending_forest_transition)
	# Existing valid positions remain exact; only collisions require relocation.
	game.player = game.layout.VILLAGE_CAST["Hiruzen"]
	var old_save: Dictionary = game.savegame.snapshot(game)
	assert(game.savegame.apply(game,old_save))
	assert(not game.blocked(game.player) and game.player.distance_to(game.layout.VILLAGE_CAST["Hiruzen"]) <= 32)
	if not art.compact_mode:
		assert(art.player_texture.get_size() == Vector2(1024,672))
		for action in art.attached_player["actions"]:
			assert(not art.attached_player["actions"][action].is_empty())
		game.lines.clear()
		game.dash_time = 0.16
		assert(art.attached_action(game) == "dodge")
		for remaining in [0.16,0.12,0.08,0.04,0.001]:
			game.dash_time = remaining
			assert(art.attached_frame(game,"dodge").has("origin"))
		game.dash_time = 0
		game.attack_flash = 0.5
		game.effect_kind = "katon"
		assert(art.attached_action(game) == "katon")
	print("PASS: uploaded cast sprites/portraits, village conversations, NPC collisions, old-save relocation and Henrique actions")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
