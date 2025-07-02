extends Control
class_name InventoryManager

enum InputMode { MOUSE, CONTROLLER }
var input_mode: InputMode = InputMode.CONTROLLER

# ================================
# Signals
# ================================
signal Add_Item_to_slot(Item)
signal Stop_mouse
signal continue_mouse
signal key_found
signal key_found_back
signal no_key_found
signal In_inventory
signal Not_in_inventory

# ================================
# Exports
# ================================
@export var player: playercontroller

@export_group("Inventory")
@export var player_inventory: InventoryContainer
@export var player_inventory_container: Control

@export var Name: Label
@export var Desc: Label
@export var Selector: TextureRect
@export var MoreOptions: VBoxContainer
@export var MoreOptionsBackGround: Panel

@export var slots_per_row: int = 4

@export_group("Quit")
@export var quit_check: Control
@export var quit_yes_label: Button
@export var quit_no_label: Button

@export_group("Quests")
@export var quest_container: VBoxContainer
@export var quest_scene: PackedScene

# ================================
# State Variables
# ================================
var inventory_is_toggled: bool = false
var is_chest_open: bool = false
var inventory_was_toggled_before_chest: bool = false
var quit_is_toggled: bool = false
#					   0       1       3
var menu_options = ["Equip", "Drop", "Back"]
var current_index = 0

var slots: Array = []
var selected_index: int = 0

var use_mouse_control: bool = true
var last_mouse_pos: Vector2 = Vector2.ZERO
var last_selected_slot = null

var quit_menu_index := 0

enum Page { QUESTS, INVENTORY, SETTINGS }

var current_page := Page.INVENTORY
var PAGE_NODES: Dictionary

# ================================
# Heart Display
# ================================
@onready var row_containers: Array = [
%"Row 1",
%"Row 2",
%"Row 3"
]

var hearts: Array = []

# ================================
# Lifecycle
# ================================
func _ready():
	if player_inventory:
		slots = player_inventory.get_children()
		rebuild_slots()

	update_menu_highlight()
	
	#if SaveManager.save_data.game_mode == true:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	Engine.time_scale = 1.0
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if player_inventory_container:
		player_inventory_container.visible = false

	if player_inventory and player_inventory.has_method("_on_inventory_manager_add_item_to_slot"):
		connect("Add_Item_to_slot", Callable(player_inventory, "_on_inventory_manager_add_item_to_slot"))
	else:
		push_warning("Player InventoryContainer not found or missing '_on_inventory_manager_add_item_to_slot' method for signal connection.")

	update_hearts_in_inventory()
	
	PAGE_NODES = {
			Page.SETTINGS:  $Settings,
			Page.INVENTORY: $Inventory,
			Page.QUESTS:    $Quests,
		}


# ================================
# Input Handling
# ================================
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Open_Inventory") and not is_chest_open:
		inventory_is_toggled = !inventory_is_toggled
		player_inventory_container.visible = inventory_is_toggled
		Selector.visible = inventory_is_toggled

		if inventory_is_toggled:
			emit_signal("Stop_mouse")
			emit_signal("In_inventory")
			on_inventory_opened()
		else:
			emit_signal("continue_mouse")
			emit_signal("Not_in_inventory")
			on_inventory_closed() 
			
		#if SaveManager.save_data.game_mode == true:
		if inventory_is_toggled:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
		#Engine.time_scale = 0.0 if inventory_is_toggled else 1.0
		self.mouse_filter = Control.MOUSE_FILTER_STOP if inventory_is_toggled else Control.MOUSE_FILTER_IGNORE

	if event.is_action_pressed("Quit"):
		on_inventory_closed()
		quit_is_toggled = !quit_is_toggled

		if quit_check:
			quit_check.visible = quit_is_toggled
			if quit_is_toggled:
				update_quit_highlight()

		if player_inventory_container:
			player_inventory_container.visible = false

		if quit_is_toggled:
			emit_signal("Stop_mouse")
		else:
			emit_signal("continue_mouse")
		#if SaveManager.save_data.game_mode == true:
		if quit_is_toggled:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Engine.time_scale = 0.0 if quit_is_toggled else 1.0
		self.mouse_filter = Control.MOUSE_FILTER_STOP if quit_is_toggled else Control.MOUSE_FILTER_IGNORE

		Selector.visible = false
		MoreOptions.visible = false
		MoreOptionsBackGround.visible = false
		

