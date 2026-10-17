extends SceneTree
func _initialize() -> void: call_deferred("checks")
func dismiss(game: Node) -> void:
	while not game.lines.is_empty(): game.next_line()
func tap(button: Button) -> void:
	for pressed in [true, false]:
		var event := InputEventScreenTouch.new()
		event.index = 12
		event.position = button.get_global_rect().get_center()
		event.pressed = pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()
func finish_travel(game: Node) -> void:
	while game.travelling: await process_frame
func checks() -> void:
	root.size = Vector2i(960, 540)
	var game = load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled = false
	root.add_child(game)
	await process_frame
	game.set_process(false)
	dismiss(game)
	game.stage = 2
	game.episode.step = 7
	game.route_guide.enabled = true
	game.player = Vector2(450, 285)
	game.ui.journal.toggle()
	tap(game.ui.journal.map_button)
	assert(game.ui.journal.village_map.visible and not game.ui.journal.contents.visible, "Map touch must open exactly once")
	var map = game.ui.journal.village_map
	assert(map.cards[1].disabled)
	for picture in map.pictures: assert(picture.texture != null)
	var player: Vector2 = game.player
	var chakra: float = game.chakra
	tap(map.cards[2])
	assert(game.world.tracked_district == "training")
	assert(game.player == player and game.chakra == chakra and game.episode.step == 7, "Marking a route must not teleport or change progress")
	var clock: float = game.day_cycle.elapsed
	game._process(1)
	assert(game.day_cycle.elapsed == clock, "The map must pause the world")
	game.ui.journal.close()
	for picture in map.pictures: assert(picture.texture == null, "Closing the map must release its additional environment textures")
	game.route_guide.update(game, 1)
	assert(game.route_guide.last_goal == Vector2(922, 292) and not game.route_guide.points.is_empty())
	await game.travel_to("home")
	game.route_guide.update(game, 1)
	assert(game.route_guide.last_goal == Vector2(480, 450), "Indoor tracking must lead through the real exit")
	await game.travel_to("outside")
	game.player = Vector2(922, 292)
	game.act("interact")
	await finish_travel(game)
	game.world.update(game, 0.05)
	assert(game.world.district == "training" and game.world.tracked_district.is_empty(), "Arrival must clear the optional route")
	map.mark("residential")
	game.route_guide.update(game, 1)
	assert(game.route_guide.last_goal == Vector2(50, 290), "Cross-district route must first return through the plaza")
	game.player = Vector2(50, 290)
	game.act("interact")
	await finish_travel(game)
	game.world.update(game, 0.05)
	game.route_guide.update(game, 1)
	assert(game.world.district == "plaza" and game.world.tracked_district == "residential")
	assert(game.route_guide.last_goal == Vector2(38, 292))
	game.player = Vector2(38, 292)
	game.act("interact")
	await finish_travel(game)
	game.world.update(game, 0.05)
	assert(game.world.district == "residential" and game.world.tracked_district.is_empty())
	map.mark("plaza")
	map.clear_route()
	assert(game.world.tracked_district.is_empty())
	game.route_guide.enabled = false
	map.mark("plaza")
	assert(map.note.text.contains("AJUSTES"), "Disabled route guidance needs a clear explanation")
	var saved: Dictionary = game.savegame.snapshot(game)
	assert(not saved.has("tracked_district") and game.savegame.apply(game, saved))
	assert(game.world.tracked_district.is_empty(), "Loading must clear transient navigation")
	game.stage = 3
	map.refresh()
	for button in map.cards: assert(button.disabled)
	map.mark("training")
	assert(game.world.tracked_district.is_empty(), "Protected story stages must reject optional tracking")
	game.route_guide.enabled = true
	game.route_guide.update(game, 1)
	assert(game.route_guide.points.is_empty())
	print("PASS: touch map, paused world, safe district routes, real doors, no teleport, arrival, cancellation and protected story")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.15).timeout
	quit()
