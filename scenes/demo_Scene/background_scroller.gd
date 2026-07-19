extends Node2D
## Smooth endless scrolling TileMapLayer background + recentering (no camera movement)
## Godot 4.x
## Scroll speed is driven by WorldUtils.flight_speed — do not set it here.

@export var tile_layer: TileMapLayer

# Tile size in pixels (must match your TileSet tile size)
@export var tile_size_px: int = 167
## Optional tile-relative base speed. Zero keeps WorldUtils' default px/sec speed.
@export_range(0.0, 10.0, 0.25) var base_tiles_per_second: float = 0.0
## Prevents subpixel texture sampling seams while preserving smooth logical motion.
@export var snap_scroll_to_whole_pixels: bool = true

# Minimum background width in cells. The actual streamed width expands to viewport size.
@export var map_width_in_tiles: int = 9
@export var extra_cols_left: int = 1
@export var extra_cols_right: int = 1

# Buffers (rows) outside the visible screen.
@export var extra_rows_above: int = 4
@export var extra_rows_below: int = 2

# How many rows beyond bottom we keep before erasing.
@export var cleanup_rows_below: int = 8

# Recenter threshold (px). When abs(position.y) exceeds this, we recenter.
@export var recenter_threshold_px: float = 50000.0

# Tile source settings (atlas TileSet)
@export var source_id: int = 0
@export var alternative_tile: int = 0

# Atlas size (your tileset is 3x2)
@export var atlas_cols: int = 3
@export var atlas_rows: int = 2

# Preferred atlas coords (your "70% mostly these")
@export var preferred_a: Vector2i = Vector2i(1, 1)
@export var preferred_b: Vector2i = Vector2i(2, 1)

# Weights (out of total_weight)
@export var total_weight: int = 1000
@export var w1: int = 400
@export var w2: int = 400

# Optional: limit long streaks of identical tiles (visual smoothing)
@export var max_same_tile_run: int = 6


# Cumulative weight tables — tiny arrays (one entry per tile, max 6)
var _tiles: Array[Vector2i] = []
var _cumulative_weights: Array[int] = []
var _total_weight_built: int = 0

var _last_tile: Vector2i = Vector2i(-999, -999)
var _last_tile_run: int = 0

var _initialized := false
var _min_row_generated: int = 0
var _max_row_generated: int = -1
var _min_col_generated: int = 0
var _max_col_generated: int = -1
var _scroll_position_y: float = 0.0


func _ready() -> void:
	if tile_layer == null:
		push_error("Assign tile_layer in the Inspector.")
		set_process(false)
		return

	if base_tiles_per_second > 0.0:
		WorldUtils.set_base_scroll_speed_for_tiles(
			float(tile_size_px),
			base_tiles_per_second
		)
	_scroll_position_y = tile_layer.position.y

	_build_weighted_tiles()
	_refresh_streaming(true)


func _process(delta: float) -> void:
	# Speed comes from WorldUtils — controlled by player or level scripts
	_scroll_position_y += WorldUtils.scroll_speed() * delta
	tile_layer.position.y = (
		roundf(_scroll_position_y)
		if snap_scroll_to_whole_pixels
		else _scroll_position_y
	)

	_recenter_if_needed()
	_refresh_streaming(false)


# ----------------------------
# Recentering (prevents huge coordinates)
# ----------------------------
func _recenter_if_needed() -> void:
	if absf(tile_layer.position.y) < recenter_threshold_px:
		return

	var shift_rows: int = int(floor(tile_layer.position.y / float(tile_size_px)))
	if shift_rows == 0:
		return

	var shift_px: float = float(shift_rows * tile_size_px)
	_scroll_position_y -= shift_px
	tile_layer.position.y -= shift_px
	_shift_generated_cells(shift_rows)

	_min_row_generated += shift_rows
	_max_row_generated += shift_rows


func _shift_generated_cells(shift_rows: int) -> void:
	var used_cells: Array[Vector2i] = tile_layer.get_used_cells()
	var source_ids: Array[int] = []
	var atlas_coords: Array[Vector2i] = []
	var alternative_tiles: Array[int] = []

	for cell in used_cells:
		source_ids.append(tile_layer.get_cell_source_id(cell))
		atlas_coords.append(tile_layer.get_cell_atlas_coords(cell))
		alternative_tiles.append(tile_layer.get_cell_alternative_tile(cell))

	tile_layer.clear()

	for i in range(used_cells.size()):
		var shifted_cell := used_cells[i] + Vector2i(0, shift_rows)
		tile_layer.set_cell(
			shifted_cell,
			source_ids[i],
			atlas_coords[i],
			alternative_tiles[i]
		)


