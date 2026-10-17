extends SceneTree
func _initialize() -> void: call_deferred("checks")
func touch(duel: Node, index: int, point: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index=index
	event.position=point
	event.pressed=pressed
	duel._input(event)
func checks() -> void:
	root.size=Vector2i(960,540)
	var game=load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled=false
	root.add_child(game)
	await process_frame
	game.set_process(false)
	while not game.lines.is_empty(): game.next_line()
	var duel=game.duel
	duel.set_process(false)
	assert(not duel.offer(),"Story must protect duel entry")
	game.stage=2
	game.episode.step=7
	game.world.district="training"
	game.layout.district="training"
	var position: Vector2=game.player
	var chakra: float=game.chakra
	assert(duel.offer() and game.ui.modal_open())
	touch(duel,0,duel.start_button.get_global_rect().get_center(),true)
	assert(duel.mode=="fight")
	for i in range(90): duel._process(1.0/60)
	touch(duel,1,Vector2(154,468),true)
	touch(duel,2,Vector2(712,380),true)
	assert(duel.held.get("right",false) and duel.held.get("guard",false))
	touch(duel,1,Vector2(154,468),false)
	assert(not duel.held.has("right") and duel.held.has("guard"))
	duel._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert(duel.mode=="pause" and duel.held.is_empty())
	var timer: float=duel.model.clock
	duel._process(1)
	assert(duel.model.clock==timer)
	duel.menu_start()
	assert(duel.mode=="fight")
	duel.model.player_rounds=2
	duel.model.max_combo=3
	duel.model.phase="complete"
	duel._process(0)
	duel.record_result()
	assert(game.sparring_stats.wins==1 and game.sparring_stats.best_combo==3)
	var save: Dictionary=game.savegame.snapshot(game)
	assert(game.savegame.validate(save))
	var old_save: Dictionary=save.duplicate(true)
	old_save.erase("duels")
	assert(game.savegame.validate(old_save))
	duel.close()
	assert(not game.ui.modal_open() and game.player==position and game.chakra==chakra and game.episode.step==7)
	assert(game.sparring_stats.wins==1)
	assert(game.savegame.apply(game,old_save) and game.sparring_stats.wins==0)
	assert(game.savegame.apply(game,save) and game.sparring_stats.wins==1)
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	print("PASS: RPG integration, multitouch, focus pause, result idempotence and compatible saves")
	quit()
