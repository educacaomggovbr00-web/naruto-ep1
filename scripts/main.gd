extends Node2D

# Playable fan adaptation starting at Naruto Classic Episode 1.
var player := Vector2(185, 270)
var stage := 7
var hits := 0
var chakra := 100.0
var cooldown := 0.0
var facing := Vector2.RIGHT
var target := Vector2(390, 270)
var mizuki := Vector2(660, 270)
var trail_progress := 0.0
var attack_flash := 0.0
var lines: Array[String] = []
var line_index := 0
var movement := Vector2.ZERO
var held := {}
var hud: Label
var objective: Label
var dialogue: Button
var restart: Button
var progress_button: Button
var progress_panel: Panel
var map_button: Button
var map_panel: Panel
var map_title: Label
var progress_text: RichTextLabel
var techniques_button: Button
var techniques_panel: Panel
var visual_clock := 0.0
var sprinting := false
var effect_kind := "kunai"
var effect_origin := Vector2.ZERO
var effect_direction := Vector2.RIGHT
var sharingan_awakened := false
var naruto_pos := Vector2(620, 265)
var naruto_action := "idle"
var naruto_battle_flash := 0.0
var action_state := ""
var action_timer := 0.0
var clone_flash := 0.0
var substitution_flash := 0.0
var art = preload("res://scripts/visuals.gd").new()
var background = preload("res://scripts/background.gd").new()
var naruto_world = preload("res://scripts/naruto_world.gd").new()
var rpg = preload("res://scripts/rpg_systems.gd").new()
var external_sprites
var story_era := 1
var mizuki_hits := 0
var episode_1_started := true
var episode_2_started := false
var current_episode := 1
var konohamaru_pos := Vector2(690, 275)
var ebisu_pos := Vector2(790, 260)
var ep2_dodge_done := false
var ep2_punch_done := false
var episode_3_started := false
var sasuke_pos := Vector2(610, 255)
var sakura_pos := Vector2(520, 290)
var kakashi_pos := Vector2(785, 250)
var ep3_shuriken_hits := 0
var ep3_substitution_done := false
var ep3_sasuke_resolved := false
var current_location_id := "academy"
const OBJECTIVES := [
	"TREINO • Acerte 3 vezes o alvo com kunai (J / botão KUNAI).",
	"CHAKRA • Use Katon perto do alvo (K / botão KATON).",
	"KONOHA • Encontre Naruto na praça e converse (E / AÇÃO).",
	"NOITE • Siga Mizuki a 70–230 passos. Segure FURTIVO para não ser visto.",
	"VOLTA • Investigue a kunai caída (E / AÇÃO).",
	"CASA • Volte para casa, à esquerda, e descanse (E / AÇÃO).",
	"TRANSIÇÃO • O alarme do Pergaminho dos Selos inicia o Episódio 1.",
	"EP 1 • Vá até a Academia e converse com Naruto e Iruka.",
	"ALARME • O Pergaminho dos Selos foi roubado. Vá à saída leste da vila.",
	"FLORESTA • Encontre Naruto e descubra o que aconteceu.",
	"CONFRONTO • Ajude Iruka: acerte Mizuki 3 vezes com kunai.",
	"DESFECHO • Fale com Naruto e Iruka.",
	"EP 1 CONCLUÍDO • Naruto dá seu primeiro passo como ninja.",
	"EP 2 • Encontre Naruto perto do Gabinete do Hokage.",
	"KONOHAMARU • Fale com o garoto que começou a seguir Naruto.",
	"TREINO • Mostre uma ESQUIVA e um SOCO perto de Konohamaru.",
	"EBISU • Fale com Ebisu depois do pequeno treino.",
	"EP 2 CONCLUÍDO • Konohamaru decide que vai treinar para ser reconhecido.",
	"EP 3 • Volte à Academia para a formação dos times.",
	"TIME 7 • Fale com Sasuke. Você decide se provoca ou só observa.",
	"AVALIAÇÃO • Acerte 3 shuriken no alvo. Só acerto conta como progresso.",
	"KAWARIMI • Execute Substituição perto do alvo para concluir sua avaliação.",
	"KAKASHI • Fale com o jōnin que chegou para buscar o Time 7.",
	"EP 3 CONCLUÍDO • Henrique conquista seu avanço por ações comprovadas."
]

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	external_sprites = preload("res://scripts/external_sprite_loader.gd").new()
	add_child(external_sprites)
	add_child(background)
	background.z_index = -1
	background.set_area(stage)
	background.set_location(naruto_world.location(current_location_id))
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(74, 10)
	hud.add_theme_font_size_override("font_size", 20)
	layer.add_child(hud)
	objective = Label.new()
	objective.position = Vector2(74, 40)
	objective.add_theme_font_size_override("font_size", 15)
	objective.size = Vector2(870, 34)
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layer.add_child(objective)
	dialogue = Button.new()
	dialogue.position = Vector2(120, 325)
	dialogue.size = Vector2(720, 100)
	dialogue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue.pressed.connect(next_line)
	style_button(dialogue, true)
	layer.add_child(dialogue)
	for item in [["←", Vector2(18, 460), "left"], ["→", Vector2(150, 460), "right"], ["↑", Vector2(84, 394), "up"], ["↓", Vector2(84, 460), "down"], ["FURTIVO", Vector2(244, 460), "sneak"], ["CORRER", Vector2(365, 460), "run"]]:
		var button := Button.new()
		button.text = item[0]
		button.position = item[1]
		button.size = Vector2(110 if item[2] == "sneak" else 95 if item[2] == "run" else 64, 64)
		var action: String = item[2]
		button.button_down.connect(func(): held[action] = true)
		button.button_up.connect(func(): held[action] = false)
		style_button(button)
		layer.add_child(button)
	for item in [["KUNAI", 610, "kunai"], ["KATON", 720, "katon"], ["AÇÃO", 830, "interact"]]:
		var button := Button.new()
		button.text = item[0]
		button.position = Vector2(item[1], 460)
		button.size = Vector2(105, 64)
		var action: String = item[2]
		button.pressed.connect(func(): act(action))
		style_button(button)
		layer.add_child(button)
	techniques_button = Button.new()
	techniques_button.text = "TÉCNICAS"
	techniques_button.position = Vector2(8, 88)
	techniques_button.size = Vector2(112, 42)
	techniques_button.pressed.connect(toggle_techniques)
	style_button(techniques_button)
	layer.add_child(techniques_button)

	techniques_panel = Panel.new()
	techniques_panel.position = Vector2(8, 136)
	techniques_panel.size = Vector2(190, 298)
	techniques_panel.visible = false
	var tech_style := StyleBoxFlat.new()
	tech_style.bg_color = Color("10232d")
	tech_style.border_color = Color("6d8788")
	tech_style.set_border_width_all(2)
	tech_style.set_corner_radius_all(6)
	techniques_panel.add_theme_stylebox_override("panel", tech_style)
	layer.add_child(techniques_panel)
	var tech_items := [
		["SOCO", "punch"], ["SHURIKEN", "shuriken"], ["ESQUIVA", "dodge"],
		["AGACHAR", "crouch"], ["PULAR", "jump"], ["DESLIZAR", "slide"],
		["CLONE", "clone"], ["SUBST.", "substitution"]
	]
	for i in range(tech_items.size()):
		var tech := Button.new()
		tech.text = tech_items[i][0]
		tech.position = Vector2(10 + (i % 2) * 86, 10 + int(i / 2) * 58)
		tech.size = Vector2(80, 48)
		var tech_action: String = tech_items[i][1]
		tech.pressed.connect(func(): use_technique(tech_action))
		style_button(tech)
		techniques_panel.add_child(tech)

	map_button = Button.new()
	map_button.text = "MAPA"
	map_button.position = Vector2(840, 88)
	map_button.size = Vector2(105, 42)
	map_button.pressed.connect(toggle_konoha_map)
	style_button(map_button)
	layer.add_child(map_button)

	map_panel = Panel.new()
	map_panel.position = Vector2(60, 74)
	map_panel.size = Vector2(840, 362)
	map_panel.visible = false
	var map_style := StyleBoxFlat.new()
	map_style.bg_color = Color("10232d")
	map_style.border_color = Color("6d8788")
	map_style.set_border_width_all(3)
	map_style.set_corner_radius_all(8)
	map_panel.add_theme_stylebox_override("panel", map_style)
	layer.add_child(map_panel)

	map_title = Label.new()
	map_title.position = Vector2(18, 10)
	map_title.size = Vector2(790, 28)
	map_title.add_theme_font_size_override("font_size", 18)
	map_title.add_theme_color_override("font_color", Color("f3dfb4"))
	map_panel.add_child(map_title)

	for info in naruto_world.all_konoha_locations():
		var place_button := Button.new()
		place_button.text = String(info["short"])
		place_button.position = Vector2(18 + int(info["x"]) * 160, 44 + int(info["y"]) * 49)
		place_button.size = Vector2(150, 42)
		place_button.add_theme_font_size_override("font_size", 11)
		var place_id: String = String(info["id"])
		place_button.pressed.connect(func(): travel_to_location(place_id))
		style_button(place_button)
		map_panel.add_child(place_button)

	progress_button = Button.new()
	progress_button.text = "PROGRESSO"
	progress_button.position = Vector2(475, 460)
	progress_button.size = Vector2(125, 64)
	progress_button.pressed.connect(toggle_progression)
	style_button(progress_button)
	layer.add_child(progress_button)

	progress_panel = Panel.new()
	progress_panel.position = Vector2(120, 72)
	progress_panel.size = Vector2(720, 372)
	progress_panel.visible = false
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("10232d")
	panel_style.border_color = Color("b29a6c")
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(8)
	progress_panel.add_theme_stylebox_override("panel", panel_style)
	layer.add_child(progress_panel)

	var title := Label.new()
	title.text = "PROGRESSÃO • HENRIQUE UCHIHA"
	title.position = Vector2(24, 18)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("f3dfb4"))
	progress_panel.add_child(title)

	progress_text = RichTextLabel.new()
	progress_text.bbcode_enabled = true
	progress_text.fit_content = false
	progress_text.position = Vector2(24, 58)
	progress_text.size = Vector2(672, 254)
	progress_text.add_theme_font_size_override("normal_font_size", 16)
	progress_text.add_theme_color_override("default_color", Color("dbe4e6"))
	progress_panel.add_child(progress_text)

	var close_progress := Button.new()
	close_progress.text = "FECHAR"
	close_progress.position = Vector2(560, 318)
	close_progress.size = Vector2(136, 42)
	close_progress.pressed.connect(toggle_progression)
	style_button(close_progress)
	progress_panel.add_child(close_progress)
	restart = Button.new()
	restart.text = "Jogar novamente"
	restart.position = Vector2(375, 240)
	restart.size = Vector2(210, 50)
	restart.visible = false
	restart.pressed.connect(func(): get_tree().reload_current_scene())
	style_button(restart)
	layer.add_child(restart)
	say(["NARUTO CLÁSSICO • EP 1", "Henrique Uchiha, 12 anos. Manhã em Konoha, no dia da prova de graduação da Academia.", "Naruto ainda é um aluno da Academia e acaba de falhar na prova. Sasuke e Sakura também estão por perto.", "Explore a praça em visão de cima, fale com Naruto e acompanhe os acontecimentos do começo da série."])

