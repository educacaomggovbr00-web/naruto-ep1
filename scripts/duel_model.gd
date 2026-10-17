extends RefCounted

# Deterministic side-view combat. No scene, input, save or rendering dependencies.
const FLOOR := 378.0
const LEFT := 65.0
const RIGHT := 895.0
const ACTIONS := {
	"light": {"duration":0.30,"windup":0.09,"damage":8.0,"reach":90.0},
	"heavy": {"duration":0.53,"windup":0.20,"damage":15.0,"reach":115.0},
	"kunai": {"duration":0.48,"windup":0.13,"damage":10.0,"reach":0.0},
	"katon": {"duration":0.80,"windup":0.30,"damage":22.0,"reach":0.0}
}
var player: Dictionary
var enemy: Dictionary
var shots: Array[Dictionary] = []
var events: Array[Dictionary] = []
var phase := "intro"
var phase_time := 1.2
var clock := 60.0
var elapsed := 0.0
var player_rounds := 0
var enemy_rounds := 0
var max_combo := 0
var total_hits := 0
var blocked_hits := 0
var ai_enabled := true
var assisted := false
var ai_wait := 0.4
var ai_guard := 0.0
var ai_serial := 0
var round_winner := ""
var hit_pause := 0.0

func fighter(x: float, direction: float) -> Dictionary:
	return {"x":x,"height":0.0,"vy":0.0,"facing":direction,"hp":100.0,
		"chakra":100.0,"stamina":100.0,"guard":100.0,"state":"idle",
		"remaining":0.0,"elapsed":0.0,"connected":false,"invulnerable":0.0,
		"windup":0.0,"knock":0.0,"combo":0,"combo_time":0.0,"chain":0,"buffer":""}

func _init() -> void:
	start_round()

func start_round() -> void:
	player = fighter(280, 1)
	enemy = fighter(680, -1)
	shots.clear()
	phase = "intro"
	phase_time = 1.2
	clock = 60
	ai_wait = 0.5
	ai_guard = 0
	hit_pause = 0
	round_winner = ""

func reset_match(easy: bool = false) -> void:
	assisted = easy
	player_rounds = 0
	enemy_rounds = 0
	max_combo = 0
	total_hits = 0
	blocked_hits = 0
	elapsed = 0
	ai_serial = 0
	events.clear()
	start_round()

func emit(kind: String, at: float, owner: String = "player", extra: Dictionary = {}) -> void:
	var event := {"kind":kind,"x":at,"owner":owner}
	event.merge(extra)
	events.append(event)

func take_events() -> Array[Dictionary]:
	var result := events.duplicate()
	events.clear()
	return result

func free_to_act(actor: Dictionary) -> bool:
	return actor.state in ["idle", "walk", "guard"]

func request(actor: Dictionary, action: String, owner: String) -> bool:
	if phase != "fight": return false
	if not free_to_act(actor):
		if action == "light" and actor.state == "light" and actor.connected and actor.elapsed >= 0.15 and actor.chain < 3:
			actor.remaining = 0
		elif action in ["light", "heavy"] and actor.remaining <= 0.12 and actor.state in ACTIONS:
			actor.buffer = action
			return false
		else: return false
	if action == "jump":
		if actor.height > 0.01: return false
		actor.vy = 490.0
		actor.state = "idle"
		emit("jump", actor.x, owner)
		return true
	if action == "dash":
		if actor.stamina < 25 or actor.height > 0.01:
			if owner == "player": emit("notice", actor.x, owner, {"text":"Esquiva precisa de 25 de fôlego."})
			return false
		actor.stamina -= 25
		actor.state = "dash"
		actor.remaining = 0.20
		actor.elapsed = 0
		actor.invulnerable = 0.16
		return true
	if not action in ACTIONS: return false
	if action == "katon" and actor.chakra < 25:
		if owner == "player": emit("notice", actor.x, owner, {"text":"Katon precisa de 25 de chakra."})
		return false
	if action == "katon": actor.chakra -= 25
	if action == "light":
		actor.chain = int(actor.chain) + 1
		if actor.chain >= 3: action = "heavy"
	elif action == "heavy": actor.chain = 0
	actor.state = action
	actor.remaining = ACTIONS[action].duration + (0.12 if owner == "enemy" and assisted else 0.0)
	actor.windup = ACTIONS[action].windup + (0.12 if owner == "enemy" and assisted else 0.0)
	actor.elapsed = 0
	actor.connected = false
	actor.buffer = ""
	var other: Dictionary = enemy if owner == "player" else player
	actor.facing = 1.0 if other.x >= actor.x else -1.0
	emit("attack", actor.x, owner, {"action":action})
	return true

