extends RefCounted

var district:="plaza"
var tracked_district := ""
var practice_hits:=0
var clock:=0.0
var manifest:Dictionary={}
var texture:Texture2D
const NAMES:={"plaza":"KONOHA · PRAÇA","residential":"BAIRRO RESIDENCIAL","training":"CAMPO DE TREINO LIVRE"}
const PORTALS:={
	"plaza":[{"at":Vector2(38,292),"to":"residential","spawn":Vector2(880,310),"label":"← BAIRRO RESIDENCIAL"},{"at":Vector2(922,292),"to":"training","spawn":Vector2(85,290),"label":"CAMPO DE TREINO →"}],
	"residential":[{"at":Vector2(920,310),"to":"plaza","spawn":Vector2(85,292),"label":"PRAÇA DE KONOHA →"}],
	"training":[{"at":Vector2(50,290),"to":"plaza","spawn":Vector2(875,292),"label":"← PRAÇA DE KONOHA"}]
}
const LOCALS:={
	"residential":[{"name":"Guardião","start":Vector2(320,300),"end":Vector2(400,300)},{"name":"Artesão","start":Vector2(650,310),"end":Vector2(735,310)}],
	"training":[{"name":"Ninja Médica","start":Vector2(280,290),"end":Vector2(345,290)},{"name":"Aprendiz","start":Vector2(740,300),"end":Vector2(815,300)}]
}
var locals:Array[Dictionary]=[]
func _init() -> void:
	if FileAccess.file_exists("res://assets/characters/shinobi-neighbors.json"):
		manifest=JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/shinobi-neighbors.json"))
func reset_locals() -> void:
	locals.clear()
	for d in LOCALS.get(district,[]):
		locals.append({"name":d.name,"at":d.start,"goal":d.end,"start":d.start,"end":d.end,"phase":0.0,"left":false,"wait":0.5,"moving":false})
func active(game:Node2D) -> bool:
	return game.stage==2 and game.room=="outside"
func away(game:Node2D) -> bool:
	return active(game) and district!="plaza"
func return_gate() -> Vector2:
	return PORTALS[district][0].at
func nearby_portal(game:Node2D) -> Dictionary:
	if not active(game): return {}
	if district=="plaza":
		if game.player.distance_to(game.layout.HOME)<48 or game.player.distance_to(game.layout.interiors.ACADEMY_DOOR)<48: return {}
		for at in game.layout.VILLAGE_CAST.values():
			if game.player.distance_to(at)<60: return {}
	for portal in PORTALS[district]:
		if game.player.distance_to(portal.at)<34: return portal
	return {}
func travel(game:Node2D,portal:Dictionary) -> void:
	if not active(game) or game.travelling or not game.lines.is_empty(): return
	game.travelling=true
	game.ui.release_touches()
	game.movement=Vector2.ZERO
	game.dash_time=0
	game.attack_flash=0
	game.combat.reset()
	var fade:Tween=game.ui.fade_to(1)
	await fade.finished
	district=portal.to
	game.layout.district=district
	game.player=game.layout.restore_position(portal.spawn,2)
	game.facing=Vector2.RIGHT if game.player.x<480 else Vector2.LEFT
	game.locomotion.reset()
	game.locomotion.mirror=game.facing.x<0
	game.route_guide.reset()
	game.population.navigation_key=""
	game.polish.dust.clear()
	reset_locals()
	if district=="residential": game.visited.residential=true
	if district=="training":
		game.visited.free_training=true
		game.target=Vector2(560,280)
	game.background.set_area(2,"outside",game.day_cycle.is_night(2))
	game.route_guide.update(game,0)
	game.cinematic.camera.position=Vector2(480,270)
	game.cinematic.look_ahead=Vector2.ZERO
	game.save_checkpoint(false)
	fade=game.ui.fade_to(0)
	await fade.finished
	game.ui.release_touches()
	game.travelling=false
func update(game:Node2D,delta:float) -> void:
	if not tracked_district.is_empty():
		if game.stage != 2:
			tracked_district = ""
			game.route_guide.reset()
		elif game.room == "outside" and district == tracked_district:
			tracked_district = ""
			game.route_guide.reset()
			game.ui.toast("Você chegou ao distrito marcado.")
	if not away(game) or not game.lines.is_empty() or game.travelling: return
	clock+=delta
	for a in locals:
		a.moving=false
		var distance:float=a.at.distance_to(game.player)
		if distance<43:
			# Give the player space, then return to the ordinary patrol route.
			if distance<38:
				var direction:Vector2=(a.at-game.player).normalized()
				if direction==Vector2.ZERO: direction=Vector2.DOWN
				var aside:Vector2=game.layout.clamp_position(a.at+direction*24*minf(delta,0.1),game.stage)
				if not game.blocked(aside):
					a.phase=fposmod(float(a.phase)+a.at.distance_to(aside)/56,1)
					a.moving=a.at.distance_to(aside)>0.01
					if absf(aside.x-a.at.x)>0.05: a.left=aside.x<a.at.x
					a.at=aside
			continue
		if a.wait>0:
			a.wait=maxf(0,a.wait-delta)
			continue
		var offset:Vector2=a.goal-a.at
		if offset.length()<2:
			a.goal=a.start if a.goal==a.end else a.end
			a.wait=1.4
			continue
		var step:Vector2=offset.normalized()*minf(offset.length(),30*minf(delta,0.1))
		var next:Vector2=a.at+step
		if game.blocked(next): continue
		a.at=next
		a.moving=true
		if absf(step.x)>0.05: a.left=step.x<0
		a.phase=fposmod(float(a.phase)+step.length()/56,1)
