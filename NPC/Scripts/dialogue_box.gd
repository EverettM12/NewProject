extends Control
class_name DialogueBoxUI

signal advance_dialogue_requested

@onready var dialogue_text_label: RichTextLabel = %DialogueText
@onready var advance_button: Button = %AdvanceButton


func _ready():
	if advance_button:
		advance_button.pressed.connect(_on_advance_button_pressed)
	hide()

func set_dialogue_text(text: String):
	dialogue_text_label.text = text

func _on_advance_button_pressed():
	emit_signal("advance_dialogue_requested")

func show_dialogue():
	show()

func hide_dialogue():
	hide()
