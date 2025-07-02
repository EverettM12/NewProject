extends Resource
class_name QuestData

@export var quest_name: String = "New Quest"
@export_multiline var quest_description: String = "A brief description of the quest."


@export var required_item: InventoryItem 
@export var required_item_quantity: int = 1

@export var gives_item: InventoryItem
@export var gives_item_quantity: int = 1

enum QuestType { MAIN, SIDE }

@export var quest_type: QuestType = QuestType.MAIN
