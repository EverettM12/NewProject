extends Area3D
class_name HealPlayer

@export var player: playercontroller

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		player.player_is_healed()
