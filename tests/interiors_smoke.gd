extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func close_dialogue(game: Node) -> void:
	while not game.lines.is_empty(): game.next_line()

func finish_travel(game: Node) -> void:
	while game.travelling: await process_frame

func run_checks() -> void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled=false
	game.savegame.path="user://interiors-test-save.json"
	root.add_child(game)
	await process_frame
	close_dialogue(game)
	game.stage=2
	game.player=game.layout.interiors.ACADEMY_DOOR
	game.held["right"]=true
	game.act("interact")
	assert(game.travelling and game.held.is_empty())
	var start: Vector2=game.player
	game._process(0.2)
	assert(game.player==start,"Transitions must lock movement")
	await finish_travel(game)
	assert(game.room=="academy" and game.background.area==3 and game.visited["academy"])
	assert(not game.blocked(game.player) and not game.travelling)
	game.move_with_collisions(Vector2(0,-135))
	assert(game.player.y<320,"The central classroom aisle must be traversable")
	game.player=Vector2(360,270)
	game.move_with_collisions(Vector2(-230,0))
	assert(game.player.x>=335,"Desks must block their painted footprint")
	game.player=Vector2(480,270)
	game.act("interact")
	assert(game.lines[0].begins_with("Iruka:") and game.visited["class_intro"])
	close_dialogue(game)
	for point in [Vector2(300,207),Vector2(685,207),Vector2(365,207)]:
		game.player=point
		game.act("interact")
		assert(not game.lines.is_empty())
		close_dialogue(game)
	assert(game.visited["board"])
	var chakra: float=game.chakra
	game.act("katon")
	game.act("dodge")
	assert(game.chakra==chakra and game.attack_flash==0 and game.dash_time==0)
	game.player=Vector2(480,300)
	game.savegame.enabled=true
	assert(game.save_checkpoint(false))
	var classroom: Dictionary=game.savegame.read_save()
	game.room="outside"
	assert(game.savegame.apply(game,classroom))
	assert(game.room=="academy" and game.player==Vector2(480,300) and game.visited["class_intro"])
	assert(game.background.area==3 and game.audio.ambient.volume_db==-40)
	await game.travel_to("outside")
	assert(game.room=="outside" and game.player.distance_to(game.layout.interiors.ACADEMY_DOOR)<32)
	assert(game.audio.ambient.volume_db==-28)
	game.player=game.layout.HOME
	game.act("interact")
	await finish_travel(game)
	assert(game.room=="home" and game.background.area==4 and game.visited["home"])
	game.move_with_collisions(Vector2(0,-260))
	assert(game.player.y>=345,"The table and cushions must block direct passage")
	game.player=Vector2(480,439)
	game.move_with_collisions(Vector2(200,0))
	game.move_with_collisions(Vector2(0,-140))
	assert(game.player.y<310 and game.player.x>=670,"A clear route must reach the bed around the table")
	for point in [Vector2(225,220),Vector2(470,207),Vector2(730,282)]:
		game.player=point
		game.act("interact")
		assert(not game.lines.is_empty())
		close_dialogue(game)
	assert(game.stage==2,"The bed must not skip the prologue")
	game.player=Vector2(480,430)
	assert(game.save_checkpoint(false))
	var house: Dictionary=game.savegame.read_save()
	game.room="outside"
	assert(game.savegame.apply(game,house) and game.room=="home")
	await game.travel_to("outside")
	var legacy: Dictionary=game.savegame.snapshot(game)
	legacy.erase("room")
	legacy.erase("return_position")
	legacy.erase("visited")
	legacy["player"]=[560,280]
	assert(game.savegame.apply(game,legacy))
	assert(game.room=="outside" and game.player==Vector2(560,280))
	var invalid: Dictionary=legacy.duplicate(true)
	invalid["room"]="missing-room"
	assert(not game.savegame.apply(game,invalid))
	invalid["room"]="home"
	invalid["stage"]=3
	assert(not game.savegame.validate(invalid))
	game.stage=5
	game.player=game.layout.HOME
	game.act("interact")
	await finish_travel(game)
	game.player=Vector2(730,282)
	game.act("interact")
	assert(game.room=="home" and game.stage==6 and not game.restart.visible,"Finish reading before continuing the story")
	close_dialogue(game)
	assert(game.restart.visible and game.restart.text.contains("CONTINUAR"))
	assert(game.save_checkpoint(false))
	var completed: Dictionary=game.savegame.read_save()
	assert(game.savegame.apply(game,completed) and game.room=="home" and game.stage==6)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.savegame.path))
	game.savegame.enabled=false
	print("PASS: room doors/fades, blocked furniture, open aisles, classroom/house interactions, indoor attacks, room saves, legacy saves and bed ending")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
