extends SceneTree
func _initialize() -> void: call_deferred("checks")
func dismiss(game:Node) -> void:
	while not game.lines.is_empty(): game.next_line()
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
	game.player=Vector2(580,410)
	var world=game.population
	assert(world.agents.size()==4 and world.manifest.actors.size()==4)
	for actor in world.manifest.actors.values():
		assert(actor.frames.size()==4 and actor.scale>0)
		for frame in actor.frames:
			assert(frame.origin[1]<=frame.rect[3])
	var minimap_toggle:CheckButton
	for child in game.ui.settings_panel.get_children():
		if child is CheckButton and child.text=="Minimapa da vila": minimap_toggle=child
	assert(minimap_toggle!=null)
	var preference:bool=minimap_toggle.button_pressed
	minimap_toggle.button_pressed=false
	var config:=ConfigFile.new()
	assert(config.load("user://interface.cfg")==OK and not bool(config.get_value("world","minimap",true)))
	assert(not world.minimap_enabled)
	minimap_toggle.button_pressed=preference
	var original:Array=[]
	for a in world.agents: original.append(a.at)
	var movement:=0.0
	for i in range(400):
		world.update(game,0.05)
		for a in world.agents: assert(not game.blocked(a.at),"Civilian must stay on actual traversable ground")
	for i in range(4): movement+=world.agents[i].at.distance_to(original[i])
	assert(movement>25)
	var frozen:Vector2=world.agents[0].at
	game.ui.journal.toggle()
	game._process(1)
	assert(world.agents[0].at==frozen,"Menus pause civilian routines")
	game.ui.journal.close()
	# Optional delivery requires a second deliberate interaction, is saved, and
	# rewards only once. Walking past the merchant never starts it.
	var merchant:Dictionary=world.agents[0]
	merchant.at=Vector2(150,280)
	game.player=Vector2(150,320)
	assert(not game.visited.parcel_started)
	game.act("interact")
	assert(world.parcel_offered and not game.visited.parcel_started)
	dismiss(game)
	game.act("interact")
	assert(game.visited.parcel_started and game.stage==2 and game.episode.step==7)
	dismiss(game)
	game.player=Vector2(858,300)
	game.chakra=10
	game.stamina=10
	game.act("interact")
	assert(game.visited.parcel_delivered and game.chakra==30 and game.stamina==100)
	dismiss(game)
	game.act("interact")
	assert(game.chakra==30,"An already delivered package cannot grant a second reward")
	dismiss(game)
	var saved:Dictionary=game.savegame.snapshot(game)
	assert(game.savegame.apply(game,saved) and game.visited.parcel_delivered)
	var old:Dictionary=saved.duplicate(true)
	old.visited.erase("parcel_started")
	old.visited.erase("parcel_delivered")
	assert(game.savegame.apply(game,old) and not game.visited.parcel_started and not game.visited.parcel_delivered)
	var invalid:Dictionary=saved.duplicate(true)
	invalid.visited.parcel_started=false
	assert(not game.savegame.validate(invalid))
	# Nightfall sends residents to their exits, rather than teleporting across
	# the map or changing the main story. No civilians in the forest/interiors.
	world.reset()
	game.player=Vector2(580,410)
	game.day_cycle.set_mode(3)
	for i in range(3000): world.update(game,0.05)
	for a in world.agents: assert(a.hidden,"Civilian should return home by night")
	var night_save:Dictionary=game.savegame.snapshot(game)
	assert(game.savegame.apply(game,night_save))
	for a in world.agents: assert(a.hidden,"A late-night save must not respawn a daytime crowd")
	game.day_cycle.set_mode(1)
	world.update(game,0.05)
	assert(world.visible_agents(game).size()==4)
	game.room="home"
	assert(world.visible_agents(game).is_empty())
	game.room="outside"
	game.stage=3
	assert(world.visible_agents(game).is_empty())
	print("PASS: generated walk sprites, civilian routes/collisions, pause, optional delivery, one-time reward, saves and day/night routines")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
