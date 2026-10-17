extends RefCounted

const SHEET="res://assets/characters/citizens-generated.png"
const DEFINITIONS:=[
	{"name":"Comerciante","speed":34.0,"home":Vector2(110,240),"route":[Vector2(90,280),Vector2(190,280),Vector2(190,295),Vector2(90,295)]},
	{"name":"Moradora","speed":32.0,"home":Vector2(344,240),"route":[Vector2(365,300),Vector2(510,300),Vector2(510,280),Vector2(365,280)]},
	{"name":"Mensageiro","speed":48.0,"home":Vector2(920,285),"route":[Vector2(685,292),Vector2(790,292),Vector2(790,312),Vector2(685,312)]},
	{"name":"Criança","speed":40.0,"home":Vector2(40,260),"route":[Vector2(275,270),Vector2(390,270),Vector2(390,288),Vector2(300,288)]}
]
var agents:Array[Dictionary]=[]
var manifest:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/citizens.json"))
var texture:Texture2D
var grid:AStarGrid2D
var navigation_key:=""
var parcel_offered:=false
var minimap_enabled:=true

func _init() -> void:
	reset()
func reset() -> void:
	agents.clear()
	grid=null
	navigation_key=""
	parcel_offered=false
	for i in range(DEFINITIONS.size()):
		var d:Dictionary=DEFINITIONS[i]
		agents.append({"name":d.name,"at":d.route[0],"next":1,"path":PackedVector2Array(),"index":0,"wait":float(i)*0.45,"phase":0.0,"moving":false,"left":false,"homebound":false,"hidden":false})
func restore_schedule(game:Node2D) -> void:
	if game.day_cycle.night_amount(game.stage)>0.6:
		for i in range(agents.size()):
			agents[i].at=DEFINITIONS[i].home
			agents[i].homebound=true
			agents[i].hidden=true

func active(game:Node2D) -> bool:
	return game.stage==2 and game.room=="outside" and game.world.district=="plaza"
func get_texture() -> Texture2D:
	if texture==null: texture=load(SHEET) as Texture2D
	return texture
func prepare_grid(game:Node2D) -> void:
	var key:=str(game.episode.step)
	if grid!=null and navigation_key==key: return
	grid=AStarGrid2D.new()
	grid.region=Rect2i(0,0,61,35)
	grid.cell_size=Vector2(16,16)
	grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.update()
	game.layout.episode_step=game.episode.step
	var story:Array=game.episode.extra_actors(game).values()
	for y in range(35):
		for x in range(61):
			var at:=Vector2(x,y)*16
			var solid:bool=game.layout.clamp_position(at,2)!=at or game.layout.blocked(at,2)
			for actor in story:
				if at.distance_to(actor)<25: solid=true
			grid.set_point_solid(Vector2i(x,y),solid)
	navigation_key=key
func nearest_free(at:Vector2) -> Vector2i:
	var center:=Vector2i((at/16).round())
	for radius in range(5):
		var best:=Vector2i(-1,-1)
		var distance:=INF
		for y in range(center.y-radius,center.y+radius+1):
			for x in range(center.x-radius,center.x+radius+1):
				var cell:=Vector2i(x,y)
				if grid.is_in_boundsv(cell) and not grid.is_point_solid(cell):
					var d:=Vector2(cell).distance_squared_to(at/16)
					if d<distance:
						best=cell
						distance=d
		if best.x>=0: return best
	return Vector2i(-1,-1)
