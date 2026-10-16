extends RefCounted

const DAY_SECONDS := 480.0
const DEFAULT_PHASE := 16.0/24.0
var phase := DEFAULT_PHASE
var mode := 0
var elapsed := 0.0

func update(game: Node2D, delta: float) -> void:
	elapsed+=delta
	if mode==0 and game.stage<=2 and game.lines.is_empty():
		phase=fposmod(phase+delta/DAY_SECONDS,1.0)

func set_mode(value: int) -> void:
	mode=clampi(value,0,3)
	if mode>0: phase=[DEFAULT_PHASE,9.0/24.0,16.5/24.0,22.0/24.0][mode]

func restore(data: Dictionary) -> void:
	mode=int(data.get("mode",0))
	phase=fposmod(float(data.get("phase",DEFAULT_PHASE)),1.0)
	elapsed=0

func hour(stage: int) -> float:
	return 21.0 if stage>=3 else phase*24.0

func night_amount(stage: int) -> float:
	var h:=hour(stage)
	return 1.0-smoothstep(5.0,8.0,h) if h<12 else smoothstep(17.0,20.0,h)

func warmth(stage: int) -> float:
	var h:=hour(stage)
	return smoothstep(14.0,17.5,h)*(1.0-smoothstep(18.5,20.0,h)) if h>=12 else smoothstep(5.0,6.5,h)*(1.0-smoothstep(7.0,9.0,h))

func is_night(stage: int) -> bool:
	return night_amount(stage)>=0.5

func caption(stage: int) -> String:
	var h:=hour(stage)
	var minutes:=int(h*60.0)%1440
	var period: String="MANHÃ" if h>=5 and h<12 else "TARDE" if h>=12 and h<18 else "NOITE"
	return "%02d:%02d · %s" % [minutes/60,minutes%60,period]

func bird_pose(index: int) -> Dictionary:
	var t:=elapsed
	return {"at":Vector2(fposmod(t*34+index*185.0,1190)-100,145+index*14+sin(t*0.8+index)*12),
		"wing":sin(t*10+index*1.7)*5.0,"size":0.72+index*0.09}

func draw_sky(game: Node2D) -> void:
	if game.room!="outside": return
	var daylight:=1.0-night_amount(game.stage)
	if daylight<0.05: return
	for i in range(4):
		var bird:=bird_pose(i)
		var at:Vector2=bird["at"]
		var wing:float=bird["wing"]
		game.draw_set_transform(at,0,Vector2.ONE*float(bird["size"]))
		var wings:=PackedVector2Array([Vector2(-9,-wing),Vector2(-4,-2),Vector2.ZERO,Vector2(4,-2),Vector2(9,-wing)])
		game.draw_polyline(wings,Color(1,0.9,0.7,daylight*0.28),3.2,true)
		game.draw_polyline(wings,Color(0.11,0.17,0.18,daylight*0.9),1.6,true)
		game.draw_circle(Vector2(0,0.6),1.1,Color(0.11,0.17,0.18,daylight*0.9))
		game.draw_set_transform(Vector2.ZERO)

func draw_leaves(game: Node2D) -> void:
	if game.room!="outside": return
	var night:=night_amount(game.stage)
	for i in range(12):
		var at:=Vector2(fposmod(i*89.0+elapsed*(10+i%4),990)-15,208+(i%5)*36+sin(elapsed*1.1+i)*15)
		game.draw_set_transform(at,sin(elapsed*1.4+i)*0.7+i)
		game.draw_colored_polygon(PackedVector2Array([Vector2(-3,0),Vector2(0,-1.5),Vector2(4,0),Vector2(0,1.5)]),Color(0.7,0.73,0.4,0.55).lerp(Color(0.4,0.62,0.6,0.45),night))
		game.draw_set_transform(Vector2.ZERO)
	if game.stage in [3,4]:
		for i in range(12):
			var at:=Vector2(65+i*76+sin(elapsed*0.5+i)*20,220+(i%4)*30+cos(elapsed*0.8+i)*15)
			var glow:float=(0.35+0.65*pow(0.5+0.5*sin(elapsed*2+i*1.7),2))*night
			game.draw_circle(at,5,Color(0.65,0.9,0.4,glow*0.08))
			game.draw_circle(at,1.3,Color(0.82,1,0.56,glow*0.85))
