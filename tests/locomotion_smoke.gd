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
	game.player=Vector2(360,270)
	game.held.right=true
	game._process(0.05)
	assert(game.motion_velocity.x>0 and game.motion_velocity.x<180)
	var start:float=game.locomotion.phase
	for i in range(12): game._process(1.0/60)
	assert(game.locomotion.phase!=start and game.locomotion.action=="walk")
	# Changing walk/run keeps a continuous stride, rather than reinterpreting
	# the accumulated distance with a different modulus.
	game.held.run=true
	var before:float=game.locomotion.phase
	game._process(0.08)
	assert(game.locomotion.action=="run")
	var advance:float=fposmod(game.locomotion.phase-before,1.0)
	assert(advance>0 and advance<0.25)
	# Half-second stop: no drift and no changing idle poses.
	game.ui.release_touches()
	var at:Vector2=game.player
	game._process(0.15)
	assert(game.player==at and game.locomotion.action=="idle")
	var rest:Dictionary=game.art.character_art.attached_frame(game,"idle")
	game._process(1.5)
	assert(game.art.character_art.attached_frame(game,"idle")==rest)
	# Left -> up retains the original mirrored pose.
	game.player=Vector2(360,280)
	game.held.left=true
	game._process(0.1)
	assert(game.locomotion.mirror)
	game.ui.release_touches()
	game.held.up=true
	game._process(0.1)
	assert(game.locomotion.mirror)
	var saved:Dictionary=game.savegame.snapshot(game)
	game.locomotion.mirror=false
	assert(game.savegame.apply(game,saved) and game.locomotion.mirror)
	var invalid:Dictionary=saved.duplicate(true)
	invalid.visual_left="left"
	assert(not game.savegame.validate(invalid))
	var old:Dictionary=saved.duplicate(true)
	old.erase("visual_left")
	assert(game.savegame.apply(game,old))
	# The same travelled distance at 30 and 60 FPS gives the same pose/steps.
	var cycles=[]
	var steps=[]
	for fps in [30,60]:
		game.locomotion.reset()
		game.sprinting=false
		game.facing=Vector2.RIGHT
		var contacts:=0
		for i in range(fps):
			game.locomotion.update(game,Vector2(180.0/fps,0),1.0/fps,false)
			contacts+=game.locomotion.footfalls
		cycles.append(game.locomotion.phase)
		steps.append(contacts)
	assert(is_equal_approx(cycles[0],cycles[1]) and steps[0]==steps[1])
	# Walls and menus cannot keep the gait or footstep effects running.
	game.player=Vector2(936,280)
	game.held.right=true
	game._process(0.1)
	game._process(0.1)
	assert(game.locomotion.action=="idle" and game.locomotion.footfalls==0)
	game.ui.journal.toggle()
	before=game.locomotion.phase
	game._process(2)
	assert(game.locomotion.phase==before)
	game.ui.journal.close()
	game.held.clear()
	game.player=Vector2(360,280)
	game.facing=Vector2.RIGHT
	game.act("dodge")
	game._process(0.05)
	assert(game.locomotion.footfalls==0,"Dash must not count as walking")
	print("PASS: stride continuity, planted stop, stable idle, vertical orientation, saves, 30/60 FPS, walls, menus and dodge")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