func handle_menu_toggle() -> void:
	if inventory_is_toggled:
		var slot = slots[selected_index]
		if slot and slot.has_method("get_item"):
			var item = slot.get_item()
			if item and Input.is_action_pressed("Map"):
				MoreOptions.visible = true
				MoreOptionsBackGround.visible = true
				current_index = 0
				update_menu_highlight()
		
	

func _unhandled_input(event: InputEvent) -> void:
	if quit_is_toggled:
		if event.is_action_pressed("Move_inventory_selected_right") or event.is_action_pressed("Move_inventory_selected_left"):
			quit_menu_index = 1 - quit_menu_index
			update_quit_highlight()
		if event.is_action_pressed("Interact"):
			if quit_menu_index == 0:
				_on_yes_pressed()
			else:
				_on_no_pressed()
		return

	if inventory_is_toggled:
		if event.is_action_pressed("Move_inventory_selected_right"):
			input_mode = InputMode.CONTROLLER
			#if SaveManager.save_data.game_mode == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			move_selection(1)
		elif event.is_action_pressed("Move_inventory_selected_left"):
			input_mode = InputMode.CONTROLLER
			#if SaveManager.save_data.game_mode == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			move_selection(-1)
		elif event.is_action_pressed("Move_inventory_selected_down"):
			input_mode = InputMode.CONTROLLER
			#if SaveManager.save_data.game_mode == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			move_selection(slots_per_row)
		elif event.is_action_pressed("Move_inventory_selected_up"):
			input_mode = InputMode.CONTROLLER
			#if SaveManager.save_data.game_mode == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			move_selection(-slots_per_row)
		elif event is InputEventMouseMotion:
			input_mode = InputMode.MOUSE
			#if SaveManager.save_data.game_mode == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		if not quit_is_toggled:
			#if SaveManager.save_data.game_mode == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if inventory_is_toggled:
		if event.is_action_pressed("R-Bumper"):
			@warning_ignore("int_as_enum_without_cast")
			current_page = (current_page + 1) % Page.size()
			change_to_page(current_page)
		elif event.is_action_pressed("L-Bumper"):
			@warning_ignore("int_as_enum_without_cast")
			current_page = (current_page - 1 + Page.size()) % Page.size()
			change_to_page(current_page)


func change_to_page(idx: int):
	if not PAGE_NODES.has(idx):
		push_warning("Invalid page index: " + str(idx))
		return

	hide_all_pages()
	PAGE_NODES[idx].visible = true


# ================================
# Inventory UI Logic
# ================================

func _on_delete_save_data_clear_inventory() -> void:
	if player_inventory:
		player_inventory.inventory.delete_inventory()
		rebuild_slots()

func move_selection(offset: int):
	if slots.is_empty(): return
	selected_index = clamp(selected_index + offset, 0, slots.size() - 1)
	update_selection()

func update_selection() -> void:
	if slots.is_empty(): return
	if selected_index >= slots.size():
		selected_index = slots.size() - 1
	var slot = slots[selected_index]
	update_selector_position(slot)
	update_more_options_position(slot)
	update_name_and_desc(slot)

func update_selector_position(slot: Node = null) -> void:
	if Selector:
		if slot == null and not slots.is_empty():
			slot = slots[selected_index]
		if slot:
			Selector.global_position = slot.get_global_position()

func update_more_options_position(slot: Node) -> void:
	if MoreOptions:
		MoreOptions.global_position = slot.get_global_position() + Vector2(50, 50)
		MoreOptionsBackGround.global_position = slot.get_global_position() + Vector2(50, 50)

