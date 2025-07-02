@tool
@icon("res://Player/Inventory/Textures/InventoryContainer.svg")
class_name InventoryContainer
extends GridContainer

@export var items: Items

@export var inventory: Inventory:
	set(value):
		inventory = value
		inventory.inventory_changed.connect(_on_inventory_changed)

@export var slot_scene: PackedScene

@export_range(1, 999) var slot_count: int = 16:
	set(value):
		slot_count = max(1, value)
		_on_inventory_changed()

func _enter_tree() -> void:
	_on_inventory_changed()

func _on_inventory_changed(_change: int = 0) -> void:
	if not slot_scene:
		push_error("No slot scene defined.")
		return

	if inventory == null:
		push_error("No inventory assigned.")
		return

	for slot in get_children():
		remove_child(slot)
		
	while inventory.items.size() < slot_count:
		inventory.items.append(null)

	for i in range(slot_count):
		var slot: InventorySlot = slot_scene.instantiate()
		slot.name = "Slot%d_%s" % [i, str(InventorySlot.new().get_instance_id())]
		add_child(slot, true)
		slot.owner = owner
		slot.slot_updated.connect(ResourceSaver.save.bind(inventory))

		var label = slot.get_node("Label")
		if label:
			label.text = str(i)

		if not Engine.is_editor_hint() and inventory.items[i]:
			inventory.items[i] = inventory.items[i].duplicate()

	ResourceSaver.save(inventory)

func _on_inventory_manager_add_item_to_slot(item: InventoryItem) -> void:
	if inventory == null:
		push_error("InventoryContainer: Inventory not assigned for adding item.")
		return

	if not is_instance_valid(item):
		push_error("InventoryContainer: Attempted to add an invalid item.")
		return

	inventory.add_item(item)

	_on_inventory_changed() 
	print("Item added (via InventoryContainer).")

	return


var _item : Items = null

func get_item() -> Items:
	return _item
