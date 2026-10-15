extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func close_dialogue(game: Node) -> void:
	while not game.lines.is_empty():
		game.next_line()

func save_frame(name: String) -> void:
	for i in range(8):
		await process_frame
	await RenderingServer.frame_post_draw
	var folder := OS.get_environment("NARUTO_PREVIEW_DIR")
	if folder.is_empty():
		folder = "/tmp"
	assert(root.get_texture().get_image().save_png(folder.path_join(name)) == OK)
	print("CAPTURE: ", name)

func capture() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	root.size = Vector2i(960, 540)
	await process_frame
	close_dialogue(game)
	game.player = game.target - Vector2(100, 0)
	await save_frame("original-treino.png")
	for i in range(3):
		game.cooldown = 0
		game.act("kunai")
	close_dialogue(game)
	game.cooldown = 0
	game.act("katon")
	close_dialogue(game)
	game.attack_flash = 0
	game.player = Vector2(520, 300)
	await save_frame("original-konoha.png")
	game.player = Vector2(620, 260)
	game.act("interact")
	close_dialogue(game)
	game.player = game.mizuki - Vector2(180, 0)
	game.held["sneak"] = true
	await save_frame("original-furtividade.png")
	quit()
