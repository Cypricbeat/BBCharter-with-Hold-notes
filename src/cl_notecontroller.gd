extends Node2D

var note_pos: float
var note_offset: float

var modifier_count: int

func _ready():
	# Globalize Tracks
	Timeline.note_controller = self
	Timeline.beat_container = $Beat
	Timeline.half_container = $Half
	Timeline.third_container = $Third
	Timeline.quarter_container = $Quarter
	Timeline.sixth_container = $Sixth
	Timeline.eighth_container = $Eighth
	Timeline.note_container = $Notes
	Timeline.marquee_selection = $"../../../MarqueeSelection"
	Timeline.marquee_selection_area = $"../../../MarqueeSelection/MarqueeSelectionShape"
	Timeline.marquee_visible = $"../../../MarqueeSelection/MarqueeSelectionShape/MarqueeVisible"
	
	Timeline.note_scroller_map = $"../../NoteScroller/Map"
	Timeline.note_timeline = $"../.."
	Timeline.timeline_root = $"../../.."
	Timeline.key_timeline = $"../../../KeyTimeline"
	Timeline.key_container = $"../../../KeyTimeline/KeyContainer"
	Timeline.shutter_timeline = $"../../../KeyTimeline/KeyContainer/Shutter"
	Timeline.animations_timeline = $"../../../KeyTimeline/KeyContainer/Animations"
	Timeline.backgrounds_timeline = $"../../../KeyTimeline/KeyContainer/Backgrounds"
	Timeline.modifier_timeline = $"../../../KeyTimeline/KeyContainer/Modifier"
	Timeline.sound_loops_timeline = $"../../../KeyTimeline/KeyContainer/SoundLoops"
	Timeline.one_shot_sound_timeline = $"../../../KeyTimeline/KeyContainer/OneshotSound"
	Timeline.voice_bank_timeline = $"../../../KeyTimeline/KeyContainer/VoiceBanks"
	
	Timeline.timeline_ui = [
		Timeline.note_timeline, 
		Timeline.key_timeline, 
		Timeline.shutter_timeline, 
		Timeline.animations_timeline, 
		Timeline.backgrounds_timeline,
		Timeline.modifier_timeline,
		Timeline.sound_loops_timeline,
		Timeline.one_shot_sound_timeline,
		Timeline.voice_bank_timeline
	]
	
	Events.chart_loaded.connect(_on_chart_loaded)
	Events.song_loaded.connect(_on_song_loaded)
	Events.note_created.connect(_on_note_created)
	Events.update_bpm.connect(_on_update_bpm)
	Timeline.marquee_selection.area_entered.connect(on_area_enter)

func _on_chart_loaded():
	print('Spawning Notes')
	for note in Global.current_chart:
		var new_note = Prefabs.note.instantiate()
		new_note.setup(note)
		$Notes.add_child(new_note)
	Timeline.update_visuals()
	Timeline.update_map()

func _on_song_loaded():
	modifier_count = Timeline.modifier_track.get_child_count()
	Global.clear_children(Timeline.beat_container)
	Global.clear_children(Timeline.half_container)
	Global.clear_children(Timeline.third_container)
	Global.clear_children(Timeline.quarter_container)
	Global.clear_children(Timeline.sixth_container)
	Global.clear_children(Timeline.eighth_container)
	create_ui()
	
	Timeline.note_timeline.position.y = 168
	Timeline.key_timeline.size.y = 168
	$"../LineCenter".points[1].y = -272

func on_area_enter(area):
	if area.owner.selected_note != null: return
	area.owner.selected_note = area.owner
	Clipboard.selected_notes.append(area.owner)
	area.owner.selected_note.update_visual()

# Create the indicators / Seperators in the timeline
func create_ui():
	print('Generating New Timeline Indicators')
	for i in Global.song_beats_total + 1:
		var new_beat_indicator = Prefabs.beat_indicator.instantiate()
		$Beat.add_child(new_beat_indicator)
		new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.BEAT)
	
	for i in Global.song_beats_total * 2:
		if i % 2 == 0: continue
		var new_beat_indicator = Prefabs.beat_indicator.instantiate()
		$Half.add_child(new_beat_indicator)
		new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.HALF_BEAT)
	
	for i in Global.song_beats_total * 3:
		if i % 3 == 0: continue
		var new_beat_indicator = Prefabs.beat_indicator.instantiate()
		$Third.add_child(new_beat_indicator)
		new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.THIRD_BEAT)
	
	for i in Global.song_beats_total * 4:
		if i % 2 == 0: continue
		var new_beat_indicator = Prefabs.beat_indicator.instantiate()
		$Quarter.add_child(new_beat_indicator)
		new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.QUARTER_BEAT)
	
	for i in Global.song_beats_total * 6:
		if i % 3 == 0: continue
		if i % 2 == 0: continue
		var new_beat_indicator = Prefabs.beat_indicator.instantiate()
		$Sixth.add_child(new_beat_indicator)
		new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.SIXTH_BEAT)
	
	for i in Global.song_beats_total * 8:
		if i % 2 == 0: continue
		var new_beat_indicator = Prefabs.beat_indicator.instantiate()
		$Eighth.add_child(new_beat_indicator)
		new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT)
	
	remove_indicators()
	Events.emit_signal('update_snapping', Global.snapping_ratios.find(Global.snapping_factor))

