extends VehicleBody3D
class_name Car

## ─── EDITOR EXPOSED ─────────────────────────────────────────────
@export var player             : playercontroller
@export var Ui                 : Control          # “Press E to drive” prompt
@export var driver_seat        : Node3D           # Empty or Mesh at seat
@export var CarCamera          : Camera3D

@export var STEER_SPEED  : float = 1.5
@export var STEER_LIMIT  : float = 0.6
@export var engine_force_value : float = 40.0
## ----------------------------------------------------------------

var steer_target       : float = 0.0
var is_in_range        : bool  = false   # player standing next to door
var in_car             : bool  = false   # player currently driving
var can_control_car    : bool  = false   # physics input gate

func _ready() -> void:
	# Auto‑grab the player if not set
	if player == null:
		player = get_parent().find_child("Player")
	# Hide prompt at start
	if Ui: Ui.visible = false

# ───────────── AREA3D ENTER/EXIT ────────────────────────────────
func _on_enter_car_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		is_in_range = true
		if Ui: Ui.visible = true

func _on_enter_car_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		is_in_range = false
		if Ui: Ui.visible = false

# ───────────── INPUT (enter / exit) ─────────────────────────────
func _input(event: InputEvent) -> void:
	# Enter car
	if is_in_range and event.is_action_pressed("Interact"):
		CarCamera.target_node = self
		in_car = true
		can_control_car = true
		if Ui: Ui.visible = false
		player.change_camera()          # switch off player cam
		CarCamera.current = true

	# Exit car
	if event.is_action_pressed("Crouch") and in_car:
		CarCamera.target_node = player
		in_car = false
		can_control_car = false
		player.character_collision.disabled = false
		CarCamera.current = false
		player.change_camera_back()

# ───────────── NON‑PHYSICS – stick player to seat ──────────────
func _process(delta: float) -> void:
	if in_car:
		player.character_collision.disabled = true
		var seat_pos := driver_seat.global_position + Vector3(0, 2, 0)
		player.global_position = seat_pos
		player.velocity = Vector3.ZERO
		player.rotation = Vector3.ZERO

# ───────────── DRIVING PHYSICS ──────────────────────────────────
func _physics_process(delta: float) -> void:
	if not can_control_car:
		engine_force = 0
		brake = 0
		return

	var speed := linear_velocity.length() * Engine.get_frames_per_second() * delta
	_apply_traction_downforce(speed)

	# Steering
	steer_target = Input.get_action_strength("Move_Right") - \
				   Input.get_action_strength("Move_Left")
	steer_target *= STEER_LIMIT
	steering = move_toward(steering, steer_target, STEER_SPEED * delta)

	# Reverse
	if Input.is_action_pressed("Move_Back"):
		if speed < 20 and speed != 0:
			engine_force = clamp(engine_force_value * 3 / speed, 0, 300)
		else:
			engine_force = engine_force_value

	else:
		engine_force = 0

	# Forward
	if Input.is_action_pressed("Move_Forward"):
		if transform.basis.x.x >= -1:  # facing forward
			if speed < 30 and speed != 0:
				engine_force = -clamp(engine_force_value * 10 / speed, 0, 300)
			else:
				engine_force = -engine_force_value

		else:
			brake = 1
	else:
		brake = 0

	# Handbrake / drift
	if Input.is_action_pressed("Jump"):
		brake = 3
		$wheal2.wheel_friction_slip = 0.8
		$wheal3.wheel_friction_slip = 0.8
	else:
		$wheal2.wheel_friction_slip = 3
		$wheal3.wheel_friction_slip = 3

# ───────────── Helpers ─────────────────────────────────────────
func _apply_traction_downforce(speed: float) -> void:
	apply_central_force(Vector3.DOWN * speed)
