extends MarginContainer
class_name ItemBox

var item_data: ItemData
var is_selected: bool = false

func set_item_data(data: ItemData) -> void:
	item_data = data
	$HBoxContainer/Label.text = data.name
	$HBoxContainer/MarginContainer/Label2.text = str(data.cost)
	$HBoxContainer/TextureRect.texture = data.texture

func set_selected(selected: bool) -> void:
	is_selected = selected
	$HBoxContainer/Button.modulate = Color(1, 0.2, 0.2) if selected else Color(1, 1, 1)

func print_name():
	print(item_data.name)

func check_price() -> int:
	return item_data.cost

func add_to_inventory():
	var inventory_manager = get_tree().get_first_node_in_group("Inventory")
	if inventory_manager and inventory_manager.player_inventory:
		var inv = inventory_manager.player_inventory.inventory
		if inv and inv.add_item(item_data.item_given_on_purchase) == OK:
			inventory_manager.rebuild_slots()
			print("Item added to inventory.")
		else:
			print("Failed to add item to inventory.")
	else:
		print("Inventory manager or player_inventory not found.")
