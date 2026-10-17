extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func close_dialogue(game:Node) -> void:
	while not game.lines.is_empty(): game.next_line()

func frame(name:String) -> void:
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
	game.stage=6
	game.room="home"
	game.continue_story()
	close_dialogue(game)
	await create_timer(0.3).timeout
	await frame("episodio-1-manha-em-casa.png")
	await game.travel_to("outside")
	game.player=game.layout.interiors.ACADEMY_DOOR
	await game.travel_to("academy")
	game.player=Vector2(480,270)
	game.act("interact")
	game.ui.finish_typing()
	await frame("episodio-1-iruka-chamada.png")
	close_dialogue(game)
	game.player=game.episode.SEAT
	game.act("interact")
	close_dialogue(game)
	game.player=Vector2(480,335)
	await frame("episodio-1-avaliacao.png")
	game.act("interact")
	game.ui.finish_typing()
	await frame("episodio-1-bunshin.png")
	close_dialogue(game)
	await game.travel_to("outside")
	game.player=Vector2(597,275)
	game.act("interact")
	game.ui.finish_typing()
	await frame("episodio-1-naruto-patio.png")
	close_dialogue(game)
	game.ui.journal.toggle()
	await frame("episodio-1-diario.png")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
