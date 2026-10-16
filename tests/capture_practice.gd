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

func wait_for_zone(practice: Control) -> void:
	for i in range(600):
		if practice.tap_lock<=0 and practice.phase>=0.46 and practice.phase<0.58: return
		await process_frame
	assert(false,"Practice cursor did not reach its zone")

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
	for i in range(3):
		game.cooldown=0
		game.act("kunai")
		settle_attack(game)
	close_dialogue(game)
	game.cooldown=0
	game.act("katon")
	settle_attack(game)
	close_dialogue(game)
	game.player=game.layout.interiors.ACADEMY_DOOR
	await game.travel_to("academy")
	game.player=Vector2(480,270)
	game.act("interact")
	close_dialogue(game)
	game.player=Vector2(365,207)
	game.act("interact")
	close_dialogue(game)
	game.player=Vector2(480,335)
	await create_timer(2.6).timeout
	await save_frame("academia-ponto-de-treino.png")
	game.act("interact")
	var practice:Control=game.ui.practice
	assert(practice.visible)
	await wait_for_zone(practice)
	await save_frame("academia-controle-de-chakra.png")
	for i in range(3):
		await wait_for_zone(practice)
		practice.confirm()
	assert(practice.finished and game.visited["chakra_drill"])
	await save_frame("academia-treino-concluido.png")
	practice.close()
	game.ui.journal.toggle()
	assert(game.ui.journal.discovery_rows[5].text.begins_with("✓"))
	await save_frame("diario-treino-registrado.png")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
