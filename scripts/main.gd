extends Node2D

# Original playable fan-game prologue, before the events of episode 1.
var player := Vector2(140, 270)
var stage := 0
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
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(18, 12)
	hud.add_theme_font_size_override("font_size", 20)
	layer.add_child(hud)
	objective = Label.new()
	objective.position = Vector2(18, 43)
	objective.add_theme_font_size_override("font_size", 16)
	layer.add_child(objective)
	dialogue = Button.new()
	dialogue.position = Vector2(120, 325)
	dialogue.size = Vector2(720, 100)
	dialogue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue.pressed.connect(next_line)
	layer.add_child(dialogue)
	for item in [["←", Vector2(18, 460), "left"], ["→", Vector2(150, 460), "right"], ["↑", Vector2(84, 394), "up"], ["↓", Vector2(84, 460), "down"], ["FURTIVO", Vector2(244, 460), "sneak"]]:
		var button := Button.new()
		button.text = item[0]
		button.position = item[1]
		button.size = Vector2(64 if item[2] != "sneak" else 110, 64)
		var action: String = item[2]
		button.button_down.connect(func(): held[action] = true)
		button.button_up.connect(func(): held[action] = false)
		layer.add_child(button)
	for item in [["KUNAI", 610, "kunai"], ["KATON", 720, "katon"], ["AÇÃO", 830, "interact"]]:
		var button := Button.new()
		button.text = item[0]
		button.position = Vector2(item[1], 460)
		button.size = Vector2(105, 64)
		var action: String = item[2]
		button.pressed.connect(func(): act(action))
		layer.add_child(button)
	restart = Button.new()
	restart.text = "Jogar novamente"
	restart.position = Vector2(375, 240)
	restart.size = Vector2(210, 50)
	restart.visible = false
	restart.pressed.connect(func(): get_tree().reload_current_scene())
	layer.add_child(restart)
	say(["NARUTO EP -1 — A Noite Antes do Começo", "Henrique Uchiha, 12 anos. Um fim de tarde em Konoha, antes do início da história de Naruto.", "Henrique: Ainda tenho muito para aprender. Vou começar pelo treino de kunai.", "Mova-se com WASD/setas ou os botões. Clique no diálogo ou pressione E para avançar."])

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
	else:
		dialogue.text = lines[line_index] + "\n[Toque para continuar]"

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_E, KEY_SPACE: act("interact")
			KEY_J: act("kunai")
			KEY_K: act("katon")

func down(action: String, key: Key, alternate: Key = KEY_NONE) -> bool:
	return held.get(action, false) or Input.is_physical_key_pressed(key) or (alternate != KEY_NONE and Input.is_physical_key_pressed(alternate))

func _process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	attack_flash = maxf(0.0, attack_flash - delta)
	chakra = minf(100.0, chakra + delta * 5.0)
	if lines.is_empty() and stage < 6:
		movement = Vector2(float(down("right", KEY_D, KEY_RIGHT)) - float(down("left", KEY_A, KEY_LEFT)), float(down("down", KEY_S, KEY_DOWN)) - float(down("up", KEY_W, KEY_UP))).normalized()
		if movement != Vector2.ZERO:
			facing = movement
		var sneaking := down("sneak", KEY_SHIFT)
		player += movement * (95.0 if sneaking else 180.0) * delta
		player = player.clamp(Vector2(35, 110), Vector2(925, 375))
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
					stage = 4
					target = mizuki
					say(["Henrique: Ele sumiu entre as árvores...", "Há uma kunai no chão. Será que ele deixou cair?"])
	hud.text = "HENRIQUE UCHIHA • 12 anos    |    Chakra %d/100" % int(chakra)
	objective.text = OBJECTIVES[stage]
	if stage == 3:
		objective.text += "  %d%%" % int(trail_progress / 12 * 100)
	queue_redraw()

