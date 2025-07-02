extends Control
class_name ContinueMenu

signal ContinueGame

@export var Scene: PackedScene

var path: String

var current_index: int

func _ready() -> void:
	if Scene:
		path = Scene.resource_path
		print("Path is:", path)
	else:
		push_error("No scene selected in continue game menu!")
		
func _on_continue_menu_opened():
	$Panel/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer/ContinueSave.modulate = Color.RED
	current_index = 1
	self.visible = true
	print("Continue Menu Opened")

	var image = Image.load_from_file("user://screenshot.png")
	var texture = ImageTexture.create_from_image(image)
	%TextureRect.texture = texture


func _on_continue_menu_closed():
	self.visible = false
	print("Continue Menu Closed")

func _input(event: InputEvent) -> void:
	if not self.visible:
		return
	if event.is_action_pressed("Quit"):
		_on_continue_menu_closed()

	if event.is_action_pressed("Move_inventory_selected_up"):
		$Panel/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer/ContinueSave.modulate = Color.RED
		$Panel/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer2/ContinueSaveAuto.modulate = Color.WHITE
		current_index = 1

	if event.is_action_pressed("Move_inventory_selected_down"):
		$Panel/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer2/ContinueSaveAuto.modulate = Color.RED
		$Panel/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer/ContinueSave.modulate = Color.WHITE
		current_index = 2

	if event.is_action_pressed("Interact"):
		if current_index == 1:
			_on_continue_save_pressed()
		elif current_index == 2:
			_on_continue_save_auto_pressed()

func _on_continue_save_pressed() -> void:
	SaveManager.load()
	
	var scene = load(path).instantiate()
	scene.init_from_menu("loaded")
	get_tree().root.add_child(scene)
	emit_signal("ContinueGame")


func _on_continue_save_auto_pressed() -> void:
	SaveManager.load()
	
	var scene = load(path).instantiate()
	scene.init_from_menu("loaded")
	get_tree().root.add_child(scene)
	emit_signal("ContinueGame")
