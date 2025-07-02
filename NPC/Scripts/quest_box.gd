extends Control
class_name QuestBoxUI

@onready var name_label: Label = %NameLabel
@onready var accept_button: Button = %AcceptButton
@onready var decline_button: Button = %DeclineButton

signal quest_accepted
signal quest_declined

func _ready():
	hide()
	accept_button.pressed.connect(func(): emit_signal("quest_accepted"))
	decline_button.pressed.connect(func(): emit_signal("quest_declined"))

@warning_ignore("unused_parameter")
func show_quest_offer(speaker_name: String, quest_text: String) -> void:
	name_label.text = speaker_name + " ( QUEST OFFER )"
	visible = true

func hide_quest_offer() -> void:
	visible = false
