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
var direction_fingers: Dictionary = {}
var resume_overlay: Control
var toast_panel: Panel
var toast_label: Label
var toast_time := 0.0
var resume_data: Dictionary = {}
var resume_title: Label
var resume_subtitle: Label
var continue_button: Button
var hud_canvas: Node2D
var settings_button: Button
var opacity_slider: HSlider
var transition_overlay: ColorRect
var practice: Control
var suppressed_menu_touch:=Vector2(INF,INF)
var journal: Control
var journal_button: Button
var light_selector:OptionButton
var light_note:Label

func _ready() -> void:
	layer = 3
	hud_canvas = preload("res://scripts/hud_canvas.gd").new()
	hud_canvas.game = game
	add_child(hud_canvas)
	settings_file.load("user://interface.cfg")
	touch_opacity = clampf(float(settings_file.get_value("touch", "opacity", 0.8)), 0.3, 1.0)
	game.hud = label_at("", Vector2(82, 10), Vector2(480, 24), 17, Color("f8e8c6"))
	game.objective = label_at("", Vector2(82, 44), Vector2(850, 24), 12, Color("cad4c7"))
	game.dialogue = button_at("", Vector2(175, 360), Vector2(610, 164))
	game.dialogue.pressed.connect(game.next_line)
	game.dialogue.z_index = 10
	game.dialogue.hide()
	game.style_button(game.dialogue,true)
	var chrome=preload("res://scripts/dialogue_chrome.gd").new()
	game.dialogue.add_child(chrome)
	# Children ignore mouse input so the whole panel remains a large advance target.
	portrait = TextureRect.new()
	portrait.position = Vector2(18, 32)
	portrait.size = Vector2(79, 106)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game.dialogue.add_child(portrait)
	speaker_label = child_label(game.dialogue, "", Vector2(120, 9), Vector2(464, 23), 17, Color("efbc6e"))
	body_label = child_label(game.dialogue, "", Vector2(120, 42), Vector2(464, 92), 16, Color("f3e6ca"))
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	continue_label = child_label(game.dialogue, "", Vector2(120, 144), Vector2(452, 17), 10, Color("a9b9b5"))
	# Larger thumb targets, safe margins and a separated two-by-two action cluster.
	for info in [["↑", Vector2(82, 350), "up"], ["←", Vector2(22, 410), "left"], ["↓", Vector2(82, 470), "down"], ["→", Vector2(142, 410), "right"], ["CORRER", Vector2(22, 300), "run"], ["FURTIVO", Vector2(118, 300), "sneak"]]:
		var action: String = info[2]
		var latched: bool = action in ["run", "sneak"]
		var button := button_at(info[0], info[1], Vector2(86, 40) if latched else Vector2(58, 58))
		button.add_theme_font_size_override("font_size", 11 if latched else 23)
		button.set_meta("action", action)
		button.set_meta("latched", latched)
		if latched:
			button.toggle_mode = true
			button.pressed.connect(func(): toggle_mode(action))
			button.tooltip_text = "Toque para ativar ou desligar"
		else:
			button.button_down.connect(func(): game.held[action] = true)
			button.button_up.connect(func(): game.held[action] = false)
		touch_buttons.append(button)
	for info in [["ESQUIVA", Vector2(760, 354), "dodge"], ["KATON", Vector2(850, 354), "katon"], ["KUNAI", Vector2(760, 446), "kunai"], ["AÇÃO", Vector2(850, 446), "interact"]]:
		var action: String = info[2]
		var button := button_at("\n"+info[0], info[1], Vector2(78, 78))
		button.add_theme_font_size_override("font_size", 10)
		var emblem=preload("res://scripts/action_emblem.gd").new()
		emblem.kind=action
		button.add_child(emblem)
		button.pressed.connect(func(): game.act(action))
		button.set_meta("action", action)
		for state in ["normal", "hover", "pressed"]:
			var style: StyleBoxFlat = button.get_theme_stylebox(state).duplicate()
			style.set_corner_radius_all(32)
			button.add_theme_stylebox_override(state, style)
		if action == "dodge": button.tooltip_text = "Q · Esquiva (30 de fôlego)"
		touch_buttons.append(button)
	journal_button=button_at("DIÁRIO · M",Vector2(716,82),Vector2(112,44))
	journal_button.add_theme_font_size_override("font_size",11)
	journal_button.pressed.connect(func(): journal.toggle())
	settings_button = button_at("AJUSTES", Vector2(838, 82), Vector2(106, 44))
	settings_button.add_theme_font_size_override("font_size", 10)
	settings_button.pressed.connect(toggle_settings)
	settings_panel = Panel.new()
	settings_panel.position = Vector2(648, 136)
	settings_panel.size = Vector2(296, 326)
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
	child_label(settings_panel,"CICLO DE LUZ",Vector2(16,187),Vector2(264,20),11,Color("edc787"))
	light_selector=OptionButton.new()
	light_selector.position=Vector2(16,211)
	light_selector.size=Vector2(264,34)
	game.style_button(light_selector)
	light_selector.add_theme_font_size_override("font_size",13)
	for caption in ["Ciclo automático","Manhã","Tarde","Noite"]: light_selector.add_item(caption)
	light_selector.item_selected.connect(change_light)
	settings_panel.add_child(light_selector)
	light_note=child_label(settings_panel,"",Vector2(16,250),Vector2(264,22),10,Color("aebeb7"))
	var save_button := Button.new()
	save_button.text = "SALVAR"
	save_button.position = Vector2(12, 282)
	save_button.size = Vector2(129, 30)
	game.style_button(save_button)
	save_button.pressed.connect(func(): game.save_checkpoint())
	settings_panel.add_child(save_button)
	var load_button := Button.new()
	load_button.text = "CARREGAR"
	load_button.position = Vector2(151, 282)
	load_button.size = Vector2(129, 30)
	game.style_button(load_button)
	load_button.pressed.connect(load_checkpoint)
	settings_panel.add_child(load_button)
	game.restart = button_at("Jogar novamente", Vector2(375, 275), Vector2(210, 46))
	game.restart.pressed.connect(game.continue_story)
	game.restart.hide()
	toast_panel = Panel.new()
	toast_panel.position = Vector2(240, 321)
	toast_panel.size = Vector2(400, 35)
	toast_panel.add_theme_stylebox_override("panel", panel_style())
	toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_panel.z_index = 30
	add_child(toast_panel)
	toast_label = child_label(toast_panel, "", Vector2(8, 6), Vector2(384, 25), 13, Color("f0d79d"))
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_panel.hide()
	journal=preload("res://scripts/journal.gd").new()
	journal.game=game
	add_child(journal)
	practice=preload("res://scripts/chakra_practice.gd").new()
	practice.game=game
	add_child(practice)
	build_resume_menu()
	set_touch_opacity(touch_opacity)
	transition_overlay=ColorRect.new()
	transition_overlay.size=Vector2(960,540)
	transition_overlay.color=Color(0.025,0.04,0.06,0)
	transition_overlay.mouse_filter=Control.MOUSE_FILTER_STOP
	transition_overlay.z_index=1000
	add_child(transition_overlay)
	transition_overlay.hide()