func act(action: String) -> void:
	if not lines.is_empty():
		if action == "interact": next_line()
		return
	if stage == 6: return
	if action == "kunai" and cooldown <= 0:
		cooldown = 0.4
		attack_flash = 0.2
		if stage == 0 and player.distance_to(target) < 150 and facing.dot((target - player).normalized()) > 0.35:
			hits += 1
			if hits >= 3:
				stage = 1
				say(["Henrique: Três acertos! Agora vou tentar o Katon."])
	elif action == "katon" and cooldown <= 0 and chakra >= 25:
		chakra -= 25
		cooldown = 1.0
		attack_flash = 0.5
		if stage == 1 and player.distance_to(target) < 150:
			stage = 2
			player = Vector2(170, 270)
			say(["Henrique: Katon!", "As chamas escapam por um instante. Seus olhos ficam vermelhos: Sharingan de um tomoe.", "Henrique: O que foi isso...? Melhor voltar para a vila."])
	elif action == "interact":
		if stage == 2 and player.distance_to(Vector2(640, 260)) < 95:
			stage = 3
			player = Vector2(450, 270)
			say(["Naruto: Ei! Por que você está sempre com essa cara séria?", "Henrique: E você, por que está sempre arrumando confusão?", "Iruka: Naruto! Volte para a Academia!", "Mais tarde, ao anoitecer...", "Henrique: Mizuki? O que um instrutor está fazendo perto da floresta a esta hora?"])
		elif stage == 4 and player.distance_to(target) < 85:
			stage = 5
			say(["Henrique: Uma kunai... Não consigo descobrir o que ele estava planejando.", "Está tarde. Vou para casa."])
		elif stage == 5 and player.distance_to(Vector2(110, 230)) < 95:
			stage = 6
			say(["Henrique adormece. No sonho: fogo, o símbolo Uchiha e uma silhueta com olhos vermelhos.", "Sinos de emergência rompem o silêncio da madrugada.", "Ninja no telhado: O Pergaminho dos Selos foi roubado!", "Henrique corre até a janela. Uma figura de roupa laranja desaparece em direção à floresta.", "Henrique: Naruto...?", "FIM DO EP -1 — A Noite Antes do Começo. Prólogo original de fã. O episódio 1 ainda não está implementado."])
			restart.show()

func ninja(at: Vector2, color: Color, label: String) -> void:
	draw_rect(Rect2(at + Vector2(-12, -7), Vector2(24, 27)), color)
	draw_rect(Rect2(at + Vector2(-10, -26), Vector2(20, 19)), Color("e1ac87"))
	draw_rect(Rect2(at + Vector2(-12, -30), Vector2(24, 10)), Color("182031"))
	draw_rect(Rect2(at + Vector2(-12, 20), Vector2(9, 10)), Color("182031"))
	draw_rect(Rect2(at + Vector2(3, 20), Vector2(9, 10)), Color("182031"))
	draw_string(ThemeDB.fallback_font, at + Vector2(-32, -38), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)

func _draw() -> void:
	var night := stage >= 3
	draw_rect(Rect2(0, 0, 960, 540), Color("172936") if night else Color("688c5b"))
	draw_rect(Rect2(0, 205, 960, 100), Color("35414c") if night else Color("b29971"))
	for i in range(12):
		var pos := Vector2(30 + i * 82, 130 if i % 2 == 0 else 360)
		draw_rect(Rect2(pos, Vector2(10, 38)), Color("694d39"))
		draw_circle(pos + Vector2(5, -3), 26, Color("243f38") if night else Color("365c3f"))
	if stage <= 1:
		draw_circle(target, 23, Color("decda4"))
		draw_circle(target, 15, Color("ad4841"))
		draw_circle(target, 6, Color("decda4"))
		draw_string(ThemeDB.fallback_font, target + Vector2(-25, -32), "%d/3" % hits)
	elif stage == 2:
		for i in range(3):
			draw_rect(Rect2(350 + i * 165, 105, 110, 75), Color("c2a183"))
			draw_rect(Rect2(340 + i * 165, 95, 130, 18), Color("784a43"))
		ninja(Vector2(640, 260), Color("ec8b35"), "Naruto")
		ninja(Vector2(730, 260), Color("597449"), "Iruka")
	elif stage == 3:
		ninja(mizuki, Color("969ab4"), "Mizuki")
	elif stage == 4:
		draw_line(target - Vector2(12, 0), target + Vector2(12, 0), Color("cedce3"), 4)
	if stage >= 5:
		draw_rect(Rect2(65, 170, 90, 80), Color("6c5860"))
		draw_rect(Rect2(95, 210, 25, 40), Color("252536"))
		draw_string(ThemeDB.fallback_font, Vector2(75, 158), "Casa", HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	ninja(player, Color("243550"), "Henrique")
	if attack_flash > 0:
		draw_line(player, player + facing * 110, Color("f5a34a"), 5)
