extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func save_frame(name: String) -> void:
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
	root.add_child(game)
	await process_frame
	while not game.lines.is_empty(): game.next_line()
	game.player = game.target - Vector2(100, 0)
	for i in range(3):
		game.cooldown = 0
		game.act("kunai")
	while not game.lines.is_empty(): game.next_line()
	game.cooldown = 0
	game.act("katon")
	while not game.lines.is_empty(): game.next_line()
	assert(game.stage == 2)
	game.player = Vector2(500, 300)
	game.facing = Vector2.RIGHT
	game.attack_flash = 0
	# Let the actual game update its area, HUD and camera after the transition.
	for i in range(8): await process_frame
	game.act("dodge")
	# Freeze simulation only while capturing each actual rendered gameplay frame.
	game.set_process(false)
	for i in range(4):
		game.dash_time = 0.16 - i * 0.04 - 0.001
		game.queue_redraw()
		await save_frame("galeria-esquiva-%d.png" % i)
	game.dash_direction = Vector2.LEFT
	game.dash_time = 0.08
	game.queue_redraw()
	await save_frame("galeria-esquiva-esquerda.png")
	game.dash_time = 0
	game.queue_redraw()
	await save_frame("galeria-base-preservada.png")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
