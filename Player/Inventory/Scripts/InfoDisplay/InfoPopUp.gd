@icon("res://Player/Inventory/Textures/InventoryInformation.svg")
extends InventoryInfo

@export var Name: Label
@export var Desc: Label

func on_info_changed() -> void:
	Name.text = hovered_item.name
	Desc.text = hovered_item.description
