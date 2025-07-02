extends Area3D
class_name IncreaseMaxHearts

@export var player: playercontroller

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		SaveManager.load()
		if SaveManager.save_data.max_health != 30:
			SaveManager.save_data.max_health += 1
			player.health = SaveManager.save_data.max_health
		
		SaveManager.save()
		player.set_blank_hearts()