func say(texts: Array[String]) -> void:
	lines = texts
	line_index = 0
	dialogue.text = lines[0] + "\n[Toque para continuar]"
	dialogue.show()

func next_line() -> void:
	line_index += 1
	if line_index >= lines.size():
		lines.clear()
		dialogue.hide()
		if stage == 6:
			begin_episode_1()
		elif stage == 12:
			begin_episode_2()
		elif stage == 17:
			begin_episode_3()
		elif stage == 23:
			restart.show()
	else:
		dialogue.text = lines[line_index] + "\n[Toque para continuar]"

func begin_episode_1() -> void:
	episode_1_started = true
	story_era = 1
	stage = 7
	current_location_id = "academy"
	background.set_location(naruto_world.location(current_location_id))
	player = Vector2(185, 270)
	naruto_pos = Vector2(620, 265)
	naruto_action = "idle"
	restart.hide()
	say(["NARUTO EP 1 — O COMEÇO DE NARUTO", "Na manhã seguinte, Konoha volta à rotina. A Academia realiza a prova de graduação.", "Henrique ainda pensa em Mizuki e na figura de laranja vista durante o alarme.", "Objetivo: vá até a Academia e descubra o que aconteceu com Naruto."])

func begin_episode_2() -> void:
	episode_2_started = true
	current_episode = 2
	stage = 13
	current_location_id = "hokage_residence"
	background.set_location(naruto_world.location(current_location_id))
	player = Vector2(210, 280)
	naruto_pos = Vector2(610, 270)
	konohamaru_pos = Vector2(700, 280)
	ebisu_pos = Vector2(815, 260)
	ep2_dodge_done = false
	ep2_punch_done = false
	restart.hide()
	say(["NARUTO CLÁSSICO • EP 2 — KONOHAMARU", "Depois de finalmente se formar, Naruto vai cuidar do registro ninja e cruza com Konohamaru, neto do Terceiro Hokage.", "Konohamaru percebe que Naruto não o trata como alguém especial só por causa da família e começa a segui-lo.", "Henrique encontra os dois na praça e resolve ver no que isso vai dar."])

