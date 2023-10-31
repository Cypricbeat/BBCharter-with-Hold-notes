extends Node

var lib: Dictionary

# Get Dirs in PATH
func get_file_list(path: String) -> Array:
	var files: Array = []
	
	var dir = DirAccess.open(path)
	dir.include_hidden = false
	dir.include_navigational = false
	dir.list_dir_begin() 
	var file_name = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			files.append(file_name)
		file_name = dir.get_next()
	
	return files

# Get Dirs in PATH
func get_file_list_of_type(path: String, type:String) -> Array:
	var files = DirAccess.get_files_at(path)
	
	for i in range(files.size()-1, -1, -1):
		var file = files[i]
		if file.get_extension() != type:
			files.remove_at(i)
	
	return files

func load_single_image(filename: String):
	Assets.lib[filename] = Global.load_texture(Save.project_dir + "/images/" + filename)

func load_images():
	for image in get_file_list_of_type(Save.project_dir + "/images", "png"):
		Assets.lib[image] = Global.load_texture(Save.project_dir + "/images/" + image)

func load_audio():
	for audio in get_file_list_of_type(Save.project_dir + "/audio", "ogg"):
		if audio == Save.asset['song_path']: continue
		Assets.lib[audio] = AudioStreamOggVorbis.load_from_file(Save.project_dir + "/audio/" + audio)
	for audio in get_file_list_of_type(Save.project_dir + "/audio", "mp3"):
		if audio == Save.asset['song_path']: continue
		Assets.lib[audio] = Global.load_mp3(Save.project_dir + "/audio/" + audio)

func get_asset(asset):
	if lib.has(asset):
		return lib[asset]
	else:
		if asset == "true": print("Could not load asset")
		else: print("Could not load asset %s" % asset)
		return null
