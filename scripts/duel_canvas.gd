extends Node2D
var duel: Node
var hud := false
func _process(_delta: float) -> void: queue_redraw()
func _draw() -> void:
	if hud: duel.draw_hud(self)
	else: duel.draw_world(self)
