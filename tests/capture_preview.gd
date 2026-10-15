extends SceneTree

# Run with a real display (or Xvfb); captures the rendered Godot viewport.
func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	root.size = Vector2i(960, 540)
	for i in range(4):
		await process_frame
	while not game.lines.is_empty():
		game.next_line()
	game.player = Vector2(540, 300)
	for i in range(20):
		await process_frame
	await RenderingServer.frame_post_draw
	var output := OS.get_environment("NARUTO_PREVIEW_PATH")
	if output.is_empty():
		output = "/tmp/naruto-preview.png"
	var result := root.get_texture().get_image().save_png(output)
	assert(result == OK, "Could not save rendered preview")
	print("Rendered preview: ", output)
	quit()
