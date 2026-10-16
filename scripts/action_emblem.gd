extends Control

var kind := "interact"
const KUNAI = preload("res://assets/art/kunai.svg")
const FIRE = preload("res://assets/characters/katon-fire.png")

func _ready() -> void:
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	size=Vector2(78,78)

func _draw() -> void:
	var center:=Vector2(39,20)
	var accent:=Color("d3b57b")
	match kind:
		"kunai":
			draw_set_transform(center,-PI/4)
			draw_texture_rect(KUNAI,Rect2(-13,-5,26,10),false,Color("d9e6df"))
			draw_set_transform(Vector2.ZERO)
		"katon": draw_texture_rect(FIRE,Rect2(center-Vector2(16,13),Vector2(32,26)),false)
		"dodge":
			for x in [-8,3]:
				draw_polyline(PackedVector2Array([center+Vector2(x-4,-8),center+Vector2(x+4,0),center+Vector2(x-4,8)]),accent,2,true)
		"interact":
			draw_rect(Rect2(center-Vector2(12,8),Vector2(24,16)),accent,false,1.5)
			draw_polyline(PackedVector2Array([center+Vector2(-7,8),center+Vector2(-7,13),center+Vector2(-1,8)]),accent,1.5,true)
			for x in [-6,0,6]: draw_circle(center+Vector2(x,0),1.2,accent)
