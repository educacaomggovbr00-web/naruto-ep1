extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func close_dialogue(game: Node) -> void:
	while not game.lines.is_empty(): game.next_line()

func save_frame(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var folder := OS.get_environment("NARUTO_PREVIEW_DIR")
	assert(not folder.is_empty())
	assert(root.get_texture().get_image().save_png(folder.path_join(name)) == OK)
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
	game.player=Vector2(185,280)
	game.attack_flash=0
	for i in range(15): await process_frame
	await create_timer(2.1).timeout
	await save_frame("personagens-anexados-konoha.png")
	game.player=game.layout.interiors.ACADEMY_DOOR
	await game.travel_to("academy")
	game.player=Vector2(300,207)
	game.act("interact")
	game.ui.finish_typing()
	await save_frame("sasuke-dialogo-anexo.png")
	close_dialogue(game)
	await game.travel_to("outside")
	game.player=Vector2(560,280)
	game.act("interact")
	while game.line_index<2:game.next_line()
	game.ui.finish_typing()
	await save_frame("iruka-dialogo-anexo.png")
	close_dialogue(game)
	assert(game.stage==3)
	game.player=game.mizuki-Vector2(180,0)
	game.held["sneak"]=true
	for i in range(8):await process_frame
	await save_frame("mizuki-floresta-anexo.png")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()

func settle_attack(game: Node) -> void:
	for i in range(60):
		if game.combat.shots.is_empty(): return
		game._process(0.02)
	assert(false,"Attack must resolve within its maximum flight time")