func prompt(game:Node2D) -> String:
	var gate:=nearby_portal(game)
	if not gate.is_empty(): return "Ir para "+str(NAMES[gate.to])
	if not away(game): return ""
	for a in locals:
		if game.player.distance_to(a.at)<55: return "Duelo de treino" if a.name=="Aprendiz" else "Conversar com "+str(a.name)
	if district=="residential" and game.player.distance_to(Vector2(90,265))<45: return "Ler avisos do bairro"
	return ""
func interact(game:Node2D) -> bool:
	var gate:=nearby_portal(game)
	if not gate.is_empty():
		travel(game,gate)
		return true
	if not away(game): return false
	for a in locals:
		if game.player.distance_to(a.at)<55:
			if a.name=="Aprendiz":
				game.duel.offer()
				return true
			var lines:={"Guardião":"Guardião: Minha ronda fica neste bairro. A praça e a Academia estão pela saída à direita.","Artesão":"Artesão: Trabalho nos reparos das casas. Passeie à vontade, mas respeite as entradas dos moradores.","Ninja Médica":"Ninja Médica: No treino, mantenha distância do alvo antes de lançar uma técnica. Faça uma pausa quando precisar.","Aprendiz":"Aprendiz: Venho praticar aqui quando a aula termina. Ainda estou acertando a mira!"}
			game.say([lines[a.name]])
			return true
	if district=="residential" and game.player.distance_to(Vector2(90,265))<45:
		game.say(["AVISOS DO BAIRRO — Respeite os jardins e mantenha as ruas livres. A praça fica a leste; o campo de treino fica depois dela."])
	else: game.ui.toast("Explore a área. As saídas ficam sinalizadas nas bordas.")
	return true
func draw_portals(game:Node2D) -> void:
	if not active(game): return
	var palette=preload("res://scripts/ui_palette.gd")
	for p in PORTALS[district]:
		var x:float=clampf(p.at.x,130,830)
		palette.name_tag(game,Vector2(x,280 if p.at.x<480 else 340),p.label,game.art.character_art.name_style,10)
		game.draw_arc(p.at+Vector2(0,14),14+sin(game.day_cycle.elapsed*2)*1.5,0,TAU,24,Color(0.95,0.82,0.48,0.6),1.5,true)
func draw_local(game:Node2D,a:Dictionary) -> void:
	if not manifest.has("actors") or not manifest.actors.has(a.name): return
	if texture==null: texture=load("res://assets/characters/shinobi-neighbors.png") as Texture2D
	var data:Dictionary=manifest.actors[a.name]
	var frame:Dictionary=data.frames[int(float(a.phase)*4) if a.moving else 0]
	var r:Array=frame.rect
	var o:Array=frame.origin
	game.art.character_art.shadow(game,a.at)
	game.draw_set_transform(a.at+Vector2(0,14),0,Vector2(-1 if a.left else 1,1))
	game.draw_texture_rect_region(texture,Rect2(-Vector2(o[0],o[1])*data.scale,Vector2(r[2],r[3])*data.scale),Rect2(r[0],r[1],r[2],r[3]),Color("bbc8dd") if game.day_cycle.is_night(2) else Color.WHITE)
	game.draw_set_transform(Vector2.ZERO)
	if a.at.distance_to(game.player)<95: preload("res://scripts/ui_palette.gd").name_tag(game,a.at+Vector2(0,-data.height-7),a.name,game.art.character_art.name_style,10)
func render(game:Node2D) -> void:
	game.day_cycle.draw_sky(game)
	if district=="training":
		game.draw_texture_rect(game.art.TARGET,Rect2(game.target+Vector2(-35,-54),Vector2(70,81)),false)
		game.art.marker(game,game.target+Vector2(0,36),game.visual_clock)
		game.draw_string(ThemeDB.fallback_font,game.target+Vector2(-37,46),"TREINO LIVRE",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("f4d79d"))
	var cast:Array[Dictionary]=[{"name":"player","at":game.player}]
	cast.append_array(locals)
	cast.sort_custom(func(a,b): return a.at.y<b.at.y)
	for a in cast:
		if a.name=="player": game.art.character_art.draw_henrique(game)
		else: draw_local(game,a)
	draw_portals(game)
	game.combat.draw(game)
	game.day_cycle.draw_leaves(game)
	game.polish.render(game)
func draw_minimap(canvas:Node2D,game:Node2D) -> void:
	var box:=Rect2(18,138,180,101.25)
	canvas.draw_style_box(game.polish.panel(),box.grow(4))
	if game.background.environment!=null: canvas.draw_texture_rect(game.background.environment,box,false,Color(0.75,0.83,0.79,0.96))
	var scale:=box.size/Vector2(960,540)
	for p in PORTALS[district]: canvas.draw_circle(box.position+p.at*scale,2.5,Color("f3cf75"))
	for a in locals: canvas.draw_circle(box.position+a.at*scale,1.7,Color("b8eee1"))
	var at:Vector2=box.position+game.player*scale
	canvas.draw_circle(at,4,Color("152b32"))
	canvas.draw_circle(at,2.8,Color("f48668"))
	canvas.draw_style_box(game.polish.panel(),Rect2(18,243,180,18))
	canvas.draw_string(ThemeDB.fallback_font,Vector2(23,255),"Saída dourada · você em vermelho",HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color("ead3a4"))

func navigation_goal(game: Node2D) -> Vector2:
	if tracked_district.is_empty() or game.stage != 2: return Vector2(INF, INF)
	if game.room != "outside": return Vector2(480, 450)
	if tracked_district == district: return Vector2(INF, INF)
	for portal in PORTALS[district]:
		if portal.to == tracked_district: return portal.at
	return return_gate()
