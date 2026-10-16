extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func close_dialogue(game: Node) -> void:
	while not game.lines.is_empty(): game.next_line()

func settle(game: Node) -> void:
	for i in range(60):
		if game.combat.shots.is_empty(): return
		game._process(0.02)
	assert(false,"Projectiles must expire")

func prepare(game: Node, offset: Vector2, direction: Vector2) -> void:
	game.ui.release_touches()
	game.combat.reset()
	game.cooldown=0
	game.player=game.target-offset
	game.facing=direction

func run_checks() -> void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled=false
	root.add_child(game)
	await process_frame
	game.audio.set_enabled(false)
	close_dialogue(game)
	prepare(game,Vector2(170,0),Vector2.RIGHT)
	game.act("kunai")
	assert(game.hits==0 and game.combat.shots.size()==1,"Pressing attack must not count a hit")
	game._process(0.04)
	game.ui._process(0)
	for button in game.ui.touch_buttons:
		if button.get_meta("action")=="kunai": assert(button.text.contains("s"),"Buttons must show remaining cooldown")
	assert(game.hits==0 and not game.combat.shots[0]["active"],"Kunai must respect its windup")
	game._process(0.06)
	assert(game.hits==0 and game.combat.shots[0]["active"],"Kunai must travel before hitting")
	settle(game)
	assert(game.hits==1 and game.combat.target_flash>0 and not game.combat.impacts.is_empty(),"Contact must produce exactly one hit and impact feedback")
	prepare(game,Vector2(100,0),Vector2.LEFT)
	game.act("kunai")
	settle(game)
	assert(game.hits==1,"Facing away must miss")
	prepare(game,Vector2(310,0),Vector2.RIGHT)
	game.act("kunai")
	settle(game)
	assert(game.hits==1,"Kunai must stop at its range")
	prepare(game,Vector2(150,25),Vector2.RIGHT)
	game.act("kunai")
	assert(game.effect_direction.y>0,"Small aim assistance must align nearby directions")
	game._process(0.5)
	assert(game.hits==2,"Swept collision must hit even during a slow frame")
	prepare(game,Vector2(150,0),Vector2.RIGHT)
	game.act("kunai")
	game.held["down"]=true
	game._process(0.03)
	assert(game.facing==Vector2.RIGHT and game.effect_direction==Vector2.RIGHT,"Attack aim must remain stable while moving")
	game.ui.release_touches()
	assert(game.combat.shots.is_empty(),"Input release must cancel pending attacks")
	game.cooldown=0.08
	game.act("kunai")
	game.act("kunai")
	assert(game.combat.buffered=="kunai")
	game._process(0.09)
	assert(game.combat.buffered.is_empty() and game.combat.shots.size()==1,"Late input must queue only one attack")
	game._notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert(game.combat.shots.is_empty() and game.combat.buffered.is_empty())
	game.cooldown=0.08
	game.act("katon")
	var pause_lines:Array[String]=["Pause regression"]
	game.say(pause_lines)
	assert(game.combat.buffered.is_empty(),"Dialogue must discard buffered actions")
	close_dialogue(game)
	prepare(game,Vector2(100,0),Vector2.RIGHT)
	game.act("kunai")
	settle(game)
	assert(game.stage==1 and game.hits==3,"Three physical kunai contacts must unlock Katon")
	close_dialogue(game)
	prepare(game,Vector2(120,0),Vector2.LEFT)
	game.chakra=100
	game.act("katon")
	assert(game.chakra==75 and game.stage==1,"Katon must spend chakra before flight")
	settle(game)
	assert(game.stage==1,"Missing Katon must not unlock the village")
	prepare(game,Vector2(120,0),Vector2.RIGHT)
	game.chakra=10
	game.act("katon")
	assert(game.combat.shots.is_empty() and game.chakra==10,"Insufficient chakra must not launch a projectile")
	game.chakra=100
	game.act("katon")
	settle(game)
	assert(game.stage==2 and game.combat.shots.is_empty(),"A Katon contact must preserve the original village transition")
	close_dialogue(game)
	game.player=Vector2(360,270)
	game.held["right"]=true
	game._process(0.01)
	assert(game.motion_velocity.x>0 and game.motion_velocity.x<180,"Starting movement must accelerate gently")
	game._process(0.1)
	assert(is_equal_approx(game.motion_velocity.x,180))
	game.held.clear()
	var at:Vector2=game.player
	game._process(0.02)
	assert(game.player==at and game.motion_velocity==Vector2.ZERO,"Releasing the direction must stop without drifting")
	game.cooldown=0
	game.act("kunai")
	var saved:Dictionary=game.savegame.snapshot(game)
	assert(game.savegame.apply(game,saved))
	assert(game.combat.shots.is_empty() and game.motion_velocity==Vector2.ZERO,"Loading must clear transient motion and attacks")
	print("PASS: projectile windup, flight, swept hits, misses, aim assist, input buffer, chakra, progression and movement")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	quit()