func fade_to(alpha: float) -> Tween:
	transition_overlay.show()
	var tween := create_tween()
	tween.tween_property(transition_overlay,"color:a",alpha,0.13)
	if alpha == 0: tween.finished.connect(transition_overlay.hide)
	return tween

func panel_style() -> StyleBoxFlat:
	return preload("res://scripts/ui_palette.gd").panel()

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

func change_light(index: int) -> void:
	if game.stage>=3 or (game.episode.active() and game.episode.step<7): return
	game.day_cycle.set_mode(index)
	game.background.set_area(game.stage,game.room,game.day_cycle.is_night(game.stage))
	game.audio.set_night(game.day_cycle.is_night(game.stage))
	game.save_checkpoint(false)

func toggle_settings() -> void:
	if practice.visible: return
	if journal.visible: journal.close()
	settings_panel.visible = not settings_panel.visible
	release_touches()
	game.movement = Vector2.ZERO
	if not settings_panel.visible:
		save_preferences()

func show_line(text: String) -> void:
	if journal!=null: journal.hide()
	if practice!=null: practice.hide()
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
		atlas.atlas = art.get_naruto_gallery_texture()
		atlas.region = Rect2(22, 18, 52, 60)
	elif art.attached_cast["actors"].has(speaker):
		atlas.atlas = art.get_cast_texture()
		var crop: Array = art.attached_cast["actors"][speaker]["portrait"]
		atlas.region = Rect2(crop[0],crop[1],crop[2],crop[3])
	elif speaker in ["Henrique", "NARRADOR"] and not art.compact_mode:
		atlas.atlas = art.player_texture
		var crop: Array = art.attached_player["portrait"]
		atlas.region = Rect2(crop[0],crop[1],crop[2],crop[3])
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
	hud_canvas.visible = not resume_overlay.visible
	game.hud.visible = not resume_overlay.visible
	game.objective.visible = not resume_overlay.visible
	settings_button.visible = not resume_overlay.visible
	journal_button.visible=not resume_overlay.visible and game.lines.is_empty() and not game.travelling
	journal_button.disabled=journal.visible or practice.visible
	light_selector.disabled=game.stage>=3 or (game.episode.active() and game.episode.step<7)
	light_selector.select(game.day_cycle.mode)
	light_note.text="A aula acontece de manhã." if game.episode.active() and game.episode.step<7 else "A história mantém a noite nesta etapa." if game.stage>=3 else "Dia completo: 8 min de exploração."
	toast_time = maxf(0, toast_time - delta)
	toast_panel.visible = toast_time > 0 and game.lines.is_empty() and not modal_open()
	refresh_controls()
	if game.dialogue.visible and body_label.visible_characters >= 0:
		typing += delta * 42
		body_label.visible_characters = mini(int(typing), body_label.text.length())
		if body_label.visible_characters >= body_label.text.length():
			continue_label.text = "E / TOQUE · Continuar  ›"

