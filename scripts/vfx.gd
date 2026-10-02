extends RefCounted

func fire(host: Node2D, at: Vector2, scale: float, clock: float) -> void:
	for i in range(12):
		var ang := float(i) * 0.52 + clock * 2.0
		var radius := 10.0 + float(i % 4) * 5.0
		var p := at + Vector2(cos(ang), sin(ang)) * radius
		host.draw_circle(p, 5.0 * scale + float(i % 3), Color(1.0, 0.28 + 0.04 * (i % 3), 0.08, 0.88))
	host.draw_circle(at, 8.0 * scale, Color(1.0, 0.83, 0.28, 0.95))

func lightning(host: Node2D, from: Vector2, to: Vector2, clock: float, thickness: float = 3.0) -> void:
	var points := PackedVector2Array()
	var segments := 8
	var dir := to - from
	var normal := Vector2(-dir.y, dir.x).normalized()
	for i in range(segments + 1):
		var t := float(i) / float(segments)
		var jitter := sin(clock * 25.0 + float(i) * 2.7) * 7.0
		if i == 0 or i == segments:
			jitter = 0.0
		points.append(from.lerp(to, t) + normal * jitter)
	for i in range(points.size() - 1):
		host.draw_line(points[i], points[i + 1], Color(0.45, 0.85, 1.0, 0.95), thickness)
		host.draw_line(points[i], points[i + 1], Color(0.86, 0.97, 1.0, 0.8), maxf(1.0, thickness * 0.35))

func water_vortex(host: Node2D, at: Vector2, clock: float) -> void:
	for ring in range(4):
		var r := 12.0 + float(ring) * 10.0
		for i in range(12):
			var a := float(i) / 12.0 * TAU + clock * (1.7 + ring * 0.2)
			var p := at + Vector2(cos(a), sin(a) * 0.45) * r
			host.draw_circle(p, 2.0 + ring * 0.5, Color(0.25, 0.68, 0.92, 0.55))

func smoke(host: Node2D, at: Vector2, clock: float, amount: int = 10) -> void:
	for i in range(amount):
		var a := float(i) * 0.83 + clock
		var p := at + Vector2(cos(a) * (10 + i * 2), sin(a * 1.4) * 12 - i * 1.5)
		host.draw_circle(p, 7.0 + float(i % 3) * 3.0, Color(0.88, 0.9, 0.92, 0.28))

func impact(host: Node2D, at: Vector2, clock: float) -> void:
	for i in range(10):
		var a := float(i) / 10.0 * TAU
		var len := 18.0 + sin(clock * 10.0 + i) * 4.0
		host.draw_line(at, at + Vector2(cos(a), sin(a)) * len, Color(0.86, 0.75, 0.58, 0.58), 2)
	for i in range(8):
		host.draw_circle(at + Vector2((i - 4) * 7, 8 + (i % 2) * 4), 5, Color(0.72, 0.63, 0.5, 0.35))

func chakra_aura(host: Node2D, at: Vector2, clock: float, purple: bool = false) -> void:
	var base := Color(0.25, 0.62, 1.0, 0.35) if not purple else Color(0.62, 0.24, 0.95, 0.34)
	for i in range(16):
		var a := float(i) / 16.0 * TAU + clock * 1.4
		var r := 24.0 + sin(clock * 3.0 + i) * 5.0
		host.draw_circle(at + Vector2(cos(a), sin(a)) * r, 4.0, base)

func susanoo_hint(host: Node2D, at: Vector2, clock: float) -> void:
	chakra_aura(host, at, clock, true)
	host.draw_arc(at + Vector2(0, -25), 34, PI, TAU, 24, Color(0.68, 0.28, 1.0, 0.42), 4)
	host.draw_line(at + Vector2(-28, -20), at + Vector2(-38, 20), Color(0.68, 0.28, 1.0, 0.42), 5)
	host.draw_line(at + Vector2(28, -20), at + Vector2(38, 20), Color(0.68, 0.28, 1.0, 0.42), 5)