func begin_episode_3() -> void:
	episode_3_started = true
	current_episode = 3
	stage = 18
	current_location_id = "academy"
	background.set_location(naruto_world.location(current_location_id))
	player = Vector2(180, 285)
	naruto_pos = Vector2(425, 270)
	sasuke_pos = Vector2(600, 250)
	sakura_pos = Vector2(520, 305)
	kakashi_pos = Vector2(790, 250)
	target = Vector2(760, 315)
	ep3_shuriken_hits = 0
	ep3_substitution_done = false
	ep3_sasuke_resolved = false
	restart.hide()
	say(["NARUTO CLÁSSICO • EP 3 — SASUKE E SAKURA", "Os recém-formados voltam à Academia para descobrir suas equipes. Naruto acaba no Time 7 ao lado de Sakura e Sasuke.", "Henrique não recebe promoção de graça: Iruka mantém sua avaliação aberta. Se ele quiser avançar, vai precisar provar precisão e controle na prática.", "Henrique: Melhor assim. Um título que vem sem teste não vale muita coisa."])

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_P: toggle_progression()
			KEY_E, KEY_SPACE:
				if not progress_panel.visible: act("interact")
			KEY_J:
				if not progress_panel.visible: act("kunai")
			KEY_K:
				if not progress_panel.visible: act("katon")
			KEY_Z:
				if not progress_panel.visible: act("punch")
			KEY_X:
				if not progress_panel.visible: act("shuriken")
			KEY_Q:
				if not progress_panel.visible: act("dodge")
			KEY_C:
				if not progress_panel.visible: act("crouch")
			KEY_V:
				if not progress_panel.visible: act("clone")
			KEY_B:
				if not progress_panel.visible: act("substitution")

