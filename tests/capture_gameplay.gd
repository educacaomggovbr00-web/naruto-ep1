extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture_frame(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var folder := OS.get_environment("NARUTO_PREVIEW_DIR")
	if folder.is_empty(): folder = "/tmp"
	assert(root.get_texture().get_image().save_png(folder.path_join(name)) == OK)
	print("CAPTURE: ", name)

func capture() -> void:
	root.size = Vector2i(960, 540)
	var game = load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled = false
	game.savegame.path = "user://preview-prologue-save.json"
	root.add_child(game)
	while not game.lines.is_empty(): game.next_line()
	game.stage = 2
	game.hits = 3
	game.chakra = 75
	game.player = Vector2(500, 300)
	game.facing = Vector2.RIGHT
	await process_frame
	game.act("dodge")
	await capture_frame("jogo-esquiva.png")
	game.dash_time = 0
	game.ui.toggle_settings()
	await capture_frame("jogo-ajustes-save.png")
	game.ui.toggle_settings()
	game.savegame.enabled = true
	assert(game.save_checkpoint(false))
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.15).timeout
	var resume = load("res://scenes/main.tscn").instantiate()
	resume.savegame.path = "user://preview-prologue-save.json"
	root.add_child(resume)
	assert(resume.ui.resume_overlay.visible)
	await capture_frame("jogo-continuar.png")
	resume.savegame.enabled = false
	resume.audio.shutdown()
	resume.queue_free()
	await create_timer(0.15).timeout
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://preview-prologue-save.json"))
	quit()
