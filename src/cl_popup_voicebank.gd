extends Panel

@onready var VBankContainer = $ScrollContainer/VBankContainer
@onready var default_bank = $ScrollContainer/VBankContainer/Bank.duplicate()
@onready var button = $ScrollContainer/VBankContainer/Add.duplicate()

var timestamp:float

func _ready():
	Events.popups_opened.connect(_on_popups_opened)
	Events.add_voicebank_to_timeline.connect(_on_add_voicebank_to_timeline)

func _on_popups_opened(_index):
	if Popups.id > 0:
		$Label.text = "Edit Voice Bank"; $Create.text = "Edit"
	else:
		$Label.text = "Place New Voice Bank"; $Create.text = "Create"

func _on_add_button_up():
	var bank: LineEdit = default_bank.duplicate()
	VBankContainer.add_child(bank)
	VBankContainer.move_child(bank, VBankContainer.get_child_count()-2)

func _on_add_voicebank_to_timeline(asset_path):
	for child in VBankContainer.get_children():
		VBankContainer.remove_child(child); child.queue_free()
	
	if Popups.id > 0:
		timestamp = asset_path['timestamp']
		for i in asset_path['voice_paths'].size():
			var bank = default_bank.duplicate()
			bank.text = asset_path['voice_paths'][i]
			VBankContainer.add_child(bank)
	else:
		var time:float
		if Global.snapping_allowed: time = Global.get_timestamp_snapped()
		else: time = Global.song_pos
		
		for bank in Timeline.voice_banks_track.get_children():
			if snappedf(bank['data']['timestamp'], 0.001) == snappedf(time, 0.001) and !Global.replacing_allowed:
				Events.emit_signal('notify', 'Voice Bank Already Exists', 'Timestamp: ' + str(snappedf(time, 0.001)))
				return
		
		_on_add_button_up(); VBankContainer.get_child(0).text = asset_path
	
	VBankContainer.add_child(button.duplicate())
	Popups.reveal(Popups.VOICEBANK)

func _on_create_button_up():
	var time:float
	if Global.snapping_allowed: time = Global.get_timestamp_snapped()
	else: time = Global.song_pos
	
	var new_voice_key = {
		"timestamp": time,
		"voice_paths": []
		}
	
	for child in VBankContainer.get_children():
		if child.get_class() == 'LineEdit': new_voice_key['voice_paths'].append(child.text)
	
	if Popups.id > 0 or Global.replacing_allowed:
		if Popups.id > 0:
			time = timestamp; new_voice_key['timestamp'] = time
		for bank in Timeline.voice_banks_track.get_children():
			if snappedf(bank['data']['timestamp'], 0.001) == snappedf(time, 0.001):
				Timeline.delete_keyframe('voice_bank', bank, Save.keyframes['voice_bank'].find(bank['data']))
	
	Global.project_saved = false
	Save.keyframes['voice_bank'].append(new_voice_key)
	Save.keyframes['voice_bank'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
	Timeline.key_controller.spawn_single_keyframe(new_voice_key, Prefabs.voice_keyframe, Timeline.voice_banks_track)
	_on_cancel_button_up()

func _on_cancel_button_up():
	Popups.close()
	Popups.id = -1