func update_name_and_desc(slot: Node) -> void:
	if Input.is_action_just_pressed("Interact") and slot:
		var item: InventoryItem = null
		if slot.has_method("get_item"):
			item = slot.get_item()
		elif slot.has_node("TextureRect/ItemTexture") and slot.get_node("TextureRect/ItemTexture").texture:
			pass
		
		if item and is_instance_valid(item):
			#print("Selected item: ", item.name)
			if Name:
				Name.text = item.name
			if Desc:
				Desc.text = item.description
		else:

			if Name:
				Name.text = ""
			if Desc:
				Desc.text = ""






func handle_menu_navigation() -> void:
	var slot = slots[selected_index]
	
	if MoreOptions and MoreOptions.visible == true and MoreOptionsBackGround.visible == true:
		if Input.is_action_just_pressed("Interact"):
			if menu_options[current_index] == "Equip":
				if slot and slot.has_method("get_item"):
					var item = slot.get_item()
					if player.has_method("equip_item"):
						player.equip_item(item)
						print(item.name)
					else:
						print("cant equip")
				else:
					print("No bueno… slot has no item getter.")

			print("Selected option: ", menu_options[current_index])
			MoreOptions.visible = false
			MoreOptionsBackGround.visible = false

		if Input.is_action_just_pressed("Move_Forward"):
			current_index = max(0, current_index - 1)
			update_menu_highlight()
		elif Input.is_action_just_pressed("Move_Back"):
			current_index = min(menu_options.size() - 1, current_index + 1)
			update_menu_highlight()





func update_menu_highlight() -> void:
	if MoreOptions:
		for i in range(menu_options.size()):
			var label = MoreOptions.get_child(i)
			if label:
				label.modulate = Color.RED if i == current_index else Color.WHITE


func update_quit_highlight() -> void:
	if quit_yes_label and quit_no_label:
		if quit_menu_index == 0:
			quit_yes_label.modulate = Color.RED
			quit_no_label.modulate = Color.WHITE
		else:
			quit_yes_label.modulate = Color.WHITE
			quit_no_label.modulate = Color.RED


# ================================
# Chest Logic
# ================================
func _on_chest_scene_chest_opened(item: InventoryItem) -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	inventory_was_toggled_before_chest = inventory_is_toggled

	if player_inventory_container:
		player_inventory_container.visible = false

	is_chest_open = true
	emit_signal("Stop_mouse")
	emit_signal("Add_Item_to_slot", item)
	await get_tree().process_frame
	rebuild_slots()

func _on_chest_scene_chest_closed() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	#if SaveManager.save_data.game_mode == true:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	inventory_is_toggled = inventory_was_toggled_before_chest

	if player_inventory_container:
		player_inventory_container.visible = false

	is_chest_open = false
	emit_signal("continue_mouse")

# ================================
# Inventory Heart Display
# ================================
func update_hearts_in_inventory():
	hearts.clear()
	for row in row_containers:
		if row:
			for heart in row.get_children():
				if heart is TextureRect:
					hearts.append(heart)

	for heart in hearts:
		if heart:
			heart.visible = false

	if SaveManager and SaveManager.save_data:
		var max_health = SaveManager.save_data.max_health
		for i in range(min(max_health, hearts.size())):
			if hearts[i]:
				hearts[i].visible = true

# ================================
# Open/Close Logic
# ================================
func on_inventory_opened():
	
	current_page = Page.INVENTORY
	change_to_page(current_page)

	update_hearts_in_inventory()
	if player:
		if player.health_scene: player.health_scene.visible = false
		if player.black_heart_holder: player.black_heart_holder.visible = false
		if player.black_heart_holder_2: player.black_heart_holder_2.visible = false
		if player.black_heart_holder_3: player.black_heart_holder_3.visible = false
	var day_night_cycle = get_parent().get_node_or_null("DayAndNightCycle")
	if day_night_cycle and day_night_cycle.get_child_count() > 2 and day_night_cycle.get_child(2):
		day_night_cycle.get_child(2).visible = false

