extends Node3D

@export var Master_Sword: InventoryItem

@export var Sword_Display: Node3D

@export var player: playercontroller

func _ready() -> void:
	Sword_Display.mesh.mesh = Master_Sword.mesh
	Sword_Display.mesh.material_override = Master_Sword.in_game_texture

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") \
	and SaveManager.save_data.max_health >= 13 \
	and not SaveManager.save_data.Master_Sword_Has_Been_Picked_Up:

		const HEARTS_TO_REMOVE := 12
		var old_health := player._health
		var new_health : int = max(old_health - HEARTS_TO_REMOVE, 1)
		var delta : int = new_health - old_health

		player._health = new_health
		if player.health_scene:
			player.health_scene.update_health(new_health, delta)

		%InventoryManager.player_inventory.inventory.add_item(Master_Sword)
		SaveManager.save_data.Master_Sword_Has_Been_Picked_Up = true
		SaveManager.save()
		%InventoryManager.rebuild_slots()

	else:
		print(
			"Not enough Hearts. Need: 13. Current: ",
			SaveManager.save_data.max_health,
			" | Missing: ",
			13 - SaveManager.save_data.max_health
		)
