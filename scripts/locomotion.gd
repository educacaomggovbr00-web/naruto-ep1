extends RefCounted

# One stride phase follows travelled ground distance, independent of render FPS.
# No new directions or in-between sprite poses are fabricated.
const WALK_STRIDE := 92.0
const RUN_STRIDE := 112.0
var phase := 0.0
var action := "idle"
var mirror := false
var idle_frame := 0
var previous_direction := Vector2.ZERO
var last_frame := 0
var settle_time := 0.0
var last_action := "walk"
var footfalls := 0
var breathing_clock := 0.0

func reset() -> void:
	phase=0
	action="idle"
	idle_frame=0
	previous_direction=Vector2.ZERO
	last_frame=0
	settle_time=0
	footfalls=0
	breathing_clock=0

func update(game: Node2D, travelled: Vector2, delta: float, dodging: bool) -> void:
	footfalls=0
	breathing_clock+=delta
	var distance:=travelled.length()
	if dodging or game.attack_flash>0 or not game.lines.is_empty():
		action="idle"
		settle_time=0
		previous_direction=Vector2.ZERO
		return
	if distance<0.001 or delta<=0:
		if action!="idle":
			last_action=action
			settle_time=0.07
			action="idle"
			# The closest original resting pose is mapped in the reviewed manifest.
			var frames:Array=game.art.character_art.attached_player.actions[last_action]
			idle_frame=int(frames[mini(last_frame,frames.size()-1)].get("rest_frame",0))
		settle_time=maxf(0,settle_time-delta)
		return
	var direction:=travelled/distance
	# Vertical movement keeps the last lateral orientation instead of snapping right.
	if absf(direction.x)>0.35: mirror=direction.x<0
	var starting:=action=="idle"
	if starting:
		phase=0
	elif previous_direction.dot(direction)<-0.25:
		# Start a fresh planted step on a reversal, without sliding through a pose.
		phase=0
	var speed:=distance/delta
	action="run" if game.sprinting and speed>(190.0 if action=="run" else 205.0) else "walk"
	var stride:=RUN_STRIDE if action=="run" else WALK_STRIDE
	var advanced:=distance/stride
	var old_half:=int(floor(phase*2.0))
	footfalls=int(floor((phase+advanced)*2.0))-old_half
	# Bound effects on a delayed frame; distance still advances the pose correctly.
	footfalls=mini(footfalls,2)
	phase=fposmod(phase+advanced,1.0)
	previous_direction=direction
	last_action=action
	last_frame=frame_index(game,action)
	settle_time=0

func frame_index(game: Node2D, kind: String) -> int:
	var count:int=game.art.character_art.attached_player.actions[kind].size()
	if kind=="idle": return mini(idle_frame,count-1)
	return mini(int(phase*count),count-1)