func hit(attacker: Dictionary, target: Dictionary, damage: float, kind: String, owner: String, from_x: float) -> bool:
	if target.invulnerable > 0 or target.hp <= 0: return false
	if owner == "enemy" and assisted: damage *= 0.65
	var facing_attack: bool = target.facing == (1.0 if from_x >= target.x else -1.0)
	var guarded: bool = target.state == "guard" and facing_attack and target.height < 1
	if guarded:
		var cost := 34.0 if kind == "katon" else 27.0 if kind == "heavy" else 18.0
		target.guard = maxf(0, target.guard - cost)
		if target.guard > 0:
			target.hp = maxf(0, target.hp - (1.0 if kind == "katon" else 0.0))
			if owner == "enemy": blocked_hits += 1
			emit("block", target.x, owner)
			return true
		target.state = "hurt"
		target.remaining = 0.85
		emit("guard_break", target.x, owner)
	else:
		target.state = "hurt"
		target.remaining = 0.28 if kind in ["heavy", "katon"] else 0.19
	target.hp = maxf(0, target.hp - damage)
	target.elapsed = 0
	target.buffer = ""
	target.chain = 0
	target.invulnerable = 0.08
	target.knock = (1 if target.x >= from_x else -1) * (180 if kind in ["heavy", "katon"] else 90)
	attacker.combo = int(attacker.combo) + 1
	attacker.combo_time = 1.15
	if owner == "player":
		total_hits += 1
		max_combo = maxi(max_combo, attacker.combo)
	hit_pause = 0.045
	emit("hit", target.x, owner, {"damage":damage,"action":kind,"combo":attacker.combo})
	return true

func tick_actor(actor: Dictionary, other: Dictionary, owner: String, move: float, guarding: bool, delta: float) -> void:
	actor.invulnerable = maxf(0, actor.invulnerable - delta)
	actor.combo_time = maxf(0, actor.combo_time - delta)
	if actor.combo_time <= 0:
		actor.combo = 0
		if free_to_act(actor): actor.chain = 0
	actor.chakra = minf(100, actor.chakra + delta * 5)
	actor.stamina = minf(100, actor.stamina + delta * 15)
	if actor.state != "guard": actor.guard = minf(100, actor.guard + delta * 11)
	if actor.height > 0 or actor.vy > 0:
		actor.height = maxf(0, actor.height + actor.vy * delta)
		actor.vy -= 1250 * delta
		if actor.height <= 0: actor.vy = 0
	actor.x = clampf(actor.x + actor.knock * delta, LEFT, RIGHT)
	actor.knock *= exp(-delta * 12)
	if not free_to_act(actor):
		actor.elapsed += delta
		actor.remaining = maxf(0, actor.remaining - delta)
		if actor.state == "dash": actor.x = clampf(actor.x + actor.facing * 440 * delta, LEFT, RIGHT)
		if actor.state in ACTIONS and not actor.connected and actor.elapsed >= actor.windup:
			actor.connected = true
			if actor.state in ["kunai", "katon"]:
				shots.append({"owner":owner,"kind":actor.state,"x":actor.x + actor.facing * 35,"height":actor.height + 65,"direction":actor.facing,"life":1.5})
				emit("launch", actor.x, owner, {"action":actor.state})
			elif absf(other.x - actor.x) <= ACTIONS[actor.state].reach and absf(other.height - actor.height) < 65 and (other.x - actor.x) * actor.facing >= 0:
				hit(actor, other, ACTIONS[actor.state].damage, actor.state, owner, actor.x)
		if actor.remaining <= 0:
			actor.state = "idle"
			var buffered: String = actor.buffer
			actor.buffer = ""
			if not buffered.is_empty(): request(actor, buffered, owner)
	else:
		actor.facing = 1.0 if other.x >= actor.x else -1.0
		if guarding and actor.height < 1:
			actor.state = "guard"
		else:
			actor.state = "walk" if absf(move) > 0.1 else "idle"
			actor.x = clampf(actor.x + move * 225 * delta, LEFT, RIGHT)

