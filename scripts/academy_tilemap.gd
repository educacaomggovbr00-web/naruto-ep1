extends TileMapLayer

# Academy exterior rebuilt as a real Godot TileMapLayer.
# The same solid tiles have TileSet physics polygons and are also queried by
# main.gd because Henrique is currently rendered/moved manually instead of
# being a CharacterBody2D.
const TILE_SIZE: Vector2i = Vector2i(32, 32)
const SOURCE_ID: int = 0
const TILE_TEXTURE: Texture2D = preload("res://assets/tiles/konoha_academy_tiles.svg")

const GRASS: Vector2i = Vector2i(0, 0)
const PATH: Vector2i = Vector2i(1, 0)
const STONE: Vector2i = Vector2i(2, 0)
const WALL: Vector2i = Vector2i(3, 0)
const WINDOW: Vector2i = Vector2i(4, 0)
const DOOR: Vector2i = Vector2i(5, 0)
const ROOF: Vector2i = Vector2i(6, 0)
const ROOF_EDGE: Vector2i = Vector2i(7, 0)
const BUSH: Vector2i = Vector2i(0, 1)
const TREE: Vector2i = Vector2i(1, 1)
const FENCE: Vector2i = Vector2i(2, 1)
const SIGN: Vector2i = Vector2i(3, 1)
const TARGET_TILE: Vector2i = Vector2i(4, 1)
const POST: Vector2i = Vector2i(5, 1)
const GRASS_ALT: Vector2i = Vector2i(6, 1)
const PATH_EDGE: Vector2i = Vector2i(7, 1)
const WALL_TOP: Vector2i = Vector2i(0, 2)
const WINDOW_LOW: Vector2i = Vector2i(1, 2)
const PATH_ALT: Vector2i = Vector2i(2, 2)
const STONE_ALT: Vector2i = Vector2i(3, 2)
const BENCH: Vector2i = Vector2i(4, 2)
const FENCE_CROSS: Vector2i = Vector2i(5, 2)
const GRASS_DARK: Vector2i = Vector2i(6, 2)
const STONE_CLEAN: Vector2i = Vector2i(7, 2)
const WATER: Vector2i = Vector2i(0, 3)
const RAIL: Vector2i = Vector2i(1, 3)
const SHRUB: Vector2i = Vector2i(2, 3)
const PATH_VERTICAL: Vector2i = Vector2i(3, 3)
const STONE_EDGE: Vector2i = Vector2i(4, 3)
const LAMP: Vector2i = Vector2i(5, 3)
const CRATE: Vector2i = Vector2i(6, 3)
const CROSSROAD: Vector2i = Vector2i(7, 3)

const SOLID_TILES: Array[Vector2i] = [
	WALL, WINDOW, DOOR, ROOF, ROOF_EDGE, TREE, FENCE, POST,
	WALL_TOP, WINDOW_LOW, FENCE_CROSS, RAIL, CRATE
]

var solid_cells: Dictionary = {}
var _active: bool = true

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = -1
	_build_tileset()
	_build_academy()
	set_active(true)

func _build_tileset() -> void:
	var set_resource: TileSet = TileSet.new()
	set_resource.tile_size = TILE_SIZE
	set_resource.add_physics_layer()
	set_resource.set_physics_layer_collision_layer(0, 1)
	set_resource.set_physics_layer_collision_mask(0, 1)

	var atlas: TileSetAtlasSource = TileSetAtlasSource.new()
	atlas.texture = TILE_TEXTURE
	atlas.texture_region_size = TILE_SIZE
	atlas.use_texture_padding = false

	for y in range(4):
		for x in range(8):
			var coords: Vector2i = Vector2i(x, y)
			atlas.create_tile(coords)

	for coords in SOLID_TILES:
		var data: TileData = atlas.get_tile_data(coords, 0)
		if data == null:
			continue
		data.set_collision_polygons_count(0, 1)
		data.set_collision_polygon_points(
			0,
			0,
			PackedVector2Array([
				Vector2(-16, -16),
				Vector2(16, -16),
				Vector2(16, 16),
				Vector2(-16, 16)
			])
		)

	set_resource.add_source(atlas, SOURCE_ID)
	tile_set = set_resource