func refresh_controls() -> void:
	for button in touch_buttons:
		var action: String = button.get_meta("action")
		if action in ["kunai","katon"]:
			var caption:="\n"+action.to_upper()
			if game.cooldown>0: caption+="\n%.1f s" % game.cooldown
			elif action=="katon" and game.chakra<25: caption+="\n25 chakra"
			button.text=caption
		if button.get_meta("latched", false):
			button.set_pressed_no_signal(bool(game.held.get(button.get_meta("action"), false)))
		button.visible = not modal_open() and (game.lines.is_empty() or button.get_meta("action") == "interact")
		if (game.room != "outside" or game.episode.active()) and action in ["kunai","katon","dodge","sneak"]: button.visible=false
		if game.stage == 6 and (game.lines.is_empty() or action != "interact"): button.visible=false

func release_touches() -> void:
	game.motion_velocity=Vector2.ZERO
	game.combat.cancel_attacks()
	touch_pointers.clear()
	direction_fingers.clear()
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
	var latched: bool = touch_pointers[index].get_meta("latched", false)
	touch_pointers.erase(index)
	if latched: return
	for other in touch_pointers.values():
		if other.get_meta("action") == action:
			return
	game.held.erase(action)

func menu_target(at: Vector2) -> Button:
	var candidates:Array[Button]=[]
	if practice.visible: candidates=[practice.confirm_button,practice.close_button]
	elif journal.visible: candidates=[journal.close_button]
	elif not modal_open() and journal_button.visible: candidates=[journal_button]
	for button in candidates:
		if button.get_global_rect().has_point(at): return button
	return null

func _input(event: InputEvent) -> void:
	# Suppress only the emulated mouse copy of a touch we dispatched ourselves.
	if event is InputEventMouse and event.device==InputEvent.DEVICE_ID_EMULATION and event.position.distance_to(suppressed_menu_touch)<5:
		get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch and event.pressed:
		suppressed_menu_touch=Vector2(INF,INF)
		var menu_button:Button=menu_target(event.position)
		if menu_button!=null:
			suppressed_menu_touch=event.position
			menu_button.pressed.emit()
			get_viewport().set_input_as_handled()
			return
	# Touch buttons are dispatched above GUI; suppress their emulated mouse copy.
	if event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION and touch_target(event.position) != null:
		get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch:
		if not event.pressed:
			if touch_pointers.has(event.index) or direction_fingers.has(event.index):
				direction_fingers.erase(event.index)
				release_pointer(event.index)
				get_viewport().set_input_as_handled()
		elif not modal_open():
			var button := touch_target(event.position)
			if button != null:
				touch_pointers[event.index] = button
				var action: String = button.get_meta("action")
				if button.get_meta("latched", false):
					toggle_mode(action)
				elif action in ["kunai", "katon", "interact", "dodge"]:
					game.act(action)
				else:
					direction_fingers[event.index] = true
					game.held[action] = true
				get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and (touch_pointers.has(event.index) or direction_fingers.has(event.index)):
		if direction_fingers.has(event.index):
			var target := touch_target(event.position)
			release_pointer(event.index)
			if target != null and target.get_meta("action") in ["left", "right", "up", "down"]:
				touch_pointers[event.index] = target
				game.held[target.get_meta("action")] = true
		elif touch_pointers.has(event.index):
			var button: Button = touch_pointers[event.index]
			if not button.get_global_rect().has_point(event.position): release_pointer(event.index)
		get_viewport().set_input_as_handled()

