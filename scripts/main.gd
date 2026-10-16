extends Node2D

# Original playable fan-game prologue, before the events of episode 1.
var player := Vector2(140, 270)
var stage := 0
var hits := 0
var chakra := 100.0
var stamina := 100.0
var dash_time := 0.0
var dash_direction := Vector2.RIGHT
var save_clock := 0.0
var layout = preload("res://scripts/world_layout.gd").new()
var savegame = preload("res://scripts/save_game.gd").new()
var cooldown := 0.0
var facing := Vector2.RIGHT
var target := Vector2(390, 270)
var mizuki := Vector2(660, 270)
var trail_progress := 0.0
var attack_flash := 0.0
var lines: Array[String] = []
var line_index := 0
var pending_forest_transition := false
var movement := Vector2.ZERO
var held := {}
var hud: Label
var objective: Label
var dialogue: Button
var restart: Button
var cinematic: Node
var audio: Node
var ui: CanvasLayer
var visual_clock := 0.0
var sprinting := false
var effect_kind := "kunai"
var effect_origin := Vector2.ZERO
var effect_direction := Vector2.RIGHT
var art = preload("res://scripts/visuals.gd").new()
var polish = preload("res://scripts/polish.gd").new()
var background = preload("res://scripts/background.gd").new()
const OBJECTIVES := [
	"TREINO • Acerte 3 vezes o alvo com kunai (J / botão KUNAI).",
	"CHAKRA • Use Katon perto do alvo (K / botão KATON).",
	"KONOHA • Encontre Naruto na praça e converse (E / AÇÃO).",
	"NOITE • Siga Mizuki a 70–230 passos. Segure FURTIVO para não ser visto.",
	"VOLTA • Investigue a kunai caída (E / AÇÃO).",
	"CASA • Volte para casa, à esquerda, e descanse (E / AÇÃO).",
	"PRÓLOGO CONCLUÍDO • A história continua no episódio 1."
]

func _ready() -> void:
	# Cap CPU/GPU work on Android, including during the opening dialogue.
	if OS.get_name() == "Android" or art.character_art.compact_mode:
		Engine.max_fps = 30
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(background)
	background.z_index = -1
	background.set_area(stage)
	audio = preload("res://scripts/soundscape.gd").new()
	add_child(audio)
	cinematic = preload("res://scripts/cinematic.gd").new()
	cinematic.game = self
	add_child(cinematic)
	ui = preload("res://scripts/game_ui.gd").new()
	ui.game = self
	add_child(ui)
	say(["NARUTO EP -1 — A Noite Antes do Começo", "Henrique Uchiha, 12 anos. Um fim de tarde em Konoha, antes do início da história de Naruto.", "Henrique: Ainda tenho muito para aprender. Vou começar pelo treino de kunai.", "WASD/setas: andar. R: correr. Q: esquiva. J/K: kunai e Katon. E ou toque: revelar a fala e depois continuar."])
	ui.offer_resume(savegame.read_save())

func say(texts: Array[String]) -> void:
	ui.release_touches()
	movement = Vector2.ZERO
	sprinting = false
	dash_time = 0
	lines = texts
	line_index = 0
	ui.show_line(lines[0])

func next_line() -> void:
	if ui.finish_typing():
		return
	line_index += 1
	if pending_forest_transition and line_index >= 3:
		pending_forest_transition = false
		stage = 3
		player = Vector2(450, 270)
	if line_index >= lines.size():
		lines.clear()
		dialogue.hide()
	else:
		ui.show_line(lines[line_index])
	save_checkpoint(false)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_Q: act("dodge")
			KEY_ENTER:
				if ui.resume_overlay.visible: ui.continue_game()
			KEY_ESCAPE:
				if ui.settings_panel.visible: ui.toggle_settings()
			KEY_E, KEY_SPACE: act("interact")
			KEY_J: act("kunai")
			KEY_K: act("katon")

func down(action: String, key: Key, alternate: Key = KEY_NONE) -> bool:
	return held.get(action, false) or Input.is_physical_key_pressed(key) or (alternate != KEY_NONE and Input.is_physical_key_pressed(alternate))

