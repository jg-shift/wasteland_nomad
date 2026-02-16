extends Node2D
## Smooth endless scrolling TileMapLayer background + recentering (no camera movement)
## Godot 4.x

@export var tile_layer: TileMapLayer

# Smooth scroll speed: background moves DOWN (positive Y).
@export var scroll_speed_px_per_sec: float = 220.0

# Tile size in pixels (must match your TileSet tile size)
@export var tile_size_px: int = 167

# How many tiles wide your background is (cells).
@export var map_width_in_tiles: int = 9

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


var _weighted_tiles: Array[Vector2i] = []
var _last_tile: Vector2i = Vector2i(-999, -999)
var _last_tile_run: int = 0

var _initialized := false
var _min_row_generated: int = 0
var _max_row_generated: int = -1


func _ready() -> void:
	if tile_layer == null:
		push_error("Assign tile_layer in the Inspector.")
		set_process(false)
		return

	randomize()
	_build_weighted_tiles()
	_refresh_streaming(true)


func _process(delta: float) -> void:
	# Smooth movement
	tile_layer.position.y += scroll_speed_px_per_sec * delta

	# Keep numbers small forever (prevents float precision issues)
	_recenter_if_needed()

	# Stream rows in/out
	_refresh_streaming(false)


# ----------------------------
# Recentering (prevents huge coordinates)
# ----------------------------
func _recenter_if_needed() -> void:
	if absf(tile_layer.position.y) < recenter_threshold_px:
		return

	# Shift back by a whole number of tile rows so visuals don't change.
	# Example: if position.y is +50123, tile_size 167 -> shift_rows ~ 300
	var shift_rows: int = int(floor(tile_layer.position.y / float(tile_size_px)))
	if shift_rows == 0:
		return

	var shift_px: float = float(shift_rows * tile_size_px)
	tile_layer.position.y -= shift_px

	# Compensate internal row indices because local_to_map() will now see different coords.
	_min_row_generated -= shift_rows
	_max_row_generated -= shift_rows


# ----------------------------
# Streaming logic (no camera)
# ----------------------------
func _refresh_streaming(force_init: bool) -> void:
	# Viewport rect in viewport coordinates
	var vp_rect: Rect2 = get_viewport().get_visible_rect()

	# Convert viewport coords -> global canvas coords
	var canvas_xform: Transform2D = get_viewport().get_canvas_transform()
	var top_left_global: Vector2 = canvas_xform.affine_inverse() * vp_rect.position
	var bottom_right_global: Vector2 = canvas_xform.affine_inverse() * (vp_rect.position + vp_rect.size)

	# Convert global -> tile_layer local -> map coords
	var top_left_local: Vector2 = tile_layer.to_local(top_left_global)
	var bottom_right_local: Vector2 = tile_layer.to_local(bottom_right_global)

	var top_left_cell: Vector2i = tile_layer.local_to_map(top_left_local)
	var bottom_right_cell: Vector2i = tile_layer.local_to_map(bottom_right_local)

	var needed_min_row: int = top_left_cell.y - extra_rows_above
	var needed_max_row: int = bottom_right_cell.y + extra_rows_below

	if force_init or not _initialized:
		_initialized = true
		_min_row_generated = needed_min_row
		_max_row_generated = needed_min_row - 1

	# Generate missing rows down to needed_max_row
	if needed_max_row > _max_row_generated:
		for y in range(_max_row_generated + 1, needed_max_row + 1):
			_generate_row(y)
		_max_row_generated = needed_max_row

	# Generate missing rows up to needed_min_row (if needed)
	if needed_min_row < _min_row_generated:
		for y in range(needed_min_row, _min_row_generated):
			_generate_row(y)
		_min_row_generated = needed_min_row

	# Cleanup: erase rows far below bottom
	var erase_below: int = needed_max_row + cleanup_rows_below
	if erase_below < _max_row_generated:
		for y in range(erase_below + 1, _max_row_generated + 1):
			_erase_row(y)
		_max_row_generated = erase_below


func _generate_row(y: int) -> void:
	for x in range(map_width_in_tiles):
		var coords := Vector2i(x, y)
		var atlas := _pick_tile_safely()
		tile_layer.set_cell(coords, source_id, atlas, alternative_tile)


func _erase_row(y: int) -> void:
	for x in range(map_width_in_tiles):
		tile_layer.erase_cell(Vector2i(x, y))


# ----------------------------
# Weighted random tiles (3x2 atlas)
# ----------------------------
func _build_weighted_tiles() -> void:
	_weighted_tiles.clear()

	# Clamp preferred tiles into atlas bounds
	preferred_a = Vector2i(clamp(preferred_a.x, 0, atlas_cols - 1), clamp(preferred_a.y, 0, atlas_rows - 1))
	preferred_b = Vector2i(clamp(preferred_b.x, 0, atlas_cols - 1), clamp(preferred_b.y, 0, atlas_rows - 1))

	# All tiles in atlas
	var all_tiles: Array[Vector2i] = []
	for yy in range(atlas_rows):
		for xx in range(atlas_cols):
			all_tiles.append(Vector2i(xx, yy))

	var others := all_tiles.filter(func(t: Vector2i) -> bool:
		return t != preferred_a and t != preferred_b
	)

	# Sane weights (use maxi/mini to avoid Variant inference issues)
	w1 = maxi(0, w1)
	w2 = maxi(0, w2)
	total_weight = maxi(1, total_weight)

	var w1_clamped: int = mini(w1, total_weight)
	var w2_clamped: int = mini(w2, maxi(0, total_weight - w1_clamped))

	_add_weight(preferred_a, w1_clamped)
	_add_weight(preferred_b, w2_clamped)

	var used: int = w1_clamped + w2_clamped
	var remaining: int = maxi(0, total_weight - used)

	# Spread remaining across others
	if others.size() > 0 and remaining > 0:
		var per_other: int = remaining / others.size()
		var remainder: int = remaining - (per_other * others.size())

		for t in others:
			_add_weight(t, per_other)
		for i in range(remainder):
			_add_weight(others[i % others.size()], 1)

	# Fallback
	if _weighted_tiles.is_empty():
		_weighted_tiles.append(preferred_a)


func _add_weight(tile: Vector2i, weight: int) -> void:
	for i in range(weight):
		_weighted_tiles.append(tile)


func _pick_tile() -> Vector2i:
	return _weighted_tiles[randi() % _weighted_tiles.size()]


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
					_last_tile_run = 1
					break
	else:
		_last_tile = t
		_last_tile_run = 1

	return t
