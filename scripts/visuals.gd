extends RefCounted

var HENRIQUE: Texture2D = null
var npc_art = preload("res://scripts/npc_art.gd").new()
var character_art = preload("res://scripts/character_art.gd").new()
const IRUKA = preload("res://assets/art/iruka.svg")
const MIZUKI = preload("res://assets/art/mizuki.svg")
const TARGET = preload("res://assets/art/target-finished.svg")
const KUNAI = preload("res://assets/art/kunai.svg")

func _init() -> void:
	# Keep the compatibility reference for desktop checks without forcing mobile to load it.
	HENRIQUE = character_art.henrique_texture

func actor(host: Node2D, at: Vector2, texture: Texture2D, direction: Vector2, moving: bool, clock: float, name_text: String, night: bool) -> void:
	character_art.draw_cast_actor(host,name_text,at,moving,night)

func marker(host: Node2D, at: Vector2, clock: float) -> void:
	var y := at.y - 100 + sin(clock * 3.5) * 3
	host.draw_colored_polygon(PackedVector2Array([Vector2(at.x - 6, y), Vector2(at.x + 6, y), Vector2(at.x, y + 7)]), Color("f4d085"))

func render(host: Node2D) -> void:
	host.route_guide.draw(host)
	if host.room != "outside":
		var data: Dictionary = host.layout.interiors.config(host.room)
		if host.room=="academy" and not host.episode.active():
			var circle:=Vector2(480,349)
			host.draw_circle(circle,23,Color(0.85,0.72,0.44,0.1))
			host.draw_arc(circle,23,0,TAU,32,Color("bda568"),1.5,true)
			host.draw_string(ThemeDB.fallback_font,circle+Vector2(-27,43),"TREINO",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("ead3a4"))
		var actors: Array[Dictionary] = [{"name":"player","at":host.player}]
		for name_text in data["actors"]:
			actors.append({"name":name_text,"at":data["actors"][name_text]})
		for name_text in host.episode.extra_actors(host):
			actors.append({"name":name_text,"at":host.episode.extra_actors(host)[name_text]})
		actors.sort_custom(func(a,b):return a["at"].y < b["at"].y)
		for person in actors:
			if person["name"] == "player": character_art.draw_henrique(host)
			elif person["name"]=="Naruto": character_art.draw_naruto(host,person["at"])
			else: character_art.draw_cast_actor(host,person["name"],person["at"])
		host.draw_string(ThemeDB.fallback_font,Vector2(413,495),"PORTA · E / AÇÃO",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("ead3a4"))
		host.episode.draw(host)
		host.polish.render(host)
		return
	host.day_cycle.draw_sky(host)
	var night: bool = host.day_cycle.is_night(host.stage)
	if host.stage <= 1:
		var shake:float=sin(host.visual_clock*65.0)*host.combat.target_flash*10.0
		host.draw_set_transform(host.target+Vector2(shake,0),shake*0.008)
		host.draw_texture_rect(TARGET,Rect2(-35,-54,70,81),false,Color(1.0,1.0-host.combat.target_flash,1.0-host.combat.target_flash))
		host.draw_set_transform(Vector2.ZERO)
		marker(host, host.target + Vector2(0, 36), host.visual_clock)
		host.draw_string(ThemeDB.fallback_font, host.target + Vector2(-16, 45), "%d / 3" % host.hits, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("fcdfa2"))
	elif host.stage == 2:
		var cast:Array[Dictionary]=[{"name":"player","at":host.player}]
		for name_text in host.layout.VILLAGE_CAST:
			cast.append({"name":name_text,"at":host.layout.VILLAGE_CAST[name_text]})
		if not host.episode.active() or host.episode.step>=5: cast.append({"name":"Naruto","at":host.layout.NARUTO})
		for name_text in host.episode.extra_actors(host): cast.append({"name":name_text,"at":host.episode.extra_actors(host)[name_text]})
		cast.sort_custom(func(a,b):return a.at.y<b.at.y)
		for person in cast:
			if person.name=="player": character_art.draw_henrique(host)
			elif person.name=="Naruto": character_art.draw_naruto(host,person.at)
			else: character_art.draw_cast_actor(host,person.name,person.at,false,night)
		if not host.episode.active() or host.episode.step==5: marker(host, host.layout.NARUTO, host.visual_clock)
		preload("res://scripts/ui_palette.gd").name_tag(host,Vector2(344,221),"ACADEMIA",character_art.name_style,10)
	if host.stage in [2,5]:
		preload("res://scripts/ui_palette.gd").name_tag(host,Vector2(110,221),"SUA CASA",character_art.name_style,10)
	if host.stage == 3:
		actor(host, host.mizuki, MIZUKI, Vector2.RIGHT, host.lines.is_empty(), host.visual_clock, "Mizuki", true)
	elif host.stage == 4:
		host.draw_texture_rect(KUNAI, Rect2(host.target - Vector2(16, 8), Vector2(32, 16)), false)
		marker(host, host.target + Vector2(0, 70), host.visual_clock)
	if host.stage == 5:
		marker(host, host.layout.HOME + Vector2(0, 80), host.visual_clock)
	if host.stage!=2: character_art.draw_henrique(host)
	host.combat.draw(host)
	host.day_cycle.draw_leaves(host)
	host.ambient.draw(host)
	host.polish.render(host)

