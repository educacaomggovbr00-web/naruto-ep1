extends SceneTree
var folder: String
func _initialize() -> void: call_deferred("capture")
func frame(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(folder.path_join(name)) == OK)
	print("CAPTURE: ", name)
func capture() -> void:
	root.size = Vector2i(960, 540)
	folder = OS.get_environment("NARUTO_PREVIEW_DIR")
	assert(not folder.is_empty())
	var game = load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled = false
	root.add_child(game)
	await process_frame
	while not game.lines.is_empty(): game.next_line()
	game.stage = 2
	game.episode.step = 7
	game.day_cycle.set_mode(1)
	game.player = Vector2(425, 285)
	game.route_guide.enabled = true
	game.cinematic.area_title.hide()
	await create_timer(0.5).timeout
	await frame("atual-praca.png")
	game.ui.journal.toggle()
	game.ui.journal.toggle_map()
	game.ui.journal.village_map.mark("training")
	await frame("atual-mapa-distritos.png")
	game.ui.journal.close()
	game._process(0.1)
	await frame("atual-rota-treino.png")
	game.player = Vector2(38, 292)
	game.act("interact")
	while game.travelling: await process_frame
	game.player = Vector2(490, 335)
	await create_timer(0.25).timeout
	await frame("atual-bairro.png")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.15).timeout
	quit()
