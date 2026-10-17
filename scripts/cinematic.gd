extends Node

var game: Node2D
var camera: Camera2D
var material: ShaderMaterial
var trauma := 0.0
var clock := 0.0
var motion_enabled := true
var previous_area := -1
var area_title: Label
var title_timer := 0.0
var displayed_night:=0.0
var displayed_warmth:=0.0
var look_ahead:=Vector2.ZERO

func _ready() -> void:
	camera = Camera2D.new()
	camera.position = Vector2(480, 270)
	camera.zoom = Vector2.ONE * 1.035
	game.add_child(camera)
	var grade := CanvasLayer.new()
	grade.layer = 1
	add_child(grade)
	var rect := ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	material = ShaderMaterial.new()
	material.shader = preload("res://shaders/cinematic.gdshader")
	rect.material = material
	grade.add_child(rect)
	var titles := CanvasLayer.new()
	titles.layer = 2
	add_child(titles)
	area_title = Label.new()
	area_title.position = Vector2(250, 104)
	area_title.size = Vector2(460, 64)
	area_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	area_title.add_theme_font_size_override("font_size", 24)
	area_title.add_theme_color_override("font_color", Color("ffedc5"))
	area_title.add_theme_color_override("font_shadow_color", Color("1c2f35"))
	area_title.add_theme_constant_override("shadow_offset_x", 2)
	area_title.add_theme_constant_override("shadow_offset_y", 2)
	area_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	titles.add_child(area_title)

func kick(amount: float) -> void:
	trauma = maxf(trauma, clampf(amount, 0, 1))

func _process(delta: float) -> void:
	clock += delta
	trauma = maxf(0, trauma - delta * 2.8)
	var center:=Vector2(480,270)
	var focus:=center
	var desired_look:=Vector2.ZERO
	if motion_enabled and game.lines.is_empty() and not game.ui.modal_open():
		var offset:Vector2=game.player-center
		var drift:=Vector2(signf(offset.x)*maxf(0,absf(offset.x)-95)*0.025,signf(offset.y)*maxf(0,absf(offset.y)-45)*0.02)
		if game.movement!=Vector2.ZERO: desired_look=game.motion_velocity*0.012
		focus+=drift
	look_ahead=look_ahead.lerp(desired_look,1.0-exp(-delta*5.0))
	if motion_enabled: focus+=look_ahead
	var margin:=Vector2(480,270)*(Vector2.ONE-Vector2.ONE/camera.zoom)-Vector2(2,2)
	focus=focus.clamp(center-margin,center+margin)
	camera.position=camera.position.lerp(focus,1.0-exp(-delta*4.0))
	camera.offset = Vector2(sin(clock * 83), cos(clock * 97)) * trauma * trauma * 6 if motion_enabled else Vector2.ZERO
	var night_target:float=game.day_cycle.night_amount(game.stage)
	var weight:=1.0-exp(-delta*2.0)
	displayed_night=lerpf(displayed_night,night_target,weight)
	displayed_warmth=lerpf(displayed_warmth,game.day_cycle.warmth(game.stage),weight)
	material.set_shader_parameter("night_amount",displayed_night*(1.0 if game.room=="outside" else 0.12))
	material.set_shader_parameter("sunset_amount",displayed_warmth*(0.55 if game.room!="outside" else 1.0))
	material.set_shader_parameter("night_darkness",displayed_night*(0.4 if game.room=="outside" and game.background.area!=2 else 0.03))
	if game.background.area != previous_area:
		previous_area = game.background.area
		title_timer = 2.5
		area_title.text = ["CAMPO DE TREINO", "VILA OCULTA DA FOLHA", "FLORESTA DE KONOHA","ACADEMIA NINJA","CASA DO HENRIQUE"][maxi(previous_area, 0)]
	title_timer = maxf(0, title_timer - delta)
	area_title.modulate.a = minf(1, title_timer) * (0.0 if not game.lines.is_empty() else 1.0)
