@tool
extends Node3D
class_name ReusableTree

@onready var _1_tree: MeshInstance3D = $_1_tree
@onready var _2_tree: MeshInstance3D = $_2_tree
@onready var _3_tree: MeshInstance3D = $_3_tree
@onready var _4_tree: MeshInstance3D = $_4_tree
@onready var _6_tree: MeshInstance3D = $_6_tree
@onready var _7_tree: MeshInstance3D = $_7_tree
@onready var _11_tree: MeshInstance3D = $_11_tree
@onready var _12_tree: MeshInstance3D = $_12_tree
@onready var _8_tree: MeshInstance3D = $_8_tree
@onready var _9_tree: MeshInstance3D = $_9_tree

@export var trees: Array[MeshInstance3D] = []

@export_range(1, 12, 1, "suffix: Tree") var chosen_tree_index: int = 1

func _ready() -> void:
	_populate_trees_array()
	_update_tree_visibility()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if trees.is_empty():
			_populate_trees_array()
		_update_tree_visibility()

func _populate_trees_array() -> void:
	trees.clear()
	trees.append(_1_tree)
	trees.append(_2_tree)
	trees.append(_3_tree)
	trees.append(_4_tree)
	trees.append(_6_tree)
	trees.append(_7_tree)
	trees.append(_8_tree)
	trees.append(_9_tree)
	trees.append(_11_tree)
	trees.append(_12_tree)

func _update_tree_visibility() -> void:
	for i in range(trees.size()):
		var tree = trees[i]
		if tree:
			var is_selected = (i == chosen_tree_index - 1)
			tree.visible = is_selected
			_set_tree_collision_enabled(tree, is_selected)

func _set_tree_collision_enabled(tree: MeshInstance3D, enabled: bool) -> void:
	for child in tree.get_children():
		if child is StaticBody3D:
			if child is CollisionShape3D:
				child.disabled = not enabled
