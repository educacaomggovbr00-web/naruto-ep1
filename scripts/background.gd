extends Node2D

# Paintings are shared by all modes; two are held briefly during a home light transition.
const ENVIRONMENTS := [
	"res://assets/environments/training-premium.png",
	"res://assets/environments/konoha-premium.png",
	"res://assets/environments/forest-premium.png"
]
var area := -1
var night := false
var environment: Texture2D
var room_id := "outside"
var previous_environment:Texture2D=null
var fade:=1.0
var foliage:ShaderMaterial
const INTERIORS = preload("res://scripts/interiors.gd")

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	foliage=ShaderMaterial.new()
	foliage.shader=preload("res://shaders/foliage.gdshader")
	material=foliage

func set_area(stage: int, room: String = "outside", clock_night: bool = false) -> void:
	var next_area := 3 if room == "academy" else 4 if room == "home" else 0 if stage <= 1 else 1 if stage == 2 or stage >= 5 else 2
	if stage==2 and room=="outside" and get_parent()!=null:
		var district:String=get_parent().world.district
		if district=="training": next_area=0
		elif district=="residential": next_area=5
	var next_night := stage >= 3 or clock_night
	if next_area != area or (room == "home" and next_night != night):
		var path: String = "res://assets/environments/residential-generated.png" if next_area==5 else INTERIORS.ROOMS[room]["image"] if room != "outside" else ENVIRONMENTS[next_area]
		if room == "home" and next_night: path="res://assets/environments/home-night-interior.jpg"
		previous_environment=environment if next_area==area and room=="home" else null
		fade=0.0 if previous_environment!=null else 1.0
		environment = load(path) as Texture2D
	if next_area != area or next_night != night:
		area = next_area
		room_id = room
		night = next_night
		if foliage!=null: foliage.set_shader_parameter("area_id",area)
		queue_redraw()

func _draw() -> void:
	if environment != null:
		draw_texture_rect(environment, Rect2(0, 0, 960, 540), false)
	if previous_environment!=null:
		draw_texture_rect(previous_environment,Rect2(0,0,960,540),false,Color(1,1,1,1.0-fade))

func animate(clock: float, strength:float=1.0, shake_at:Vector2=Vector2.ZERO, shake_life:float=0.0) -> void:
	if foliage==null: return
	foliage.set_shader_parameter("wind_time",clock)
	foliage.set_shader_parameter("wind_strength",strength)
	foliage.set_shader_parameter("shake_at",shake_at/Vector2(960,540))
	foliage.set_shader_parameter("shake_life",shake_life)

func _process(delta: float) -> void:
	if previous_environment!=null:
		fade=minf(1.0,fade+delta/0.9)
		if fade>=1: previous_environment=null
		queue_redraw()