func down(action: String, key: Key, alternate: Key = KEY_NONE) -> bool:
	return held.get(action, false) or Input.is_physical_key_pressed(key) or (alternate != KEY_NONE and Input.is_physical_key_pressed(alternate))

func _process(delta: float) -> void:
	visual_clock += delta
	background.set_area(stage)
	background.set_location(naruto_world.location(current_location_id))
	cooldown = maxf(0.0, cooldown - delta)
	attack_flash = maxf(0.0, attack_flash - delta)
	naruto_battle_flash = maxf(0.0, naruto_battle_flash - delta)
	action_timer = maxf(0.0, action_timer - delta)
	clone_flash = maxf(0.0, clone_flash - delta)
	substitution_flash = maxf(0.0, substitution_flash - delta)
	if action_timer <= 0.0:
		action_state = ""
	chakra = minf(100.0, chakra + delta * 5.0)
	if stage == 2:
		naruto_pos = Vector2(640 + sin(visual_clock * 0.85) * 34, 260 + sin(visual_clock * 0.42) * 5)
		naruto_action = "walk" if absf(cos(visual_clock * 0.85)) > 0.18 else "idle"
	elif stage == 7:
		naruto_pos = Vector2(620 + sin(visual_clock * 0.7) * 18, 265)
		naruto_action = "walk" if absf(cos(visual_clock * 0.7)) > 0.25 else "idle"
	elif stage == 9:
		naruto_action = "crouch"
	elif stage == 10:
		naruto_action = "run" if lines.is_empty() else "idle"
	elif stage >= 11:
		naruto_action = "idle"
	if lines.is_empty() and stage < 23 and not progress_panel.visible and not map_panel.visible and action_timer <= 0.0:
		movement = Vector2(float(down("right", KEY_D, KEY_RIGHT)) - float(down("left", KEY_A, KEY_LEFT)), float(down("down", KEY_S, KEY_DOWN)) - float(down("up", KEY_W, KEY_UP))).normalized()
		if movement != Vector2.ZERO:
			facing = movement
		var sneaking := down("sneak", KEY_SHIFT)
		sprinting = down("run", KEY_R) and not sneaking
		var previous_position := player
		player += movement * (95.0 if sneaking else 240.0 if sprinting else 180.0) * delta
		if can_roam_konoha():
			if player.x < 26.0 and movement.x < 0.0:
				change_to_neighbor("west", Vector2(910, player.y))
			elif player.x > 934.0 and movement.x > 0.0:
				change_to_neighbor("east", Vector2(50, player.y))
			elif player.y < 104.0 and movement.y < 0.0:
				change_to_neighbor("north", Vector2(player.x, 360))
			elif player.y > 382.0 and movement.y > 0.0:
				change_to_neighbor("south", Vector2(player.x, 120))
		if stage == 2 or stage == 5 or stage == 7 or stage == 8 or (stage >= 13 and stage <= 16) or (stage >= 18 and stage <= 23):
			for house_rect in [Rect2(36, 91, 152, 130), Rect2(268, 85, 152, 130), Rect2(460, 91, 152, 130), Rect2(714, 82, 152, 130)]:
				if house_rect.grow(8).has_point(player):
					player = previous_position
		player = player.clamp(Vector2(35, 110), Vector2(925, 375))
		if stage == 8 and current_location_id == "village_gate" and player.distance_to(Vector2(885, 275)) < 55:
			stage = 9
			current_location_id = "village_gate"
			background.set_location(naruto_world.location(current_location_id))
			player = Vector2(170, 275)
			naruto_pos = Vector2(520, 275)
			mizuki = Vector2(760, 255)
			say(["Henrique atravessa a trilha e chega a uma clareira.", "Naruto está ali com o Pergaminho dos Selos, exausto depois de treinar uma técnica proibida.", "Henrique: Então foi você... Mas por quê?", "Naruto: Mizuki-sensei disse que, se eu aprendesse uma técnica do pergaminho, eu poderia me formar."])
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
				mizuki.y = 260 + sin(trail_progress * 0.5) * 65
				if trail_progress >= 12:
					rpg.complete_mission("shadow_mizuki", 50, 30)
					stage = 4
					target = mizuki
					say(["Henrique: Ele sumiu entre as árvores...", "Há uma kunai no chão. Será que ele deixou cair?"])
	var eye_status := "SHARINGAN 1T" if sharingan_awakened else "OLHOS NORMAIS"
	hud.text = "HENRIQUE • NV %d • %d RYO     | CHAKRA %d | %s" % [rpg.level, rpg.ryo, int(chakra), eye_status]
	objective.text = OBJECTIVES[stage] + "   •   " + naruto_world.location_name(current_location_id)
	if stage == 3:
		objective.text += "  %d%%" % int(trail_progress / 12 * 100)
	elif stage == 10:
		objective.text += "  %d / 3" % mizuki_hits
	queue_redraw()

