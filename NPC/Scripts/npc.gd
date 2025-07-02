extends Node3D
class_name NPC

## --- NPC Properties ---
@export var Npc_Name: String = "Unnamed NPC"
@export_multiline var Dialogue_Text: Array[String] = []
@export_multiline var Quest_Offer_Text: Array[String] = []
@export_multiline var Quest_Accepted_Text: Array[String] = []
@export_multiline var Quest_Completed_Text: Array[String] = []
@export_multiline var No_Quest_Text: Array[String] = []

@export var Dialogue_Box_Scene: PackedScene
@export var Quest_Offer_Box_Scene: PackedScene
@export var Shop_Scene: PackedScene

@export var has_quest_to_offer: bool = false
@export var is_quest_accepted: bool = false
@export var is_quest_completed: bool = false
@export var Quest: QuestData

@export var has_shop: bool = false
@export var item: PackedScene
var shop_instance: Node = null

@export var items_selling: Array[ItemData]


## --- Signals ---
signal quest_accepted(npc_name: String)


## --- Internal State ---
enum NpcState {
	IDLE,
	DIALOGUE_INITIAL,
	DIALOGUE_QUEST_OFFER,
	DIALOGUE_QUEST_ACCEPTED,
	DIALOGUE_QUEST_COMPLETED,
	DIALOGUE_NO_QUEST,
	QUEST_OFFER_UI_ACTIVE,
	SHOP_ACTIVE
}


var current_npc_state: NpcState = NpcState.IDLE
var current_dialogue_index: int = 0
var current_dialogue_array: Array[String] = []

var dialogue_box_instance: DialogueBoxUI = null
var quest_offer_box_instance: QuestBoxUI = null

var player_in_range: bool = false


## --- Lifecycle Methods ---
func _ready() -> void:
	var interaction_area: Area3D = find_child("InteractionArea")
	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact") and player_in_range:

		match current_npc_state:
			NpcState.IDLE:
				_start_dialogue()
			NpcState.DIALOGUE_INITIAL, \
			NpcState.DIALOGUE_QUEST_OFFER, \
			NpcState.DIALOGUE_QUEST_ACCEPTED, \
			NpcState.DIALOGUE_QUEST_COMPLETED, \
			NpcState.DIALOGUE_NO_QUEST:
				_advance_dialogue()
			NpcState.QUEST_OFFER_UI_ACTIVE:
				pass
	#if SaveManager.save_data.game_mode == true: # Keyboard
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_interaction_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true


func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		_end_current_interaction()
		_on_shop_closed()


func _setup_shop() -> void:
	if not is_instance_valid(shop_instance) and Shop_Scene:
		shop_instance = Shop_Scene.instantiate()
		get_tree().root.add_child(shop_instance)
		shop_instance.name = "ShopUI_%s" % Npc_Name.replace(" ", "_")

		var item_list = shop_instance.get_node("MarginContainer/MainContent/Main/ScrollContainer/ItemHolder")

		for item_data in items_selling:
			if is_instance_valid(item):
				var item_instance = item.instantiate()
				
				if item_instance.has_method("set_item_data"):
					item_instance.set_item_data(item_data)
				else:
					print("Warning: Item instance missing set_item_data()")

				item_list.add_child(item_instance)

		if shop_instance.has_signal("shop_closed"):
			shop_instance.connect("shop_closed", Callable(self, "_on_shop_closed"))


func _open_shop() -> void:
	_setup_shop()
	if is_instance_valid(shop_instance):
		current_npc_state = NpcState.SHOP_ACTIVE
		shop_instance.show()
		#if SaveManager.save_data.game_mode == true: # Keyboard
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



func _on_shop_closed() -> void:
	current_npc_state = NpcState.IDLE
	if shop_instance:
		shop_instance.queue_free()
		shop_instance = null
		#if SaveManager.save_data.game_mode == true: # Keyboard
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


## --- Dialogue Flow Management ---
func _start_dialogue() -> void:
	_setup_dialogue_box()

	if is_quest_completed:
		current_dialogue_array = Quest_Completed_Text
		current_npc_state = NpcState.DIALOGUE_QUEST_COMPLETED
		_show_dialogue()
	elif is_quest_accepted:
		Check_if_player_has_item()
	elif has_quest_to_offer:
		current_dialogue_array = Quest_Offer_Text
		current_npc_state = NpcState.DIALOGUE_QUEST_OFFER
		_show_dialogue()
	else:
		current_dialogue_array = No_Quest_Text if not No_Quest_Text.is_empty() else Dialogue_Text
		current_npc_state = NpcState.DIALOGUE_NO_QUEST
		_show_dialogue()

func _show_dialogue() -> void:
	if current_dialogue_array.is_empty():
		push_warning("NPC '%s' has no dialogue set for its current state." % Npc_Name)
		_end_dialogue_display()
		return

	current_dialogue_index = 0
	dialogue_box_instance.show_dialogue()
	_display_current_line()

