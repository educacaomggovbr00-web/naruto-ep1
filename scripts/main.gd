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
var progress_text: RichTextLabel
var visual_clock := 0.0
var sprinting := false
var effect_kind := "kunai"
var effect_origin := Vector2.ZERO
var effect_direction := Vector2.RIGHT
var sharingan_awakened := false
var naruto_pos := Vector2(620, 265)
var naruto_action := "idle"
var naruto_battle_flash := 0.0
var art = preload("res://scripts/visuals.gd").new()
var background = preload("res://scripts/background.gd").new()
var naruto_world = preload("res://scripts/naruto_world.gd").new()
var rpg = preload("res://scripts/rpg_systems.gd").new()
var story_era := 1
var mizuki_hits := 0
var episode_1_started := true
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
	"EP 1 CONCLUÍDO • Naruto dá seu primeiro passo como ninja."
]

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(background)
	background.z_index = -1
	background.set_area(stage)
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
			restart.show()
	else:
		dialogue.text = lines[line_index] + "\n[Toque para continuar]"

func begin_episode_1() -> void:
	episode_1_started = true
	story_era = 1
	stage = 7
	player = Vector2(185, 270)
	naruto_pos = Vector2(620, 265)
	naruto_action = "idle"
	restart.hide()
	say(["NARUTO EP 1 — O COMEÇO DE NARUTO", "Na manhã seguinte, Konoha volta à rotina. A Academia realiza a prova de graduação.", "Henrique ainda pensa em Mizuki e na figura de laranja vista durante o alarme.", "Objetivo: vá até a Academia e descubra o que aconteceu com Naruto."])

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

func down(action: String, key: Key, alternate: Key = KEY_NONE) -> bool:
	return held.get(action, false) or Input.is_physical_key_pressed(key) or (alternate != KEY_NONE and Input.is_physical_key_pressed(alternate))

func _process(delta: float) -> void:
	visual_clock += delta
	background.set_area(stage)
	cooldown = maxf(0.0, cooldown - delta)
	attack_flash = maxf(0.0, attack_flash - delta)
	naruto_battle_flash = maxf(0.0, naruto_battle_flash - delta)
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
	if lines.is_empty() and stage < 12 and not progress_panel.visible:
		movement = Vector2(float(down("right", KEY_D, KEY_RIGHT)) - float(down("left", KEY_A, KEY_LEFT)), float(down("down", KEY_S, KEY_DOWN)) - float(down("up", KEY_W, KEY_UP))).normalized()
		if movement != Vector2.ZERO:
			facing = movement
		var sneaking := down("sneak", KEY_SHIFT)
		sprinting = down("run", KEY_R) and not sneaking
		var previous_position := player
		player += movement * (95.0 if sneaking else 240.0 if sprinting else 180.0) * delta
		if stage == 2 or stage == 5 or stage == 7 or stage == 8:
			for house_rect in [Rect2(36, 91, 152, 130), Rect2(268, 85, 152, 130), Rect2(460, 91, 152, 130), Rect2(714, 82, 152, 130)]:
				if house_rect.grow(8).has_point(player):
					player = previous_position
		player = player.clamp(Vector2(35, 110), Vector2(925, 375))
		if stage == 8 and player.distance_to(Vector2(885, 275)) < 55:
			stage = 9
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
	objective.text = OBJECTIVES[stage]
	if stage == 3:
		objective.text += "  %d%%" % int(trail_progress / 12 * 100)
	elif stage == 10:
		objective.text += "  %d / 3" % mizuki_hits
	queue_redraw()

func act(action: String) -> void:
	if progress_panel.visible:
		return
	if not lines.is_empty():
		if action == "interact": next_line()
		return
	if stage == 12: return
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
		elif stage == 7 and player.distance_to(naruto_pos) < 105:
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

func toggle_progression() -> void:
	progress_panel.visible = not progress_panel.visible
	if progress_panel.visible:
		held.clear()
		movement = Vector2.ZERO
		refresh_progression()

func refresh_progression() -> void:
	var chapter := "NARUTO CLÁSSICO • EP 1"
	if stage >= 12:
		chapter = "NARUTO CLÁSSICO • EP 1 CONCLUÍDO"
	var story_percent := int(clampf(float(stage - 7) / 5.0, 0.0, 1.0) * 100.0)
	var sharingan_text := "Sharingan 1 Tomoe" if sharingan_awakened else "Ainda não despertado nesta linha do tempo"
	var jutsu_text := "Kunai • Shuriken • Katon: Bola de Fogo"
	if sharingan_awakened:
		jutsu_text += " • Sharingan 1T"
	progress_text.text = "[b]ERA:[/b] %s\n[b]IDADE:[/b] 12 anos     [b]RANK:[/b] Aluno da Academia\n[b]NÍVEL:[/b] %d     [b]XP:[/b] %d / %d     [b]RYO:[/b] %d     [b]CHAKRA:[/b] %d / 100\n[b]HISTÓRIA:[/b] %d%%     [b]MISSÕES CONCLUÍDAS:[/b] %d\n\n[b]ARSENAL ATUAL[/b]\n%s\n%s\nKunai x%d • Shuriken x%d • Pílula do Soldado x%d\n\n[b]BLOQUEADO NESTA FASE[/b]\nChidori • Mangekyō • Amaterasu • Susanoo • técnicas avançadas\n[i]Essas habilidades ficam para fases futuras; o jogo ainda está no começo de Naruto Clássico.[/i]" % [
		chapter, rpg.level, rpg.xp, rpg.level * 100, rpg.ryo, int(chakra),
		story_percent, rpg.completed_missions.size(), jutsu_text, sharingan_text,
		int(rpg.inventory.get("kunai", 0)), int(rpg.inventory.get("shuriken", 0)), int(rpg.inventory.get("soldier_pill", 0))
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