func _place(cell: Vector2i, tile: Vector2i) -> void:
	set_cell(cell, SOURCE_ID, tile, 0)
	if SOLID_TILES.has(tile):
		solid_cells[cell] = true
	else:
		solid_cells.erase(cell)

func _fill_rect(from_cell: Vector2i, to_cell: Vector2i, tile: Vector2i) -> void:
	for y in range(from_cell.y, to_cell.y + 1):
		for x in range(from_cell.x, to_cell.x + 1):
			_place(Vector2i(x, y), tile)

func _build_academy() -> void:
	clear()
	solid_cells.clear()

	# 960x544 world = 30x17 cells. Base grass stays crisp at 32px.
	for y in range(17):
		for x in range(30):
			var tile: Vector2i = GRASS if (x + y) % 5 != 0 else GRASS_ALT
			_place(Vector2i(x, y), tile)

	# Main village road and academy courtyard.
	_fill_rect(Vector2i(0, 11), Vector2i(29, 16), PATH)
	_fill_rect(Vector2i(5, 7), Vector2i(24, 11), STONE)
	_fill_rect(Vector2i(13, 8), Vector2i(16, 16), PATH_VERTICAL)
	_place(Vector2i(14, 11), CROSSROAD)
	_place(Vector2i(15, 11), CROSSROAD)

	# Academy building. It ends above the NPC interaction line, so Naruto/Iruka
	# remain reachable in the courtyard.
	_fill_rect(Vector2i(6, 2), Vector2i(23, 2), ROOF)
	_fill_rect(Vector2i(7, 3), Vector2i(22, 3), ROOF_EDGE)
	_fill_rect(Vector2i(7, 4), Vector2i(22, 6), WALL)

	for x in [9, 12, 17, 20]:
		_place(Vector2i(x, 5), WINDOW)
		_place(Vector2i(x, 6), WINDOW_LOW)

	_place(Vector2i(14, 6), DOOR)
	_place(Vector2i(15, 6), DOOR)
	_place(Vector2i(11, 7), SIGN)
	_place(Vector2i(18, 7), SIGN)

	# Side vegetation and fences. East/west road exits stay open around rows 10-12.
	for y in range(3, 9):
		_place(Vector2i(1, y), TREE if y % 2 == 0 else SHRUB)
		_place(Vector2i(28, y), TREE if y % 2 == 1 else SHRUB)
	for x in range(2, 6):
		_place(Vector2i(x, 8), FENCE)
	for x in range(24, 28):
		_place(Vector2i(x, 8), FENCE)

	# Small environmental details.
	_place(Vector2i(5, 10), BENCH)
	_place(Vector2i(23, 10), BENCH)
	_place(Vector2i(4, 12), LAMP)
	_place(Vector2i(25, 12), LAMP)
	_place(Vector2i(3, 13), BUSH)
	_place(Vector2i(26, 13), BUSH)
	_place(Vector2i(7, 13), CRATE)
	_place(Vector2i(22, 13), CRATE)

func set_active(value: bool) -> void:
	if _active == value and visible == value:
		return
	_active = value
	visible = value
	collision_enabled = value

func is_active() -> bool:
	return _active and visible

func has_collision_tiles() -> bool:
	return not solid_cells.is_empty()

func is_blocked_world_point(point: Vector2) -> bool:
	if not is_active():
		return false
	var cell: Vector2i = local_to_map(to_local(point))
	return solid_cells.has(cell)

func blocks_player(center: Vector2, radius: float = 13.0) -> bool:
	if not is_active():
		return false
	var probes: Array[Vector2] = [
		center,
		center + Vector2(radius, 0),
		center + Vector2(-radius, 0),
		center + Vector2(0, radius),
		center + Vector2(0, -radius),
		center + Vector2(radius * 0.7, radius * 0.7),
		center + Vector2(-radius * 0.7, radius * 0.7),
		center + Vector2(radius * 0.7, -radius * 0.7),
		center + Vector2(-radius * 0.7, -radius * 0.7)
	]
	for probe in probes:
		if is_blocked_world_point(probe):
			return true
	return false
