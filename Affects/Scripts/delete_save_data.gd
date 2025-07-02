extends Area3D
class_name DeletSaveData

signal ClearInventory

@export var player: playercontroller

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		delete_save()

func delete_save():
	SaveManager.load()
	
	SaveManager.save_data.last_saved_position = Vector3(0, 2, 0)
	SaveManager.save_data.last_saved_health = 3
	SaveManager.save_data.max_health = 3
	player.set_blank_hearts()
	
	emit_signal("ClearInventory")
	print("data cleared!")
	SaveManager.save()

func delete_inventory():
	emit_signal("ClearInventory")
