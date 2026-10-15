extends RefCounted

# Matching body proportions for the two original story NPCs.
func draw(host: Node2D, at: Vector2, mizuki: bool, moving: bool, clock: float, night: bool) -> void:
	var ink := Color("26323b")
	var vest := Color("687b59") if not mizuki else Color("87959c")
	var shade := Color("435849") if not mizuki else Color("5f6a7b")
	var hair := Color("423a35") if not mizuki else Color("c2c7ca")
	var bob := sin(clock * 3) * 0.65
	var stride := sin(clock * 9) * 4 if moving else 0.0
	host.draw_set_transform(at + Vector2(0, 9), 0, Vector2(1, 0.25))
	for radius in [20, 17, 14]:
		host.draw_circle(Vector2.ZERO, radius, Color(0.05, 0.12, 0.14, 0.12), true)
	host.draw_set_transform(at + Vector2(0, bob), 0, Vector2.ONE)
	# Sandals, leg wraps, trousers, sleeves and padded flak jacket.
	for side in [-1, 1]:
		var x := float(side * 7)
		host.draw_line(Vector2(x, -23), Vector2(x + stride * side, 1), ink, 11, true)
		host.draw_line(Vector2(x, -23), Vector2(x + stride * side, 1), Color("3d4d61"), 7, true)
		host.draw_line(Vector2(x + stride * side, -6), Vector2(x + stride * side, -1), Color("c4c8b5"), 8, true)
		host.draw_line(Vector2(x + stride * side - 3, 6), Vector2(x + stride * side + 4, 6), ink, 9, true)
		host.draw_line(Vector2(x + stride * side - 3, 4), Vector2(x + stride * side + 4, 4), Color("65747b"), 3, true)
		host.draw_line(Vector2(side * 13, -45), Vector2(side * 20, -24 + stride), ink, 10, true)
		host.draw_line(Vector2(side * 13, -45), Vector2(side * 20, -24 + stride), Color("3e5060"), 7, true)
		host.draw_circle(Vector2(side * 20, -22 + stride), 3.5, Color("d9ac88"), true)
	host.draw_colored_polygon(PackedVector2Array([Vector2(-13, -49), Vector2(13, -49), Vector2(14, -24), Vector2(9, -18), Vector2(-10, -18), Vector2(-15, -25)]), ink)
	host.draw_colored_polygon(PackedVector2Array([Vector2(-11, -47), Vector2(11, -47), Vector2(12, -25), Vector2(8, -21), Vector2(-9, -21), Vector2(-12, -26)]), vest)
	host.draw_line(Vector2(0, -47), Vector2(0, -21), shade, 2, true)
	for side in [-1, 1]:
		host.draw_rect(Rect2(side * 7 - 4, -38, 7, 10), shade)
		host.draw_line(Vector2(side * 7 - 3, -36), Vector2(side * 7 + 2, -36), vest.lightened(0.25), 1)
	host.draw_line(Vector2(-9, -44), Vector2(9, -44), vest.lightened(0.2), 2, true)
	# Neck, face, ears and the recognizable forehead protector.
	host.draw_line(Vector2(0, -53), Vector2(0, -46), Color("c18e70"), 8, true)
	host.draw_circle(Vector2.ZERO + Vector2(0, -64), 12, ink, true)
	host.draw_circle(Vector2(0, -63), 10.5, Color("deb28c"), true)
	for side in [-1, 1]:
		host.draw_circle(Vector2(side * 10.5, -64), 2.4, Color("c49176"), true)
		host.draw_line(Vector2(side * 6, -64), Vector2(side * 3, -64), ink, 1.5, true)
	host.draw_line(Vector2(-3, -57), Vector2(3, -57), Color("996d5c"), 1, true)
	if not mizuki:
		host.draw_line(Vector2(-8, -60), Vector2(8, -60), Color("b08168"), 1, true)
		host.draw_line(Vector2(7, -74), Vector2(16, -83), hair, 6, true)
		host.draw_colored_polygon(PackedVector2Array([Vector2(-12, -69), Vector2(-13, -79), Vector2(-6, -77), Vector2(-4, -84), Vector2(1, -80), Vector2(8, -83), Vector2(11, -76), Vector2(12, -69)]), hair)
	else:
		host.draw_colored_polygon(PackedVector2Array([Vector2(-13, -69), Vector2(-15, -76), Vector2(-9, -80), Vector2(-2, -85), Vector2(3, -80), Vector2(11, -82), Vector2(15, -73), Vector2(12, -60), Vector2(6, -73), Vector2(-8, -70)]), hair)
	host.draw_line(Vector2(-11, -69), Vector2(11, -69), Color("3b4b5d"), 6, true)
	host.draw_line(Vector2(-6, -69), Vector2(6, -69), Color("aeb9b9"), 4, true)
	host.draw_arc(Vector2(0, -69), 2, -1.7, 2.6, 8, Color("4c6570"), 1, true)
	if night:
		host.draw_circle(Vector2(0, -63), 10, Color(0.2, 0.28, 0.48, 0.12), true)
	host.draw_set_transform(Vector2.ZERO)
