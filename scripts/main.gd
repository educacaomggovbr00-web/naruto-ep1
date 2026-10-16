extends Node2D

# Original playable fan-game prologue, before the events of episode 1.
var player := Vector2(140, 270)
var stage := 0
var room := "outside"
var return_position := Vector2(170,270)
var visited := {"academy":false,"home":false,"class_intro":false,"board":false,"notes":false,"chakra_drill":false}
var travelling := false
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
var motion_velocity := Vector2.ZERO
var combat = preload("res://scripts/combat.gd").new()
var held := {}
var hud: Label
var objective: Label
var dialogue: Button
var restart: Button
var cinematic: Node
var audio: Node
var ui: CanvasLayer
var visual_clock := 0.0
var gait_distance := 0.0
var ambient=preload("res://scripts/ambient_world.gd").new()
var day_cycle=preload("res://scripts/day_cycle.gd").new()
var sprinting := false
var effect_kind := "kunai"
var effect_origin := Vector2.ZERO
var effect_direction := Vector2.RIGHT
var art = preload("res://scripts/visuals.gd").new()
var polish = preload("res://scripts/polish.gd").new()
var background = preload("res://scripts/background.gd").new()
const OBJECTIVES := [
	"TREINO • Acerte 3 vezes o alvo com kunai (J / botão KUNAI).",
	"CHAKRA • Acerte o alvo com Katon (K / botão KATON).",
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
	for actor_name in art.character_art.attached_cast["actors"]:
		if lines[0].begins_with(actor_name+":"): ambient.react(actor_name)

func travel_to(destination: String) -> void:
	if travelling or not lines.is_empty(): return
	if room != "outside" and destination != "outside": return
	if destination == "outside" and room == "outside": return
	if destination == "academy" and stage != 2: return
	if destination == "home" and not stage in [2,5]: return
	if destination != "outside" and not layout.interiors.ROOMS.has(destination): return
	travelling=true
	ui.release_touches()
	movement=Vector2.ZERO
	dash_time=0
	attack_flash=0
	combat.reset()
	var tween: Tween = ui.fade_to(1.0)
	await tween.finished
	if destination == "outside":
		room="outside"
		player=layout.restore_position(return_position,stage)
	else:
		return_position=layout.restore_position(player+Vector2(0,24),stage)
		room=destination
		player=layout.interiors.config(room)["spawn"]
		visited[room]=true
	facing=Vector2.UP if room != "outside" else Vector2.DOWN
	polish.dust.clear()
	background.set_area(stage,room,day_cycle.is_night(stage))
	audio.set_indoor(room != "outside")
	cinematic.camera.position=Vector2(480,270)
	cinematic.camera.offset=Vector2.ZERO
	save_checkpoint(false)
	queue_redraw()
	tween=ui.fade_to(0.0)
	await tween.finished
	ui.release_touches()
	travelling=false

func interior_action() -> void:
	var point: Dictionary = layout.interiors.nearby(player,room)
	if point.is_empty():
		ui.toast("Aproxime-se de uma pessoa ou objeto para interagir.")
		return
	match str(point["id"]):
		"exit": travel_to("outside")
		"Iruka":
			visited["class_intro"]=true
			say(["Iruka: Henrique, o treino de hoje é controle de chakra e precisão. Não basta fazer força: concentre-se.","Iruka: Amanhã continuaremos as avaliações. Por hoje, revise suas anotações e converse com seus colegas."])
		"practice":
			if not visited["class_intro"]: say(["Henrique: Vou conversar com Iruka, à frente da sala, antes de começar o exercício."])
			elif not visited["board"]: say(["Henrique: A revisão está no quadro à esquerda de Iruka. Vou ler antes de praticar."])
			else: ui.practice.start()
		"Sasuke": say(["Sasuke: Já terminei meus exercícios. Vou revisar os movimentos mais uma vez."])
		"Sakura": say(["Sakura: O Iruka deixou a revisão no quadro. Quero estar preparada para a próxima aula."])
		"board":
			visited["board"]=true
			say(["No quadro: controle de chakra, transformação e clonagem básica. O treinamento com armas deve acontecer no campo de treino.","Henrique: Vou revisar com calma. Primeiro, preciso dominar os fundamentos."])
		"desk":
			visited["notes"]=true
			say(["Henrique: Meus cadernos e materiais de treino. Ainda há anotações que preciso revisar."])
		"kitchen": say(["Uma cozinha simples, com água, frutas e os utensílios do dia a dia. A casa está em ordem."])
		"bed":
			if stage == 5: finish_prologue()
			else: say(["Henrique: Ainda é cedo para dormir. Vou terminar o que tenho para fazer na vila."])

func finish_prologue() -> void:
	stage=6
	say(["Henrique se deita em sua cama. No sonho: fogo, o símbolo Uchiha e uma silhueta com olhos vermelhos.","Sinos de emergência rompem o silêncio da madrugada.","Ninja no telhado: O Pergaminho dos Selos foi roubado!","Henrique corre até a janela. Uma figura de roupa laranja desaparece em direção à floresta.","Henrique: Naruto...?","FIM DO EP -1 — A Noite Antes do Começo. Prólogo original de fã. O episódio 1 ainda não está implementado."])
	restart.show()

func next_line() -> void:
	if ui.finish_typing():
		return
	line_index += 1
	if pending_forest_transition and line_index >= 3:
		pending_forest_transition = false
		stage = 3
		room = "outside"
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
			KEY_M: ui.journal.toggle()
			KEY_Q: act("dodge")
			KEY_ENTER:
				if ui.resume_overlay.visible: ui.continue_game()
			KEY_ESCAPE:
				if ui.practice.visible: ui.practice.close()
				elif ui.journal.visible: ui.journal.close()
				elif ui.settings_panel.visible: ui.toggle_settings()
			KEY_E, KEY_SPACE:
				if ui.practice.visible: ui.practice.confirm()
				else: act("interact")
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
	day_cycle.update(self,delta)
	ambient.update(self,delta)
	background.animate(day_cycle.elapsed,day_cycle.wind_strength(),ambient.shake_at,ambient.shake_life)
	audio.set_night(day_cycle.is_night(stage))
	stamina = minf(100, stamina + delta * 18)
	save_clock += delta
	if save_clock >= 8 and lines.is_empty():
		save_checkpoint(false)
	background.set_area(stage,room,day_cycle.is_night(stage))
	cooldown = maxf(0.0, cooldown - delta)
	attack_flash = maxf(0.0, attack_flash - delta)
	chakra = minf(100.0, chakra + delta * 5.0)
	combat.update(self,delta)
	if lines.is_empty() and stage < 6 and not ui.settings_panel.visible:
		movement = Vector2(float(down("right", KEY_D, KEY_RIGHT)) - float(down("left", KEY_A, KEY_LEFT)), float(down("down", KEY_S, KEY_DOWN)) - float(down("up", KEY_W, KEY_UP))).normalized()
		if movement != Vector2.ZERO and attack_flash<=0:
			facing = movement
		var sneaking := down("sneak", KEY_SHIFT)
		sprinting = down("run", KEY_R) and not sneaking
		var previous := player
		var speed := 95.0 if sneaking else 240.0 if sprinting else 180.0
		if dash_time > 0:
			motion_velocity=Vector2.ZERO
			movement = dash_direction
			sprinting = true
			speed = 440.0
			move_with_collisions(movement * speed * minf(delta, dash_time))
			dash_time = maxf(0, dash_time - delta)
		else:
			motion_velocity=Vector2.ZERO if movement==Vector2.ZERO else motion_velocity.move_toward(movement*speed,2800.0*delta)
			move_with_collisions(motion_velocity * delta)
		gait_distance+=player.distance_to(previous)
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
	if room == "academy" and stage < 6:
		objective.text="ACADEMIA • Converse com Iruka, à frente da sala."
		if visited["class_intro"]: objective.text="ACADEMIA • Leia o quadro e pratique chakra no centro da sala (E / AÇÃO)."
		if visited["chakra_drill"]: objective.text="ACADEMIA • Treino concluído. Explore a sala ou volte à praça para encontrar Naruto."
	elif room == "home" and stage < 6: objective.text = "CASA • " + ("Aproxime-se da cama e use AÇÃO para descansar." if stage == 5 else "Explore sua casa. A saída fica na parte de baixo.")
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
	if room != "outside" and action in ["kunai","katon","dodge"]:
		ui.toast("Guarde as técnicas para o campo de treino.")
		return
	if action == "interact":
		if room != "outside":
			interior_action()
			return
		if stage in [2,5] and player.distance_to(layout.HOME) < 48:
			travel_to("home")
			return
		if stage == 2 and player.distance_to(layout.interiors.ACADEMY_DOOR) < 48:
			travel_to("academy")
			return
		if stage == 5 and player.distance_to(layout.interiors.ACADEMY_DOOR) < 48:
			ui.toast("A Academia está fechada à noite. Volte de manhã.")
			return
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
		if cooldown<=0.12: combat.buffered=action
		else: ui.toast("Aguarde a técnica ficar pronta.")
		return
	if action == "katon" and chakra < 25:
		ui.toast("Katon precisa de 25 de chakra.")
		return
	if action == "kunai" and cooldown <= 0:
		combat.begin(self,"kunai")
	elif action == "katon" and cooldown <= 0 and chakra >= 25:
		combat.begin(self,"katon")
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
			else: ambient.interact(self)
		elif stage == 4 and player.distance_to(target) < 85:
			stage = 5
			say(["Henrique: Uma kunai... Não consigo descobrir o que ele estava planejando.", "Está tarde. Vou para casa."])
		else: ambient.interact(self)

func training_hit(kind: String) -> void:
	if stage==0 and kind=="kunai":
		hits=mini(3,hits+1)
		ui.toast("Acerto %d / 3" % hits)
		if hits>=3:
			stage=1
			say(["Henrique: Três acertos! Agora vou tentar o Katon."])
	elif stage==1 and kind=="katon":
		stage=2
		player=Vector2(170,270)
		combat.reset()
		say(["Henrique: Katon!","As chamas escapam por um instante. Seus olhos ficam vermelhos: Sharingan de um tomoe.","Henrique: O que foi isso...? Melhor voltar para a vila."])

func style_button(button: Button, is_dialogue: bool = false) -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 18 if is_dialogue else 15)
	button.add_theme_color_override("font_color", Color("f3dfb4"))
	for state in ["normal", "hover", "pressed", "focus"]:
		button.add_theme_stylebox_override(state,preload("res://scripts/ui_palette.gd").button(state,is_dialogue))

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
	return layout.blocked(at, stage,room)

func move_with_collisions(displacement: Vector2) -> void:
	var steps := maxi(1, int(ceil(displacement.length() / 6.0)))
	var step := displacement / steps
	for i in range(steps):
		var next := layout.clamp_position(player + Vector2(step.x, 0), stage,room)
		if not blocked(next): player = next
		next = layout.clamp_position(player + Vector2(0, step.y), stage,room)
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
