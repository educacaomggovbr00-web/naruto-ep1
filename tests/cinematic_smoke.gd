extends SceneTree
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.savegame.enabled = false
	root.add_child(game)
	await process_frame
	assert(game.ui.layer > 1, "Interface must stay above the world grading")
	assert(game.cinematic.camera.zoom.x > 1, "Camera must crop to safe world margins")
	game.cinematic.motion_enabled = true
	game.cinematic.kick(0.9)
	game.cinematic._process(0.02)
	assert(game.cinematic.camera.offset.length() > 0, "Impact should move the world camera")
	game.cinematic.motion_enabled = false
	game.cinematic._process(0.02)
	assert(game.cinematic.camera.offset == Vector2.ZERO, "Motion option must disable camera shake")
	var grade: ShaderMaterial = game.cinematic.material
	assert(grade.shader != null)
	for kind in ["kunai", "katon", "impact"]:
		var stream: AudioStreamWAV = game.audio.sounds[kind]
		assert(stream.data.size() > 3000 and stream.mix_rate == 11025)
	game.audio.set_enabled(false)
	game.audio.play("kunai")
	assert(not game.audio.ambient.playing, "Disabling audio must stop the ambience")
	for voice in game.audio.voices:
		assert(not voice.playing)
	await create_timer(0.1).timeout
	game.audio.set_enabled(true)
	await create_timer(0.1).timeout
	assert(game.audio.ambient.playing)
	print("PASS: stable interface, camera impact, reduced motion, color grade and sound controls")
	game.audio.shutdown()
	game.queue_free()
	await create_timer(0.1).timeout
	call_deferred("quit")
