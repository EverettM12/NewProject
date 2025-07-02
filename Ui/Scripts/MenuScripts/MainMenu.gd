extends Control
class_name MainMenu

# Signals
signal continue_Menu_Opened
signal newG_Menu_Opened
signal settings_Menu_Opened

@export var main_content: MarginContainer

@export_group("Buttons")
@export var continue_button: Button
@export var new_game_button: Button
@export var quit_button: Button
@export var settings_button: Button
@export var change_button: Button

@export_group("Menus")
@export var continue_scene: Control
@export var new_game_scene: Control
@export var settings_scene: Control

var main_menu_buttons := []
var main_menu_index := 0
var is_in_menu: bool
func _ready() -> void:
	
	main_menu_buttons = [
		continue_button,
		new_game_button,
		quit_button,
		settings_button,
		change_button
	]
	
	main_menu_index = 1
	
	#OS.shell_open(ProjectSettings.globalize_path("user://"))
	SaveManager.load()
	
	_update_continue_button_state()
	
	update_main_menu_highlight()
	
	if SaveManager.save_data.game_mode == true:
		%Label.text = "MODE : KEYBOARD"
	elif SaveManager.save_data.game_mode == false:
		%Label.text = "MODE : CONTROLLER"

func _on_continue_pressed() -> void:
	emit_signal("continue_Menu_Opened")
	is_in_menu = true

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_new_game_pressed() -> void:
	emit_signal("newG_Menu_Opened")
	is_in_menu = true

func _on_settings_pressed() -> void:
	emit_signal("settings_Menu_Opened")
	is_in_menu = true


func _update_continue_button_state():
	if SaveManager.save_data.last_saved_position == Vector3(0, 2, 0):
		continue_button.disabled = true
	else:
		continue_button.disabled = false

func _on_continue_menu_continue_game() -> void:
	queue_free()

func _on_new_g_menu_create_new_game() -> void:
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Quit"):
		is_in_menu = false
	
	if is_in_menu == false:
		if event.is_action_pressed("Move_inventory_selected_down"):
			move_main_menu_selection(1)
		elif event.is_action_pressed("Move_inventory_selected_up"):
			move_main_menu_selection(-1)


		elif event.is_action_pressed("Interact"):
			main_menu_buttons[main_menu_index].emit_signal("pressed")


		elif event.is_action_pressed("Interact"):
			main_menu_buttons[main_menu_index].emit_signal("pressed")

func update_main_menu_highlight():
	if is_in_menu == false:
		for i in range(main_menu_buttons.size()):
			var button = main_menu_buttons[i]
			button.modulate = Color.RED if i == main_menu_index else Color.WHITE

func move_main_menu_selection(offset: int):
	if is_in_menu == false:
		var next_index = main_menu_index
		var attempts = 0
		while attempts < main_menu_buttons.size():
			next_index = (next_index + offset + main_menu_buttons.size()) % main_menu_buttons.size()
			if not main_menu_buttons[next_index].disabled:
				break
			attempts += 1
		main_menu_index = next_index
		update_main_menu_highlight()

var mode: bool = false

func _on_change_mode_pressed() -> void:
	SaveManager.load()
	mode = !mode
	
	if mode:
		SaveManager.save_data.game_mode = true # Keyboard
		%Label.text = "MODE : KEYBOARD"
		SaveManager.save()
	else:
		SaveManager.save_data.game_mode = false # Controller
		%Label.text = "MODE : CONTROLLER"
		SaveManager.save()