func reset_indicators():
	var difference = Global.song_beats_total + 1 - $Beat.get_child_count()
	if difference != 0:
		for i in range(Global.song_beats_total - difference + 1, Global.song_beats_total + 1, 1 if difference>0 else -1):
			if difference > 0:
				var new_beat_indicator = Prefabs.beat_indicator.instantiate()
				$Beat.add_child(new_beat_indicator)
				new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.BEAT)
			else:
				$Beat.remove_child($Beat.get_child($Beat.get_child_count()-1))
		
		for i in range((Global.song_beats_total - difference) * 2, Global.song_beats_total * 2, 1 if difference>0 else -1):
			if i % 2 == 0: continue
			if difference > 0:
				var new_beat_indicator = Prefabs.beat_indicator.instantiate()
				$Half.add_child(new_beat_indicator)
				new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.HALF_BEAT)
			else:
				$Half.remove_child($Half.get_child($Half.get_child_count()-1))
		
		for i in range((Global.song_beats_total - difference) * 3, Global.song_beats_total * 3, 1 if difference>0 else -1):
			if i % 3 == 0: continue
			if difference > 0:
				var new_beat_indicator = Prefabs.beat_indicator.instantiate()
				$Third.add_child(new_beat_indicator)
				new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.THIRD_BEAT)
			else:
				$Third.remove_child($Third.get_child($Third.get_child_count()-1))
		
		for i in range((Global.song_beats_total - difference) * 4, Global.song_beats_total * 4, 1 if difference>0 else -1):
			if i % 2 == 0: continue
			if difference > 0:
				var new_beat_indicator = Prefabs.beat_indicator.instantiate()
				$Quarter.add_child(new_beat_indicator)
				new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.QUARTER_BEAT)
			else:
				$Quarter.remove_child($Quarter.get_child($Quarter.get_child_count()-1))
		
		for i in range((Global.song_beats_total - difference) * 6, Global.song_beats_total * 6, 1 if difference>0 else -1):
			if i % 3 == 0: continue
			if i % 2 == 0: continue
			if difference > 0:
				var new_beat_indicator = Prefabs.beat_indicator.instantiate()
				$Sixth.add_child(new_beat_indicator)
				new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.SIXTH_BEAT)
			else:
				$Sixth.remove_child($Sixth.get_child($Sixth.get_child_count()-1))
		
		for i in range((Global.song_beats_total - difference) * 8, Global.song_beats_total * 8, 1 if difference>0 else -1):
			if i % 2 == 0: continue
			if difference > 0:
				var new_beat_indicator = Prefabs.beat_indicator.instantiate()
				$Eighth.add_child(new_beat_indicator)
				new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT)
			else:
				$Eighth.remove_child($Eighth.get_child($Eighth.get_child_count()-1))
	
	remove_indicators()
	Events.emit_signal('update_snapping', Global.snapping_ratios.find(Global.snapping_factor))

func remove_indicators():
	var song_end = -(Global.song_length - Global.offset * 2) * Global.note_speed
	
	for i in range($Beat.get_child_count()-1, -1, -1):
		var beat = $Beat.get_child(i)
		print("Beat Position: ", beat.position.x, " | Song Length Position: ", song_end)
		if beat.position.x < song_end: $Beat.remove_child(beat)
		else: break
	
	for i in range($Half.get_child_count()-1, -1, -1):
		var half = $Half.get_child(i)
		print("Half Position: ", half.position.x, " | Song Length Position: ", song_end)
		if half.position.x < song_end: $Half.remove_child(half)
		else: break
	
	for i in range($Third.get_child_count()-1, -1, -1):
		var third = $Third.get_child(i)
		print("Third Position: ", third.position.x, " | Song Length Position: ", song_end)
		if third.position.x < song_end: $Third.remove_child(third)
		else: break
	
	for i in range($Quarter.get_child_count()-1, -1, -1):
		var quarter = $Quarter.get_child(i)
		print("Quarter Position: ", quarter.position.x, " | Song Length Position: ", song_end)
		if quarter.position.x < song_end: $Quarter.remove_child(quarter)
		else: break
	
	for i in range($Sixth.get_child_count()-1, -1, -1):
		var sixth = $Sixth.get_child(i)
		print("Sixth Position: ", sixth.position.x, " | Song Length Position: ", song_end)
		if sixth.position.x < song_end: $Sixth.remove_child(sixth)
		else: break
	
	for i in range($Eighth.get_child_count()-1, -1, -1):
		var eighth = $Eighth.get_child(i)
		print("Eighth Position: ", eighth.position.x, " | Song Length Position: ", song_end)
		if eighth.position.x < song_end: $Eighth.remove_child(eighth)
		else: break

func _process(_delta):
	note_pos = Global.song_pos * Global.note_speed
	note_offset = Global.offset * Global.note_speed
	position.x = note_pos - note_offset
	
	$Gradient.position.x = -position.x - 960
	$Label.position.x = -position.x - 944

# Add Physical note to timeline
func _on_note_created(new_note_data):
	Global.project_saved = false
	var new_note = Prefabs.note.instantiate()
	new_note.setup(new_note_data)
	$Notes.add_child(new_note)

# Changes BPM of the song for charting
func _physics_process(_delta):
	if modifier_count != Timeline.modifier_track.get_child_count():
		modifier_count = Timeline.modifier_track.get_child_count()

func _on_update_bpm():
	if Global.project_loaded: reset_indicators()
