extends RefCounted

# Ephemeral world reactions never alter chapter progress or save data.
const CLEARING_BRANCH := {"id":"branch","at":Vector2(92,238),"label":"Agitar o galho","effect":Vector2(92,195)}
const FOREST_BRANCH := {"id":"branch","at":Vector2(120,240),"label":"Agitar o galho","effect":Vector2(120,185)}
const VILLAGE_POINTS := [
	{"id":"water","at":Vector2(471,309),"label":"Tocar a água","effect":Vector2(478,353)},
	{"id":"bench","at":Vector2(255,342),"label":"Recuperar o fôlego","effect":Vector2(255,324)}
]
var particles:Array[Dictionary]=[]
var ripples:Array[Dictionary]=[]
var reactions:Dictionary={}
var greetings:Dictionary={}
var cooldown:=0.0
var shake_life:=0.0
var shake_at:=Vector2.ZERO
var area_key:=""

func nearby(game:Node2D) -> Dictionary:
	if game.world.away(game): return {}
	if game.room!="outside" or game.stage in [3,6]: return {}
	var points:Array=[]
	if game.stage<=1: points=[CLEARING_BRANCH]
	elif game.stage==4: points=[FOREST_BRANCH]
	elif game.stage in [2,5]: points=VILLAGE_POINTS
	var result:Dictionary={}
	var distance:=38.0
	for point in points:
		var candidate:float=game.player.distance_to(point.at)
		if candidate<distance:
			distance=candidate
			result=point
	return result

func reset_effects() -> void:
	particles.clear()
	ripples.clear()
	shake_life=0
	reactions.clear()
	greetings.clear()
	cooldown=0

func react(name_text:String) -> void:
	reactions[name_text]=1.4

func update(game:Node2D,delta:float) -> void:
	var key:="%s:%d" % [game.room,game.stage]
	if key!=area_key:
		reset_effects()
		area_key=key
	cooldown=maxf(0,cooldown-delta)
	shake_life=maxf(0,shake_life-delta)
	for name_text in reactions.keys():
		reactions[name_text]=maxf(0,reactions[name_text]-delta)
	for particle in particles:
		particle.life-=delta
		particle.velocity+=Vector2(12,24)*delta
		particle.at+=particle.velocity*delta
	particles=particles.filter(func(p):return p.life>0)
	for ripple in ripples: ripple.life-=delta
	ripples=ripples.filter(func(r):return r.life>0)
	if not game.lines.is_empty() or game.stage>=6: return
	var actors:Dictionary={}
	if game.room!="outside": actors=game.layout.interiors.config(game.room).actors
	elif game.stage==2: actors=game.layout.VILLAGE_CAST
	for name_text in actors:
		var distance:float=game.player.distance_to(actors[name_text])
		if distance<82 and not greetings.has(name_text):
			react(name_text)
			greetings[name_text]=0.0
		elif distance>115: greetings.erase(name_text)

func interact(game:Node2D) -> bool:
	var point:=nearby(game)
	if point.is_empty(): return false
	if cooldown>0: return true
	cooldown=1.2
	match point.id:
		"branch":
			shake_life=1.8
			shake_at=point.effect
			for i in range(18):
				var angle:=float(i)*2.39996
				particles.append({"at":point.effect+Vector2(sin(angle)*28,cos(angle)*12),"velocity":Vector2(30+sin(angle)*32,-14+cos(angle)*24),"life":1.6+float(i%4)*0.2,"angle":angle})
			game.ui.toast("As folhas se soltam do galho com o vento.")
		"water":
			for i in range(3): ripples.append({"at":point.effect+Vector2(i*7,i%2*3),"life":1.5-float(i)*0.2})
			game.ui.toast("A água fresca forma pequenas ondas.")
		"bench":
			game.stamina=100
			game.ui.toast("Uma pausa à sombra. Fôlego recuperado.")
	game.audio.play("step")
	return true

func reaction(name_text:String) -> float:
	return float(reactions.get(name_text,0))

func draw(game:Node2D) -> void:
	if game.room!="outside": return
	for particle in particles:
		game.draw_set_transform(particle.at,particle.angle+game.day_cycle.elapsed*3)
		game.draw_colored_polygon(PackedVector2Array([Vector2(-4,0),Vector2(0,-2),Vector2(5,0),Vector2(0,2)]),Color(0.72,0.8,0.35,minf(1,particle.life*2)))
		game.draw_set_transform(Vector2.ZERO)
	for ripple in ripples:
		game.draw_set_transform(ripple.at,0,Vector2(1,0.3))
		game.draw_arc(Vector2.ZERO,4+(1.5-ripple.life)*28,0,TAU,40,Color(0.8,0.96,1,ripple.life*0.55),1.5,true)
		game.draw_set_transform(Vector2.ZERO)

func draw_reaction(game:Node2D,name_text:String,at:Vector2) -> void:
	var life:=reaction(name_text)
	if life<=0: return
	var center:=at+Vector2(26,-78-sin((1.4-life)*PI)*5)
	game.draw_circle(center,10,Color(0.08,0.15,0.18,minf(0.92,life*3)))
	game.draw_string(ThemeDB.fallback_font,center+Vector2(-2,5),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color(1,0.85,0.51,minf(1,life*3)))
