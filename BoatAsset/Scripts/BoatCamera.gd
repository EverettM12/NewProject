extends Camera3D
class_name Follow_Camera

@export var target_node_path       : NodePath
@export var follow_speed           : float   = 5.0
@export var mouse_sensitivity      : float   = 0.007
@export var zoom_min               : float   = 4.0
@export var zoom_max               : float   = 12.0
@export var default_zoom           : float   = 6.0
@export var pitch_limit_up         : float   = 60.0
@export var pitch_limit_down       : float   = -30.0
@export var idle_time              : float   = 2.0
@export var recenter_speed         : float   = 180.0
@export var controller_sensitivity : float   = 100
@export var controller_deadzone    : float   = 0.1


var smoothed_target_pos     : Vector3
var camera_collision_margin : float = 0.2
var target_node             : Node3D
var yaw                     : float = 0.0
var pitch                   : float = 0.0
var zoom                    : float
var idle_timer              : float = 0.0

func _ready() -> void:
	set_as_top_level(true)
	zoom = default_zoom

	if target_node_path:
		target_node = get_node(target_node_path)
		if not target_node:
			push_error("Target not found at path: ", target_node_path)
	else:
		push_error("target_node_path is not set!")

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	smoothed_target_pos = target_node.global_position

# ----------------------- INPUT ----------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var sx = event.relative.x * mouse_sensitivity
		var sy = event.relative.y * mouse_sensitivity
		yaw -= sx
		pitch += sy
		pitch = clamp(pitch, deg_to_rad(pitch_limit_down), deg_to_rad(pitch_limit_up))
		idle_timer = 0.0

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = max(zoom - 0.5, zoom_min)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = min(zoom + 0.5, zoom_max)

func handle_controller_look(delta: float) -> void:
	var joy_x := Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var joy_y := Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)

	if abs(joy_x) < controller_deadzone:
		joy_x = 0.0
	if abs(joy_y) < controller_deadzone:
		joy_y = 0.0

	if joy_x == 0.0 and joy_y == 0.0:
		return

	var speed_rad := deg_to_rad(controller_sensitivity) * delta
	yaw   -= joy_x * speed_rad
	pitch += joy_y * speed_rad
	pitch = clamp(pitch, deg_to_rad(pitch_limit_down), deg_to_rad(pitch_limit_up))
	idle_timer = 0.0

# ----------------------- MAIN LOOP ------------------------------------------
func _physics_process(delta: float) -> void:
	handle_controller_look(delta)

	if not target_node:
		print("No target node! ", target_node)
		return

	idle_timer += delta
	if idle_timer >= idle_time:
		_recenter(delta)

	smoothed_target_pos = smoothed_target_pos.lerp(target_node.global_position, follow_speed * delta)
	
	var offset := Vector3(
		zoom * cos(pitch) * sin(yaw),
		zoom * sin(pitch),
		zoom * cos(pitch) * cos(yaw)
	)
	var desired_camera_pos = smoothed_target_pos + offset
	var final_camera_pos = get_non_clipping_camera_pos(smoothed_target_pos, desired_camera_pos)
	
	global_position = global_position.lerp(final_camera_pos, follow_speed * delta)
	look_at(smoothed_target_pos, Vector3.UP)

func get_non_clipping_camera_pos(origin: Vector3, target: Vector3) -> Vector3:
	var space_state := get_world_3d().direct_space_state

	var query := PhysicsRayQueryParameters3D.create(origin, target)
	query.exclude = [self, target_node]
	query.collision_mask = 0xFFFFFFFF

	var result := space_state.intersect_ray(query)
	if result:
		return result.position + result.normal * camera_collision_margin
	else:
		return target

# ----------------------- RECENTERING ----------------------------------------
func _recenter(delta: float) -> void:
	var target_vec: Vector3 = target_node.global_transform.basis.z
	var target_yaw: float = atan2(target_vec.x, target_vec.z)
	var step: float = deg_to_rad(recenter_speed) * delta
	var diff: float = wrapf(target_yaw - yaw, -PI, PI)

	if abs(diff) <= step:
		yaw = target_yaw
	else:
		yaw += step * sign(diff)