func act(action: String) -> void:
	if progress_panel.visible or map_panel.visible:
		return
	if not lines.is_empty():
		if action == "interact": next_line()
		return
	if stage == 23: return
	if action == "punch" and cooldown <= 0:
		cooldown = 0.35
		start_action("punch_combo", 0.48)
		if stage == 19 and current_location_id == "academy" and player.distance_to(sasuke_pos) < 145:
			rpg.register_personality_choice("initiative")
			rpg.register_success("punch")
			ep3_sasuke_resolved = true
			stage = 20
			target = Vector2(760, 315)
			if int(rpg.inventory.get("shuriken", 0)) < 3:
				rpg.inventory["shuriken"] = 3
			say(["Henrique dá um golpe de teste; Sasuke recua antes do impacto completo.", "Sasuke: Era isso?", "Henrique: Era pra ver se você estava acordado.", "Iruka corta a provocação antes que vire luta.", "Iruka: Se vocês querem provar alguma coisa, façam isso numa avaliação. Henrique: três shuriken no alvo. Só acerto vale."])
			return
		if stage == 15 and current_location_id == "central_plaza" and player.distance_to(konohamaru_pos) < 150:
			ep2_punch_done = true
			rpg.register_success("punch")
			check_ep2_training()
		return
	if action == "shuriken" and cooldown <= 0 and (stage == 20 or rpg.consume_item("shuriken")):
		cooldown = 0.45
		attack_flash = 0.28
		effect_kind = "shuriken"
		effect_origin = player
		effect_direction = facing
		start_action("shuriken_throw", 0.45)
		if stage == 20 and current_location_id == "academy" and player.distance_to(target) < 180 and facing.dot((target - player).normalized()) > 0.35:
			ep3_shuriken_hits += 1
			rpg.register_success("shuriken")
			if ep3_shuriken_hits >= 3:
				rpg.award_milestone("ep3_shuriken_accuracy", 25)
				stage = 21
				say(["O terceiro shuriken acerta o centro do alvo.", "Iruka: Três acertos válidos. Isso eu posso registrar.", "Henrique: Finalmente um número que significa alguma coisa.", "Próximo teste: execute Substituição perto do alvo."])
		return
	if action == "dodge" and cooldown <= 0:
		cooldown = 0.45
		start_action("dodge_roll", 0.45)
		player = (player + facing * 58.0).clamp(Vector2(35, 110), Vector2(925, 375))
		if stage == 15 and current_location_id == "central_plaza" and player.distance_to(konohamaru_pos) < 180:
			ep2_dodge_done = true
			rpg.register_success("dodge")
			check_ep2_training()
		return
	if action == "crouch" and cooldown <= 0:
		cooldown = 0.35
		start_action("crouch", 0.65)
		return
	if action == "jump" and cooldown <= 0:
		cooldown = 0.45
		start_action("jump", 0.60)
		return
	if action == "slide" and cooldown <= 0:
		cooldown = 0.50
		start_action("slide", 0.52)
		player = (player + facing * 72.0).clamp(Vector2(35, 110), Vector2(925, 375))
		return
	if action == "clone" and cooldown <= 0 and chakra >= 10:
		chakra -= 10
		cooldown = 0.8
		clone_flash = 0.8
		start_action("shadow_clone", 0.75)
		return
	if action == "substitution" and cooldown <= 0 and chakra >= 12:
		chakra -= 12
		cooldown = 0.8
		substitution_flash = 0.8
		start_action("substitution", 0.70)
		player = (player - facing * 45.0).clamp(Vector2(35, 110), Vector2(925, 375))
		if stage == 21 and current_location_id == "academy" and player.distance_to(target) < 190:
			ep3_substitution_done = true
			rpg.register_success("substitution")
			rpg.award_milestone("ep3_substitution_control", 30)
			stage = 22
			rpg.mission_rank = "Genin"
			say(["O tronco aparece no ponto onde Henrique estava um instante antes.", "Iruka confere a execução antes de anotar o resultado.", "Iruka: Precisão e controle aprovados. Agora sim: você avançou por mérito próprio.", "Henrique: Ótimo. Então essa bandana não é decoração.", "Nesse momento, um jōnin de cabelo prateado finalmente aparece para buscar Naruto, Sasuke e Sakura."])
		return
	if action == "kunai" and cooldown <= 0:
		cooldown = 0.4
		attack_flash = 0.2
		effect_kind = "kunai"
		effect_origin = player
		effect_direction = facing
		if stage == 0 and player.distance_to(target) < 150 and facing.dot((target - player).normalized()) > 0.35:
			hits += 1
			if hits >= 3:
				rpg.complete_mission("training_kunai", 30, 20)
				stage = 1
				say(["Henrique: Três acertos! Agora vou tentar o Katon."])
		elif stage == 10 and player.distance_to(mizuki) < 170 and facing.dot((mizuki - player).normalized()) > 0.2:
			mizuki_hits += 1
			rpg.register_success("kunai")
			if mizuki_hits >= 3:
				stage = 11
				naruto_battle_flash = 1.7
				naruto_pos = Vector2(535, 275)
				say(["Henrique força Mizuki a recuar e ganha alguns segundos para Iruka e Naruto.", "Mizuki tenta atacar novamente, mas Naruto finalmente entende quem estava tentando usá-lo.", "Naruto usa a técnica que aprendeu no pergaminho e a clareira se enche de clones das sombras.", "A luta termina com Mizuki derrotado. O golpe decisivo foi de Naruto."])
	elif action == "katon" and cooldown <= 0 and chakra >= 25:
		chakra -= 25
		cooldown = 1.0
		attack_flash = 0.5
		effect_kind = "katon"
		effect_origin = player
		effect_direction = facing
		if stage == 1 and player.distance_to(target) < 150:
			sharingan_awakened = true
			rpg.unlock_jutsu("sharingan")
			rpg.complete_mission("first_katon", 40, 25)
			stage = 2
			player = Vector2(170, 270)
			say(["Henrique: Katon!", "As chamas escapam por um instante. Seus olhos ficam vermelhos: Sharingan de um tomoe.", "Henrique: O que foi isso...? Melhor voltar para a vila."])
	elif action == "interact":
		if stage == 2 and player.distance_to(naruto_pos) < 95:
			stage = 3
			player = Vector2(450, 270)
			say(["Naruto: Ei! Por que você está sempre com essa cara séria?", "Henrique: E você, por que está sempre arrumando confusão?", "Iruka: Naruto! Volte para a Academia!", "Mais tarde, ao anoitecer...", "Henrique: Mizuki? O que um instrutor está fazendo perto da floresta a esta hora?"])
		elif stage == 4 and player.distance_to(target) < 85:
			stage = 5
			say(["Henrique: Uma kunai... Não consigo descobrir o que ele estava planejando.", "Está tarde. Vou para casa."])
		elif stage == 5 and player.distance_to(Vector2(110, 230)) < 95:
			stage = 6
			rpg.complete_mission("scroll_alarm", 80, 0)
			story_era = 1
			say(["Henrique adormece. No sonho: fogo, o símbolo Uchiha e uma silhueta com olhos vermelhos.", "Sinos de emergência rompem o silêncio da madrugada.", "Um ninja anuncia que o Pergaminho dos Selos desapareceu.", "Henrique corre até a janela. Uma figura de roupa laranja some na direção da floresta.", "Henrique: Naruto...?", "FIM DO EP -1 — a continuação começa agora."])
		elif stage == 7 and current_location_id == "academy" and player.distance_to(naruto_pos) < 105:
			stage = 8
			player = Vector2(185, 270)
			say(["Na Academia, Naruto falha novamente na prova de graduação ao não executar corretamente o Bunshin.", "Iruka não pode aprová-lo, embora saiba o quanto Naruto quer ser reconhecido.", "Mais tarde, Mizuki conversa com Naruto longe dos outros alunos.", "Henrique reconhece o mesmo comportamento estranho da noite anterior.", "Pouco depois, o alarme toca: Naruto levou o Pergaminho dos Selos. Henrique corre para a saída leste."])
		elif stage == 9 and player.distance_to(naruto_pos) < 105:
			stage = 10
			mizuki_hits = 0
			mizuki = Vector2(735, 265)
			player = Vector2(250, 285)
			say(["Iruka chega à clareira tentando proteger Naruto.", "Mizuki aparece e revela que enganou Naruto para conseguir acesso ao pergaminho.", "Naruto percebe que foi usado. Iruka se coloca entre ele e o ataque.", "Henrique: Eu sabia que tinha alguma coisa errada. Mizuki, acabou.", "Objetivo: use kunai para abrir espaço. Naruto ainda precisa enfrentar isso por conta própria."])
		elif stage == 11 and player.distance_to(naruto_pos) < 120:
			stage = 12
			rpg.complete_mission("academy_day", 60, 20)
			say(["Depois da luta, Iruka reconhece o esforço de Naruto e entrega a ele sua própria bandana da Folha.", "Naruto finalmente consegue o símbolo de que tanto precisava: agora pode começar seu caminho como ninja.", "Henrique observa em silêncio, ainda pensando no Sharingan recém-desperto e nas intenções de Mizuki.", "NARUTO EP 1 CONCLUÍDO — adaptação jogável de fã pelo ponto de vista de Henrique Uchiha.", "Próximo: EP 2 — Konohamaru e os primeiros passos de Naruto como ninja."])
		elif stage == 13 and current_location_id == "hokage_residence" and player.distance_to(naruto_pos) < 120:
			stage = 14
			current_location_id = "central_plaza"
			background.set_location(naruto_world.location(current_location_id))
			say(["Naruto termina seu registro e, no caminho de volta, tromba com Konohamaru.", "Konohamaru: Você não vai ficar me tratando diferente só porque eu sou neto do Hokage?", "Naruto: Por que eu faria isso?", "Konohamaru fica impressionado e começa a seguir Naruto pela vila.", "Henrique: Pronto. Agora ele arrumou um mini-Naruto."])
		elif stage == 14 and current_location_id == "central_plaza" and player.distance_to(konohamaru_pos) < 115:
			stage = 15
			say(["Konohamaru quer ser reconhecido pela vila e acha que virar Hokage rapidamente resolveria tudo.", "Naruto responde que título nenhum substitui treino e esforço.", "Konohamaru desafia os dois a mostrarem alguma coisa de verdade.", "Objetivo: perto de Konohamaru, use ESQUIVA e depois SOCO."])
		elif stage == 16 and current_location_id == "central_plaza" and player.distance_to(ebisu_pos) < 125:
			stage = 17
			rpg.complete_mission("konohamaru_first_meeting", 70, 30)
			say(["Ebisu chega procurando Konohamaru e encontra Naruto, Henrique e o garoto no meio do treino.", "Depois da discussão, Konohamaru percebe que ser reconhecido não é algo que se consegue apenas usando o nome do avô.", "Naruto segue seu caminho com uma nova sombra pequena correndo atrás dele.", "Henrique: Essa vila só fica mais estranha a cada dia.", "NARUTO EP 2 CONCLUÍDO — próximo passo: formação dos times e a apresentação do Time 7."])
		elif stage == 18 and current_location_id == "academy" and player.distance_to(Vector2(360, 265)) < 125:
			rpg.register_social_interaction()
			stage = 19
			say(["Iruka termina de anunciar as equipes. Naruto, Sakura e Sasuke formam o Time 7.", "Naruto olha para Sasuke como se a sala tivesse acabado de declarar guerra.", "Henrique: Três pessoas que não conseguem ficar cinco minutos em silêncio. Vai dar muito certo.", "Iruka: Henrique, sua avaliação ainda está aberta. Antes disso, fale com Sasuke e depois venha para o alvo."])
		elif stage == 19 and current_location_id == "academy" and player.distance_to(sasuke_pos) < 120:
			rpg.register_social_interaction()
			rpg.register_personality_choice("restraint")
			ep3_sasuke_resolved = true
			stage = 20
			target = Vector2(760, 315)
			if int(rpg.inventory.get("shuriken", 0)) < 3:
				rpg.inventory["shuriken"] = 3
			say(["Sasuke: Você ficou olhando desde que anunciaram os times.", "Henrique: Estou tentando descobrir qual de vocês três vai irritar o Kakashi primeiro.", "Sasuke: Hn.", "Henrique não compra briga. A rivalidade existe, mas ele prefere medir alguém pelo que faz, não pelo sobrenome.", "Iruka chama Henrique para a avaliação: três acertos de shuriken no alvo. Erro não conta."])
		elif stage == 22 and current_location_id == "academy" and player.distance_to(kakashi_pos) < 130:
			rpg.register_social_interaction()
			stage = 23
			rpg.complete_mission("episode3_real_evaluation", 80, 40)
			rpg.award_milestone("earned_genin_rank", 50)
			say(["Kakashi observa a ficha de Henrique antes de olhar para o Time 7.", "Kakashi: Então você passou na avaliação complementar.", "Henrique: Passei no que fizeram eu executar. O resto eu ainda não provei.", "Kakashi: Uma resposta menos comum do que parece.", "Naruto reclama da demora; Sakura manda Naruto parar; Sasuke continua com a mesma cara de sempre.", "Henrique: É. Definitivamente vão irritar o professor rápido.", "NARUTO EP 3 CONCLUÍDO — Henrique agora é Genin por testes concluídos no gameplay. Próximo: o teste de sobrevivência do Time 7."])

