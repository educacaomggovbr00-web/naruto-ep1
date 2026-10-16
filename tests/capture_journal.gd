extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func close_dialogue(game: Node) -> void:
	while not game.lines.is_empty(): game.next_line()

func settle_attack(game: Node) -> void:
	for i in range(60):
		if game.combat.shots.is_empty(): return
		game._process(0.02)
	assert(false)

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
	game.audio.set_enabled(false)
	close_dialogue(game)
	game.player=game.target-Vector2(100,0)
	game.facing=Vector2.RIGHT
	game.ui.journal.toggle()
	await save_frame("diario-primeiro-treino.png")
	game.ui.journal.close()
	for i in range(3):
		game.cooldown=0
		game.act("kunai")
		settle_attack(game)
	close_dialogue(game)
	game.cooldown=0
	game.act("katon")
	settle_attack(game)
	close_dialogue(game)
	assert(game.stage==2)
	game.player=game.layout.interiors.ACADEMY_DOOR
	await game.travel_to("academy")
	game.player=Vector2(480,270)
	game.act("interact")
	close_dialogue(game)
	game.player=Vector2(365,207)
	game.act("interact")
	close_dialogue(game)
	await game.travel_to("outside")
	game.player=game.layout.HOME
	await game.travel_to("home")
	game.player=Vector2(225,220)
	game.act("interact")
	close_dialogue(game)
	game.ui.journal.toggle()
	assert(game.ui.journal.discovery_label.text=="5 de 6 anotações")
	await save_frame("diario-descobertas-academia-casa.png")
	game.ui.journal.close()
	game.player=Vector2(690,310)
	await create_timer(2.6).timeout
	await save_frame("casa-com-acesso-ao-diario.png")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