# ----------------------------
# Streaming logic (no camera)
# ----------------------------
func _refresh_streaming(force_init: bool) -> void:
	var world_rect := WorldUtils.world_view_rect(get_viewport())

	var top_left_local: Vector2 = tile_layer.to_local(world_rect.position)
	var bottom_right_local: Vector2 = tile_layer.to_local(world_rect.position + world_rect.size)

	var top_left_cell: Vector2i = tile_layer.local_to_map(top_left_local)
	var bottom_right_cell: Vector2i = tile_layer.local_to_map(bottom_right_local)

	var visible_width_in_tiles: int = int(ceil(world_rect.size.x / float(tile_size_px)))
	var min_width_in_tiles: int = maxi(maxi(1, map_width_in_tiles), visible_width_in_tiles)
	var needed_min_col: int = top_left_cell.x - extra_cols_left
	var needed_max_col: int = maxi(
		bottom_right_cell.x + extra_cols_right,
		needed_min_col + min_width_in_tiles - 1
	)
	var needed_min_row: int = top_left_cell.y - extra_rows_above
	var needed_max_row: int = bottom_right_cell.y + extra_rows_below

	if force_init or not _initialized:
		_initialized = true
		_min_row_generated = needed_min_row
		_max_row_generated = needed_min_row - 1
		_min_col_generated = needed_min_col
		_max_col_generated = needed_max_col

	if needed_max_row > _max_row_generated:
		for y in range(_max_row_generated + 1, needed_max_row + 1):
			_generate_row(y, needed_min_col, needed_max_col)
		_max_row_generated = needed_max_row

	if needed_min_row < _min_row_generated:
		for y in range(needed_min_row, _min_row_generated):
			_generate_row(y, needed_min_col, needed_max_col)
		_min_row_generated = needed_min_row

	if needed_min_col < _min_col_generated:
		for y in range(_min_row_generated, _max_row_generated + 1):
			_generate_row(y, needed_min_col, _min_col_generated - 1)
		_min_col_generated = needed_min_col

	if needed_max_col > _max_col_generated:
		for y in range(_min_row_generated, _max_row_generated + 1):
			_generate_row(y, _max_col_generated + 1, needed_max_col)
		_max_col_generated = needed_max_col

	var erase_below: int = needed_max_row + cleanup_rows_below
	if erase_below < _max_row_generated:
		for y in range(erase_below + 1, _max_row_generated + 1):
			_erase_row(y)
		_max_row_generated = erase_below


func _generate_row(y: int, min_col: int, max_col: int) -> void:
	for x in range(min_col, max_col + 1):
		var coords := Vector2i(x, y)
		var atlas := _pick_tile_safely()
		tile_layer.set_cell(coords, source_id, atlas, alternative_tile)


func _erase_row(y: int) -> void:
	for x in range(_min_col_generated, _max_col_generated + 1):
		tile_layer.erase_cell(Vector2i(x, y))


# ----------------------------
# Weighted random tiles — cumulative weight table
# Max 6 entries (3x2 atlas), no large flat arrays
# ----------------------------
func _build_weighted_tiles() -> void:
	_tiles.clear()
	_cumulative_weights.clear()
	_total_weight_built = 0

	preferred_a = Vector2i(clamp(preferred_a.x, 0, atlas_cols - 1), clamp(preferred_a.y, 0, atlas_rows - 1))
	preferred_b = Vector2i(clamp(preferred_b.x, 0, atlas_cols - 1), clamp(preferred_b.y, 0, atlas_rows - 1))

	var all_tiles: Array[Vector2i] = []
	for yy in range(atlas_rows):
		for xx in range(atlas_cols):
			all_tiles.append(Vector2i(xx, yy))

	var others := all_tiles.filter(func(t: Vector2i) -> bool:
		return t != preferred_a and t != preferred_b
	)

	w1 = maxi(0, w1)
	w2 = maxi(0, w2)
	total_weight = maxi(1, total_weight)

	var w1_clamped: int = mini(w1, total_weight)
	var w2_clamped: int = mini(w2, maxi(0, total_weight - w1_clamped))

	_add_weight(preferred_a, w1_clamped)
	_add_weight(preferred_b, w2_clamped)

	var used: int = w1_clamped + w2_clamped
	var remaining: int = maxi(0, total_weight - used)

	if others.size() > 0 and remaining > 0:
		var per_other: int = floori(float(remaining) / float(others.size()))
		var remainder: int = remaining - (per_other * others.size())
		for t in others:
			_add_weight(t, per_other)
		for i in range(remainder):
			_add_weight(others[i % others.size()], 1)

	# Fallback: ensure at least one tile exists
	if _tiles.is_empty():
		_add_weight(preferred_a, 1)


func _add_weight(tile: Vector2i, weight: int) -> void:
	if weight <= 0:
		return
	_total_weight_built += weight
	_tiles.append(tile)
	_cumulative_weights.append(_total_weight_built)


func _pick_tile() -> Vector2i:
	var r := randi() % _total_weight_built
	for i in range(_cumulative_weights.size()):
		if r < _cumulative_weights[i]:
			return _tiles[i]
	return _tiles[-1]  # fallback на случай ошибки округления


func _pick_tile_safely() -> Vector2i:
	if max_same_tile_run <= 0:
		return _pick_tile()

	var t := _pick_tile()

	if t == _last_tile:
		_last_tile_run += 1
		if _last_tile_run > max_same_tile_run:
			for _i in range(8):
				var alt := _pick_tile()
				if alt != _last_tile:
					t = alt
					_last_tile = t
					_last_tile_run = 1
					break
	else:
		_last_tile = t
		_last_tile_run = 1

	return t
