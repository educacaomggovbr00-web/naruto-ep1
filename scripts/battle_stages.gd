extends RefCounted

var user_assets = preload("res://scripts/user_asset_pack.gd").new()

func draw(host: Node2D, stage_id: String) -> void:
	var exact_key: String = ""
	match stage_id:
		"plaza": exact_key = "village"
		"forest": exact_key = "forest"
		"bridge": exact_key = "bridge"
		"training_ground": exact_key = "training"
	if not exact_key.is_empty():
		var exact: Texture2D = user_assets.stage_texture(exact_key)
		if exact != null:
			host.draw_rect(Rect2(0, 78, 960, 367), Color("17252b"))
			host.draw_texture_rect(exact, Rect2(0, 78, 960, 367), false)
			return
	match stage_id:
		"plaza":
			_plaza(host)
		"forest":
			_forest(host)
		"bridge":
			_bridge(host)
		"academy":
			_academy(host)
		"chunin_exam":
			_chunin(host)
		"valley":
			_valley(host)
		"river":
			_river(host)
		"training_ground":
			_training(host)
		"interior":
			_interior(host)
		_:
			_training(host)

func _base(host: Node2D, sky: Color, ground: Color) -> void:
	host.draw_rect(Rect2(0, 78, 960, 367), sky)
	host.draw_rect(Rect2(0, 250, 960, 195), ground)

func _plaza(host: Node2D) -> void:
	_base(host, Color("91b6c2"), Color("aaa38f"))
	for x in range(70, 920, 150):
		host.draw_rect(Rect2(x, 155, 100, 72), Color("d0b38b"))
		host.draw_polygon(PackedVector2Array([Vector2(x-8,155),Vector2(x+50,125),Vector2(x+108,155)]), PackedColorArray([Color("a85745")]))
	host.draw_circle(Vector2(480, 320), 70, Color("c6b995"))

func _forest(host: Node2D) -> void:
	_base(host, Color("7ea09e"), Color("72805f"))
	for x in range(30, 930, 70):
		host.draw_rect(Rect2(x, 155, 10, 150), Color("5b4636"))
		host.draw_circle(Vector2(x+5, 150), 36, Color("3e6948"))

func _bridge(host: Node2D) -> void:
	_base(host, Color("8db0bd"), Color("527d8b"))
	host.draw_rect(Rect2(90, 250, 780, 110), Color("aaa59c"))
	for x in range(120, 860, 45):
		host.draw_rect(Rect2(x, 244, 5, 122), Color("d8d3c8"))

func _academy(host: Node2D) -> void:
	_base(host, Color("c4d1d1"), Color("d4c6a5"))
	host.draw_rect(Rect2(245, 145, 470, 160), Color("d8c8ab"))
	host.draw_rect(Rect2(410, 210, 140, 95), Color("7c5948"))
	host.draw_string(ThemeDB.fallback_font, Vector2(420, 190), "ACADEMIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("54473f"))

func _chunin(host: Node2D) -> void:
	_base(host, Color("c6d0d0"), Color("9b978b"))
	host.draw_arc(Vector2(480, 315), 170, 0, TAU, 64, Color("d3cec2"), 18)
	host.draw_arc(Vector2(480, 315), 115, 0, TAU, 64, Color("6d7776"), 5)

func _valley(host: Node2D) -> void:
	_base(host, Color("7ea0ad"), Color("486a58"))
	host.draw_rect(Rect2(0, 190, 170, 220), Color("68706d"))
	host.draw_rect(Rect2(790, 190, 170, 220), Color("68706d"))
	host.draw_rect(Rect2(430, 210, 100, 235), Color("4d7c8f"))

func _river(host: Node2D) -> void:
	_base(host, Color("9eb9c0"), Color("5b8ca1"))
	for i in range(24):
		host.draw_line(Vector2(10+i*42, 290+(i%3)*18), Vector2(32+i*42, 290+(i%3)*18), Color(0.75,0.9,0.95,0.45), 3)

func _training(host: Node2D) -> void:
	_base(host, Color("a6b89d"), Color("bca57d"))
	for at in [Vector2(280,250),Vector2(480,235),Vector2(680,250)]:
		host.draw_rect(Rect2(at.x-4,at.y,8,85), Color("63472f"))
		host.draw_circle(at, 28, Color("d5be88"))
		host.draw_circle(at, 17, Color("a14c46"))
		host.draw_circle(at, 7, Color("eee0b8"))

func _interior(host: Node2D) -> void:
	_base(host, Color("7e6f61"), Color("8f785f"))
	host.draw_rect(Rect2(80, 120, 800, 250), Color("b89a75"))
	for x in range(100, 860, 95):
		host.draw_line(Vector2(x,120),Vector2(x,370),Color("6d5745"),3)
