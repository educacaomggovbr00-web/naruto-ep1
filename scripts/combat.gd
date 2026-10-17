extends RefCounted

const KUNAI = preload("res://assets/art/kunai.svg")
var fire_texture: Texture2D = null
var shots: Array[Dictionary] = []
var impacts: Array[Dictionary] = []
var buffered := ""
var target_flash := 0.0
var last_cooldown := 0.4

func cancel_attacks() -> void:
	shots.clear()
	buffered=""

func reset() -> void:
	cancel_attacks()
	impacts.clear()
	target_flash=0

func aim_direction(game: Node2D, kind: String) -> Vector2:
	var direction: Vector2=game.facing.normalized()
	if direction==Vector2.ZERO: direction=Vector2.RIGHT
	if game.target_active():
		var offset: Vector2=game.target-game.player
		var reach:=280.0 if kind=="kunai" else 220.0
		if offset.length()<=reach and offset.length()>1 and direction.dot(offset.normalized())>=0.96:
			direction=offset.normalized()
	return direction

func begin(game: Node2D, kind: String) -> void:
	var direction:=aim_direction(game,kind)
	game.effect_kind=kind
	game.effect_origin=game.player
	game.effect_direction=direction
	game.facing=direction
	game.attack_flash=0.2 if kind=="kunai" else 0.5
	last_cooldown=0.4 if kind=="kunai" else 1.0
	game.cooldown=last_cooldown
	if kind=="katon": game.chakra-=25
	shots.append({"kind":kind,"at":game.player,"direction":direction,
		"delay":0.06 if kind=="kunai" else 0.18,"travel":0.0,
		"speed":640.0 if kind=="kunai" else 420.0,
		"range":280.0 if kind=="kunai" else 220.0,
		"radius":8.0 if kind=="kunai" else 23.0,"active":false})
	if kind=="katon" and fire_texture==null:
		fire_texture=load("res://assets/characters/katon-fire.png") as Texture2D

func update(game: Node2D, delta: float) -> void:
	target_flash=maxf(0,target_flash-delta)
	for impact in impacts: impact["life"]-=delta
	impacts=impacts.filter(func(p):return p["life"]>0)
	var alive: Array[Dictionary]=[]
	var hits: Array[Dictionary]=[]
	for shot in shots:
		var step_delta:=delta
		if not shot["active"]:
			var wait_time:=minf(float(shot["delay"]),step_delta)
			shot["delay"]-=wait_time
			step_delta-=wait_time
			if shot["delay"]>0.000001:
				alive.append(shot)
				continue
			shot["active"]=true
			shot["at"]=game.player+shot["direction"]*22.0
			shot["travel"]=22.0
			game.audio.play(shot["kind"])
			if shot["kind"]=="katon": game.cinematic.kick(0.18)
		var previous: Vector2=shot["at"]
		var distance:=minf(float(shot["speed"])*step_delta,float(shot["range"])-float(shot["travel"]))
		var next: Vector2=previous+shot["direction"]*distance
		shot["travel"]+=distance
		shot["at"]=next
		var hit:=false
		if game.target_active():
			var closest:=Geometry2D.get_closest_point_to_segment(game.target,previous,next)
			hit=closest.distance_to(game.target)<=15.0+float(shot["radius"])
		if hit:
			hits.append(shot)
		elif shot["travel"]<shot["range"]:
			alive.append(shot)
		elif game.target_active():
			game.ui.toast("A técnica passou pelo alvo. Ajuste a direção e a distância.")
	shots=alive
	for shot in hits:
		target_flash=0.3
		impacts.append({"at":game.target+Vector2(0,-26),"direction":shot["direction"],"kind":shot["kind"],"life":0.32})
		game.audio.play("impact")
		game.cinematic.kick(0.65 if shot["kind"]=="katon" else 0.4)
		game.training_hit(shot["kind"])
	if not buffered.is_empty() and game.cooldown<=0 and game.lines.is_empty():
		var action:=buffered
		buffered=""
		game.act(action)

func draw(game: Node2D) -> void:
	for shot in shots:
		if not shot["active"]: continue
		var at: Vector2=shot["at"]+Vector2(0,-28)
		game.draw_set_transform(at,shot["direction"].angle())
		if shot["kind"]=="kunai":
			game.draw_line(Vector2(-17,0),Vector2(-42,0),Color(0.82,0.91,1,0.5),2,true)
			game.draw_texture_rect(KUNAI,Rect2(-16,-6,32,12),false)
		elif fire_texture!=null:
			var pulse:=1.0+sin(game.visual_clock*36.0)*0.04
			game.draw_circle(Vector2.ZERO,26,Color(1,0.4,0.08,0.09))
			game.draw_texture_rect(fire_texture,Rect2(Vector2(-50,-34)*pulse,Vector2(80,68)*pulse),false)
		game.draw_set_transform(Vector2.ZERO)
	for impact in impacts:
		var progress:=1.0-float(impact["life"])/0.32
		var at: Vector2=impact["at"]
		var color:=Color("ffb95b") if impact["kind"]=="katon" else Color("fff0ba")
		color.a=1.0-progress
		game.draw_arc(at,8+progress*32,0,TAU,24,color,2,true)
		for i in range(7):
			var ray:=Vector2.RIGHT.rotated(i*TAU/7.0)
			game.draw_line(at+ray*(7+progress*17),at+ray*(11+progress*30),color,2,true)
