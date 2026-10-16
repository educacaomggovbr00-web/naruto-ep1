extends RefCounted

# Coordinates follow the fixed 960x540 paintings, not the old procedural tiles.
const VILLAGE_FLOOR := Rect2(24, 232, 912, 182)
const CLEARING_FLOOR := Rect2(35, 228, 890, 147)
const WATER := Rect2(422, 336, 307, 63)
const BRIDGE := Rect2(530, 321, 101, 85)
const BENCHES := [Rect2(226, 309, 60, 18), Rect2(811, 307, 63, 18)]
const NARUTO := Vector2(640, 260)
const IRUKA := Vector2(730, 260)
const HOME := Vector2(110, 235)
const VILLAGE_CAST := {"Sasuke": Vector2(310,260), "Sakura": Vector2(400,280),
	"Hiruzen": Vector2(495,245), "Teuchi": Vector2(858,260)}

func village(stage: int) -> bool:
	return stage == 2 or stage >= 5

func bounds(stage: int) -> Rect2:
	return VILLAGE_FLOOR if village(stage) else CLEARING_FLOOR

func clamp_position(at: Vector2, stage: int) -> Vector2:
	var floor := bounds(stage)
	return at.clamp(floor.position, floor.end)

func restore_position(at: Vector2, stage: int) -> Vector2:
	var start := clamp_position(at,stage)
	if not blocked(start,stage): return start
	# An older save may now sit inside a newly added NPC. Find nearby free floor.
	for radius in range(8,169,8):
		for sector in range(16):
			var candidate := clamp_position(start + Vector2.RIGHT.rotated(TAU*sector/16.0)*radius,stage)
			if not blocked(candidate,stage): return candidate
	return start

func blocked(at: Vector2, stage: int) -> bool:
	if village(stage):
		if WATER.has_point(at) and not BRIDGE.has_point(at): return true
		for bench in BENCHES:
			if bench.grow(3).has_point(at): return true
	if stage == 2:
		for npc in VILLAGE_CAST.values():
			if at.distance_to(npc) < 22: return true
		for npc in [NARUTO, IRUKA]:
			if at.distance_to(npc) < 22: return true
	return false
