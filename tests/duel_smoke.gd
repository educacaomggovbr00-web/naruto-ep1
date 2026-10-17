extends SceneTree
const Model = preload("res://scripts/duel_model.gd")
func _initialize() -> void: call_deferred("checks")
func fresh() -> RefCounted:
	var model = Model.new()
	model.ai_enabled = false
	model.phase = "fight"
	model.player.x = 300
	model.enemy.x = 370
	return model
func steps(model: RefCounted, seconds: float, controls: Dictionary = {}) -> void:
	for i in range(int(ceil(seconds*120))): model.advance(1.0/120.0,controls)
func checks() -> void:
	var m = fresh()
	assert(m.request(m.player,"light","player"))
	steps(m,0.08)
	assert(m.enemy.hp==100,"A melee strike must respect startup")
	steps(m,0.03)
	assert(m.enemy.hp==92 and m.total_hits==1,"A hitbox must connect once after startup")
	steps(m,0.2)
	assert(m.enemy.hp==92,"An attack must not deal damage every frame")
	m=fresh()
	m.enemy.x=600
	m.request(m.player,"heavy","player")
	steps(m,0.7)
	assert(m.enemy.hp==100,"Out-of-range melee must miss")
	m=fresh()
	m.enemy.x=650
	m.request(m.player,"kunai","player")
	steps(m,0.12)
	assert(m.shots.is_empty() and m.enemy.hp==100)
	steps(m,0.06)
	assert(m.shots.size()==1 and m.enemy.hp==100,"Projectiles must travel through the arena")
	steps(m,0.6)
	assert(m.enemy.hp==90 and m.shots.is_empty())
	m=fresh()
	m.player.x=370
	m.enemy.x=300
	m.request(m.enemy,"light","enemy")
	steps(m,0.5,{"guard":true})
	assert(m.player.hp==100 and m.player.guard<100 and m.blocked_hits==1,"Facing guard must absorb a strike and use guard meter")
	for i in range(6):
		m.request(m.enemy,"heavy","enemy")
		steps(m,0.7,{"guard":true})
	assert(m.player.hp<100,"Holding guard forever must eventually break it")
	var broken := false
	for event in m.events:
		if event.kind=="guard_break": broken=true
	assert(broken)
	m=fresh()
	m.player.x=370
	m.enemy.x=300
	m.shots.append({"owner":"enemy","kind":"kunai","x":420.0,"height":65.0,"direction":-1.0,"life":1.5})
	steps(m,0.1,{"guard":true})
	assert(m.player.hp==90,"Guard must not block a projectile from behind")
	m=fresh()
	m.player.x=370
	m.enemy.x=300
	m.request(m.player,"jump","player")
	steps(m,0.25)
	assert(m.player.height>65)
	m.shots.append({"owner":"enemy","kind":"kunai","x":330.0,"height":65.0,"direction":1.0,"life":1.5})
	steps(m,0.1)
	assert(m.player.hp==100,"A high jump must evade a low projectile")
	m=fresh()
	m.player.x=370
	m.enemy.x=300
	m.request(m.player,"dash","player")
	assert(m.player.stamina==75 and m.player.invulnerable>0)
	m.shots.append({"owner":"enemy","kind":"kunai","x":350.0,"height":65.0,"direction":1.0,"life":1.5})
	steps(m,0.04)
	assert(m.player.hp==100,"Dodge must protect during its invulnerability window")
	m.player.state="idle"
	m.player.stamina=20
	assert(not m.request(m.player,"dash","player"))
	m.player.chakra=24
	assert(not m.request(m.player,"katon","player") and m.player.chakra==24)
	m=fresh()
	for i in range(3):
		m.player.x=m.enemy.x-65
		assert(m.request(m.player,"light","player"))
		steps(m,0.22 if i<2 else 0.3)
	assert(m.max_combo>=3 and m.enemy.hp<80,"Three connected inputs must form a real combo")
	var a=fresh()
	var b=fresh()
	a.enemy.x=895
	b.enemy.x=895
	for i in range(60): a.advance(1.0/60,{"move":1.0})
	for i in range(30): b.advance(1.0/30,{"move":1.0})
	assert(absf(a.player.x-b.player.x)<0.01,"30 and 60 FPS must cover the same distance")
	var before:float=a.player.x
	a.advance(2,{"move":1.0})
	assert(a.player.x-before<=22.51,"A stalled frame must not teleport the fighter")
	m=fresh()
	m.enemy.hp=0
	m.advance(0.01)
	assert(m.player_rounds==1 and m.phase=="round_over")
	for i in range(20): m.advance(0.1)
	assert(m.phase=="intro")
	m.phase="fight"
	m.enemy.hp=0
	m.advance(0.01)
	for i in range(20): m.advance(0.1)
	assert(m.phase=="complete" and m.player_rounds==2)
	var completions:=0
	for event in m.take_events():
		if event.kind=="complete": completions+=1
	for i in range(20): m.advance(0.1)
	assert(completions==1 and m.take_events().is_empty(),"A match result must only fire once")
	m=Model.new()
	m.phase="fight"
	for i in range(800): m.advance(0.1)
	assert(m.enemy_rounds>=2 and m.phase=="complete","The adversary must approach, attack and win against an idle player")
	print("PASS: side-view startup, hitboxes, projectiles, directional guard, guard break, jump, dodge, combos, FPS parity, rounds and active AI")
	quit()
