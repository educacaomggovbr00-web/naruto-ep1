extends SceneTree
func _initialize() -> void: call_deferred("checks")
func dismiss(game:Node) -> void:
	while not game.lines.is_empty(): game.next_line()
func settle(game:Node) -> void:
	for i in range(90):
		if game.combat.shots.is_empty(): return
		game._process(0.02)
	assert(false,"Projectile must resolve")
func finish_travel(game:Node) -> void:
	while game.travelling: await process_frame
func checks() -> void:
	root.size=Vector2i(960,540)
	var game=load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled=false
	root.add_child(game)
	await process_frame
	game.set_process(false)
	dismiss(game)
	game.stage=2
	game.episode.step=7
	game.day_cycle.set_mode(1)
	assert(game.world.manifest.actors.size()==4)
	for actor in game.world.manifest.actors.values(): assert(actor.frames.size()==4)
	game.player=Vector2(38,292)
	game.act("interact")
	assert(game.travelling and game.held.is_empty())
	await finish_travel(game)
	assert(game.world.district=="residential" and game.background.area==5 and game.visited.residential)
	assert(game.lines.is_empty() and not game.blocked(game.player))
	assert(not game.population.active(game) and game.episode.extra_actors(game).is_empty())
	game.route_guide.update(game,1)
	assert(not game.route_guide.points.is_empty())
	var original:Vector2=game.world.locals[0].at
	game.player=Vector2(800,380)
	for i in range(90): game.world.update(game,0.05)
	assert(game.world.locals[0].at!=original)
	# A nearby pedestrian yields a little, stays inside the street, and stops in dialogue.
	var pedestrian:Dictionary=game.world.locals[0]
	game.player=pedestrian.at+Vector2(0,20)
	var before:Vector2=pedestrian.at
	game.world.update(game,0.05)
	assert(pedestrian.at.distance_to(game.player)>before.distance_to(game.player))
	assert(game.layout.clamp_position(pedestrian.at,2)==pedestrian.at)
	before=pedestrian.at
	game.world.update(game,1.0)
	assert(pedestrian.at.distance_to(before)<=2.41,"A slow frame must not teleport a yielding NPC")
	game.player=game.world.locals[0].at+Vector2(0,40)
	game.act("interact")
	assert(game.lines[0].begins_with("Guardião:"))
	before=pedestrian.at
	game.world.update(game,0.2)
	assert(pedestrian.at==before,"Conversation must pause pedestrians")
	dismiss(game)
	game.player=Vector2(90,265)
	game.act("interact")
	assert(game.lines[0].begins_with("AVISOS"))
	dismiss(game)
	game.savegame.path="user://open-world-smoke.json"
	game.savegame.enabled=true
	assert(game.save_checkpoint(false))
	var saved:Dictionary=game.savegame.read_save()
	assert(saved.district=="residential")
	game.savegame.enabled=false
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.savegame.path))
	assert(game.savegame.apply(game,saved) and game.world.district=="residential" and game.background.area==5)
	assert(not game.blocked(game.player))
	var invalid:Dictionary=saved.duplicate(true)
	invalid.stage=3
	assert(not game.savegame.validate(invalid))
	invalid=saved.duplicate(true)
	invalid.district="missing"
	assert(not game.savegame.validate(invalid))
	var old:Dictionary=saved.duplicate(true)
	old.erase("district")
	assert(game.savegame.apply(game,old) and game.world.district=="plaza" and game.layout.district=="plaza")
	# Traverse both routes using actual interaction and fade, not test-only scene switches.
	game.player=Vector2(922,292)
	game.act("interact")
	await finish_travel(game)
	assert(game.world.district=="training" and game.background.area==0 and game.visited.free_training)
	game.player=Vector2(450,280)
	game.facing=Vector2.RIGHT
	game.cooldown=0
	game.act("kunai")
	settle(game)
	assert(game.world.practice_hits==1 and game.stage==2 and game.episode.step==7)
	game.player=Vector2(450,280)
	game.facing=Vector2.RIGHT
	game.cooldown=0
	game.chakra=100
	game.act("katon")
	settle(game)
	assert(game.world.practice_hits==2 and game.chakra<100 and game.stage==2)
	game.player=Vector2(50,290)
	game.act("interact")
	await finish_travel(game)
	assert(game.world.district=="plaza" and game.background.area==1)
	# Doors and main characters keep priority over adjacent district exits.
	game.player=game.layout.HOME
	assert(game.world.nearby_portal(game).is_empty())
	game.player=Vector2(858,300)
	assert(game.world.nearby_portal(game).is_empty())
	game.stage=3
	assert(not game.world.active(game) and game.world.nearby_portal(game).is_empty())
	print("PASS: connected districts, native-style sprites, return paths, free practice, story/door priority and old/new district saves")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
