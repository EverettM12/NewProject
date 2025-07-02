extends Marker3D
class_name Floater

@export var water: Node3D
@export var float_force := 15.0
@export var drag := 2.0
@export var angular_drag := 1.0

@onready var rb: RigidBody3D = _find_parent_rigidbody()

#func _ready() -> void:
	#water = get_parent().get_parent().find_child("Map/Water")

func _find_parent_rigidbody() -> RigidBody3D:
	var n := get_parent()
	while n:
		if n is RigidBody3D:
			return n
		n = n.get_parent()
	push_error("Floater: couldn’t locate a StaticBody3D in its parents.")
	return null

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if rb == null or water == null:
		return

	var pos := global_transform.origin
	var water_y = water.get_height_at(pos.x, pos.z)
	var depth = water_y - pos.y        # >0 = submerged

	if depth > 0.0:
		# Up-buoyancy
		var force = Vector3.UP * float_force * depth
		rb.apply_force(force, pos - rb.global_transform.origin)

		# Linear & angular drag
		rb.apply_central_force(-rb.linear_velocity * drag)
		rb.apply_torque(-rb.angular_velocity * angular_drag)
