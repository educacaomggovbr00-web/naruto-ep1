extends CanvasLayer

var game: Node2D
var touch_buttons: Array[Button] = []
var touch_opacity := 0.8
var settings_panel: Panel
var speaker_label: Label
var body_label: Label
var continue_label: Label
var portrait: TextureRect
var typing := 0.0
var settings_file := ConfigFile.new()
var touch_pointers: Dictionary = {}
var opacity_slider: HSlider

func _ready() -> void:
	layer = 3
	var hud_canvas := preload("res://scripts/hud_canvas.gd").new()
	hud_canvas.game = game
	add_child(hud_canvas)
	settings_file.load("user://interface.cfg")
	touch_opacity = clampf(float(settings_file.get_value("touch", "opacity", 0.8)), 0.3, 1.0)
	game.hud = label_at("", Vector2(70, 7), Vector2(425, 24), 17, Color("f8e8c6"))
	game.objective = label_at("", Vector2(70, 33), Vector2(860, 24), 13, Color("cad4c7"))
	game.dialogue = button_at("", Vector2(175, 369), Vector2(610, 155))
	game.dialogue.pressed.connect(game.next_line)
	game.dialogue.z_index = 10
	game.dialogue.hide()
	# Children ignore mouse input so the whole panel remains a large advance target.
	portrait = TextureRect.new()
	portrait.position = Vector2(15, 29)
	portrait.size = Vector2(83, 98)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game.dialogue.add_child(portrait)
	speaker_label = child_label(game.dialogue, "", Vector2(113, 12), Vector2(470, 23), 18, Color("efbc6e"))
	body_label = child_label(game.dialogue, "", Vector2(113, 42), Vector2(477, 80), 16, Color("f3e6ca"))
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	continue_label = child_label(game.dialogue, "", Vector2(113, 130), Vector2(470, 18), 11, Color("a9b9b5"))
	# A 48px directional pad leaves the center of the screen clear.
	for info in [["↑", Vector2(66, 380), "up"], ["←", Vector2(16, 430), "left"], ["↓", Vector2(66, 430), "down"], ["→", Vector2(116, 430), "right"], ["CORRER", Vector2(16, 491), "run"], ["FURTIVO", Vector2(100, 491), "sneak"]]:
		var size := Vector2(80, 32) if info[2] in ["run", "sneak"] else Vector2(48, 48)
		var button := button_at(info[0], info[1], size)
		button.add_theme_font_size_override("font_size", 11 if size.x == 80 else 20)
		var action: String = info[2]
		button.button_down.connect(func(): game.held[action] = true)
		button.button_up.connect(func(): game.held[action] = false)
		button.set_meta("action", action)
		touch_buttons.append(button)
	for info in [["KUNAI", Vector2(754, 450), "kunai"], ["KATON", Vector2(821, 389), "katon"], ["AÇÃO", Vector2(881, 450), "interact"]]:
		var button := button_at(info[0], info[1], Vector2(62, 62))
		var action: String = info[2]
		button.add_theme_font_size_override("font_size", 12)
		button.pressed.connect(func(): game.act(action))
		button.set_meta("action", action)
		touch_buttons.append(button)
	var settings_button := button_at("AJUSTES", Vector2(838, 72), Vector2(106, 30))
	settings_button.add_theme_font_size_override("font_size", 10)
	settings_button.pressed.connect(toggle_settings)
	settings_panel = Panel.new()
	settings_panel.position = Vector2(648, 111)
	settings_panel.size = Vector2(296, 190)
	settings_panel.add_theme_stylebox_override("panel", panel_style())
	settings_panel.z_index = 20
	add_child(settings_panel)
	settings_panel.hide()
	child_label(settings_panel, "OPACIDADE DOS CONTROLES", Vector2(16, 12), Vector2(265, 20), 12, Color("edc787"))
	opacity_slider = HSlider.new()
	opacity_slider.position = Vector2(16, 44)
	opacity_slider.size = Vector2(264, 30)
	opacity_slider.min_value = 0.3
	opacity_slider.max_value = 1.0
	opacity_slider.step = 0.05
	opacity_slider.value = touch_opacity
	opacity_slider.value_changed.connect(set_touch_opacity)
	opacity_slider.drag_ended.connect(func(_changed: bool): save_preferences())
	settings_panel.add_child(opacity_slider)
	child_label(settings_panel, "WASD · R correr · Shift furtivo · J / K / E", Vector2(16, 88), Vector2(266, 20), 10, Color("aebeb7"))
	var camera_toggle := CheckButton.new()
	camera_toggle.text = "Câmera dinâmica"
	camera_toggle.position = Vector2(12, 113)
	camera_toggle.size = Vector2(270, 30)
	camera_toggle.button_pressed = bool(settings_file.get_value("cinema", "motion", true))
	game.cinematic.motion_enabled = camera_toggle.button_pressed
	camera_toggle.toggled.connect(func(value: bool): game.cinematic.motion_enabled = value; settings_file.set_value("cinema", "motion", value); save_preferences())
	settings_panel.add_child(camera_toggle)
	var audio_toggle := CheckButton.new()
	audio_toggle.text = "Som ambiente e efeitos"
	audio_toggle.position = Vector2(12, 149)
	audio_toggle.size = Vector2(270, 30)
	audio_toggle.button_pressed = bool(settings_file.get_value("cinema", "audio", true))
	game.audio.set_enabled(audio_toggle.button_pressed)
	audio_toggle.toggled.connect(func(value: bool): game.audio.set_enabled(value); settings_file.set_value("cinema", "audio", value); save_preferences())
	settings_panel.add_child(audio_toggle)
	game.restart = button_at("Jogar novamente", Vector2(375, 275), Vector2(210, 46))
	game.restart.pressed.connect(func(): get_tree().reload_current_scene())
	game.restart.hide()
	set_touch_opacity(touch_opacity)

func panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("172c35")
	style.border_color = Color("ad8a52")
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.shadow_color = Color(0, 0, 0, 0.25)
	style.shadow_size = 6
	return style

func button_at(text: String, at: Vector2, size: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.position = at
	button.size = size
	game.style_button(button)
	add_child(button)
	return button

func label_at(text: String, at: Vector2, size: Vector2, font_size: int, color: Color) -> Label:
	return child_label(self, text, at, size, font_size, color)

func child_label(parent: Node, text: String, at: Vector2, size: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = at
	label.size = size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func set_touch_opacity(value: float) -> void:
	touch_opacity = clampf(value, 0.3, 1.0)
	for button in touch_buttons:
		button.modulate.a = touch_opacity

func save_preferences() -> void:
	settings_file.set_value("touch", "opacity", touch_opacity)
	settings_file.save("user://interface.cfg")

func toggle_settings() -> void:
	settings_panel.visible = not settings_panel.visible
	release_touches()
	game.movement = Vector2.ZERO
	if not settings_panel.visible:
		save_preferences()

func show_line(text: String) -> void:
	settings_panel.hide()
	var speaker := "NARRADOR"
	var body := text
	var colon := text.find(":")
	if colon > 0 and colon < 24:
		speaker = text.substr(0, colon)
		body = text.substr(colon + 1).strip_edges()
	speaker_label.text = speaker.to_upper()
	body_label.text = body
	body_label.visible_characters = 0
	typing = 0
	continue_label.text = "E / TOQUE · Revelar texto"
	update_portrait(speaker)
	game.dialogue.show()

func update_portrait(speaker: String) -> void:
	var atlas := AtlasTexture.new()
	var art = game.art.character_art
	if speaker == "Naruto":
		atlas.atlas = load("res://assets/mugen/naruto/7322-34.png")
		atlas.region = Rect2(18, 0, 58, 58)
	elif speaker in ["Iruka", "Mizuki"]:
		atlas.atlas = load("res://assets/art/%s.svg" % speaker.to_lower())
		atlas.region = Rect2(3, 0, 18, 15)
	elif speaker in ["Henrique", "NARRADOR"] and not art.compact_mode:
		atlas.atlas = art.henrique_texture
		atlas.region = Rect2(85, 23, 109, 125)
	else:
		atlas.atlas = load("res://assets/art/henrique.svg")
		atlas.region = Rect2(3, 0, 18, 15)
	portrait.texture = atlas
	portrait.modulate = Color(0.75, 0.83, 0.83) if speaker == "NARRADOR" else Color.WHITE

func finish_typing() -> bool:
	if body_label.visible_characters >= 0 and body_label.visible_characters < body_label.text.length():
		body_label.visible_characters = -1
		continue_label.text = "E / TOQUE · Continuar  ›"
		return true
	return false

func _process(delta: float) -> void:
	for button in touch_buttons:
		button.visible = game.lines.is_empty() or button.get_meta("action") == "interact"
	if game.dialogue.visible and body_label.visible_characters >= 0:
		typing += delta * 42
		body_label.visible_characters = mini(int(typing), body_label.text.length())
		if body_label.visible_characters >= body_label.text.length():
			continue_label.text = "E / TOQUE · Continuar  ›"

func release_touches() -> void:
	touch_pointers.clear()
	game.held.clear()

func touch_target(at: Vector2) -> Button:
	for button in touch_buttons:
		if button.visible and button.get_global_rect().has_point(at):
			return button
	return null

func release_pointer(index: int) -> void:
	if not touch_pointers.has(index):
		return
	var action: String = touch_pointers[index].get_meta("action")
	touch_pointers.erase(index)
	for other in touch_pointers.values():
		if other.get_meta("action") == action:
			return
	game.held.erase(action)

func _input(event: InputEvent) -> void:
	# Touch buttons are dispatched above GUI; suppress their emulated mouse copy.
	if event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION and touch_target(event.position) != null:
		get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch:
		if not event.pressed:
			if touch_pointers.has(event.index):
				release_pointer(event.index)
				get_viewport().set_input_as_handled()
		elif not settings_panel.visible:
			var button := touch_target(event.position)
			if button != null:
				touch_pointers[event.index] = button
				var action: String = button.get_meta("action")
				if action in ["kunai", "katon", "interact"]:
					game.act(action)
				else:
					game.held[action] = true
				get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and touch_pointers.has(event.index):
		var button: Button = touch_pointers[event.index]
		if not button.get_global_rect().has_point(event.position):
			release_pointer(event.index)
		get_viewport().set_input_as_handled()
