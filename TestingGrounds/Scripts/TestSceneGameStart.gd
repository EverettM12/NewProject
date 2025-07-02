extends Node3D

@export var player : playercontroller

@export var inventory_manager: Control

@export var delete_save: Area3D

@export var ball: RigidBody3D

@export var viewport: SubViewport
@export var viewport_camera: Camera3D

@export var save_interval = 15

var is_in_shrine: bool = false

var time_accumulator = 0.0

@export var UI: Control
@export var Can_save_ui: MarginContainer
@export var Saving_ui: MarginContainer

@export var static_boat: StaticBody3D
@export var player_boat: Boat

@export_group("Player Data")
@export var starting_position: Vector3


func _ready():
	Saving_ui.visible = false
	Can_save_ui.visible = not is_in_shrine
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func init_from_menu(mode: String):
	if mode == "loaded":
		# Player Data
		player.position = SaveManager.save_data.last_saved_position
		player.health = SaveManager.save_data.last_saved_health
		player.set_blank_hearts()
		# Ball Data
		if ball:
			ball.position = SaveManager.save_data.last_saved_ball_position
	
	elif mode == "new":
		if player:
			# Player Data
			player.position = starting_position
			player.health = 3
			SaveManager.save_data.max_health = 3
			player.set_blank_hearts()
			delete_save.delete_inventory()
			
			# Ball Data
			if ball:
				ball.position = Vector3(-3.615, 1, 1.264)

func _process(delta: float) -> void:
	save_data(delta)
	shrine_detection()
	if player:
		SaveManager.save_data.last_saved_health = player.health
	%Label.text = str("Frames: ", Engine.get_frames_per_second())

func take_screenshot():
	viewport_camera.global_transform.origin = player.global_transform.origin + -player.global_transform.basis.z.normalized() * 2.0
	viewport_camera.current = true
	await RenderingServer.frame_post_draw
	var img: Image = viewport.get_texture().get_image()
	img.save_png("user://screenshot.png")
	viewport_camera.current = false

func display_save_text():
	get_tree().create_tween().tween_property(Saving_ui, "modulate:a", 1.0, 2.0)
	await get_tree().create_timer(3).timeout
	get_tree().create_tween().tween_property(Saving_ui, "modulate:a", 0.0, 2.0)

func shrine_detection():
	Can_save_ui.visible = not is_in_shrine

func save_data(delta):
	if player and player.health > 0 and is_in_shrine == false and player.is_on_floor():
		time_accumulator += delta
		if time_accumulator >= save_interval:
			
			time_accumulator = 0
			
			save_player_state()
			take_screenshot()
			display_save_text()

func save_player_state():
	if player.health > 0:
		SaveManager.save_data.last_saved_position = player.position
		SaveManager.save_data.last_saved_health = player.health
		
	if ball:
		SaveManager.save_data.last_saved_ball_position = ball.position
	
	SaveManager.save()

func _on_player_player_died() -> void:
	if inventory_manager and inventory_manager.is_node_ready():
		inventory_manager.visible = false
