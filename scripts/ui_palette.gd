extends RefCounted

const INK := Color("131f28")
const PAPER := Color("f4e7ca")
const MUTED := Color("b8c5bd")
const GOLD := Color("c6a76b")
const RED := Color("a95340")

static func panel() -> StyleBoxFlat:
	var box:=StyleBoxFlat.new()
	box.bg_color=Color(0.055,0.09,0.115,0.97)
	box.border_color=Color("88704c")
	box.set_border_width_all(1)
	box.set_corner_radius_all(10)
	box.shadow_color=Color(0.015,0.025,0.035,0.55)
	box.shadow_size=10
	box.shadow_offset=Vector2(0,4)
	return box

static func button(state: String, dialogue: bool = false) -> StyleBoxFlat:
	var box:=panel()
	box.bg_color=Color(0.055,0.09,0.115,0.96) if dialogue else Color(0.07,0.12,0.15,0.92)
	box.border_color=Color("756b53")
	if state=="hover":
		box.bg_color=Color("2a393b")
		box.border_color=GOLD
	elif state=="pressed":
		box.bg_color=Color("633d30")
		box.border_color=Color("ebc883")
	elif state=="focus": box.border_color=GOLD
	box.set_corner_radius_all(12)
	box.shadow_size=5
	box.shadow_offset=Vector2(0,3)
	box.content_margin_left=18 if dialogue else 6
	box.content_margin_right=18 if dialogue else 6
	box.content_margin_top=10
	box.content_margin_bottom=10
	return box

static func name_tag(host: Node2D, anchor: Vector2, caption: String, style: StyleBoxFlat, font_size: int = 11) -> void:
	var font:=ThemeDB.fallback_font
	var width:=font.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
	var box:=Rect2(anchor+Vector2(-width*0.5-7,-14),Vector2(width+14,21))
	host.draw_style_box(style,box)
	host.draw_string(font,anchor+Vector2(-width*0.5,0),caption,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,PAPER)

static func name_box() -> StyleBoxFlat:
	var box:=StyleBoxFlat.new()
	box.bg_color=Color(0.04,0.075,0.09,0.76)
	box.set_corner_radius_all(4)
	return box
