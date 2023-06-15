extends Node2D

var shutter_index: int
var last_shutter_index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.chart_loaded.connect(_on_chart_loaded)
	Events.project_loaded.connect(_on_project_loaded)
	
func _on_chart_loaded():
	print(Save.keyframes['shutter'])

func _on_project_loaded():
	shutter_index = 0
	last_shutter_index = 0

func _process(_delta):
	if Save.keyframes.has('shutter') and Save.keyframes['shutter'].size() > 0 and Timeline.shutter_track.get_child_count() > 0:
		var arr = Save.keyframes['shutter'].filter(func(shutter): return Global.get_synced_song_pos() > shutter['timestamp'])
		shutter_index = arr.size()
		if shutter_index != last_shutter_index:
			last_shutter_index = shutter_index
			$AnimationPlayer.play("Shutters")

