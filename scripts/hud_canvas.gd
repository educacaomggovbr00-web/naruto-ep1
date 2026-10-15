extends Node2D
var game: Node2D
func _process(_delta: float) -> void:
	queue_redraw()
func _draw() -> void:
	game.art.draw_hud(self, game)
