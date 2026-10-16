extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func close_dialogue(game: Node) -> void:
	while not game.lines.is_empty(): game.next_line()

func key(code: Key) -> void:
	for pressed in [true,false]:
		var event:=InputEventKey.new()
		event.keycode=code
		event.physical_keycode=code
		event.pressed=pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()

func touch(at: Vector2) -> void:
	for pressed in [true,false]:
		var event:=InputEventScreenTouch.new()
		event.index=9
		event.position=at
		event.pressed=pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()
	# Android's mouse copy must not count a second hit or close the result.
	for pressed in [true,false]:
		var mouse:=InputEventMouseButton.new()
		mouse.device=InputEvent.DEVICE_ID_EMULATION
		mouse.button_index=MOUSE_BUTTON_LEFT
		mouse.position=at
		mouse.pressed=pressed
		Input.parse_input_event(mouse)
		Input.flush_buffered_events()

func reach_zone(practice: Node) -> void:
	for i in range(300):
		if practice.tap_lock<=0 and practice.phase>=0.45 and practice.phase<=0.6: return
		practice._process(0.02)
	assert(false,"The moving cursor must reach the valid zone")

func run_checks() -> void:
	root.size=Vector2i(960,540)
	var game=load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled=false
	game.savegame.path="user://practice-test-%d.json" % OS.get_process_id()
	root.add_child(game)
	await process_frame
	game.audio.set_enabled(false)
	close_dialogue(game)
	var practice:Control=game.ui.practice
	practice.start()
	assert(not practice.visible,"Practice must not be accessible in the training field")
	game.stage=2
	game.player=game.layout.interiors.ACADEMY_DOOR
	await game.travel_to("academy")
	game.player=Vector2(480,335)
	assert(not game.blocked(game.player),"Practice spot must be on free floor")
	game.act("interact")
	assert(not practice.visible and not game.lines.is_empty(),"Iruka's introduction must precede the optional exercise")
	close_dialogue(game)
	game.player=Vector2(480,270)
	game.act("interact")
	close_dialogue(game)
	game.player=Vector2(480,335)
	game.act("interact")
	assert(not practice.visible and game.lines[0].contains("quadro"))
	close_dialogue(game)
	game.player=Vector2(365,207)
	game.act("interact")
	close_dialogue(game)
	game.player=Vector2(480,335)
	game.held["right"]=true
	game.act("interact")
	assert(practice.visible and game.ui.modal_open() and game.held.is_empty())
	assert(practice.portrait.texture!=null)
	for panel in practice.get_children():
		if panel is Panel:
			for child in panel.get_children():
				if child is Label:
					assert(child.get_rect().end.x<=panel.size.x-16,"Text must fit the practice panel")
	var at:Vector2=game.player
	var chakra:float=game.chakra
	game._process(2.0)
	game.act("dodge")
	game.ui.journal.toggle()
	assert(game.player==at and game.chakra==chakra and game.dash_time==0 and not game.ui.journal.visible)
	key(KEY_E)
	assert(practice.successes==0 and practice.feedback.text.contains("fora"),"An early press must miss without a penalty")
	reach_zone(practice)
	touch(practice.confirm_button.get_global_rect().get_center())
	assert(practice.successes==1,"Touch and emulated mouse must count once")
	practice.confirm()
	assert(practice.successes==1,"Rapid repeated input must be ignored")
	practice._notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	var phase:float=practice.phase
	practice._process(3.0)
	assert(practice.paused and practice.phase==phase,"Losing focus must pause timing until explicit resume")
	key(KEY_E)
	assert(not practice.paused and practice.successes==1)
	reach_zone(practice)
	key(KEY_E)
	assert(practice.successes==2)
	practice._process(0.5)
	# A deliberate miss must preserve previous successes.
	while practice.phase<0.8: practice._process(0.02)
	practice.confirm()
	assert(practice.successes==2)
	game.savegame.enabled=true
	reach_zone(practice)
	touch(practice.confirm_button.get_global_rect().get_center())
	assert(practice.successes==3 and practice.finished and practice.visible)
	assert(game.visited["chakra_drill"] and game.stage==2 and game.chakra==chakra,"The reward must not skip story stages or consume chakra")
	var saved:Dictionary=game.savegame.read_save()
	assert(saved.visited["chakra_drill"],"Completion must persist immediately")
	practice._process(0.5)
	key(KEY_E)
	assert(not practice.visible and not game.ui.modal_open())
	game.ui.journal.toggle()
	assert(game.ui.journal.discovery_rows[5].text.begins_with("✓"))
	game.ui.journal.close()
	game.act("interact")
	reach_zone(practice)
	key(KEY_E)
	key(KEY_ESCAPE)
	assert(not practice.visible and game.visited["chakra_drill"],"Cancelling a replay must preserve previous completion")
	game.act("interact")
	assert(game.savegame.apply(game,saved) and not practice.visible)
	var legacy:Dictionary=saved.duplicate(true)
	legacy["visited"].erase("chakra_drill")
	assert(game.savegame.apply(game,legacy) and not game.visited["chakra_drill"])
	var invalid:Dictionary=saved.duplicate(true)
	invalid["visited"]["chakra_drill"]="invalid"
	assert(not game.savegame.validate(invalid))
	await game.travel_to("outside")
	game.player=Vector2(560,280)
	game.act("interact")
	close_dialogue(game)
	assert(game.stage==3,"The main story must continue without completing the optional exercise")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.savegame.path))
	game.savegame.enabled=false
	print("PASS: optional academy practice, prerequisites, timing, misses, touch deduplication, focus pause, completion, saves and story continuation")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
