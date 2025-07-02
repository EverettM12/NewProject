extends Resource
class_name SaveResource

# Player Data
@export var last_saved_position: Vector3 = Vector3(0, 2, 0)
@export var last_saved_health: int = 3
@export var max_health: int = 3
@export var inventory: Array
@export var amount_of_scraps: int

# Ball Data
@export var last_saved_ball_position: Vector3

# Shrine states
@export var Shrine_1_opened: bool
@export var Shrine_2_opened: bool
@export var Shrine_3_opened: bool
@export var Shrine_4_opened: bool
@export var Shrine_5_opened: bool
@export var Shrine_6_opened: bool
@export var Shrine_7_opened: bool
@export var Shrine_8_opened: bool
@export var Shrine_9_opened: bool
@export var Shrine_10_opened: bool

# Shrine states
@export var Shrine_1_text_played: bool
@export var Shrine_2_text_played: bool
@export var Shrine_3_text_played: bool
@export var Shrine_4_text_played: bool
@export var Shrine_5_text_played: bool
@export var Shrine_6_text_played: bool
@export var Shrine_7_text_played: bool
@export var Shrine_8_text_played: bool
@export var Shrine_9_text_played: bool
@export var Shrine_10_text_played: bool

@export var game_mode: bool = true

@export var Master_Sword_Has_Been_Picked_Up: bool

@export var current_quests: Array[QuestData] = []

func delete_save():
# Player Data
	last_saved_position = Vector3(0, 2, 0)
	last_saved_health = 3
	max_health = 3
	amount_of_scraps = 0
	
	Master_Sword_Has_Been_Picked_Up = false
	current_quests.clear()

func reset_shrines_state():
	# Reset shrine states
	Shrine_1_opened = false
	Shrine_2_opened = false
	Shrine_3_opened = false
	Shrine_4_opened = false
	Shrine_5_opened = false
	Shrine_6_opened = false
	Shrine_7_opened = false
	Shrine_8_opened = false
	Shrine_9_opened = false
	Shrine_10_opened = false
	
	Shrine_1_text_played = false
	Shrine_2_text_played = false
	Shrine_3_text_played = false
	Shrine_4_text_played = false
	Shrine_5_text_played = false
	Shrine_6_text_played = false
	Shrine_7_text_played = false
	Shrine_8_text_played = false
	Shrine_9_text_played = false
	Shrine_10_text_played = false
