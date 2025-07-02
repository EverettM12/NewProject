extends Control

@export var swap_jump: Button

var current_index: int

func _ready() -> void:
	current_index = 1
	$Panel/CenterContainer/VBoxContainer/HBoxContainer/Swapjump.modulate = Color.RED
	$Panel/CenterContainer/VBoxContainer/HBoxContainer/Label.modulate = Color.RED
	swap_jump.text = "B"
	_set_jump_to("B")
	swap_jump.pressed.connect(_on_swap_jump_pressed)

func _on_settings_menu_opened():
	self.visible = true
	print("Settings menu opened")

func _on_settings_menu_closed():
	self.visible = false
	print("Settings menu closed")

func _input(event: InputEvent) -> void:
	if not self.visible:
		return
	if event.is_action_pressed("Quit"):
		_on_settings_menu_closed()
	if event.is_action_pressed("Interact"):
		if current_index == 1:
			_on_swap_jump_pressed()

func _on_swap_jump_pressed() -> void:
	if swap_jump.text == "A":
		swap_jump.text = "B"
		_set_jump_to("B")
	elif swap_jump.text == "B":
		swap_jump.text = "A"
		_set_jump_to("A")
	print("Swapped Jump to: ", swap_jump.text)

func _set_jump_to(button: String) -> void:
	InputMap.action_erase_events("Jump")
	InputMap.action_erase_events("Interact")
	
	var space_event := InputEventKey.new()
	space_event.physical_keycode = KEY_SPACE
	InputMap.action_add_event("Jump", space_event)

	var interact_event := InputEventKey.new()
	interact_event.physical_keycode = KEY_E
	InputMap.action_add_event("Interact", interact_event)


	var jump_button := InputEventJoypadButton.new()
	jump_button.device = 0


	var interact_button := InputEventJoypadButton.new()
	interact_button.device = 0

	if button == "A":
		jump_button.button_index = JOY_BUTTON_B
		interact_button.button_index = JOY_BUTTON_A
	elif button == "B":
		jump_button.button_index = JOY_BUTTON_A
		interact_button.button_index = JOY_BUTTON_B
	else:
		print("Unknown button:", button)
		return

	InputMap.action_add_event("Jump", jump_button)
	InputMap.action_add_event("Interact", interact_button)

	print("Jump mapped to ", button)
	print("Interact mapped to ", "A" if button == "B" else "B")
