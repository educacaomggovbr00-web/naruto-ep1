extends Control

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	size=Vector2(610,164)

func _draw() -> void:
	var palette=preload("res://scripts/ui_palette.gd")
	draw_rect(Rect2(18,0,74,3),palette.RED)
	draw_rect(Rect2(96,0,28,3),palette.GOLD)
	draw_style_box(palette.panel(),Rect2(14,27,87,116))
	draw_line(Vector2(120,34),Vector2(584,34),Color(0.77,0.65,0.42,0.26),1)
	draw_line(Vector2(120,138),Vector2(584,138),Color(0.77,0.65,0.42,0.18),1)
	draw_colored_polygon(PackedVector2Array([Vector2(583,147),Vector2(591,147),Vector2(587,152)]),palette.GOLD)