func update(game:Node2D,delta:float) -> void:
	if not active(game) or not game.lines.is_empty(): return
	prepare_grid(game)
	var night:bool=game.day_cycle.night_amount(2)>0.6
	for i in range(agents.size()):
		var a:Dictionary=agents[i]
		var d:Dictionary=DEFINITIONS[i]
		a.moving=false
		if a.homebound!=night:
			a.homebound=night
			a.hidden=false
			a.path=PackedVector2Array()
			a.wait=0.0
		if a.hidden: continue
		var distance:float=a.at.distance_to(game.player)
		if distance<50:
			# Soft avoidance cannot lock the player into a crowd or a doorway.
			if distance<26:
				var away:Vector2=(a.at-game.player).normalized()
				if away==Vector2.ZERO: away=Vector2.DOWN
				var retreat:Vector2=game.layout.clamp_position(a.at+away*minf(delta,0.1)*30,2)
				if not game.blocked(retreat): a.at=retreat
			continue
		if a.wait>0:
			a.wait=maxf(0,a.wait-delta)
			continue
		if a.path.is_empty():
			var target:Vector2=d.home if night else d.route[int(a.next)]
			var start:=nearest_free(a.at)
			var finish:=nearest_free(target)
			if start.x<0 or finish.x<0: continue
			a.path=grid.get_point_path(start,finish)
			a.index=0
		if a.path.is_empty(): continue
		var target:Vector2=a.path[int(a.index)]
		var offset:Vector2=target-a.at
		if offset.length()<3:
			a.index+=1
			if a.index>=a.path.size():
				a.path=PackedVector2Array()
				if night: a.hidden=true
				else:
					a.next=(int(a.next)+1)%d.route.size()
					a.wait=1.0+float(i)*0.35
			continue
		var step:Vector2=offset.normalized()*minf(offset.length(),float(d.speed)*minf(delta,0.1))
		# Keep a little personal space while retaining traversable footpaths.
		for other in agents:
			if other==a or other.hidden: continue
			var apart:Vector2=a.at-other.at
			if apart.length()>0.1 and apart.length()<24: step+=apart.normalized()*(24-apart.length())*minf(delta,0.1)
		var next:Vector2=game.layout.clamp_position(a.at+step,2)
		if game.blocked(next):
			a.path=PackedVector2Array()
			a.wait=0.25
			continue
		var travelled:float=next.distance_to(a.at)
		a.at=next
		a.moving=travelled>0.01
		if absf(step.x)>0.05: a.left=step.x<0
		a.phase=fposmod(float(a.phase)+travelled/56.0,1.0)
func visible_agents(game:Node2D) -> Array[Dictionary]:
	var result:Array[Dictionary]=[]
	if not active(game): return result
	for a in agents:
		if not a.hidden: result.append(a)
	return result
func nearby(game:Node2D) -> Dictionary:
	if not active(game): return {}
	for person in game.layout.VILLAGE_CAST.values():
		if game.player.distance_to(person)<62: return {}
	if (not game.episode.active() or game.episode.step>=5) and game.player.distance_to(game.layout.NARUTO)<95: return {}
	for actor in game.episode.extra_actors(game).values():
		if game.player.distance_to(actor)<62: return {}
	var nearest:Dictionary={}
	var best:=55.0
	for a in agents:
		var distance:float=game.player.distance_to(a.at)
		if not a.hidden and distance<best:
			best=distance
			nearest=a
	return nearest
func interact(game:Node2D) -> bool:
	var a:=nearby(game)
	if a.is_empty(): return false
	match str(a.name):
		"Comerciante":
			if game.visited.parcel_delivered: game.say(["Comerciante: Teuchi recebeu a encomenda. Obrigado pela ajuda, Henrique!"])
			elif game.visited.parcel_started: game.say(["Comerciante: Teuchi está no Ichiraku, à direita da praça. A encomenda é para ele."])
			elif parcel_offered:
				game.visited.parcel_started=true
				game.say(["Comerciante: Aqui está o pacote de temperos. Leve ao Teuchi no Ichiraku quando puder. Não tem pressa.","ENTREGA OPCIONAL — O pacote está com você. A história principal continua disponível."])
			else:
				parcel_offered=true
				game.say(["Comerciante: Tenho um pacote de temperos para o Teuchi. Pode levar até o Ichiraku?", "Comerciante: Se quiser aceitar, termine esta conversa e fale comigo de novo. Você também pode continuar seu caminho."])
		"Moradora": game.say(["Moradora: Gosto de passar pela praça antes de voltar para casa. Quando escurece, o movimento diminui."])
		"Mensageiro": game.say(["Mensageiro: Tenho entregas pela vila. Vou pela rua; atravessar os quintais só atrapalha os moradores."])
		"Criança": game.say(["Criança: Um dia eu vou estudar na Academia também! Por enquanto, fico aqui perto de casa."])
	game.save_checkpoint(false)
	return true
