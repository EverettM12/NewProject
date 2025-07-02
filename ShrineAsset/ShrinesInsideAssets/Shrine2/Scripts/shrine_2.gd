extends Node3D
class_name Shrine2ScriptInside

@export var Shrine: String = "Shrine 2"

@export var return_shrine_name: String = "Shrine2"

@onready var csg_cylinder_3d: CSGCylinder3D = $CSGCylinder3D
var return_shrine

@onready var animplayer: AnimationPlayer = $AnimationPlayer

func _enter_tree() -> void:
	return_shrine = "$" + return_shrine_name

func _on_area_3d_body_entered(_body: Node3D) -> void:
	var shrine_node := get_node_or_null("../" + return_shrine_name)
	if shrine_node and shrine_node is Node3D:
		animplayer.play("Fade")
		await animplayer.animation_finished
		animplayer.play("UnFade")
		get_parent().is_in_shrine = false
		get_parent().player.position = shrine_node.respawn_point.global_position
		queue_free()
	else:
		push_error("Could not find shrine node: " + return_shrine_name)
