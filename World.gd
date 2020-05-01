extends Node2D

enum Tiles { WALL, GROUND }

export (int)      var iterations := 20
export (Vector2)  var size       := Vector2(60, 40)

export (int)    var death_limit           := 3
export (int)    var born_limit            := 4
export (float)  var chance_to_start_alive := 0.45

onready var _tilemap : TileMap = $TileMap
onready var _label   : Label   = $Progress


var _running := false


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _on_Button_pressed() -> void:
	if not _running:
		_running = true
		_tilemap.clear()
		yield(_generate_map(), "completed")
		_running = false


func _new_map() -> Array:
	var map := []
	map.resize(int(size.x))
	for x in size.x:
		map[x] = []
		map[x].resize(int(size.y))
	return map


func _copy_map(from : Array, to : Array) -> void:
	for x in from.size():
		for y in from[x].size():
			to[x][y] = from[x][y]


func _count_alive_neighborurs(map : Array, x : int, y : int) -> int:
	var count := 0

	for i in range(-1, 2):
		for j in range(-1, 2):
			var nx := x+i
			var ny := y+j

			if i == 0 and j == 0:
				continue

			if nx < 0 or ny < 0 or nx >= size.x or ny >= size.y:
				count += 1
			elif map[nx][ny] == true:
				count += 1

	return count


func _simulate_step(oldmap : Array, newmap : Array) -> Array:
	for x in oldmap.size():
		for y in oldmap[x].size():
			var neighbours := _count_alive_neighborurs(oldmap, x, y)

			if oldmap[x][y] == true:
				if neighbours < death_limit:
					newmap[x][y] = false
				else:
					newmap[x][y] = true
			else:
				if neighbours > born_limit:
					newmap[x][y] = true
				else:
					newmap[x][y] = false

	return [oldmap, newmap]


func _initialize(map : Array):
	for x in map.size():
		for y in map[x].size():
			map[x][y] = randf() < chance_to_start_alive


func _generate_map():
	var map := _new_map()
	var tmp := _new_map()
	
	_initialize(map)
	_copy_map(map, tmp)

	for i in iterations:
		var r = _simulate_step(map, tmp)
		map = r[0]
		tmp = r[1]
		_copy_map(tmp, map)
		_draw_map(map)
		_label.text = str(i+1) + "/" + str(iterations)
		yield(get_tree().create_timer(0.1), "timeout")


func _draw_map(map : Array):
	for x in map.size():
		for y in map[x].size():
			_tilemap.set_cell(x, y, Tiles.GROUND if map[x][y] else Tiles.WALL)


func _on_death_limit_value_changed(value: float) -> void:
	$death_limit_label.text = "death_limit: " + str(int(value))
	death_limit = value


func _on_born_limit_value_changed(value: float) -> void:
	$born_limit_label.text = "born_limit: " + str(int(value))
	born_limit = value


func _on_initial_probability_value_changed(value: float) -> void:
	$initial_probability_label.text = "initial_probability: " + str(value)
	chance_to_start_alive = value


func _on_iterations_value_changed(value: float) -> void:
	$iterations_label.text = "iterations: " + str(int(value))
	iterations = value