func _process(delta: float) -> void:
	movement = Vector2.ZERO
	sprinting = false
	visual_clock += delta
	if ui.modal_open():
		queue_redraw()
		return
	stamina = minf(100, stamina + delta * 18)
	save_clock += delta
	if save_clock >= 8 and lines.is_empty():
		save_checkpoint(false)
	background.set_area(stage)
	cooldown = maxf(0.0, cooldown - delta)
	attack_flash = maxf(0.0, attack_flash - delta)
	chakra = minf(100.0, chakra + delta * 5.0)
	if lines.is_empty() and stage < 6 and not ui.settings_panel.visible:
		movement = Vector2(float(down("right", KEY_D, KEY_RIGHT)) - float(down("left", KEY_A, KEY_LEFT)), float(down("down", KEY_S, KEY_DOWN)) - float(down("up", KEY_W, KEY_UP))).normalized()
		if movement != Vector2.ZERO:
			facing = movement
		var sneaking := down("sneak", KEY_SHIFT)
		sprinting = down("run", KEY_R) and not sneaking
		var previous := player
		var speed := 95.0 if sneaking else 240.0 if sprinting else 180.0
		if dash_time > 0:
			movement = dash_direction
			sprinting = true
			speed = 440.0
			move_with_collisions(movement * speed * minf(delta, dash_time))
			dash_time = maxf(0, dash_time - delta)
		else:
			move_with_collisions(movement * speed * delta)
		if player.is_equal_approx(previous):
			movement = Vector2.ZERO
			sprinting = false
			dash_time = 0
		if stage == 3:
			var distance := player.distance_to(mizuki)
			if distance < 70 or (distance < 160 and not sneaking and movement != Vector2.ZERO):
				trail_progress = 0.0
				player = Vector2(450, 270)
				mizuki = Vector2(660, 270)
				say(["Mizuki: Quem está aí?", "Henrique: Preciso manter distância e andar em silêncio. Vou tentar de novo."])
			elif distance <= 230:
				trail_progress += delta
				mizuki.x = 660 + sin(trail_progress * 0.35) * 140
				mizuki.y = 280 + sin(trail_progress * 0.5) * 35
				if trail_progress >= 12:
					stage = 4
					target = mizuki
					say(["Henrique: Ele sumiu entre as árvores...", "Há uma kunai no chão. Será que ele deixou cair?"])
	hud.text = "HENRIQUE UCHIHA  /  12 ANOS"
	objective.text = OBJECTIVES[stage]
	if stage == 3:
		objective.text += "  %d%%" % int(trail_progress / 12 * 100)
	polish.update(self, delta)
	queue_redraw()

