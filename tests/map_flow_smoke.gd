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
	game.route_guide.enabled=true
	game.player=Vector2(170,270)
	game.route_guide.update(game,0)
	assert(not game.route_guide.points.is_empty())
	for point in game.route_guide.points: assert(not game.blocked(point))
	var rebuilds:int=game.route_guide.rebuilds
	for i in range(30): game.route_guide.update(game,1.0/60)
	assert(game.route_guide.rebuilds==rebuilds,"Static map navigation must be cached")
	# Safe route across the bridge; no guide points through the water.
	game.player=Vector2(400,405)
	game.route_guide.update(game,1)
	assert(not game.route_guide.points.is_empty())
	for point in game.route_guide.points:
		assert(not game.layout.WATER.has_point(point) or game.layout.BRIDGE.has_point(point))
	# Direct navigation in the house has to go around the table.
	game.room="home"
	game.stage=5
	game.player=Vector2(480,439)
	game.route_guide.update(game,1)
	assert(not game.route_guide.points.is_empty())
	for point in game.route_guide.points: assert(not game.blocked(point))
	assert(game.route_guide.points[-1].distance_to(Vector2(730,282))<30)
	game.stage=3
	game.room="outside"
	game.route_guide.update(game,0)
	assert(game.route_guide.points.is_empty(),"Guide cannot disclose the pursuit route")
	game.stage=2
	game.route_guide.enabled=false
	game.route_guide.update(game,0)
	assert(game.route_guide.points.is_empty())
	game.route_guide.enabled=true
	# Exact acceleration integral: same start/stop trip at 30 and 60 FPS.
	var positions=[]
	for fps in [30,60]:
		game.player=Vector2(260,280)
		game.motion_velocity=Vector2.ZERO
		for i in range(fps/2): game.advance_motion(Vector2.RIGHT,180,1.0/fps)
		game.advance_motion(Vector2.ZERO,180,1.0/fps)
		positions.append(game.player)
	assert(positions[0].distance_to(positions[1])<0.05)
	# A single delayed frame must not launch the player across the map.
	game.player=Vector2(260,280)
	game.motion_velocity=Vector2.RIGHT*240
	game.advance_motion(Vector2.RIGHT,240,1.0)
	assert(game.player.x-260<=28.81)
	# Camera dead zone is quiet near the center; look ahead stays within image.
	game.cinematic.camera.position=Vector2(480,270)
	game.cinematic.look_ahead=Vector2.ZERO
	game.player=Vector2(500,280)
	game.movement=Vector2.ZERO
	game.motion_velocity=Vector2.ZERO
	game.cinematic._process(0.5)
	assert(game.cinematic.camera.position==Vector2(480,270))
	game.player=Vector2(935,414)
	game.motion_velocity=Vector2.RIGHT*240
	game.movement=Vector2.RIGHT
	for i in range(60): game.cinematic._process(1.0/60)
	var camera:Camera2D=game.cinematic.camera
	var half:=Vector2(480,270)/camera.zoom
	assert(camera.position.x-half.x>=0 and camera.position.x+half.x<=960)
	assert(camera.position.y-half.y>=0 and camera.position.y+half.y<=540)
	game.cinematic.motion_enabled=false
	game.cinematic._process(0.5)
	assert(camera.offset==Vector2.ZERO)
	game.ui.toggle_settings()
	assert(game.ui.settings_panel.position.y+game.ui.settings_panel.size.y<=528)
	var route_toggle:CheckButton
	for child in game.ui.settings_panel.get_children():
		if child is CheckButton and child.text=="Guia de caminho no chão": route_toggle=child
	assert(route_toggle!=null)
	var original:bool=route_toggle.button_pressed
	route_toggle.button_pressed=false
	var preferences:=ConfigFile.new()
	assert(preferences.load("user://interface.cfg")==OK)
	assert(not bool(preferences.get_value("world","route_guide",true)) and not game.route_guide.enabled)
	route_toggle.button_pressed=original
	game.ui.toggle_settings()
	print("PASS: cached obstacle-aware route, bridge, home furniture, protected pursuit, 30/60 FPS travel, slow frames, camera bounds and settings")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
