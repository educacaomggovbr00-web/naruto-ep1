extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func save_frame(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var folder:=OS.get_environment("NARUTO_PREVIEW_DIR")
	assert(not folder.is_empty())
	assert(root.get_texture().get_image().save_png(folder.path_join(name))==OK)
	print("CAPTURE: ",name)

func capture() -> void:
	root.size=Vector2i(960,540)
	var game=load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled=false
	root.add_child(game)
	await process_frame
	while not game.lines.is_empty(): game.next_line()
	game.player=game.target-Vector2(190,0)
	game.facing=Vector2.RIGHT
	await create_timer(2.5).timeout
	game.act("kunai")
	await create_timer(0.16).timeout
	assert(game.hits==0 and not game.combat.shots.is_empty())
	await save_frame("kunai-em-voo.png")
	while game.hits==0: await process_frame
	await save_frame("impacto-no-alvo.png")
	await create_timer(0.5).timeout
	game.act("katon")
	await create_timer(0.35).timeout
	assert(not game.combat.shots.is_empty())
	await save_frame("katon-da-galeria-em-voo.png")
	while not game.combat.shots.is_empty(): await process_frame
	assert(game.stage==0 and game.hits==1)
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
