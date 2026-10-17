extends SceneTree
func _initialize() -> void: call_deferred("capture")
func frame(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_environment("NARUTO_PREVIEW_DIR").path_join(name))
func capture() -> void:
	root.size=Vector2i(960,540)
	var game=load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled=false
	root.add_child(game)
	await process_frame
	game.set_process(false)
	while not game.lines.is_empty(): game.next_line()
	game.stage=2
	game.episode.step=7
	game.world.district="training"
	game.layout.district="training"
	var duel=game.duel
	duel.set_process(false)
	assert(duel.offer())
	await frame("duelo-menu.png")
	duel.menu_start()
	duel.model.ai_enabled=false
	for i in range(90): duel._process(1.0/60)
	duel.model.player.x=350
	duel.model.enemy.x=630
	duel.queued.append("katon")
	for i in range(27): duel._process(1.0/60)
	await frame("duelo-katon.png")
	for i in range(60): duel._process(1.0/60)
	duel.model.player.x=440
	duel.model.enemy.x=510
	duel.queued.append("light")
	for i in range(9): duel._process(1.0/60)
	await frame("duelo-impacto.png")
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	print("PASS: actual duel screenshots captured")
	quit()
