extends SceneTree

var folder: String
var frame_index:=0
const STEP:=1.0/15.0

func _initialize() -> void:
	call_deferred("capture")

func close_dialogue(game: Node) -> void:
	while not game.lines.is_empty(): game.next_line()

func tick(game: Node, delta: float) -> void:
	game._process(delta)
	game.background._process(delta)
	game.cinematic._process(delta)
	game.ui._process(delta)

func draw_frame() -> void:
	await process_frame
	await RenderingServer.frame_post_draw

func screenshot(name: String) -> void:
	await draw_frame()
	assert(root.get_texture().get_image().save_png(folder.path_join(name))==OK)
	print("CAPTURE: ",name)

func movie_frame() -> void:
	await draw_frame()
	assert(root.get_texture().get_image().save_png(folder.path_join("frames/frame_%04d.png" % frame_index))==OK)
	frame_index+=1

func settle_attack(game: Node) -> void:
	for i in range(60):
		if game.combat.shots.is_empty(): return
		tick(game,0.02)
	assert(false)

func capture() -> void:
	folder=OS.get_environment("NARUTO_PREVIEW_DIR")
	assert(not folder.is_empty())
	DirAccess.make_dir_recursive_absolute(folder.path_join("frames"))
	root.size=Vector2i(960,540)
	var game=load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled=false
	root.add_child(game)
	await process_frame
	game.audio.set_enabled(false)
	close_dialogue(game)
	# Fixed simulation steps record real gameplay at a reproducible 15 frames/s.
	for node in [game,game.background,game.cinematic,game.ui,game.audio]: node.set_process(false)
	game.day_cycle.set_mode(1)
	game.player=Vector2(106,244)
	tick(game,0)
	game.act("interact")
	for i in range(45):
		tick(game,STEP)
		await movie_frame()
		if i==8: await screenshot("galho-e-vento.png")
	game.player=game.target-Vector2(100,0)
	game.facing=Vector2.RIGHT
	for i in range(3):
		game.cooldown=0
		game.act("kunai")
		settle_attack(game)
	close_dialogue(game)
	game.cooldown=0
	game.act("katon")
	settle_attack(game)
	close_dialogue(game)
	assert(game.stage==2)
	game.player=Vector2(471,309)
	tick(game,0)
	game.act("interact")
	for i in range(30):
		tick(game,STEP)
		await movie_frame()
		if i==5: await screenshot("agua-interativa.png")
	game.player=Vector2(350,280)
	tick(game,STEP)
	game.player=Vector2(495,292)
	for i in range(30):
		tick(game,STEP)
		await movie_frame()
		if i==4: await screenshot("hiruzen-reagindo.png")
	game.player=game.layout.interiors.ACADEMY_DOOR
	await game.travel_to("academy")
	game.player=Vector2(480,285)
	tick(game,0)
	game.held["up"]=true
	for i in range(3): tick(game,STEP)
	game.ui.release_touches()
	for i in range(30):
		tick(game,STEP)
		await movie_frame()
		if i==4: await screenshot("iruka-reagindo.png")
	game.act("interact")
	assert(game.visited.class_intro)
	close_dialogue(game)
	print("MOVIE: ",frame_index," frames at 15 fps")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
