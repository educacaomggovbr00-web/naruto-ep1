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
	game.episode.step=7
	game.day_cycle.set_mode(1)
	game.population.minimap_enabled=true
	game.player=Vector2(590,305)
	caption.text="VILA VIVA · moradores em movimento e minimapa"
	for i in range(60):
		await frame(game)
		if i==35: screenshot("vila-moradores-sprites.png")
	game.player=game.population.agents[0].at+Vector2(0,40)
	game.act("interact")
	dismiss(game)
	game.act("interact")
	game.ui.finish_typing()
	caption.text="COMERCIANTE · entrega opcional, sem bloquear a história"
	for i in range(24): await frame(game)
	screenshot("comerciante-entrega-opcional.png")
	dismiss(game)
	game.player=Vector2(858,300)
	game.act("interact")
	game.ui.finish_typing()
	caption.text="ICHIRAKU · pacote entregue e recompensa única"
	for i in range(24): await frame(game)
	screenshot("teuchi-encomenda-recebida.png")
	dismiss(game)
	game.player=Vector2(580,410)
	game.day_cycle.set_mode(3)
	caption.text="NOITE · moradores retornam às entradas da vila"
	for i in range(42): await frame(game)
	screenshot("vila-rotina-noturna.png")
	print("CAPTURE: ",frame_number," real civilian-world frames at 15 FPS")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
