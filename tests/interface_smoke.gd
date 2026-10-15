extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func touch(game: Node, index: int, at: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = at
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func run_checks() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.size = Vector2i(960, 540)
	game.savegame.enabled = false
	root.add_child(game)
	await process_frame
	assert(game.ui.body_label.visible_characters < game.ui.body_label.text.length())
	touch(game, 9, Vector2(910, 480), true)
	touch(game, 9, Vector2(910, 480), false)
	assert(game.line_index == 0, "First press must reveal text without skipping a line")
	assert(game.ui.body_label.visible_characters == -1)
	game.next_line()
	assert(game.line_index == 1, "Second press advances dialogue")
	while not game.lines.is_empty():
		game.next_line()
	await process_frame
	var start: Vector2 = game.player
	touch(game, 0, Vector2(140, 450), true)
	touch(game, 1, Vector2(50, 506), true)
	assert(game.held.get("right", false) and game.held.get("run", false), "Two fingers must hold direction and run together")
	game._process(0.1)
	assert(is_equal_approx(game.player.x, start.x + 24), "Simultaneous direction and sprint must move the player")
	touch(game, 0, Vector2(140, 450), false)
	assert(not game.held.has("right") and game.held.get("run", false), "Releasing one finger must preserve the other")
	touch(game, 1, Vector2(50, 506), false)
	assert(game.held.is_empty())
	touch(game, 2, Vector2(140, 450), true)
	var drag := InputEventScreenDrag.new()
	drag.index = 2
	drag.position = Vector2(250, 330)
	Input.parse_input_event(drag)
	Input.flush_buffered_events()
	assert(game.held.is_empty(), "Dragging outside a control must release it")
	game.cooldown = 0
	touch(game, 3, Vector2(780, 480), true)
	assert(game.attack_flash > 0, "Action touch must launch kunai")
	touch(game, 3, Vector2(780, 480), false)
	game.ui.toggle_settings()
	game.held["right"] = true
	start = game.player
	game._process(0.2)
	assert(game.player == start, "Opening settings must pause movement")
	var original_opacity: float = game.ui.touch_opacity
	game.ui.set_touch_opacity(0.45)
	for button in game.ui.touch_buttons:
		assert(is_equal_approx(button.modulate.a, 0.45))
	game.ui.save_preferences()
	var saved := ConfigFile.new()
	assert(saved.load("user://interface.cfg") == OK)
	assert(is_equal_approx(float(saved.get_value("touch", "opacity")), 0.45))
	game.ui.set_touch_opacity(original_opacity)
	game.ui.toggle_settings()
	game._notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert(game.ui.touch_pointers.is_empty() and game.held.is_empty())
	print("PASS: dialogue reveal, simultaneous touch, drag release, actions, settings and saved opacity")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
