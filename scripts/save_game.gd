extends RefCounted

const VERSION := 1
var enabled := true
var path := "user://prologue_save.json"
var last_error := ""

func snapshot(game: Node2D) -> Dictionary:
	return {"version": VERSION, "stage": game.stage, "hits": game.hits,
		"chakra": game.chakra, "stamina": game.stamina,
		"player": [game.player.x, game.player.y], "facing": [game.facing.x, game.facing.y],
		"target": [game.target.x, game.target.y], "mizuki": [game.mizuki.x, game.mizuki.y],
		"trail_progress": clampf(game.trail_progress, 0, 12), "lines": game.lines.duplicate(),
		"line_index": game.line_index, "pending_forest_transition": game.pending_forest_transition}

func valid_number(value: Variant, low: float, high: float) -> bool:
	return (value is float or value is int) and is_finite(float(value)) and float(value) >= low and float(value) <= high

func valid_vector(value: Variant, low: float, high: float) -> bool:
	return value is Array and value.size() == 2 and valid_number(value[0], low, high) and valid_number(value[1], low, high)

func validate(data: Variant) -> bool:
	if not data is Dictionary or data.get("version") != VERSION:
		return false
	if not data.get("stage") is int or not valid_number(data.stage, 0, 6):
		return false
	if not valid_number(data.get("hits"), 0, 3) or not valid_number(data.get("chakra"), 0, 100) or not valid_number(data.get("stamina"), 0, 100):
		return false
	for key in ["player", "target", "mizuki"]:
		if not valid_vector(data.get(key), 0, 960): return false
	if not valid_vector(data.get("facing"), -1, 1) or not valid_number(data.get("trail_progress"), 0, 12):
		return false
	if not data.get("lines") is Array or data.lines.size() > 32 or not data.get("line_index") is int:
		return false
	if data.line_index < 0 or (not data.lines.is_empty() and data.line_index >= data.lines.size()):
		return false
	for line in data.lines:
		if not line is String or line.length() > 2000: return false
	return data.get("pending_forest_transition") is bool

func read_save() -> Dictionary:
	last_error = ""
	if not enabled or not FileAccess.file_exists(path): return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 131072:
		last_error = "Não foi possível ler o progresso salvo."
		return {}
	var data: Variant = JSON.parse_string(file.get_as_text())
	# JSON numbers are floats, including whole numbers.
	if data is Dictionary:
		for key in ["version", "stage", "line_index"]:
			if data.get(key) is float and data[key] == floor(data[key]): data[key] = int(data[key])
	if not validate(data):
		last_error = "O progresso salvo não é compatível ou está danificado."
		return {}
	return data

func write_save(game: Node2D) -> bool:
	if not enabled: return false
	var data := snapshot(game)
	if not validate(data): return false
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		last_error = "Não foi possível salvar o progresso."
		return false
	file.store_string(JSON.stringify(data))
	file.flush()
	if file.get_error() != OK:
		file.close()
		last_error = "Não foi possível gravar o progresso."
		return false
	file.close()
	var result := DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(path))
	last_error = "" if result == OK else "Não foi possível concluir o salvamento."
	return result == OK

func apply(game: Node2D, data: Dictionary) -> bool:
	if not validate(data): return false
	game.stage = int(data.stage)
	game.hits = int(data.hits)
	game.chakra = float(data.chakra)
	game.stamina = float(data.stamina)
	game.player = game.layout.clamp_position(Vector2(data.player[0], data.player[1]), game.stage)
	game.target = game.layout.clamp_position(Vector2(data.target[0], data.target[1]), game.stage)
	game.mizuki = game.layout.clamp_position(Vector2(data.mizuki[0], data.mizuki[1]), 3)
	game.facing = Vector2(data.facing[0], data.facing[1]).normalized()
	if game.facing == Vector2.ZERO: game.facing = Vector2.RIGHT
	game.trail_progress = float(data.trail_progress)
	game.lines.assign(data.lines)
	game.line_index = int(data.line_index)
	game.pending_forest_transition = data.pending_forest_transition
	game.cooldown = 0
	game.attack_flash = 0
	game.dash_time = 0
	game.movement = Vector2.ZERO
	game.sprinting = false
	game.save_clock = 0
	game.ui.release_touches()
	game.background.set_area(game.stage)
	game.restart.visible = game.stage == 6
	if game.lines.is_empty(): game.dialogue.hide()
	else: game.ui.show_line(game.lines[game.line_index])
	return true
