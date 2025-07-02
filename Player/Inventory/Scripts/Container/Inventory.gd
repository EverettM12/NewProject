## Basic [Inventory] resource.
@tool
@icon("res://Player/Inventory/Textures/Inventory.svg")
class_name Inventory
extends Resource

## Emited after most altering functions
signal inventory_changed(change_id: Changes)

## Types of changes for [signal inventory_changed] [br]
## Most are very self-explanatory.
enum Changes {
	## Used when inventory enters tree
	GENERAL_UPDATE,
	ITEM_ADDED,
	ITEM_REMOVED,
	ITEM_MOVED,
	SIZE_CHANGED,
}

## Manually changing [member items] size automatically adds [InventorySlot]s to the scene tree.
@export var items: Array[InventoryItem] = []:
	set(value):
		if value.size() != items.size():
			items = value
			inventory_changed.emit(Changes.SIZE_CHANGED)
		else:
			items = value

var _item_counts: Dictionary = {}

func _init():
	_rebuild_item_counts()

func _rebuild_item_counts() -> void:
	_item_counts.clear()
	for item in items:
		if item and is_instance_valid(item):
			_item_counts[item.item_name] = _item_counts.get(item.item_name, 0) + 1

## Stores an [InventoryItem] in the first empty slot.
func add_item(item: InventoryItem) -> Error:
	if not is_instance_valid(item):
		push_error("Attempted to add an invalid item.")
		return FAILED
	if is_full():
		return FAILED
	return add_item_to(item, get_first_empty())


## Stores an [InventoryItem] at the specified index.
func add_item_to(item: InventoryItem, index: int) -> Error:
	if not is_instance_valid(item):
		push_error("Attempted to add invalid item to slot %d." % index)
		return FAILED
	if index < 0 or index >= items.size():
		push_error("Invalid index %d for adding item." % index)
		return FAILED
	if not is_slot_empty(index):
		return FAILED

	items[index] = item

	_item_counts[item.name] = _item_counts.get(item.name, 0) + 1

	inventory_changed.emit(Changes.ITEM_ADDED)
	return OK


## Returns an [InventoryItem] at the specified index.
func get_item_by_index(index: int) -> InventoryItem:
	if index < 0 or index >= items.size():
		push_error("Invalid Inventory Index %s." % index)
		return null
	if not is_slot_empty(index):
		return items[index]
	else:
		return null

## Moves an [InventoryItem] from one position to another.
## Automatically swaps [InventoryItem]s if both 'from' and 'to' indexes have an [InventoryItem].
## Returns [constant FAILED] if items couldn't be moved and [constant OK] otherwise.
func move_from_to(from: int, to: int) -> Error:
	if from < 0 or from >= items.size() or to < 0 or to >= items.size():
		push_error("Invalid 'from' or 'to' index in move_from_to.")
		return FAILED

	var from_item = items[from]
	var to_item = items[to]

	if not is_instance_valid(from_item):
		return FAILED

	if not is_slot_empty(to):
		if not is_instance_valid(to_item):
			push_error("Invalid item in target slot %d during move_from_to." % to)
			return FAILED
		items[to] = from_item
		items[from] = to_item
	else:
		items[to] = from_item
		items[from] = null

	if not is_instance_valid(to_item):
		_item_counts[from_item.item_name] = _item_counts.get(from_item.item_name, 0)

	inventory_changed.emit(Changes.ITEM_MOVED)
	return OK

## Removes an [InventoryItem] from the inventory at the specified index.
## Returns [constant FAILED] if item isn't found and [constant OK] otherwise.
func remove_by_index(index: int) -> Error:
	if index < 0 or index >= items.size():
		push_error("Invalid index %d for removing item." % index)
		return FAILED
	if is_slot_empty(index):
		return FAILED

	var removed_item = items[index]
	items[index] = null

	if is_instance_valid(removed_item):
		_item_counts[removed_item.item_name] = max(0, _item_counts.get(removed_item.item_name, 1) - 1)
		if _item_counts[removed_item.item_name] == 0:
			_item_counts.erase(removed_item.item_name)
	else:
		push_warning("Removed invalid item at index %d. _item_counts may be inaccurate." % index)

	inventory_changed.emit(Changes.ITEM_REMOVED)
	return OK