func draw_hud(canvas: Node2D, host: Node2D) -> void:
	var palette=preload("res://scripts/ui_palette.gd")
	canvas.draw_rect(Rect2(0,0,960,76),Color(0.035,0.065,0.085,0.97))
	canvas.draw_rect(Rect2(0,76,960,5),Color(0.01,0.025,0.035,0.25))
	canvas.draw_line(Vector2(0,75),Vector2(960,75),Color(0.77,0.65,0.42,0.55),1)
	canvas.draw_style_box(host.polish.panel(),Rect2(14,9,54,60))
	character_art.portrait(canvas)
	canvas.draw_rect(Rect2(14,9,54,2),palette.RED)
	canvas.draw_string(ThemeDB.fallback_font,Vector2(83,40),"OBJETIVO ATUAL",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("c5a875"))
	# Reserve the first line for identity and resources; the mission has its own line.
	canvas.draw_string(ThemeDB.fallback_font,Vector2(588,21),"CHAKRA",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("b3c5c0"))
	canvas.draw_style_box(host.polish.panel(),Rect2(640,10,220,15))
	canvas.draw_rect(Rect2(644,14,212*host.chakra/100.0,7),Color("79c4c4"))
	canvas.draw_rect(Rect2(644,14,212*host.chakra/100.0,2),Color("b2e2d4"))
	for i in range(1,10):
		canvas.draw_line(Vector2(644+i*21.2,14),Vector2(644+i*21.2,21),Color(0.05,0.1,0.12,0.6),1)
	canvas.draw_rect(Rect2(644,28,212,3),Color("34464b"))
	canvas.draw_rect(Rect2(644,28,212*host.stamina/100.0,3),palette.GOLD)
	canvas.draw_string(ThemeDB.fallback_font,Vector2(873,21),"%03d / 100" % int(host.chakra),HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("e0dec8"))
	var place: String="CAMPO DE TREINO" if host.stage<=1 else "KONOHA · PRAÇA" if host.stage==2 else "FLORESTA · NOITE" if host.stage<=4 else "KONOHA · CASA"
	if host.room!="outside": place=host.layout.interiors.config(host.room)["title"]
	canvas.draw_style_box(host.polish.panel(),Rect2(16,90,205,29))
	canvas.draw_colored_polygon(PackedVector2Array([Vector2(29,100),Vector2(33,104),Vector2(29,108),Vector2(25,104)]),palette.GOLD)
	canvas.draw_string(ThemeDB.fallback_font,Vector2(42,108),place,HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("e4d1aa"))
	canvas.draw_style_box(host.polish.panel(),Rect2(235,90,153,29))
	canvas.draw_string(ThemeDB.fallback_font,Vector2(248,108),host.day_cycle.caption(host.stage),HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("e4d1aa"))
	if host.lines.is_empty():
		canvas.draw_style_box(host.polish.panel(),Rect2(350,502,260,27))
		canvas.draw_rect(Rect2(350,507,2,17),palette.RED)
		canvas.draw_string(ThemeDB.fallback_font,Vector2(364,520),("EPISÓDIO 1  ·  %02d / 07" % host.episode.step if host.episode.active() else "PRÓLOGO  ·  %02d / 07" % (host.stage+1)),HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("e4d1aa"))
		for i in range(7):
			canvas.draw_circle(Vector2(514+i*12,516),2.5,palette.GOLD if i<=(host.episode.step-1 if host.episode.active() else host.stage) else Color("43514f"))
