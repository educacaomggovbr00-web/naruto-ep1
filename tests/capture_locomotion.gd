extends SceneTree

const STEP:=1.0/15.0
var folder:String
var frame_number:=0
var caption:Label

func _initialize() -> void: call_deferred("capture")
func dismiss(game:Node) -> void:
	while not game.lines.is_empty(): game.next_line()

func tick(game:Node) -> void:
	game._process(STEP)
	game.cinematic._process(STEP)
	game.cinematic.area_title.hide()
	game.ui._process(STEP)
	game.background._process(STEP)
	await process_frame
	await RenderingServer.frame_post_draw
	var image:Image=root.get_texture().get_image()
	assert(image.save_png(folder.path_join("frames/frame_%04d.png" % frame_number))==OK)
	if frame_number==18: assert(image.save_png(folder.path_join("caminhada-ajustada.png"))==OK)
	frame_number+=1

func section(game:Node,text:String,at:Vector2,commands:Dictionary,count:int) -> void:
	game.ui.release_touches()
	game.player=at
	game.locomotion.reset()
	game.held=commands
	caption.text=text
	for i in range(count): await tick(game)

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
	for node in [game,game.cinematic,game.ui,game.background]: node.set_process(false)
	game.stage=2
	game.episode.step=7
	game.day_cycle.set_mode(1)
	var legend:=Panel.new()
	legend.position=Vector2(240,132)
	legend.size=Vector2(480,34)
	legend.add_theme_stylebox_override("panel",game.ui.panel_style())
	game.ui.add_child(legend)
	caption=game.ui.label_at("",Vector2(252,139),Vector2(456,24),14,Color("ffe4aa"))
	await section(game,"CAMINHADA · passos pelo deslocamento",Vector2(320,285),{"right":true},21)
	game.ui.release_touches()
	caption.text="PARADA · sem deslizar"
	for i in range(9): await tick(game)
	await section(game,"ESQUERDA → VERTICAL · orientação estável",Vector2(405,295),{"left":true},12)
	game.ui.release_touches()
	game.held.up=true
	for i in range(8): await tick(game)
	game.ui.release_touches()
	for i in range(10): await tick(game)
	await section(game,"ANDAR → CORRER · mesmo ciclo de passos",Vector2(300,285),{"right":true},10)
	game.held.run=true
	for i in range(12): await tick(game)
	game.ui.release_touches()
	for i in range(8): await tick(game)
	await section(game,"FURTIVO · passos mais lentos",Vector2(425,285),{"left":true,"sneak":true},30)
	await section(game,"PAREDE · animação para junto do personagem",Vector2(920,280),{"right":true},15)
	game.ui.release_touches()
	for i in range(15): await tick(game)
	print("CAPTURE: ",frame_number," actual gameplay frames at 15 FPS")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