## Returns [code]true[/code] if inventory is full.
func is_full() -> bool:
	return get_first_empty() == -1

## Returns the first empty slot index. [br]
## If [code]from[/code] is invalid or inventory is full, returns [code]-1[/code]
func get_first_empty(from: int = 0) -> int:
	if from < 0 or from >= items.size():
		return -1

	for i in range(from, items.size()):
		if not is_instance_valid(items[i]): return i

	return -1

## Returns [code]true[/code] if there is no [InventoryItem] at index.
func is_slot_empty(index: int) -> bool:
	if index < 0 or index >= items.size():
		push_error("is_slot_empty: Index %d out of bounds." % index)
		return true
	return not is_instance_valid(items[index])

## Returns [code]true[/code] if has specified [InventoryItem] (by object reference).
func has_item(item: InventoryItem) -> bool:
	if not is_instance_valid(item):
		return false
	return items.has(item)

## Returns [code]true[/code] if the inventory contains the specified item name and quantity.
func has_item_with_name_and_quantity(item_name: String, quantity: int) -> bool:
	var current_count = _item_counts.get(item_name, 0)
	return current_count >= quantity

func save_inventory() -> Array:
	var data: Array = []
	for item in items:
		if is_instance_valid(item):
			data.append(item.to_dict())
		else:
			data.append(null)
	return data

func load_inventory(data: Array) -> void:
	items.clear()
	for entry in data:
		if entry != null:
			var item = InventoryItem.new()
			item.from_dict(entry)
			items.append(item)
		else:
			items.append(null)
	_rebuild_item_counts()
	inventory_changed.emit(Changes.GENERAL_UPDATE)

func resize_inventory(new_size: int) -> void:
	if new_size < 0:
		push_error("resize_inventory(): new_size cannot be negative.")
		return

	var current_size = items.size()

	if new_size == current_size:
		return

	elif new_size > current_size:
		for i in range(new_size - current_size):
			items.append(null)

	else:
		for i in range(new_size, current_size):
			var removed_item = items[i]
			if is_instance_valid(removed_item):
				_item_counts[removed_item.item_name] = max(0, _item_counts.get(removed_item.item_name, 1) - 1)
				if _item_counts[removed_item.item_name] == 0:
					_item_counts.erase(removed_item.item_name)
		items.resize(new_size)

	inventory_changed.emit(Changes.SIZE_CHANGED)

func delete_inventory() -> void:
	for i in range(items.size()):
		items[i] = null
	_item_counts.clear()
	inventory_changed.emit(Changes.GENERAL_UPDATE)
	print("Inventory Cleared!")

## Attempts to remove a specific quantity of an item by name.
## Returns true if successful, false otherwise (e.g., not enough items).
func remove_item_by_name(item_name: String, quantity_to_remove: int) -> bool:
	if not has_item_with_name_and_quantity(item_name, quantity_to_remove):
		push_warning("Inventory: Not enough '%s' to remove %d." % [item_name, quantity_to_remove])
		return false

	var removed_count = 0
	for i in range(items.size() - 1, -1, -1):
		var item_in_slot = items[i]
		if is_instance_valid(item_in_slot) and item_in_slot.name == item_name:
			items[i] = null
			removed_count += 1
			_item_counts[item_name] = max(0, _item_counts.get(item_name, 1) - 1)
			if _item_counts[item_name] == 0:
				_item_counts.erase(item_name)

			if removed_count >= quantity_to_remove:
				inventory_changed.emit(Changes.ITEM_REMOVED)
				return true

	push_error("Inventory: Inconsistency detected when removing '%s'. Items in _item_counts but not in slots." % item_name)
	inventory_changed.emit(Changes.ITEM_REMOVED)
	return false
