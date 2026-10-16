extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled = false
	root.add_child(game)
	await process_frame
	while not game.lines.is_empty(): game.next_line()
	var art = game.art.character_art
	assert(art.naruto_gallery_texture == null, "Gallery NPC should load only when needed")
	assert(art.get_naruto_gallery_texture().get_size() == Vector2(384, 160))
	assert(art.naruto_gallery["frames"].size() == 4)
	game.ui.update_portrait("Naruto")
	assert(game.ui.portrait.texture.atlas == art.naruto_gallery_texture, "Dialogue must use the same original gallery art")
	assert(art.dodge_manifest["frames"].size() == 4)
	assert(art.dodge_texture == null if art.compact_mode else art.dodge_texture.get_size() == Vector2(384, 96))
	game.player = Vector2(500, 300)
	game.facing = Vector2.RIGHT
	game.act("dodge")
	var start: Vector2 = game.player
	var stamina: float = game.stamina
	assert(art.gallery_dodge_frame(game) == 0)
	game._process(0.041)
	assert(art.gallery_dodge_frame(game) == 1)
	game._process(0.04)
	assert(art.gallery_dodge_frame(game) == 2)
	game._process(0.04)
	assert(art.gallery_dodge_frame(game) == 3)
	game._process(0.04)
	assert(game.dash_time == 0)
	assert(game.player.x > start.x and game.player.x - start.x <= 70.5)
	assert(game.stamina >= stamina and game.stamina < 100)
	# The same atlas works in either direction without modifying collision origin.
	game.facing = Vector2.LEFT
	game.act("dodge")
	assert(game.dash_direction == Vector2.LEFT)
	var dialogue_lines: Array[String] = ["Henrique: Teste de diálogo."]
	game.say(dialogue_lines)
	assert(game.dash_time == 0, "Dialogue must cancel dodge and return to existing art")
	print("PASS: gallery atlas, all timed dodge frames, both directions, unchanged travel and dialogue cancellation")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
