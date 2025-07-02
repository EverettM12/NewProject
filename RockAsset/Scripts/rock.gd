@tool
extends Node3D
class_name ReusableRock

@onready var sm_rocks_01: MeshInstance3D = $SM_Rocks_01
@onready var sm_rocks_02: MeshInstance3D = $SM_Rocks_02
@onready var sm_rocks_03: MeshInstance3D = $SM_Rocks_03
@onready var sm_rocks_04: MeshInstance3D = $SM_Rocks_04
@onready var sm_rocks_05: MeshInstance3D = $SM_Rocks_05
@onready var sm_rocks_06: MeshInstance3D = $SM_Rocks_06
@onready var sm_rocks_07: MeshInstance3D = $SM_Rocks_07
@onready var sm_rocks_08: MeshInstance3D = $SM_Rocks_08
@onready var sm_rocks_09: MeshInstance3D = $SM_Rocks_09
@onready var sm_rocks_10: MeshInstance3D = $SM_Rocks_10
@onready var sm_rocks_11: MeshInstance3D = $SM_Rocks_11

@export var rocks: Array[MeshInstance3D] = [] 

@export_range(1, 11, 1, "suffix: Rock") var chosen_rock_index: int = 1 

func _ready() -> void:
	_populate_rocks_array()
	_update_rock_visibility()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if rocks.is_empty() and sm_rocks_01 != null: 
			_populate_rocks_array()
		_update_rock_visibility()

func _populate_rocks_array() -> void:
	rocks.clear() 
	rocks.append(sm_rocks_01)
	rocks.append(sm_rocks_02)
	rocks.append(sm_rocks_03)
	rocks.append(sm_rocks_04)
	rocks.append(sm_rocks_05)
	rocks.append(sm_rocks_06)
	rocks.append(sm_rocks_07)
	rocks.append(sm_rocks_08)
	rocks.append(sm_rocks_09)
	rocks.append(sm_rocks_10)
	rocks.append(sm_rocks_11)

func _update_rock_visibility() -> void:
	for rock_instance in rocks:
		if rock_instance:
			rock_instance.visible = false


	var array_index: int = chosen_rock_index - 1


	if array_index >= 0 and array_index < rocks.size() and rocks[array_index]:
		rocks[array_index].visible = true
	else:
		if not rocks.is_empty() and rocks[0]:
			rocks[0].visible = true
