extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func close_dialogue(game: Node) -> void:
	while not game.lines.is_empty(): game.next_line()

func finish_travel(game: Node) -> void:
	while game.travelling: await process_frame

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
	close_dialogue(game)
	game.player=game.target-Vector2(100,0)
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
	game.act("interact")
	await finish_travel(game)
	assert(game.room=="academy")
	game.player=Vector2(480,333)
	await create_timer(2.6).timeout
	await save_frame("academia-interior-jogavel.png")
	game.player=Vector2(480,270)
	game.act("interact")
	game.ui.finish_typing()
	await save_frame("academia-iruka-aula.png")
	close_dialogue(game)
	await game.travel_to("outside")
	game.player=game.layout.HOME
	game.act("interact")
	await finish_travel(game)
	assert(game.room=="home")
	game.player=Vector2(690,310)
	await create_timer(2.6).timeout
	await save_frame("casa-henrique-interior.png")
	await game.travel_to("outside")
	game.player=Vector2(560,280)
	game.act("interact")
	close_dialogue(game)
	assert(game.stage==3)
	game.player=game.mizuki-Vector2(180,0)
	game.held["sneak"]=true
	game.trail_progress=11.9
	game._process(0.2)
	close_dialogue(game)
	game.player=game.target
	game.act("interact")
	close_dialogue(game)
	assert(game.stage==5)
	game.player=game.layout.HOME
	game.act("interact")
	await finish_travel(game)
	game.player=Vector2(730,282)
	await create_timer(2.6).timeout
	await save_frame("casa-henrique-noite.png")
	game.act("interact")
	assert(game.stage==6)
	game.ui.finish_typing()
	await save_frame("casa-descanso-prologo.png")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()

func settle_attack(game: Node) -> void:
	for i in range(60):
		if game.combat.shots.is_empty(): return
		game._process(0.02)
	assert(false,"Attack must resolve within its maximum flight time")
