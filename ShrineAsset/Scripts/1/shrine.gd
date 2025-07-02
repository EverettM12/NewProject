extends Node3D
class_name Shrine1Script

# === EXPORTS ===
@export var player: playercontroller
@export var shrine: PackedScene
@onready var respawn_point: CSGBox3D = $RespawnPoint

@export var pedestal: Area3D
@export var moving_platform: Area3D
@export var camera: Camera3D

@export var DisplayText: Control

@export_group("Animation Players")
@export var door_anim: AnimationPlayer
@export var cam_anim: AnimationPlayer

@export_group("UI")
@export var pedestal_ui: Control
@export var platform_ui: Control

@export_group("Shrine Info")
@export var shrine_id: int = 0
@export var shrine_name: String
@export var shrine_sub_name: String

# === INTERNAL STATE ===
var can_interact: bool = true
var is_on_platform: bool = false
var entering_shrine: bool = false

# === READY ===
func _ready() -> void:
	
	SaveManager.load()
	
	if SaveManager.save_data.Shrine_1_opened == true:
		door_anim.play("Open")
	else:
		door_anim.play("Closed")

# === SHRINE TRANSITION ===
func ready_player_for_shrine():
	player.can_take_damage = false
	player.can_move = false
	player.position = moving_platform.global_position + Vector3(0, 1, 0)
	
	player.change_camera()
	camera.current = true
	cam_anim.play("Move Camera")
	await cam_anim.animation_finished
	
	player.can_take_damage = true
	player.can_move = true
	
	camera.current = false
	player.change_camera_back()
	
	#===============================================================================
	# Adds Shrine to scene
	var Shrine = shrine.instantiate()
	$"..".add_child(Shrine)
	$"..".is_in_shrine = true
	Shrine.transform.origin = Vector3(100, 100, 100)
	player.position = Shrine.csg_cylinder_3d.global_position + Vector3(0, 1, 0)
	#===============================================================================

	cam_anim.play("Move Camera Back")
	door_anim.play("RESET")

# === TRIGGER AREAS ===
	#===============================================================================
func _on_body_entered_pedestal(body: Node3D) -> void: # Pedestal
	if body.is_in_group("Player") and can_interact == true and SaveManager.save_data.Shrine_1_opened == false and body is playercontroller:
		pedestal_ui.visible = true

func _on_body_exited_pedestal(body: Node3D) -> void: # Pedestal
	if body.is_in_group("Player") and body is playercontroller:
		pedestal_ui.visible = false

	#===============================================================================
func _on_body_entered_platform(body: Node3D) -> void: # Platform
	if body.is_in_group("Player") and entering_shrine == false and body is playercontroller:
		platform_ui.visible = true
		is_on_platform = true

func _on_body_exited_platform(body: Node3D) -> void: # Platform
	if body.is_in_group("Player") and body is playercontroller:
		platform_ui.visible = false
		is_on_platform = false

	#===============================================================================

# === INPUT HANDLING ===
func _input(event: InputEvent) -> void:
	#===============================================================================
	if event.is_action_pressed("Interact") and pedestal_ui.visible == true and SaveManager.save_data.Shrine_1_opened == false: # Pedestal
		can_interact = false
		door_anim.play("Open_Door")
		shrine_has_opened()

	#===============================================================================
	if event.is_action_pressed("Interact") and is_on_platform == true: # Platform
		entering_shrine = true
		door_anim.play("Enter_Shrine") # Calls ready_player_for_shrine()
		platform_ui.visible = false
		await get_tree().create_timer(2).timeout
		entering_shrine = false
		
	#===============================================================================

# === SAVE CALLBACK ===
func shrine_has_opened():
	SaveManager.load()
	SaveManager.save_data.Shrine_1_opened = true
	SaveManager.save()

func _on_shrine_discovered(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		if DisplayText and DisplayText.label and SaveManager.save_data.Shrine_1_text_played == false:
			DisplayText.label.text = shrine_name
			DisplayText.sub_label.text = shrine_sub_name
			DisplayText.appear()
			
			SaveManager.load()
			SaveManager.save_data.Shrine_1_text_played = true
			SaveManager.save()
