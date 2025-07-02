extends Node3D
class_name Door

signal check_player_key
signal check_player_key_Back

@export var needs_key: bool = false

@export var player: playercontroller

@export_group("Children")

@export var Ui: Control
@export var label: Label

@export var animplayer: AnimationPlayer

@export var starting_point: CSGBox3D

@export var ending_point: CSGBox3D

var can_open_door: bool = false
var can_open_door_from_back :bool = false

func _on_body_entered_door(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		Ui.visible = true
		can_open_door = true

func _on_body_exited_door(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		Ui.visible = false
		can_open_door = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact") and can_open_door == true:
		if needs_key == true:
			emit_signal("check_player_key")
	
		elif needs_key == false:
			animplayer.play("Open_Door")

	if event.is_action_pressed("Interact") and can_open_door_from_back == true:
		if needs_key == true:
			emit_signal("check_player_key_Back")
	
		elif needs_key == false:
			animplayer.play("Open_Door_Back")

func move_player():
	var target_pos_start = starting_point.global_position
	var tween1 = get_tree().create_tween()
	tween1.tween_property(player, "global_position", target_pos_start, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(0.1).timeout
	
	var target_pos = ending_point.global_position
	var tween2 = get_tree().create_tween()
	tween2.tween_property(player, "global_position", target_pos, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func move_player_back():
	var target_pos_start = ending_point.global_position
	var tween1 = get_tree().create_tween()
	tween1.tween_property(player, "global_position", target_pos_start, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(0.1).timeout
	
	var target_pos = starting_point.global_position
	var tween2 = get_tree().create_tween()
	tween2.tween_property(player, "global_position", target_pos, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_inventorymanager_key_found() -> void:
	animplayer.play("Open_Door")

func _on_inventorymanager_key_found_back() -> void:
	animplayer.play("Open_Door_Back")


func _on_inventorymanager_no_key_found() -> void:
	label.text = "No key found"
	await get_tree().create_timer(1).timeout
	label.text = "(E)"

func _on_other_door_side_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		Ui.visible = true
		can_open_door_from_back = true


func _on_other_door_side_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		Ui.visible = false
		can_open_door_from_back = false
