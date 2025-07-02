@icon("res://Player/Inventory/Textures/InventoryItem.svg")

class_name InventoryItem
extends Resource

enum ItemType {
	DEFAULT,
	CONSUMABLE,
	WEAPON,
	KEY_ITEM,
	MATERIAL,
	QUEST
}

@export_group("Basic Data")

@export var item_type: ItemType = ItemType.DEFAULT

@export var name: String = ""

@export var description: String = ""

@export var texture: Texture2D = preload("res://Assets/ItemAsset/Items/Textures/PlaceHolder.png")

@export var can_pick_up: bool 

@export var hearts_given: int = 0

@export_group("Stacking")

@export var amount: int

@export var max_stack: int

#====== 3D ======#
@export_group("3D Properties")

@export var mesh: Mesh

@export var in_game_texture: StandardMaterial3D = null

@export var rigid_body_physics_material: PhysicsMaterial

@export_subgroup("Area3D Body Collision Options")

@export var collision_shape_area3d_body: Shape3D = null

@export var collision_shape_size_area3d_body: Transform3D

@export var collision_color_area3d_body: Color

@export_subgroup("Rigid Body Collision Options")

@export var collision_shape_rigid_body: Shape3D = null

@export var collision_shape_size_rigid_body: Transform3D

@export var collision_color_rigid_body: Color
