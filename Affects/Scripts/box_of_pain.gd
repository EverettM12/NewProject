extends Area3D
class_name DamagePlayer

signal player_hit

@export var player: playercontroller


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		player.player_is_hit()
		emit_signal("player_hit")
		if player.health <= 0:
			emit_signal("player_hit")
			await get_tree().create_timer(0.5).timeout
			player.player_died()
