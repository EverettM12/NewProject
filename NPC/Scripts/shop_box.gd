extends Control
class_name ShopBox

@onready var item_holder = $MarginContainer/MainContent/Main/ScrollContainer/ItemHolder
var selected_index: int = 0

func _ready():
	_update_selection()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Move_inventory_selected_down"):
		selected_index = min(selected_index + 1, item_holder.get_child_count() - 1)
		_update_selection()
	elif event.is_action_pressed("Move_inventory_selected_up"):
		selected_index = max(selected_index - 1, 0)
		_update_selection()

	if event.is_action_pressed("Interact") and selected_index != null:
		var item = item_holder.get_child(selected_index)
		if item and item.has_method("print_name"):
			if get_tree().get_first_node_in_group("Player").amount_of_scraps >= item.check_price():
				item.print_name()
				item.add_to_inventory()
			else:
				print("Not enough scraps.")



func _update_selection():
	for i in range(item_holder.get_child_count()):
		var item = item_holder.get_child(i)
		if item.has_method("set_selected"):
			item.set_selected(i == selected_index)