func on_inventory_closed():
	
	current_page = Page.INVENTORY
	change_to_page(current_page)
	hide_all_pages()
	
	update_hearts_in_inventory()
	if player:
		if player.health_scene: player.health_scene.visible = true
		if player.black_heart_holder: player.black_heart_holder.visible = true
		if player.black_heart_holder_2: player.black_heart_holder_2.visible = true
		if player.black_heart_holder_3: player.black_heart_holder_3.visible = true
	var day_night_cycle = get_parent().get_node_or_null("DayAndNightCycle")
	if day_night_cycle and day_night_cycle.get_child_count() > 2 and day_night_cycle.get_child(2):
		day_night_cycle.get_child(2).visible = true

func hide_all_pages() -> void:
	for node in PAGE_NODES.values():
		if node:
			node.visible = false


# ================================
# Key Check Logic (Renamed for clarity and reusability)
# ================================

func _perform_item_check(item_name_to_find: String) -> bool:
	if not player_inventory or not player_inventory.inventory or not player_inventory.inventory.items:
		push_error("Inventory or item list not found for key check.")
		return false

	for item in player_inventory.inventory.items:
		if item != null and item.name == item_name_to_find:
			return true
	return false

func _on_door_scene_check_player_key() -> void:
	if _perform_item_check("KEY"):
		emit_signal("key_found")
	else:
		emit_signal("no_key_found")

func _on_door_scene_check_player_key_back() -> void:
	if _perform_item_check("KEY"):
		emit_signal("key_found_back")
	else:
		emit_signal("no_key_found")

# ================================
# Process Loop
# ================================
func _process(_delta: float) -> void:
	
	
	handle_menu_toggle()
	
	match input_mode:
		InputMode.MOUSE:
			if inventory_is_toggled:
				var nearest_slot = get_nearest_slot()
				if nearest_slot:
					update_selector_position(nearest_slot)
					update_more_options_position(nearest_slot)
					update_name_and_desc(nearest_slot)
					if nearest_slot != last_selected_slot:
						last_selected_slot = nearest_slot
		InputMode.CONTROLLER:
			if inventory_is_toggled:
				update_selection()

	if inventory_is_toggled:
		handle_menu_navigation()

# ================================
# Mouse Slot Detection
# ================================
func get_nearest_slot() -> Node:
	var mouse_pos = get_global_mouse_position()
	var nearest_slot = null
	var nearest_dist = INF
	if slots.is_empty(): return null

	for slot in slots:
		if slot:
			var dist = mouse_pos.distance_to(slot.get_global_position())
			if dist < nearest_dist:
				nearest_dist = dist
				nearest_slot = slot
	return nearest_slot

func rebuild_slots():
	if player_inventory:
		slots = player_inventory.get_children()
		slots = slots.filter(func(child): return child is Control and child.visible)
		selected_index = clamp(selected_index, 0, slots.size() - 1)

		if inventory_is_toggled:
			update_selection()
			update_selector_position()

func _on_yes_pressed() -> void:
	if SaveManager:
		SaveManager.save()
	get_tree().quit()

func _on_no_pressed() -> void:
	if quit_check:
		quit_check.visible = false
	if player_inventory_container:
		player_inventory_container.visible = false
	emit_signal("continue_mouse")
	#if SaveManager.save_data.game_mode == true:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	Engine.time_scale = 1.0
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quit_is_toggled = false

func add_quest(q: QuestData) -> void:
	if not quest_container or not quest_scene:
		push_warning("Quest UI not configured!")
		return

	# 1. Save it
	SaveManager.save_data.current_quests.append(q)
	SaveManager.save()

	# --- 2. Spawn the UI entry ------------------------------------------
	var quest_node := quest_scene.instantiate()
	quest_node.quest_title.text = q.quest_name

	# enum → readable text  (add the type hint!)
	var type_str: String = QuestData.QuestType.keys()[q.quest_type] as String
	quest_node.type.text = type_str.capitalize()

	quest_container.add_child(quest_node)