func start_action(name: String, duration: float) -> void:
	if not art.character_art.henrique_actions.has(name):
		return
	action_state = name
	action_timer = duration
	movement = Vector2.ZERO

func check_ep2_training() -> void:
	if stage == 15 and ep2_dodge_done and ep2_punch_done:
		stage = 16
		ebisu_pos = Vector2(800, 265)
		say(["Konohamaru tenta copiar os movimentos, tropeça e levanta rápido como se nada tivesse acontecido.", "Naruto ri, mas admite que o garoto tem coragem.", "Uma voz irritada interrompe o treino: Ebisu finalmente encontrou Konohamaru.", "Objetivo: fale com Ebisu."])

func can_roam_konoha() -> bool:
	return not (stage >= 9 and stage <= 12) and lines.is_empty()

func change_to_neighbor(direction: String, spawn: Vector2) -> void:
	var next_id := naruto_world.neighbor(current_location_id, direction)
	if next_id.is_empty():
		player = player.clamp(Vector2(35, 110), Vector2(925, 375))
		return
	current_location_id = next_id
	player = spawn.clamp(Vector2(35, 110), Vector2(925, 375))
	background.set_location(naruto_world.location(current_location_id))

func toggle_konoha_map() -> void:
	if progress_panel.visible:
		progress_panel.hide()
	if techniques_panel.visible:
		techniques_panel.hide()
	map_panel.visible = not map_panel.visible
	if map_panel.visible:
		held.clear()
		movement = Vector2.ZERO
		map_title.text = "KONOHA • %s  |  30 ÁREAS CONECTADAS" % naruto_world.location_name(current_location_id)

