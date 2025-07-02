extends RigidBody3D
class_name Buoyancy

@export var water: Node3D
@export var float_force: float
@export var water_drag: float = 2.0
@export var water_angular_drag: float = 1.0
@export var water_offset: float
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	float_force = randi_range(1, 3)

func _physics_process(delta: float) -> void:
	var water_height = water.global_position.y + water_offset
	var depth = water_height - global_position.y

	if depth > 0.0:
		apply_central_force(Vector3.UP * float_force * gravity * depth)


		linear_velocity -= linear_velocity * water_drag * delta
		angular_velocity -= angular_velocity * water_angular_drag * delta
	
	var current_up = global_transform.basis.y
	var desired_up = Vector3.UP
	var torque_direction = current_up.cross(desired_up)
	var torque_strength = 4.0

	apply_torque(torque_direction * torque_strength)
