extends Control

@export var label: Label
@export var sub_label: Label

func appear():
	get_tree().create_tween().tween_property(label, "modulate:a", 1.0, 2.0)
	get_tree().create_tween().tween_property(sub_label, "modulate:a", 1.0, 2.0)
	await get_tree().create_timer(2).timeout
	get_tree().create_tween().tween_property(label, "modulate:a", 0.0, 2.0)
	get_tree().create_tween().tween_property(sub_label, "modulate:a", 0.0, 2.0)
