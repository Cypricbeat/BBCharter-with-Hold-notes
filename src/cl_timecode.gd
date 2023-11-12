extends Node

var current_time_msec: float
var current_time_sec: float
var current_time_min: float

var total_time_msec: float
var total_time_sec: float
var total_time_min: float

var offset_time_msec: float
var offset_time_sec: float
var offset_time_min: float

var timecode_label: Label
var playback_speed_label: Label
var playback_str: String

func _ready():
	timecode_label = $TimeCode
	playback_speed_label = $PlaybackSpeed

func _process(_delta):
	if not Global.project_loaded: return
	
	current_time_msec = snappedi(fmod(Global.song_pos, 1) * 1000, 1)
	current_time_sec = int(fmod(Global.song_pos, 60))
	current_time_min = int(fmod(Global.song_pos, 60 * 60) / 60)
	
	total_time_msec = snappedi(fmod(Global.song_length, 1) * 1000, 1)
	total_time_sec = int(fmod(Global.song_length, 60))
	total_time_min = int(fmod(Global.song_length, 60 * 60) / 60)
	
	offset_time_msec = snappedi(fmod(Global.offset, 1) * 1000, 1)
	offset_time_sec = int(fmod(Global.offset, 60))
	offset_time_min = int(fmod(Global.offset, 60 * 60) / 60)
	
	var current_array = [
		abs(current_time_min), 
		abs(current_time_sec), 
		abs(current_time_msec)
	]
	
	if current_time_min < 0 or current_time_sec < 0 or current_time_msec < 0:
		timecode_label.text = "-%02d:%02d.%03d" % current_array
	else:
		timecode_label.text = "%02d:%02d.%03d" % current_array
	
	timecode_label.text += " : "
	
	if total_time_msec - offset_time_msec < 0:
		total_time_msec = total_time_msec - offset_time_msec + 1000
		total_time_sec -= 1
	else:
		total_time_msec -= offset_time_msec
	if total_time_sec - offset_time_sec < 0:
		total_time_sec = total_time_sec - offset_time_sec + 60
		total_time_min -= 1
	else:
		total_time_sec -= offset_time_sec
	total_time_min -= offset_time_min
	
	var total_array = [
		total_time_min, 
		total_time_sec, 
		total_time_msec
	]
	
	timecode_label.text += "%02d:%02d.%03d" % total_array
	if Global.song_playing:
		playback_str = str(snappedf(Global.song_pitch_speed, 0.1))
	else:
		playback_str = str(1.0)
	playback_speed_label.text = "x%s" % playback_str.pad_decimals(1)
