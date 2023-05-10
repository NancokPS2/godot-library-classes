extends Node
#TODO: Make cache system that stores the names of the resources and their location in the dictionary
var resources:Dictionary = {}
#Structure:resources:Dict>type:Dict>list:Array


#Loading
func _init():#Loading of files
	pass

func load_from_folder(folderPath:String,type:String):
	var files:Array[String] = DirAccess.get_files_at(folderPath)
	for fileName in files:
		var loadedFile = load(folderPath+str(fileName))
		if !resources.has(type):#Ensure the type exists in resources
			resources[type] = []
			
		if loadedFile is GDScript:#If it is a script of a resource
			var script = loadedFile
			loadedFile = Resource.new()
			loadedFile.set_script(script)

			
		resources[type].append(loadedFile.duplicate())#Add it to the list of the corresponding type
	pass
	
func get_resource(identifier:String,type:String,useCategory:bool = false):#If useCategory is true
	if identifier == "":
		push_error("No identifier given for " + type + " returnal.")
	elif type == "":
		push_error("Tried to retrieve resource but a type was not specified for identifier: " + identifier)
		return
	if not useCategory:#If NOT USING a category
		for resource in resources[type]:
			if resource.internalName == identifier:
				assert(resource != null)
				return resource
	else:#If USING a category
		for resource in resources[type]:
			if resources.get("resCategory") != null and resource.get("resCategory") == identifier:
				assert(resource != null)
				return resource
	push_error("Resource not found. Name: "+identifier+" | Type: " + type)
	
func get_all_resources(type:String)->Array:
	return resources[type]
	
#var loadedAbilities:Array
#func load_abilities(pathToFolder:String):
#	var loading = Directory.new()
#	loading.open(pathToFolder)#Start loading abilities
#	loading.list_dir_begin()
#	var file_name = loading.get_next()
#	while file_name != "":
#		if !loading.current_is_dir() and file_name.ends_with(".gd"):#If it is a script...
#			var abilityScript = load(pathToFolder + file_name)#Load the script into a var
#			var ability = Resource.new()#Create an Ability resource
#			ability.script=abilityScript#Attach the script to the resource
#			if ability is Resource:#Make sure it resulted in an Ability
#				loadedAbilities.append(ability)#Add it to the list
#		file_name = loading.get_next()#Get next file
#
#var loadedClasses:Array
#func load_classes(pathToFolder:String):
#	var loading = Directory.new()
#	loading.open(pathToFolder)
#	loading.list_dir_begin()
#	var file_name = loading.get_next()
#	while file_name != "":
#		if !loading.current_is_dir() and file_name.ends_with(".tres"):#If it is a resource...
#			var unitClass =  load(pathToFolder + file_name)#Load the script into a var
#			if unitClass is Resource:#Make sure it resulted in a resource
#				loadedClasses.append(unitClass)#Add it to the list
#		file_name = loading.get_next()#Get next file
#
#var loadedRaces:Array
#func load_races(pathToFolder:String):
#	var loading = Directory.new()
#	loading.open(pathToFolder)
#	loading.list_dir_begin()
#	var file_name = loading.get_next()
#	while file_name != "":
#		if !loading.current_is_dir() and file_name.ends_with(".tres"):#If it is a resource...
#			var unitRace =  load(pathToFolder + file_name)#Load the script into a var
#			loadedRaces.append(unitRace)#Add it to the list
#		file_name = loading.get_next()#Get next file
#
#var loadedFactions:Array
#func load_factions(pathToFolder:String):
#	var loading = Directory.new()
#	loading.open(pathToFolder)
#	loading.list_dir_begin()
#	var file_name = loading.get_next()
#	while file_name != "":
#		if !loading.current_is_dir() and file_name.ends_with(".tres"):#If it is a resource...
#			var faction = load(pathToFolder + file_name)#Load the script into a var
#			loadedFactions.append(faction)#Add it to the list
#		file_name = loading.get_next()#Get next file
#
#var loadedCharacters:Array
#var generatedCharacters:Array
#func load_characters(pathToFolder:String):
#	var loading = Directory.new()
#	loading.open(pathToFolder)
#	loading.list_dir_begin()
#	var file_name = loading.get_next()
#	while file_name != "":
#		if !loading.current_is_dir() and file_name.ends_with(".tres"):#If it is a script...
#			var character = load(pathToFolder + file_name)#Load the script into a var
#			loadedCharacters.append(character)#Add it to the list
#		file_name = loading.get_next()#Get next file

#func load_character(charSaveName:String):
#	loadedCharacters.append( load(Const.dirChars + charSaveName) )
#
#func get_character(charSaveName):
#	for x in loadedCharacters:
#		if x.attributes.saveName:
#			pass
