extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func close_dialogue(game:Node) -> void:
	while not game.lines.is_empty(): game.next_line()

func walk_to(game:Node, destination:Vector2) -> void:
	var grid:=AStarGrid2D.new()
	grid.region=Rect2i(0,0,121,68)
	grid.cell_size=Vector2(8,8)
	grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.update()
	for y in range(68):
		for x in range(121):
			var at:=Vector2(x*8,y*8)
			grid.set_point_solid(Vector2i(x,y),game.blocked(at) or game.layout.clamp_position(at,game.stage,game.room)!=at)
	var from:=Vector2i((game.player/8).round())
	var to:=Vector2i((destination/8).round())
	var path:=grid.get_point_path(from,to)
	assert(not path.is_empty(),"Story interaction must be reachable around furniture")
	for at in path:
		game.move_with_collisions(at-game.player)
		assert(game.player.distance_to(at)<1,"Walking the route must respect collisions")
	assert(game.player.distance_to(destination)<8)

func run_checks() -> void:
	root.size=Vector2i(960,540)
	var game=load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled=false
	root.add_child(game)
	await process_frame
	game.set_process(false)
	close_dialogue(game)
	game.stage=6
	game.room="home"
	game.continue_story()
	assert(game.episode.step==1 and game.stage==2 and game.room=="home")
	assert(game.day_cycle.hour(2)==7.5)
	close_dialogue(game)
	game.continue_story()
	assert(game.episode.step==1,"Continuing twice must not reset story")
	walk_to(game,Vector2(480,442))
	await game.travel_to("outside")
	assert(game.episode.step==2 and game.room=="outside")
	# Naruto cannot trigger the old nocturnal prologue a second time.
	game.player=game.layout.NARUTO-Vector2(40,0)
	game.act("interact")
	close_dialogue(game)
	assert(game.stage==2 and not game.pending_forest_transition and game.episode.step==2)
	game.player=game.layout.interiors.ACADEMY_DOOR
	await game.travel_to("academy")
	assert(game.blocked(game.episode.CLASS_NARUTO))
	walk_to(game,Vector2(480,270))
	game.act("interact")
	assert(game.episode.step==3)
	close_dialogue(game)
	walk_to(game,game.episode.SEAT)
	assert(not game.blocked(game.player))
	game.act("interact")
	assert(game.episode.step==4)
	close_dialogue(game)
	walk_to(game,game.episode.EXAM)
	game.ui.refresh_controls()
	var touch:=InputEventScreenTouch.new()
	touch.index=8
	touch.position=Vector2(889,485)
	touch.pressed=true
	Input.parse_input_event(touch)
	Input.flush_buffered_events()
	await process_frame
	touch.pressed=false
	Input.parse_input_event(touch)
	Input.flush_buffered_events()
	await process_frame
	assert(game.episode.step==5 and game.episode.echo_time>0)
	# Saving mid-dialogue must resume the same line and lesson beat.
	game.savegame.enabled=true
	game.savegame.path="user://episode_smoke_save.json"
	assert(game.save_checkpoint(false))
	var data:Dictionary=game.savegame.read_save()
	assert(not data.is_empty())
	var first_line:String=game.lines[0]
	game.episode.step=1
	game.lines.clear()
	assert(game.savegame.apply(game,data))
	assert(game.episode.step==5 and game.lines[0]==first_line)
	close_dialogue(game)
	await game.travel_to("outside")
	game.player=game.layout.NARUTO-Vector2(40,0)
	game.act("interact")
	assert(game.episode.step==6 and game.stage==2)
	close_dialogue(game)
	game.player=game.layout.HOME
	await game.travel_to("home")
	walk_to(game,Vector2(225,220))
	game.act("interact")
	assert(game.episode.step==7 and game.visited.notes)
	close_dialogue(game)
	game.ui.journal.toggle()
	assert(game.ui.journal.mission.text==game.episode.TITLES[7])
	game.ui.journal.close()
	game.ui.refresh_controls()
	for button in game.ui.touch_buttons:
		if button.get_meta("action") in ["katon","kunai","dodge","sneak"]: assert(not button.visible)
	game.act("katon")
	assert(game.combat.shots.is_empty())
	var old:Dictionary=data.duplicate(true)
	old.erase("episode_step")
	assert(game.savegame.apply(game,old) and game.episode.step==0,"Old saves remain in original prologue")
	for bad in [-1,8,2.5,"3",null]:
		var invalid:Dictionary=data.duplicate(true)
		invalid.episode_step=bad
		assert(not game.savegame.validate(invalid))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.savegame.path))
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	print("PASS: narrative morning, class, clone exam, Naruto, return home, old and new saves, contextual controls")
	quit()
