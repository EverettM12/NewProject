extends Node3D
class_name Patrolpath

@export var patrol_points_data: Array[Vector3] = []

signal patrol_points_ready(points_data: Array[Vector3])

func _ready() -> void:
	patrol_points_data.clear()

	for child in get_children():
		if child is CSGBox3D:
			patrol_points_data.append(child.global_position)

	patrol_points_ready.emit(patrol_points_data)

	for child in get_children():
		if child is CSGBox3D:
			child.visible = false
			child.queue_free()
