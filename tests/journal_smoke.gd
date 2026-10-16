extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func close_dialogue(game: Node) -> void:
	while not game.lines.is_empty(): game.next_line()

func press_key(code: Key) -> void:
	var event:=InputEventKey.new()
	event.keycode=code
	event.physical_keycode=code
	event.pressed=true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	event=event.duplicate()
	event.pressed=false
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func touch(at: Vector2) -> void:
	for pressed in [true,false]:
		var event:=InputEventScreenTouch.new()
		event.index=8
		event.position=at
		event.pressed=pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()

func run_checks() -> void:
	root.size=Vector2i(960,540)
	var game=load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled=false
	game.savegame.path="user://journal-test.json"
	root.add_child(game)
	await process_frame
	game.audio.set_enabled(false)
	game.ui.journal.toggle()
	assert(not game.ui.journal.visible,"Journal must not interrupt dialogue")
	close_dialogue(game)
	game.ui._process(0)
	touch(game.ui.journal_button.get_global_rect().get_center())
	assert(game.ui.journal.visible,"Touch must open the journal without mouse emulation")
	touch(game.ui.journal.close_button.get_global_rect().get_center())
	assert(not game.ui.journal.visible,"Touch must close the journal")
	game.act("kunai")
	game.cooldown=0.08
	game.act("katon")
	game.held["right"]=true
	press_key(KEY_M)
	assert(game.ui.journal.visible and game.ui.modal_open(),"M must open the journal")
	assert(game.held.is_empty() and game.combat.shots.is_empty() and game.combat.buffered.is_empty())
	for button in game.ui.touch_buttons: assert(not button.visible,"Journal must hide gameplay controls immediately")
	assert(game.ui.journal.mission.text.contains("0 / 3"))
	assert(game.ui.journal.progress.size.y<=10,"Progress must not overlap chapter text")
	assert(game.ui.journal.chapter_rows[3].text.contains("Ainda não revelado"),"Future story must remain hidden")
	var at:Vector2=game.player
	var chakra:float=game.chakra
	var cooldown:float=game.cooldown
	game._process(3.0)
	game.act("dodge")
	assert(game.player==at and game.chakra==chakra and game.cooldown==cooldown and game.dash_time==0,"Journal must pause simulation")
	press_key(KEY_ESCAPE)
	assert(not game.ui.modal_open(),"Escape must return to play")
	game.stage=3
	game.trail_progress=4.0
	game.ui.journal.toggle()
	game._process(2.0)
	assert(game.trail_progress==4.0,"Reading must not advance stealth")
	game.ui.journal.close()
	game.stage=2
	game.room="home"
	game.player=Vector2(225,220)
	game.act("interact")
	assert(game.visited["notes"] and not game.lines.is_empty())
	close_dialogue(game)
	game.ui.journal.toggle()
	assert(game.ui.journal.discovery_rows[4].text.begins_with("✓"))
	assert(game.ui.journal.guidance.text.contains("saída"),"Indoor hints must explain how to resume the main objective")
	game.savegame.enabled=true
	assert(game.save_checkpoint(false))
	var saved:Dictionary=game.savegame.read_save()
	assert(saved.visited["notes"])
	game.visited["notes"]=false
	assert(game.savegame.apply(game,saved))
	assert(game.visited["notes"] and not game.ui.journal.visible,"Loading must restore notes and close the journal")
	var legacy:Dictionary=saved.duplicate(true)
	legacy["visited"].erase("notes")
	assert(game.savegame.apply(game,legacy) and not game.visited["notes"],"Existing v1 saves must default missing notes to false")
	var invalid:Dictionary=saved.duplicate(true)
	invalid["visited"]["notes"]="invalid"
	assert(not game.savegame.validate(invalid))
	game.ui.journal.toggle()
	game.ui.toggle_settings()
	assert(game.ui.settings_panel.visible and not game.ui.journal.visible,"Menus must not stack")
	game.ui.toggle_settings()
	game.stage=5
	game.ui.journal.toggle()
	assert(game.ui.journal.guidance.text.contains("mesa"))
	game.ui.journal.close()
	game.stage=6
	game.ui.journal.toggle()
	assert(game.ui.journal.progress.value==6 and game.ui.journal.mission.text=="Prólogo concluído")
	game.ui.journal.close()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.savegame.path))
	game.savegame.enabled=false
	print("PASS: journal keyboard, modal pause, input cancellation, spoiler hiding, room hints, notes save and legacy compatibility")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