func _display_current_line() -> void:
	if current_dialogue_index < current_dialogue_array.size():
		dialogue_box_instance.set_dialogue_text(current_dialogue_array[current_dialogue_index])
	else:
		_end_dialogue_display()

func _advance_dialogue() -> void:
	current_dialogue_index += 1
	if current_dialogue_index < current_dialogue_array.size():
		_display_current_line()
	else:
		_end_dialogue_display()
		_handle_dialogue_end_transition()

func _end_dialogue_display() -> void:
	if is_instance_valid(dialogue_box_instance):
		dialogue_box_instance.hide_dialogue()
	current_dialogue_index = 0

func _handle_dialogue_end_transition() -> void:
	match current_npc_state:
		NpcState.DIALOGUE_QUEST_OFFER:
			_offer_quest()
		NpcState.DIALOGUE_NO_QUEST:
			if has_shop:
				_open_shop()
		_:
			current_npc_state = NpcState.IDLE


func _end_current_interaction() -> void:
	if is_instance_valid(dialogue_box_instance):
		dialogue_box_instance.hide_dialogue()
	if is_instance_valid(quest_offer_box_instance):
		quest_offer_box_instance.hide_quest_offer()
	current_npc_state = NpcState.IDLE
	current_dialogue_index = 0

## --- UI Instantiation ---
func _setup_dialogue_box() -> void:
	if not is_instance_valid(dialogue_box_instance) and Dialogue_Box_Scene:
		dialogue_box_instance = Dialogue_Box_Scene.instantiate() as DialogueBoxUI
		get_tree().root.add_child(dialogue_box_instance)
		dialogue_box_instance.advance_dialogue_requested.connect(_advance_dialogue)
		dialogue_box_instance.name = "NPCDialogueBox_%s" % Npc_Name.replace(" ", "_")
	elif not Dialogue_Box_Scene:
		push_error("Dialogue Box Scene is not assigned for NPC '%s'." % Npc_Name)

func _setup_quest_offer_box() -> void:
	if not is_instance_valid(quest_offer_box_instance) and Quest_Offer_Box_Scene:
		quest_offer_box_instance = Quest_Offer_Box_Scene.instantiate() as QuestBoxUI
		get_tree().root.add_child(quest_offer_box_instance)
		quest_offer_box_instance.quest_accepted.connect(_on_quest_offer_accepted)
		quest_offer_box_instance.quest_declined.connect(_on_quest_offer_declined)
		quest_offer_box_instance.name = "NPCQuestOfferBox_%s" % Npc_Name.replace(" ", "_")
	elif not Quest_Offer_Box_Scene:
		push_error("Quest Offer Box Scene is not assigned for NPC '%s'." % Npc_Name)

## --- Quest Logic ---
func _offer_quest() -> void:
	_setup_quest_offer_box()
	if is_instance_valid(quest_offer_box_instance):
		current_npc_state = NpcState.QUEST_OFFER_UI_ACTIVE
		quest_offer_box_instance.show_quest_offer(Npc_Name, Quest_Offer_Text.back())

func _on_quest_offer_accepted() -> void:
	print("%s: Quest Accepted!" % Npc_Name)
	is_quest_accepted = true
	has_quest_to_offer = false
	current_npc_state = NpcState.IDLE
	_end_current_interaction()
	emit_signal("quest_accepted", Npc_Name)
	
	#var quest_title = Quest.quest_name
	#var quest_type  = Quest.quest_type
	
	var q : QuestData = Quest
	#q.quest_name
	#q.quest_type

	var ui := get_parent().find_child("InventoryManager")
	if ui:
		ui.add_quest(q)


func _on_quest_offer_declined() -> void:
	print("%s: Quest Declined." % Npc_Name)
	current_npc_state = NpcState.IDLE
	_end_current_interaction()

## --- Inventory Check Logic ---
func Check_if_player_has_item():
	var inventory_manager = get_parent().get_node("InventoryManager")
	var player_inventory: Inventory = inventory_manager.player_inventory.inventory

	if not player_inventory:
		return

	var item_to_find_name = Quest.required_item.name
	var found_item: InventoryItem = null

	for i in range(player_inventory.items.size()):
		var current_item = player_inventory.get_item_by_index(i)
		if current_item and current_item.name == item_to_find_name:
			found_item = current_item
			break

	if found_item:
		print("Found item: ", found_item.name)
		print("Description: ", found_item.description)
		current_dialogue_array = Quest_Completed_Text
		current_npc_state = NpcState.DIALOGUE_QUEST_COMPLETED
		player_inventory.add_item(Quest.gives_item)
		player_inventory.remove_item_by_name(Quest.required_item.name, 1)
		inventory_manager.rebuild_slots()

	else:
		print("Item not found: ", item_to_find_name)
		current_dialogue_array = Quest_Accepted_Text
		current_npc_state = NpcState.DIALOGUE_QUEST_ACCEPTED

	_show_dialogue()
