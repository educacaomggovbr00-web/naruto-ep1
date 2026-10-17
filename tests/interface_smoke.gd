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

func center(game: Node, action: String) -> Vector2:
	for button in game.ui.touch_buttons:
		if button.get_meta("action") == action: return button.get_global_rect().get_center()
	return Vector2.ZERO

func run_checks() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.size = Vector2i(960, 540)
	game.savegame.enabled = false
	root.add_child(game)
	await process_frame
	assert(game.ui.body_label.visible_characters < game.ui.body_label.text.length())
	touch(game, 9, center(game, "interact"), true)
	touch(game, 9, center(game, "interact"), false)
	assert(game.line_index == 0, "First press must reveal text without skipping a line")
	assert(game.ui.body_label.visible_characters == -1)
	game.next_line()
	assert(game.line_index == 1, "Second press advances dialogue")
	while not game.lines.is_empty():
		game.next_line()
	await process_frame
	for button in game.ui.touch_buttons:
		var rect: Rect2 = button.get_global_rect()
		assert(rect.position.x >= 12 and rect.end.x <= 948 and rect.end.y <= 528, "Touch controls need safe screen margins")
		for other in game.ui.touch_buttons:
			if other != button: assert(not rect.intersects(other.get_global_rect()), "Touch targets must not overlap")
	var start: Vector2 = game.player
	touch(game, 0, center(game, "right"), true)
	touch(game, 1, center(game, "run"), true)
	assert(game.held.get("right", false) and game.held.get("run", false), "Two fingers must hold direction and run together")
	game._process(0.1)
	var first_step:float=game.player.x-start.x
	assert(first_step>0 and first_step<24, "Simultaneous touch must start sprinting with acceleration")
	var accelerated:Vector2=game.player
	game._process(0.1)
	assert(game.player.x-accelerated.x>first_step and is_equal_approx(game.player.x-accelerated.x,24), "Held touch must reach full sprint after accelerating")
	touch(game, 0, center(game, "right"), false)
	assert(not game.held.has("right") and game.held.get("run", false), "Releasing one finger must preserve the other")
	touch(game, 1, center(game, "run"), false)
	assert(game.held.get("run", false), "Running must stay enabled after a tap")
	touch(game, 1, center(game, "run"), true)
	touch(game, 1, center(game, "run"), false)
	assert(game.held.is_empty())
	touch(game, 2, center(game, "right"), true)
	var drag := InputEventScreenDrag.new()
	drag.index = 2
	drag.position = center(game, "up")
	Input.parse_input_event(drag)
	Input.flush_buffered_events()
	assert(game.held.get("up", false) and not game.held.has("right"), "A finger must slide between directions without lifting")
	drag = drag.duplicate()
	drag.position = Vector2(250, 330)
	Input.parse_input_event(drag)
	Input.flush_buffered_events()
	assert(game.held.is_empty(), "Dragging outside a control must release it")
	game.cooldown = 0
	touch(game, 3, center(game, "kunai"), true)
	assert(game.attack_flash > 0, "Action touch must launch kunai")
	touch(game, 3, center(game, "kunai"), false)
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
