extends Area3D

signal Chest_Opened(Item)
signal Chest_Closed

@export var resource: Items
@export var Item: InventoryItem

@export var chest_prompt: Control


@export_group("Chest Pop Up")
@export var chest_menu: PanelContainer
@export var title: Label
@export var desc: Label
@export var texture: TextureRect

@export var heart_scene: PackedScene
@export var heart_holder: HBoxContainer

var able_to_interact: bool = false
var chest_is_open: bool = false

func _ready():
	randomize()

	if Item == null:
		Item = random_item()

	set_loot_ui(Item)

	if %InventoryManager:
		connect("Chest_Opened", Callable(%InventoryManager, "_on_chest_scene_chest_opened"))
		connect("Chest_Closed", Callable(%InventoryManager, "_on_chest_scene_chest_closed"))

	

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		chest_prompt.visible = true
		able_to_interact = true


func _input(event: InputEvent) -> void:
	if able_to_interact:
		if event.is_action_pressed("Interact"):
			open_chest()
		elif chest_is_open and (
			event.is_action_pressed("Interact") or 
			event.is_action_pressed("Quit") or
			event.is_action_pressed("Move_Forward") or
			event.is_action_pressed("Move_Back") or
			event.is_action_pressed("Move_Left") or
			event.is_action_pressed("Move_Right") or 
			event.is_action_pressed("Open_Inventory")
		):
			close_chest()

func open_chest():
	chest_is_open = true
	chest_menu.visible = true
	chest_prompt.visible = false
	emit_signal("Chest_Opened", Item)
	print("🎁 Looted: %s | Heals: %d hearts | Desc: %s" % [Item.name, Item.hearts_given, Item.description])

func close_chest():
	chest_is_open = false
	chest_menu.visible = false
	emit_signal("Chest_Closed")

func set_loot_ui(res):
	# Clear any previous hearts
	for child in heart_holder.get_children():
		child.queue_free()

	if res == null:
		title.text = "Nothing"
		desc.text = ""
		texture.texture = null

		var heart_instance = heart_scene.instantiate()
		heart_holder.add_child(heart_instance)
		heart_instance.change_alpha(0.5)
	else:
		for i in range(res.hearts_given):
			var heart_instance = heart_scene.instantiate()
			heart_holder.add_child(heart_instance)
			heart_instance.change_alpha(1.0)

		title.text = res.name
		desc.text = res.description
		texture.texture = res.texture

func random_item():
	if resource and resource.random_items_for_the_chest.size() > 0:
		var index := randi() % resource.random_items_for_the_chest.size()
		return resource.random_items_for_the_chest[index]
	return null


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player") and body is playercontroller:
		chest_prompt.visible = false
		able_to_interact = false
		close_chest()