func act(action: String) -> void:
	if ui.modal_open():
		return
	if not lines.is_empty():
		if action == "interact": next_line()
		return
	if stage == 6: return
	if action == "dodge":
		if dash_time > 0: return
		if stamina < 30:
			ui.toast("Recupere o fôlego antes de esquivar.")
			return
		stamina -= 30
		dash_direction = facing
		dash_time = 0.16
		return
	if action in ["kunai", "katon"] and cooldown > 0:
		ui.toast("Aguarde a técnica ficar pronta.")
		return
	if action == "katon" and chakra < 25:
		ui.toast("Katon precisa de 25 de chakra.")
		return
	if action == "kunai" and cooldown <= 0:
		cooldown = 0.4
		audio.play("kunai")
		attack_flash = 0.2
		effect_kind = "kunai"
		effect_origin = player
		effect_direction = facing
		if stage == 0 and player.distance_to(target) < 150 and facing.dot((target - player).normalized()) > 0.35:
			audio.play("impact")
			cinematic.kick(0.55)
			hits += 1
			ui.toast("Acerto %d / 3" % hits)
			if hits >= 3:
				stage = 1
				say(["Henrique: Três acertos! Agora vou tentar o Katon."])
		elif stage == 0:
			ui.toast("Aproxime-se do alvo." if player.distance_to(target) >= 150 else "Vire-se para o alvo antes de lançar.")
	elif action == "katon" and cooldown <= 0 and chakra >= 25:
		audio.play("katon")
		cinematic.kick(0.85)
		chakra -= 25
		cooldown = 1.0
		attack_flash = 0.5
		effect_kind = "katon"
		effect_origin = player
		effect_direction = facing
		if stage == 1 and player.distance_to(target) < 150:
			stage = 2
			player = Vector2(170, 270)
			say(["Henrique: Katon!", "As chamas escapam por um instante. Seus olhos ficam vermelhos: Sharingan de um tomoe.", "Henrique: O que foi isso...? Melhor voltar para a vila."])
	elif action == "interact":
		if stage == 2 and player.distance_to(layout.NARUTO) < 95:
			pending_forest_transition = true
			say(["Naruto: Ei! Por que você está sempre com essa cara séria?", "Henrique: E você, por que está sempre arrumando confusão?", "Iruka: Naruto! Volte para a Academia!", "Mais tarde, ao anoitecer...", "Henrique: Mizuki? O que um instrutor está fazendo perto da floresta a esta hora?"])
		elif stage == 2:
			var nearest := ""
			var distance := 60.0
			for person in layout.VILLAGE_CAST:
				var candidate: float = player.distance_to(layout.VILLAGE_CAST[person])
				if candidate < distance:
					distance = candidate
					nearest = person
			var greetings := {"Sasuke": "Sasuke: Estou indo treinar. Até mais.",
				"Sakura": "Sakura: Você já terminou seu treino de hoje, Henrique?",
				"Hiruzen": "Hiruzen: Aproveite o tempo na Academia para aprender com seus colegas.",
				"Teuchi": "Teuchi: Depois do treino, passe no Ichiraku. Um lámen quente cai bem!"}
			if greetings.has(nearest):
				var greeting_lines: Array[String] = [greetings[nearest]]
				say(greeting_lines)
		elif stage == 4 and player.distance_to(target) < 85:
			stage = 5
			say(["Henrique: Uma kunai... Não consigo descobrir o que ele estava planejando.", "Está tarde. Vou para casa."])
		elif stage == 5 and player.distance_to(layout.HOME) < 58:
			stage = 6
			say(["Henrique adormece. No sonho: fogo, o símbolo Uchiha e uma silhueta com olhos vermelhos.", "Sinos de emergência rompem o silêncio da madrugada.", "Ninja no telhado: O Pergaminho dos Selos foi roubado!", "Henrique corre até a janela. Uma figura de roupa laranja desaparece em direção à floresta.", "Henrique: Naruto...?", "FIM DO EP -1 — A Noite Antes do Começo. Prólogo original de fã. O episódio 1 ainda não está implementado."])
			restart.show()

func style_button(button: Button, is_dialogue: bool = false) -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 18 if is_dialogue else 15)
	button.add_theme_color_override("font_color", Color("f3dfb4"))
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("203b48") if state == "normal" else Color("3f5b62") if state == "hover" else Color("786344")
		style.border_color = Color("b29a6c") if is_dialogue else Color("6d8788")
		style.set_border_width_all(2)
		style.set_corner_radius_all(9)
		style.shadow_color = Color(0, 0, 0, 0.3)
		style.shadow_size = 3
		style.shadow_offset = Vector2(0, 3)
		style.content_margin_left = 18 if is_dialogue else 6
		style.content_margin_right = 18 if is_dialogue else 6
		style.content_margin_top = 10
		style.content_margin_bottom = 10
		button.add_theme_stylebox_override(state, style)

func _draw() -> void:
	if is_instance_valid(ui) and ui.resume_overlay.visible: return
	art.render(self)

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_CLOSE_REQUEST]:
		if is_instance_valid(ui):
			ui.release_touches()
			if not ui.resume_overlay.visible: save_checkpoint(false)
		held.clear()
		movement = Vector2.ZERO
		sprinting = false

func blocked(at: Vector2) -> bool:
	return layout.blocked(at, stage)

func move_with_collisions(displacement: Vector2) -> void:
	var steps := maxi(1, int(ceil(displacement.length() / 6.0)))
	var step := displacement / steps
	for i in range(steps):
		var next := layout.clamp_position(player + Vector2(step.x, 0), stage)
		if not blocked(next): player = next
		next = layout.clamp_position(player + Vector2(0, step.y), stage)
		if not blocked(next): player = next

func save_checkpoint(notify: bool = true) -> bool:
	save_clock = 0
	var success: bool = savegame.write_save(self)
	if notify: ui.toast("Progresso salvo." if success else "Não foi possível salvar o progresso.")
	return success

func restart_game() -> void:
	if savegame.enabled and FileAccess.file_exists(savegame.path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(savegame.path))
	get_tree().reload_current_scene()
