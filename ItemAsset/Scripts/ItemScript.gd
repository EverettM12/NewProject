@tool
extends Node3D

@export var inventory_item: InventoryItem
@onready var mesh: MeshInstance3D = $MeshInstance3D

func update_item_visual() -> void:
	if inventory_item:
		mesh.mesh = inventory_item.mesh
