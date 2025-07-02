extends RigidBody3D
class_name Boat

@export var player: playercontroller
@export var Ui: Control
@export var front_seat: MeshInstance3D
@export var BoatCamera: Camera3D

@export var engine_force: float = 20.0
@export var turn_speed: float = 1.5
@export var water_drag: float = 0.5
@export var angular_drag: float = 0.8

@export var buoyancy_force: float = 10.0
@export var water_level_y: float = 0.0
var is_in_range: bool = false
var on_boat: bool = false
var Can_Control_Boat: bool

func _ready() -> void:
	player = get_parent().find_child("Player")

func _on_enter_boat_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		is_in_range = true
		Ui.visible = true

func _on_enter_boat_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		is_in_range = false
		Ui.visible = false

func _input(event: InputEvent) -> void:
	if is_in_range and event.is_action_pressed("Interact"):
		BoatCamera.target_node = self
		on_boat = true
		Ui.visible = false
		player.change_camera()
		BoatCamera.current = true
		Can_Control_Boat = true

	if event.is_action_pressed("Crouch") and on_boat == true:
		BoatCamera.target_node = player
		player.character_collision.disabled = false
		on_boat = false
		Ui.visible = false
		BoatCamera.current = false
		player.change_camera_back()
		Can_Control_Boat = false


@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if on_boat:
		player.character_collision.disabled = true
		var seat_pos := front_seat.global_position + Vector3(0, 1, 0)
		player.global_position = seat_pos
		player.velocity = Vector3.ZERO
		player.rotation = Vector3.ZERO
		


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if Can_Control_Boat == true:


		# ─── INPUT ─────────────────────────────────────────────
		var input_forward := Input.get_action_strength("Move_Forward") \
						   - Input.get_action_strength("Move_Back")
		var input_turn    := Input.get_action_strength("Move_Right")  \
						   - Input.get_action_strength("Move_Left")

		# ─── LINEAR THRUST ─────────────────────────────────────
		var forward_direction = global_transform.basis.x
		state.apply_central_force(forward_direction * input_forward * engine_force)

		# ─── TURNING ───────────────────────────────────────────
		state.apply_torque(Vector3.UP * input_turn * turn_speed)

		# ─── WATER DRAG ────────────────────────────────────────
		state.apply_central_force(-state.linear_velocity * water_drag * state.linear_velocity.length())
		state.apply_torque(-state.angular_velocity * angular_drag * state.angular_velocity.length())

		# ─── BUOYANCY ──────────────────────────────────────────
		if global_position.y < water_level_y:
			var depth = water_level_y - global_position.y
			var current_buoyancy = buoyancy_force * depth
			state.apply_central_force(Vector3.UP * current_buoyancy)

		# ─── SELF-RIGHTING (OPTIONAL) ──────────────────────────
		var current_up = global_transform.basis.y
		var desired_up = Vector3.UP
		var torque_direction = current_up.cross(desired_up)
		var torque_strength = 4.0

		apply_torque(torque_direction * torque_strength)

			#var max_speed = 10.0
			#if state.linear_velocity.length() > max_speed:
				#state.linear_velocity = state.linear_velocity.normalized() * max_speed

			#var max_angular_speed = 2.0
			#if state.angular_velocity.length() > max_angular_speed:
				#state.angular_velocity = state.angular_velocity.normalized() * max_angular_speed