func toggle_mode(action: String) -> void:
	var active: bool = not bool(game.held.get(action, false))
	if active: game.held[action] = true
	else: game.held.erase(action)
	if active: game.held.erase("sneak" if action == "run" else "run")

func toast(text: String) -> void:
	toast_label.text = text
	toast_time = 2.2

func modal_open() -> bool:
	return settings_panel.visible or resume_overlay.visible or (journal!=null and journal.visible) or (practice!=null and practice.visible) or game.travelling

func build_resume_menu() -> void:
	resume_overlay = Control.new()
	resume_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resume_overlay.z_index = 40
	add_child(resume_overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.06, 0.08, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resume_overlay.add_child(shade)
	var panel := Panel.new()
	panel.position = Vector2(235, 145)
	panel.size = Vector2(490, 238)
	panel.add_theme_stylebox_override("panel", panel_style())
	resume_overlay.add_child(panel)
	resume_title = child_label(panel, "NARUTO  /  EP -1", Vector2(28, 22), Vector2(430, 30), 25, Color("e9c47d"))
	resume_subtitle = child_label(panel, "Continue sua jornada em Konoha", Vector2(28, 62), Vector2(430, 30), 16, Color("d0dacf"))
	continue_button = Button.new()
	continue_button.text = "CONTINUAR  ›"
	continue_button.position = Vector2(28, 112)
	continue_button.size = Vector2(434, 44)
	game.style_button(continue_button)
	continue_button.pressed.connect(continue_game)
	panel.add_child(continue_button)
	var new_button := Button.new()
	new_button.text = "NOVO JOGO"
	new_button.position = Vector2(28, 169)
	new_button.size = Vector2(434, 39)
	game.style_button(new_button)
	new_button.pressed.connect(new_game)
	panel.add_child(new_button)
	resume_overlay.hide()

func offer_resume(data: Dictionary) -> void:
	if data.is_empty():
		if not game.savegame.last_error.is_empty():
			resume_title.text = "PROGRESSO INDISPONÍVEL"
			resume_title.add_theme_font_size_override("font_size", 21)
			resume_subtitle.text = "Arquivo inválido. Você pode começar um novo jogo."
			resume_subtitle.add_theme_font_size_override("font_size", 13)
			continue_button.disabled = true
			game.dialogue.hide()
			resume_overlay.show()
		return
	resume_data = data
	game.background.set_area(int(data.stage),str(data.get("room","outside")))
	resume_subtitle.text = "%s · Etapa %d de 7" % [game.OBJECTIVES[int(data.stage)].split(" • ")[0], int(data.stage) + 1]
	if int(data.get("episode_step",0))>0: resume_subtitle.text="EPISÓDIO 1 · "+game.episode.TITLES[int(data.episode_step)]
	game.dialogue.hide()
	resume_overlay.show()
	release_touches()

func continue_game() -> void:
	if resume_data.is_empty(): return
	if game.savegame.apply(game, resume_data):
		resume_overlay.hide()
		toast("Progresso retomado.")

func new_game() -> void:
	resume_overlay.hide()
	resume_data.clear()
	show_line(game.lines[game.line_index])
	game.save_checkpoint(false)

func load_checkpoint() -> void:
	var data: Dictionary = game.savegame.read_save()
	if data.is_empty():
		toast("Nenhum progresso válido para carregar.")
		return
	settings_panel.hide()
	game.savegame.apply(game, data)
	toast("Progresso retomado.")
