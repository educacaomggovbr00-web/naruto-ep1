extends Node

# Stable/mobile mode:
# Do not perform HTTP downloads during boot/gameplay.
# Naruto falls back to the local MUGEN frames already bundled in the project.
func _ready() -> void:
	pass

func has_texture(_key: String) -> bool:
	return false

func get_texture(_key: String) -> Texture2D:
	return null

func naruto_texture(_action: String, _clock: float) -> Texture2D:
	return null