func deliver(game:Node2D) -> bool:
	if not game.visited.parcel_started or game.visited.parcel_delivered: return false
	game.visited.parcel_delivered=true
	game.chakra=minf(100,game.chakra+20)
	game.stamina=100
	game.say(["Teuchi: Os temperos chegaram! Pode agradecer ao comerciante por mim.","Teuchi: Esta tigela é por conta da casa. Bom apetite!", "ENTREGA CONCLUÍDA — O lámen recuperou seu fôlego e até 20 de chakra."])
	game.save_checkpoint(false)
	return true
func draw_actor(game:Node2D,a:Dictionary) -> void:
	var data:Dictionary=manifest.actors[a.name]
	var index:=int(float(a.phase)*4) if a.moving else 0
	var frame:Dictionary=data.frames[index]
	var r:Array=frame.rect
	var origin:Array=frame.origin
	var factor:float=data.scale
	game.art.character_art.shadow(game,a.at)
	var breathe:=1.0 if a.moving else 1.0+sin(game.day_cycle.elapsed*2.0+float(str(a.name).hash()%13))*0.004
	game.draw_set_transform(a.at+Vector2(0,14),0,Vector2(-1 if a.left else 1,breathe))
	game.draw_texture_rect_region(get_texture(),Rect2(-Vector2(origin[0],origin[1])*factor,Vector2(r[2],r[3])*factor),Rect2(r[0],r[1],r[2],r[3]),Color("bbc8dd") if game.day_cycle.is_night(2) else Color.WHITE)
	game.draw_set_transform(Vector2.ZERO)
	if game.player.distance_to(a.at)<90:
		preload("res://scripts/ui_palette.gd").name_tag(game,a.at+Vector2(0,-data.height-7),a.name,game.art.character_art.name_style,10)

func draw_minimap(canvas:Node2D,game:Node2D) -> void:
	if not minimap_enabled or game.room!="outside" or not game.stage in [2,5] or not game.lines.is_empty() or game.ui.modal_open(): return
	if game.world.away(game):
		game.world.draw_minimap(canvas,game)
		return
	var box:=Rect2(18,138,180,101.25)
	canvas.draw_style_box(game.polish.panel(),box.grow(4))
	if game.background.environment!=null: canvas.draw_texture_rect(game.background.environment,box,false,Color(0.75,0.83,0.79,0.96))
	var scale:=box.size/Vector2(960,540)
	for at in [game.layout.HOME,game.layout.interiors.ACADEMY_DOOR,game.layout.VILLAGE_CAST.Teuchi]:
		var point:Vector2=box.position+at*scale
		canvas.draw_rect(Rect2(point-Vector2(2,2),Vector2(4,4)),Color("f3cf75"))
	for a in visible_agents(game): canvas.draw_circle(box.position+a.at*scale,1.7,Color("b8eee1"))
	if game.route_guide.enabled and game.route_guide.points.size()>1:
		var path:=PackedVector2Array()
		for at in game.route_guide.points: path.append(box.position+at*scale)
		canvas.draw_polyline(path,Color(1,0.87,0.45,0.75),1.2,true)
	var player_at:Vector2=box.position+game.player*scale
	canvas.draw_circle(player_at,4.2,Color("152b32"))
	canvas.draw_circle(player_at,2.8,Color("f48668"))
	canvas.draw_style_box(game.polish.panel(),Rect2(18,243,180,18))
	canvas.draw_string(ThemeDB.fallback_font,Vector2(23,255),"VILA · você / moradores / locais",HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color("ead3a4"))
