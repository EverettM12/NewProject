extends Control

@onready var row_1: HBoxContainer = $Row_1/HBoxContainer
@onready var row_2: HBoxContainer = $Row_2/HBoxContainer
@onready var row_3: HBoxContainer = $Row_3/HBoxContainer

@export var heart_scene = preload("res://Player/Health/Scenes/heart.tscn")

func setup(value: int) -> void:
	_clear_hearts()
	for i in range(value):
		var heart = heart_scene.instantiate()
		
		if i < 10:
			row_1.add_child(heart)
		elif i < 20:
			row_2.add_child(heart)
		else:
			row_3.add_child(heart)
		
		heart.change_alpha(1.0)
		await get_tree().create_timer(0.05).timeout


func update_health(value: int, direction: int) -> void:
	_clear_hearts()

	for i in range(value):
		var heart = heart_scene.instantiate()
		if i < 10:
			row_1.add_child(heart)
		elif i < 20:
			row_2.add_child(heart)
		else:
			row_3.add_child(heart)

	if direction < 0:
		var extra_heart = heart_scene.instantiate()
		if value < 10:
			row_1.add_child(extra_heart)
		elif value < 20:
			row_2.add_child(extra_heart)
		else:
			row_3.add_child(extra_heart)
		extra_heart.change_alpha(0.0)

func _clear_hearts() -> void:
	for container in [row_1, row_2, row_3]:
		for child in container.get_children():
			child.queue_free()
