extends StaticBody3D

@export var rocking_amplitude : float = 5.0
@export var rocking_speed : float = 1.0
@export var position_amplitude : float = 0.05

var time_passed : float = 0.0

func _process(delta: float) -> void:
	global_position = $"../BoatScene".global_position
	time_passed += delta
	var pitch = deg_to_rad(rocking_amplitude) * sin(time_passed * rocking_speed * TAU)
	var roll = deg_to_rad(rocking_amplitude / 2.0) * sin((time_passed + 1.0) * rocking_speed * TAU)

	var current_rotation = rotation
	rotation = Vector3(pitch, current_rotation.y, roll)

	rotation = Vector3(pitch, rotation.y, roll)

	var sway_x = position_amplitude * sin(time_passed * rocking_speed * TAU * 0.5)
	var sway_z = position_amplitude * sin((time_passed + 0.5) * rocking_speed * TAU * 0.5)
	position.x = sway_x
	position.z = sway_z
