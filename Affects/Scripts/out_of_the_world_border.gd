extends Area3D

@export var player: playercontroller


func _ready() -> void:
	player = get_parent().get_parent().find_child("Player")

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		player.fell_out_of_world()
