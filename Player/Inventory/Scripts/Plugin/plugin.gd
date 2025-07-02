@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type("Inventory", "Resource", preload("res://Player/Inventory/Scripts/Container/Inventory.gd"), preload("res://Player/Inventory/Textures/Inventory.svg"))
	add_custom_type("InventoryContainer", "GridContainer", preload("res://Player/Inventory/Scripts/Container/InventoryContainer.gd"), preload("res://Player/Inventory/Textures/InventoryContainer.svg"))
	add_custom_type("InventoryItem", "Resource", preload("res://Assets/ItemAsset/Scripts/InventoryItem.gd"), preload("res://Player/Inventory/Textures/InventoryItem.svg"))
	add_custom_type("InventorySlot", "TextureRect", preload("res://Player/Inventory/Scripts/Slot/InventorySlot.gd"), preload("res://Player/Inventory/Textures/InventorySlot.svg"))
	add_custom_type("InventoryInfo", "Control", preload("res://Player/Inventory/Scripts/Info/InventoryInfo.gd"), preload("res://Player/Inventory/Textures/InventoryInfo.svg"))

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("Inventory")
	remove_custom_type("InventoryContainer")
	remove_custom_type("InventoryItem")
	remove_custom_type("InventorySlot")
	remove_custom_type("InventoryInfo")
