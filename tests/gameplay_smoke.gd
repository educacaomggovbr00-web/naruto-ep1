extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func close_dialogue(game: Node) -> void:
	while not game.lines.is_empty(): game.next_line()

func run_checks() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled = false
	game.savegame.path = "user://test-prologue-save.json"
	root.add_child(game)
	await process_frame
	close_dialogue(game)
	game.stage = 2
	game.player = Vector2(440, 245)
	game.move_with_collisions(Vector2(100, -70))
	assert(is_equal_approx(game.player.y, 232) and game.player.x > 440, "Diagonal movement must slide along the wall")
	game.player = Vector2(210, 320)
	game.move_with_collisions(Vector2(100, 0))
	assert(game.player.x < 223, "The painted bench must block the same spot in gameplay")
	game.player = Vector2(450, 330)
	game.move_with_collisions(Vector2(0, 60))
	assert(game.player.y < 341, "Water must block walking outside the bridge")
	game.player = Vector2(580, 330)
	game.move_with_collisions(Vector2(0, 45))
	assert(game.player.y == 375, "The bridge must remain traversable")
	game.move_with_collisions(Vector2(0, 60))
	assert(game.player.y == 414, "The player must be able to reach the south bank")
	game.stage = 3
	game.player = Vector2(400, 250)
	game.move_with_collisions(Vector2(0, -200))
	assert(game.player.y == 228, "Painted forest vegetation must not be walkable")
	game.stage = 2
	game.player = Vector2(600, 260)
	game.move_with_collisions(Vector2(100, 0))
	assert(game.player.x <= 618, "The player must not walk through Naruto")
	game.stage = 0
	game.player = Vector2(100, 300)
	game.facing = Vector2.RIGHT
	game.act("dodge")
	assert(game.stamina == 70)
	game._process(0.2)
	assert(is_equal_approx(game.player.x, 170.4) and game.dash_time == 0, "Dash duration must cap displacement even on a slow frame")
	game.stamina = 20
	game.act("dodge")
	assert(game.dash_time == 0 and game.stamina == 20, "Insufficient stamina must prevent dash")
	game.stage = 2
	game.player = Vector2(500, 260)
	game.facing = Vector2.UP
	game.stamina = 100
	game.act("dodge")
	game._process(0.2)
	assert(game.player.y >= 229, "Dash must not tunnel through a house")
	game.chakra = 10
	game.cooldown = 0
	game.act("katon")
	assert(game.chakra == 10 and game.ui.toast_label.text.contains("25"))
	game.player = Vector2(560, 280)
	game.chakra = 56
	game.act("interact")
	while game.line_index < 2: game.next_line()
	game.savegame.enabled = true
	assert(game.save_checkpoint(false), "Saving must succeed")
	assert(game.save_checkpoint(false), "Updating an existing save must be atomic")
	var saved: Dictionary = game.savegame.read_save()
	assert(not saved.is_empty() and saved.line_index == 2 and saved.pending_forest_transition)
	game.stage = 0
	game.lines.clear()
	game.player = Vector2(100, 300)
	assert(game.savegame.apply(game, saved))
	assert(game.stage == 2 and game.line_index == 2 and game.player == Vector2(560, 280))
	close_dialogue(game)
	assert(game.stage == 3, "Resuming mid-dialogue must preserve the forest transition")
	game.stage = 4
	game.trail_progress = 12.1
	assert(game.save_checkpoint(false), "Completed pursuit progress must clamp before saving")
	var resumed = load("res://scenes/main.tscn").instantiate()
	resumed.savegame.path = game.savegame.path
	root.add_child(resumed)
	assert(resumed.ui.resume_overlay.visible, "A valid save must offer Continue on boot")
	resumed._notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert(resumed.savegame.read_save().stage == 4, "The opening menu must not overwrite an existing save")
	resumed.ui.continue_game()
	assert(resumed.stage == 4 and not resumed.ui.modal_open())
	resumed.savegame.enabled = false
	resumed.audio.shutdown()
	resumed.queue_free()
	var file := FileAccess.open(game.savegame.path, FileAccess.WRITE)
	file.store_string('{"version":999}')
	file.close()
	assert(game.savegame.read_save().is_empty() and not game.savegame.last_error.is_empty())
	assert(game.stage == 4, "Invalid saves must not change the live game")
	var damaged = load("res://scenes/main.tscn").instantiate()
	damaged.savegame.path = game.savegame.path
	root.add_child(damaged)
	assert(damaged.ui.resume_overlay.visible and damaged.ui.continue_button.disabled, "An invalid save must show recovery choices")
	damaged.ui.new_game()
	assert(damaged.stage == 0 and not damaged.ui.resume_overlay.visible)
	assert(not damaged.savegame.read_save().is_empty(), "New Game must replace an invalid save with valid progress")
	damaged.savegame.enabled = false
	damaged.audio.shutdown()
	damaged.queue_free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.savegame.path))
	game.savegame.enabled = false
	print("PASS: sliding, bridge, NPC collision, dash bounds, attack feedback, atomic save and dialogue restore")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
