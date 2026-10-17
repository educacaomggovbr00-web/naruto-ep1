extends Control

var game: Node2D
var cards: Array[Button] = []
var pictures: Array[TextureRect] = []
var statuses: Array[Label] = []
var cancel_button: Button
var note: Label
const DISTRICTS := ["residential", "plaza", "training"]
const LABELS := ["Bairro residencial", "Praça de Konoha", "Campo de treino"]
const PICTURES := ["residential-generated.png", "konoha-premium.png", "training-premium.png"]

func _ready() -> void:
	position = Vector2(26, 96)
	size = Vector2(744, 295)
	game.ui.child_label(self, "KONOHA  /  ÁREAS CONECTADAS", Vector2.ZERO, Vector2(490, 24), 15, Color("ecd09a"))
	for i in range(3):
		var panel := Panel.new()
		panel.position = Vector2(i * 252, 35)
		panel.size = Vector2(232, 202)
		panel.add_theme_stylebox_override("panel", game.ui.panel_style())
		add_child(panel)
		var picture := TextureRect.new()
		picture.position = Vector2(8, 8)
		picture.size = Vector2(216, 92)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		pictures.append(picture)
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(picture)
		game.ui.child_label(panel, LABELS[i], Vector2(10, 109), Vector2(212, 23), 16, Color("f3e4bf"))
		statuses.append(game.ui.child_label(panel, "", Vector2(10, 136), Vector2(212, 21), 12, Color("b4c6b7")))
		var button := Button.new()
		button.position = Vector2(8, 162)
		button.size = Vector2(216, 32)
		game.style_button(button)
		button.add_theme_font_size_override("font_size", 11)
		var destination: String = DISTRICTS[i]
		button.pressed.connect(func(): mark(destination))
		panel.add_child(button)
		cards.append(button)
	note = game.ui.child_label(self, "", Vector2(0, 247), Vector2(540, 50), 12, Color("becac1"))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cancel_button = Button.new()
	cancel_button.text = "REMOVER ROTA"
	cancel_button.position = Vector2(560, 250)
	cancel_button.size = Vector2(176, 38)
	game.style_button(cancel_button)
	cancel_button.add_theme_font_size_override("font_size", 12)
	cancel_button.pressed.connect(clear_route)
	add_child(cancel_button)
	visibility_changed.connect(release_hidden_pictures)
	hide()

func release_hidden_pictures() -> void:
	if not is_visible_in_tree():
		for picture in pictures: picture.texture = null

func refresh() -> void:
	for i in range(DISTRICTS.size()):
		if is_visible_in_tree() and pictures[i].texture == null:
			pictures[i].texture = load("res://assets/environments/" + PICTURES[i])
		var district: String = DISTRICTS[i]
		var here: bool = district == game.world.district
		var visited: bool = district == "plaza" and game.stage >= 2 or district == "residential" and game.visited.residential or district == "training" and game.visited.free_training
		statuses[i].text = "Você está aqui" if here and game.stage == 2 else "Visitado" if visited else "A explorar"
		cards[i].disabled = game.stage != 2 or here
		cards[i].text = "VOCÊ ESTÁ AQUI" if here and game.stage == 2 else "ROTA MARCADA" if game.world.tracked_district == district else "MARCAR CAMINHO"
	cancel_button.disabled = game.world.tracked_district.is_empty()
	if game.stage != 2:
		note.text = "As rotas entre distritos ficam disponíveis durante a exploração de Konoha. A história mantém prioridade."
	elif not game.world.tracked_district.is_empty():
		note.text = "Destino: %s. Volte ao jogo e siga o caminho dourado. Não há teletransporte." % game.world.NAMES[game.world.tracked_district]
		if not game.route_guide.enabled: note.text = "Destino marcado. Ative 'Guia de caminho no chão' em AJUSTES para ver a rota."
	else:
		note.text = "Bairro ↔ Praça ↔ Campo. Marque um caminho opcional. Sua missão e seu progresso não mudam."

func mark(destination: String) -> void:
	if game.stage != 2 or not destination in DISTRICTS or destination == game.world.district: return
	game.world.tracked_district = destination
	game.route_guide.reset()
	refresh()

func clear_route() -> void:
	game.world.tracked_district = ""
	game.route_guide.reset()
	refresh()

func touch_buttons() -> Array[Button]:
	var buttons: Array[Button] = []
	if visible:
		buttons.append_array(cards)
		buttons.append(cancel_button)
	return buttons