func update_ai(delta: float) -> Dictionary:
	var controls := {"move":0.0,"guard":false}
	if not ai_enabled: return controls
	var distance: float = absf(player.x - enemy.x)
	ai_wait -= delta
	ai_guard = maxf(0, ai_guard - delta)
	if ai_wait <= 0 and free_to_act(enemy):
		ai_serial += 1
		ai_wait = 0.48 if assisted else 0.30
		if distance < 155 and player.state in ["light", "heavy", "katon"] and ai_serial % 3 == 0:
			ai_guard = 0.50
		elif distance < 100: request(enemy, "heavy" if ai_serial % 3 == 0 else "light", "enemy")
		elif distance < 360 and ai_serial % 4 == 0: request(enemy, "kunai", "enemy")
		elif distance > 240 and ai_serial % 7 == 0: request(enemy, "dash", "enemy")
	controls.guard = ai_guard > 0
	if distance > 78 and free_to_act(enemy) and not controls.guard: controls.move = signf(player.x - enemy.x)
	return controls

func end_round() -> void:
	if phase != "fight": return
	if player.hp == enemy.hp:
		round_winner = "draw"
	else:
		round_winner = "player" if player.hp > enemy.hp else "enemy"
		if round_winner == "player": player_rounds += 1
		else: enemy_rounds += 1
	phase = "round_over"
	phase_time = 1.8
	shots.clear()
	emit("round", 480, round_winner)

func advance(delta: float, controls: Dictionary = {}) -> void:
	if phase == "complete": return
	var remaining := clampf(delta, 0, 0.1)
	if phase in ["intro", "round_over"]:
		phase_time = maxf(0, phase_time - remaining)
		if phase_time <= 0:
			if phase == "intro": phase = "fight"
			elif player_rounds >= 2 or enemy_rounds >= 2:
				phase = "complete"
				emit("complete", 480, "player" if player_rounds >= 2 else "enemy")
			else: start_round()
		return
	for action in controls.get("actions", []): request(player, action, "player")
	while remaining > 0.000001 and phase == "fight":
		var dt := minf(remaining, 1.0 / 120.0)
		remaining -= dt
		if hit_pause > 0:
			hit_pause = maxf(0, hit_pause - dt)
			continue
		clock = maxf(0, clock - dt)
		elapsed += dt
		var enemy_controls := update_ai(dt)
		tick_actor(player, enemy, "player", float(controls.get("move", 0)), bool(controls.get("guard", false)), dt)
		tick_actor(enemy, player, "enemy", enemy_controls.move, enemy_controls.guard, dt)
		if absf(player.x - enemy.x) < 48 and absf(player.height - enemy.height) < 65 and player.state != "dash" and enemy.state != "dash":
			var push: float = (48 - absf(player.x - enemy.x)) * 0.5
			var direction: float = 1 if enemy.x >= player.x else -1
			player.x = clampf(player.x - direction * push, LEFT, RIGHT)
			enemy.x = clampf(enemy.x + direction * push, LEFT, RIGHT)
		var alive: Array[Dictionary] = []
		for shot in shots:
			shot.life -= dt
			var previous: float = shot.x
			shot.x += shot.direction * (660 if shot.kind == "kunai" else 410) * dt
			var target: Dictionary = enemy if shot.owner == "player" else player
			var source: Dictionary = player if shot.owner == "player" else enemy
			var radius := 7 if shot.kind == "kunai" else 22
			var collision: bool = minf(previous, shot.x) - radius <= target.x + 23 and maxf(previous, shot.x) + radius >= target.x - 23 and absf(shot.height - (target.height + 55)) < 44 + radius
			var connected: bool = collision and hit(source, target, ACTIONS[shot.kind].damage, shot.kind, shot.owner, previous)
			if not connected and shot.life > 0 and shot.x > 0 and shot.x < 960: alive.append(shot)
		shots = alive
		if player.hp <= 0 or enemy.hp <= 0 or clock <= 0: end_round()
