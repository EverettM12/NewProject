extends Control
class_name NewGameMenu

signal CreateNewGame

@export var Scene: PackedScene

var path: String

func _ready() -> void:
	if Scene:
		path = Scene.resource_path
		print("Path is:", path)
	else:
		push_error("No scene selected in new game menu!")

func _on_newG_menu_opened():
	self.visible = true


func _on_newG_menu_closed():
	self.visible = false

func _input(event: InputEvent) -> void:
	if not self.visible:
		return
	if event.is_action_pressed("Quit"):
		_on_newG_menu_closed()
	if self.visible == true:
		$Panel/CenterContainer/VBoxContainer/NewSave.modulate = Color.RED
		if event.is_action_pressed("Interact"):
			_on_new_save_pressed()


func _on_new_save_pressed() -> void:
	SaveManager.save_data.reset_shrines_state()
	SaveManager.save_data.delete_save()
	SaveManager.save()
	
	var scene = load(path).instantiate()
	scene.init_from_menu("new")
	get_tree().root.add_child(scene)
	emit_signal("CreateNewGame")
