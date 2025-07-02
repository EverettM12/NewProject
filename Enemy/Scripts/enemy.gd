extends CharacterBody3D
class_name EnemyClass

signal player_hit

# --- EXPORTS & CONFIGURATION ---
@export var resource: EnemyResource
@export var enemy_camp: Patrolpath

@export var player_path: NodePath
@export var detection_area: Area3D
@export var disengage_timer: Timer
@export var disengage_timer_label: Label3D
@export var navigation_agent: NavigationAgent3D
@onready var collision_shape_3d_2: CollisionShape3D = $DamagePlayer/CollisionShape3D2

# --- INTERNAL STATE ---
var player: playercontroller = null
var current_patrol_index: int = 0
var is_chasing_player: bool = false
var internal_patrol_points: Array[Vector3] = []

var _assigned_move_speed: float = 0.0

# --- READY ---
func _ready() -> void:
	player = get_node(player_path)

	if enemy_camp:
		enemy_camp.patrol_points_ready.connect(_on_patrol_points_ready)
		$Label3D2.text = str("Assigned: ", enemy_camp.name)
	else:
		printerr(name, ": WARNING: No 'enemy_camp' (PatrolPath node) assigned! Enemy will not patrol.")

	collision_shape_3d_2.disabled = true


	if resource:
		var speed_options_from_resource: Array[float] = [
			resource.FAST_MOVE_SPEED,
			resource.REGULAR_MOVE_SPEED,
			resource.SLOW_MOVE_SPEED
		]

		var random_index: int = randi_range(0, speed_options_from_resource.size() - 1)

		_assigned_move_speed = speed_options_from_resource[random_index]
	else:
		_assigned_move_speed = 0.0

func _on_patrol_points_ready(points_data: Array[Vector3]) -> void:
	internal_patrol_points = points_data.duplicate()

	if internal_patrol_points.size() > 0:
		navigation_agent.target_position = internal_patrol_points[current_patrol_index]

# --- PHYSICS ---
func _physics_process(delta: float) -> void:
	disengage_timer_label.text = "Time Left: " + str("%.1f" % disengage_timer.time_left)

	# --- CHASE LOGIC ---
	if is_chasing_player and is_instance_valid(player) and player.health > 0:
		navigation_agent.target_position = player.global_transform.origin
	elif is_instance_valid(player) and player.health <= 0:
		is_chasing_player = false
		if internal_patrol_points.size() > 0:
			navigation_agent.target_position = internal_patrol_points[current_patrol_index]
		disengage_timer.stop()
	else:
		# --- PATROL LOGIC ---
		if internal_patrol_points.size() > 0:
			if navigation_agent.is_navigation_finished() or global_position.distance_to(navigation_agent.target_position) < resource.PATROL_REACHED_THRESHOLD:
				current_patrol_index = (current_patrol_index + 1) % internal_patrol_points.size()
				navigation_agent.target_position = internal_patrol_points[current_patrol_index]

	# --- MOVEMENT ---
	var next_point = navigation_agent.get_next_path_position()
	if next_point != Vector3.ZERO:
		var direction = (next_point - global_transform.origin).normalized()
		velocity = direction * _assigned_move_speed

		var flat_look_pos = Vector3(next_point.x, global_position.y, next_point.z)
		var distance_to_look_target_sq = global_position.distance_squared_to(flat_look_pos)


		if distance_to_look_target_sq > 0.01 * 0.01:
			var target_transform = global_transform.looking_at(flat_look_pos, Vector3.UP)
			var target_rotation_quat = target_transform.basis.get_rotation_quaternion()
			var turn_speed: float = 5.0
			var current_rotation_quat = global_transform.basis.get_rotation_quaternion()
			var new_rotation_quat = current_rotation_quat.slerp(target_rotation_quat, delta * turn_speed)
			global_transform.basis = Basis(new_rotation_quat)
	else:
		velocity = Vector3.ZERO

	if is_instance_valid(player) and player.health > 0 and global_position.distance_to(player.global_position) < resource.REGULAR_ATTACK_RANGE:
		attack()
	else:
		collision_shape_3d_2.disabled = true

	move_and_slide()

# --- DETECTION SIGNALS ---
func _on_player_detected(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller and player.health > 0:
		is_chasing_player = true
		disengage_timer.stop()

func _on_player_not_detected(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller and player.health > 0:
		disengage_timer.start()

func _on_disengage_timer_timeout() -> void:
	is_chasing_player = false
	disengage_timer.stop()
	if internal_patrol_points.size() > 0:
		navigation_agent.target_position = internal_patrol_points[current_patrol_index]

func _on_damage_player(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		player.player_is_hit()
		emit_signal("player_hit")

		if player.health <= 0:
			is_chasing_player = false
			if internal_patrol_points.size() > 0:
				navigation_agent.target_position = internal_patrol_points[current_patrol_index]
			await get_tree().create_timer(0.5).timeout
			player.player_died()

func _on_outer_detected(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller and body.velocity.length() >= 7.5 and player.health > 0:
		is_chasing_player = true
		disengage_timer.stop()

func attack():
	collision_shape_3d_2.disabled = false
