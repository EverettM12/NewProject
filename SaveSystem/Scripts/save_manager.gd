extends Node

var save_data: SaveResource = SaveResource.new()

const SAVE_PATH := "user://save_data.tres"

func load():
	if FileAccess.file_exists(SAVE_PATH):
		var loaded = ResourceLoader.load(SAVE_PATH)
		if loaded is SaveResource:
			save_data = loaded
	else:
		save_data = SaveResource.new()

func save():
	ResourceSaver.save(save_data, SAVE_PATH)
 
