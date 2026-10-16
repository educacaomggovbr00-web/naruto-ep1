extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func close_dialogue(game: Node) -> void:
	while not game.lines.is_empty(): game.next_line()

func run_checks() -> void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled=false
	root.add_child(game)
	await process_frame
	game.audio.set_enabled(false)
	var cycle=game.day_cycle
	var phase:float=cycle.phase
	game._process(2.0)
	assert(cycle.phase==phase,"Dialogue must not consume the day")
	close_dialogue(game)
	game._process(1.0)
	assert(cycle.phase>phase and cycle.elapsed>0)
	game.ui.journal.toggle()
	phase=cycle.phase
	var elapsed:float=cycle.elapsed
	game._process(5.0)
	assert(cycle.phase==phase and cycle.elapsed==elapsed,"Journal must pause the world clock and environment")
	game.ui.journal.close()
	game.ui.toggle_settings()
	game.ui.light_selector.item_selected.emit(1)
	assert(cycle.mode==1 and cycle.hour(0)==9 and cycle.night_amount(0)==0)
	phase=cycle.phase
	game._process(5.0)
	assert(cycle.phase==phase,"Settings must pause the clock")
	game.ui.light_selector.item_selected.emit(3)
	assert(cycle.mode==3 and cycle.is_night(0) and game.audio.night)
	game.ui.toggle_settings()
	game._process(2.0)
	assert(cycle.hour(0)==22,"Manual light must remain fixed")
	game.ui.change_light(0)
	cycle.phase=0.999
	game._process(2.0)
	assert(cycle.phase>=0 and cycle.phase<0.01,"Automatic days must wrap")
	var morning_bird:Dictionary=cycle.bird_pose(1)
	game._process(0.2)
	var later_bird:Dictionary=cycle.bird_pose(1)
	assert(morning_bird["at"]!=later_bird["at"] and morning_bird["wing"]!=later_bird["wing"],"Birds must travel and flap")
	game.stage=2
	game.ui.change_light(1)
	game.player=game.layout.HOME
	await game.travel_to("home")
	game.ui.change_light(3)
	assert(game.background.night and game.background.previous_environment!=null,"House lights must crossfade between real paintings")
	game.ui.change_light(1)
	assert(not game.background.night)
	await game.travel_to("outside")
	game.player=Vector2(360,280)
	game.held["right"]=true
	var old_gait:float=game.gait_distance
	game._process(0.2)
	assert(game.gait_distance>old_gait)
	game.ui.release_touches()
	old_gait=game.gait_distance
	game._process(0.2)
	assert(game.gait_distance==old_gait,"Standing still must not advance walking frames")
	cycle.set_mode(2)
	var saved:Dictionary=game.savegame.snapshot(game)
	assert(game.savegame.validate(saved))
	cycle.set_mode(3)
	assert(game.savegame.apply(game,saved))
	assert(cycle.mode==2 and is_equal_approx(cycle.phase,float(saved.day_cycle.phase)))
	var legacy:Dictionary=saved.duplicate(true)
	legacy.erase("day_cycle")
	assert(game.savegame.apply(game,legacy) and cycle.mode==0 and is_equal_approx(cycle.phase,cycle.DEFAULT_PHASE),"Old saves must receive the original afternoon")
	for bad in [{"phase":0.5,"mode":1.5},{"phase":-1,"mode":0},{"phase":0.5,"mode":"bad"}]:
		var invalid:Dictionary=saved.duplicate(true)
		invalid["day_cycle"]=bad
		assert(not game.savegame.validate(invalid))
	game.stage=3
	cycle.set_mode(1)
	assert(cycle.hour(game.stage)==21 and cycle.is_night(game.stage),"The night pursuit must override free exploration time")
	game.ui._process(0)
	assert(game.ui.light_selector.disabled)
	var mode:int=cycle.mode
	game.ui.change_light(2)
	assert(cycle.mode==mode,"Light controls must not override story night")
	game.cinematic._process(1.0)
	assert(game.cinematic.material.get_shader_parameter("night_amount")>0.8)
	assert(game.background.foliage.shader!=null)
	assert(game.audio.night_stream.loop_mode==AudioStreamWAV.LOOP_FORWARD)
	print("PASS: automatic/manual lighting, pause, birds, home transition, distance-based walking, old/new saves and protected story night")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