func travel_to_location(id: String) -> void:
	if stage >= 9 and stage <= 12:
		map_title.text = "Viagem bloqueada durante o incidente do Pergaminho dos Selos."
		return
	current_location_id = id
	player = Vector2(480, 300)
	background.set_location(naruto_world.location(current_location_id))
	map_panel.hide()

func toggle_techniques() -> void:
	if map_panel.visible:
		map_panel.hide()
	if progress_panel.visible:
		progress_panel.hide()
	techniques_panel.visible = not techniques_panel.visible

func use_technique(action: String) -> void:
	techniques_panel.hide()
	act(action)

func toggle_progression() -> void:
	if map_panel.visible:
		map_panel.hide()
	if techniques_panel.visible:
		techniques_panel.hide()
	progress_panel.visible = not progress_panel.visible
	if progress_panel.visible:
		held.clear()
		movement = Vector2.ZERO
		refresh_progression()

func refresh_progression() -> void:
	var chapter := "NARUTO CLÁSSICO • EP 1"
	var story_percent := int(clampf(float(stage - 7) / 5.0, 0.0, 1.0) * 100.0)
	if stage == 12:
		chapter = "NARUTO CLÁSSICO • EP 1 CONCLUÍDO"
	elif stage >= 13 and stage <= 17:
		chapter = "NARUTO CLÁSSICO • EP 2 — KONOHAMARU"
		story_percent = int(clampf(float(stage - 13) / 4.0, 0.0, 1.0) * 100.0)
	elif stage >= 18:
		chapter = "NARUTO CLÁSSICO • EP 3 — SASUKE E SAKURA"
		story_percent = int(clampf(float(stage - 18) / 5.0, 0.0, 1.0) * 100.0)
	if stage == 17:
		chapter = "NARUTO CLÁSSICO • EP 2 CONCLUÍDO"
	if stage >= 23:
		chapter = "NARUTO CLÁSSICO • EP 3 CONCLUÍDO"
	var sharingan_text := "Sharingan 1 Tomoe" if sharingan_awakened else "Ainda não despertado nesta linha do tempo"
	var jutsu_text := "Kunai • Shuriken • Katon: Bola de Fogo"
	if sharingan_awakened:
		jutsu_text += " • Sharingan 1T"
	var rank_text := rpg.mission_rank
	progress_text.text = "[b]ERA:[/b] %s\n[b]IDADE:[/b] 12 anos     [b]RANK REAL:[/b] %s\n[b]NÍVEL:[/b] %d     [b]XP GANHO:[/b] %d total     [b]RYO:[/b] %d     [b]CHAKRA:[/b] %d / 100\n[b]HISTÓRIA:[/b] %d%%     [b]MISSÕES REAIS:[/b] %d\n\n[b]PERSONALIDADE EM JOGO[/b]\n%s\nInterações: %d • Iniciativa: %d • Controle: %d\n\n[b]DOMÍNIO COMPROVADO[/b]\nKunai: %s (%d) • Shuriken: %s (%d)\nEsquiva: %s (%d) • Soco: %s (%d) • Substituição: %s (%d)\n\n[b]ARSENAL[/b]\n%s\n%s\nKunai x%d • Shuriken x%d\n\n[i]Nada sobe só porque a história disse. Acertos, testes e missões concluídas alimentam estes números.[/i]" % [
		chapter, rank_text, rpg.level, rpg.total_xp, rpg.ryo, int(chakra), story_percent, rpg.completed_missions.size(),
		rpg.personality_summary(), int(rpg.real_stats["social_interactions"]), int(rpg.real_stats["initiative_choices"]), int(rpg.real_stats["restraint_choices"]),
		rpg.mastery_label("kunai"), int(rpg.technique_mastery["kunai"]), rpg.mastery_label("shuriken"), int(rpg.technique_mastery["shuriken"]),
		rpg.mastery_label("dodge"), int(rpg.technique_mastery["dodge"]), rpg.mastery_label("punch"), int(rpg.technique_mastery["punch"]),
		rpg.mastery_label("substitution"), int(rpg.technique_mastery["substitution"]),
		jutsu_text, sharingan_text, int(rpg.inventory.get("kunai", 0)), int(rpg.inventory.get("shuriken", 0))
	]

func style_button(button: Button, is_dialogue: bool = false) -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 18 if is_dialogue else 15)
	button.add_theme_color_override("font_color", Color("f3dfb4"))
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("203b48") if state != "pressed" else Color("496066")
		style.border_color = Color("b29a6c") if is_dialogue else Color("6d8788")
		style.set_border_width_all(2)
		style.set_corner_radius_all(5)
		style.content_margin_left = 18 if is_dialogue else 6
		style.content_margin_right = 18 if is_dialogue else 6
		style.content_margin_top = 10
		style.content_margin_bottom = 10
		button.add_theme_stylebox_override(state, style)

func _draw() -> void:
	art.render(self)
