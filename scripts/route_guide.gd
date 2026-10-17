extends RefCounted

# Optional, cached footpath using the same obstacles as gameplay; never moves
# the player and never reveals the route during the stealth sequence.
const CELL:=16.0
var enabled:=true
var grid:AStarGrid2D
var area_key:=""
var points:=PackedVector2Array()
var cooldown:=0.0
var last_goal:=Vector2(INF,INF)
var last_player:=Vector2(INF,INF)
var rebuilds:=0

func reset() -> void:
	grid=null
	area_key=""
	points.clear()
	cooldown=0
	last_goal=Vector2(INF,INF)
	last_player=Vector2(INF,INF)

func destination(game:Node2D) -> Vector2:
	var no_goal:=Vector2(INF,INF)
	if game.world.away(game): return game.world.return_gate()
	if game.episode.active():
		match game.episode.step:
			1: return Vector2(480,450) if game.room=="home" else game.layout.interiors.ACADEMY_DOOR
			2: return Vector2(480,260) if game.room=="academy" else Vector2(480,450) if game.room=="home" else game.layout.interiors.ACADEMY_DOOR
			3: return game.episode.SEAT if game.room=="academy" else Vector2(480,450) if game.room=="home" else game.layout.interiors.ACADEMY_DOOR
			4: return game.episode.EXAM if game.room=="academy" else Vector2(480,450) if game.room=="home" else game.layout.interiors.ACADEMY_DOOR
			5: return game.layout.NARUTO if game.room=="outside" else Vector2(480,450)
			6: return Vector2(225,220) if game.room=="home" else Vector2(480,450) if game.room=="academy" else game.layout.HOME
			_: return game.layout.VILLAGE_CAST.Teuchi if game.room=="outside" and game.visited.parcel_started and not game.visited.parcel_delivered else no_goal
	match game.stage:
		2: return game.layout.NARUTO if game.room=="outside" else Vector2(480,450)
		4: return game.target
		5: return Vector2(730,282) if game.room=="home" else game.layout.HOME
	return no_goal

func free_cell(at:Vector2) -> Vector2i:
	var center:=Vector2i((at/CELL).round())
	if grid.is_in_boundsv(center) and not grid.is_point_solid(center): return center
	for radius in range(1,6):
		var best:=Vector2i(-1,-1)
		var distance:=INF
		for y in range(center.y-radius,center.y+radius+1):
			for x in range(center.x-radius,center.x+radius+1):
				var cell:=Vector2i(x,y)
				if grid.is_in_boundsv(cell) and not grid.is_point_solid(cell):
					var d:=Vector2(cell).distance_squared_to(at/CELL)
					if d<distance:
						distance=d
						best=cell
		if best.x>=0: return best
	return Vector2i(-1,-1)

func obstructed(game:Node2D,at:Vector2,actors:Array) -> bool:
	if game.layout.blocked(at,game.stage,game.room): return true
	for actor in actors:
		if at.distance_to(actor)<22: return true
	return false

func update(game:Node2D,delta:float) -> void:
	if not enabled or not game.lines.is_empty():
		points.clear()
		return
	var goal:=destination(game)
	if not goal.is_finite():
		points.clear()
		return
	cooldown=maxf(0,cooldown-delta)
	var key:="%d:%s:%d:%s" % [game.stage,game.room,game.episode.step,game.world.district]
	if grid==null or key!=area_key:
		grid=AStarGrid2D.new()
		grid.region=Rect2i(0,0,61,35)
		grid.cell_size=Vector2.ONE*CELL
		grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER
		grid.update()
		var actors:Array=game.episode.extra_actors(game).values()
		game.layout.episode_step=game.episode.step
		for y in range(35):
			for x in range(61):
				var at:=Vector2(x,y)*CELL
				var blocked:bool=game.layout.clamp_position(at,game.stage,game.room)!=at or obstructed(game,at,actors)
				# Probe edges too: a path cannot clip a narrow desk/bank corner.
				if not blocked:
					for offset in [Vector2(5,0),Vector2(-5,0),Vector2(0,5),Vector2(0,-5)]:
						if obstructed(game,at+offset,actors): blocked=true
				grid.set_point_solid(Vector2i(x,y),blocked)
		area_key=key
		last_goal=Vector2(INF,INF)
		rebuilds+=1
	if cooldown>0 and goal==last_goal and game.player.distance_to(last_player)<32: return
	var start:=free_cell(game.player)
	var end:=free_cell(goal)
	points=grid.get_point_path(start,end) if start.x>=0 and end.x>=0 else PackedVector2Array()
	last_goal=goal
	last_player=game.player
	cooldown=0.65

func draw(game:Node2D) -> void:
	if not enabled or not game.lines.is_empty() or game.ui.modal_open(): return
	var drawn:=0
	for i in range(1,points.size(),2):
		if points[i].distance_to(game.player)<22: continue
		var at:Vector2=points[i]+Vector2(0,14)
		var pulse:=0.65+0.35*sin(game.day_cycle.elapsed*2.8-float(i)*0.35)
		var alpha:float=(1.0-float(drawn)/24.0)*0.82*pulse
		game.draw_set_transform(at,0,Vector2(1,0.42))
		game.draw_circle(Vector2.ZERO,5.0,Color(0.035,0.06,0.05,alpha*0.85))
		game.draw_circle(Vector2.ZERO,3.5,Color(0.98,0.84,0.49,alpha))
		game.draw_circle(Vector2.ZERO,1.2,Color(1.0,0.96,0.77,alpha))
		game.draw_set_transform(Vector2.ZERO)
		drawn+=1
		if drawn>=16: break
