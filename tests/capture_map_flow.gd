extends SceneTree
const STEP:=1.0/15.0
var folder:String
var frame_number:=0
var caption:Label

func _initialize() -> void: call_deferred("capture")
func dismiss(game:Node) -> void:
	while not game.lines.is_empty(): game.next_line()
func frame(game:Node) -> void:
	game._process(STEP)
	game.background._process(STEP)
	game.cinematic._process(STEP)
	game.cinematic.area_title.hide()
	game.ui._process(STEP)
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(folder.path_join("frames/frame_%04d.png" % frame_number))==OK)
	frame_number+=1
func screenshot(name:String) -> void:
	assert(root.get_texture().get_image().save_png(folder.path_join(name))==OK)
func capture() -> void:
	root.size=Vector2i(960,540)
	folder=OS.get_environment("NARUTO_PREVIEW_DIR")
	assert(not folder.is_empty())
	DirAccess.make_dir_recursive_absolute(folder.path_join("frames"))
	var game=load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled=false
	root.add_child(game)
	await process_frame
	dismiss(game)
	game.audio.set_enabled(false)
	for node in [game,game.ui,game.background,game.cinematic]: node.set_process(false)
	var legend:=Panel.new()
	legend.position=Vector2(240,132)
	legend.size=Vector2(480,34)
	legend.add_theme_stylebox_override("panel",game.ui.panel_style())
	game.ui.add_child(legend)
	caption=game.ui.label_at("",Vector2(252,139),Vector2(456,24),14,Color("ffe4aa"))
	game.stage=2
	game.episode.step=2
	game.player=Vector2(145,285)
	game.day_cycle.set_mode(1)
	game.route_guide.enabled=true
	game.route_guide.reset()
	caption.text="KONOHA · caminho até a Academia"
	game.held.right=true
	for i in range(15): await frame(game)
	game.ui.release_touches()
	for i in range(15):
		await frame(game)
		if i==5: screenshot("konoha-guia-academia.png")
	game.episode.step=5
	game.player=Vector2(400,405)
	game.route_guide.reset()
	caption.text="PONTE · guia respeita as margens e a água"
	for i in range(30):
		await frame(game)
		if i==10: screenshot("ponte-caminho-seguro.png")
	game.episode.step=7
	game.route_guide.reset()
	game.player=Vector2(370,285)
	caption.text="CANAL · corrente suave e ponte estável"
	game.cinematic.motion_enabled=false
	for i in range(30):
		await frame(game)
		if i==10: screenshot("canal-animado.png")
	game.episode.step=6
	game.player=game.layout.HOME
	await game.travel_to("home")
	game.player=Vector2(480,439)
	game.route_guide.reset()
	caption.text="CASA · caminho até os cadernos, contornando a mesa"
	for i in range(30):
		await frame(game)
		if i==10: screenshot("casa-rota-cadernos.png")
	print("GUIDE final path points: ",game.route_guide.points.size())
	print("CAPTURE: ",frame_number," real map/animation frames at 15 FPS")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
