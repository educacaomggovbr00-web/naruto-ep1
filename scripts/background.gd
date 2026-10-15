extends Node2D

# Keep only the current painting resident. The imported art is shared by all modes.
const ENVIRONMENTS := [
	"res://assets/environments/training-premium.png",
	"res://assets/environments/konoha-premium.png",
	"res://assets/environments/forest-premium.png"
]
var area := -1
var night := false
var environment: Texture2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

func set_area(stage: int) -> void:
	var next_area := 0 if stage <= 1 else 1 if stage == 2 or stage >= 5 else 2
	var next_night := stage >= 3
	if next_area != area:
		environment = load(ENVIRONMENTS[next_area]) as Texture2D
	if next_area != area or next_night != night:
		area = next_area
		night = next_night
		queue_redraw()

func _draw() -> void:
	if environment != null:
		draw_texture_rect(environment, Rect2(0, 0, 960, 540), false)
	if night and area != 2:
		draw_rect(Rect2(0, 0, 960, 540), Color(0.025, 0.065, 0.19, 0.55))
