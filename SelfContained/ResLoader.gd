extends Node
class_name ResLoader
@export var autoScanFolders:Dictionary = {"res://":"main"}
var resources:Dictionary = {
	"main":{}
}
#Structure:resources:Dict>type:Dict>list:Array


#Loading
func _init():#Loading of files
	for folder in autoScanFolders:
		var type:String = autoScanFolders[folder]
		store_from_folder(folder,type)
	pass

func store_from_folder(folderPath:String,type:String):
	var files:PackedStringArray = DirAccess.get_files_at(folderPath)
	for fileName in files:
		store_single_resource(folderPath, type)
	
func store_single_resource(filePath:String,type:String):
	var fileName:String = filePath.get_file()
	
	#Ensure the type exists in resources
	if not resources.has(type): resources[type] = {}
	
	#Add it to the list of the corresponding type
	resources[type][fileName] = fileName
	
func get_resource(fileName:String,type:String):#If useCategory is true
	if fileName == "":
		push_error("No identifier given for " + type + " returnal.")
	elif type == "":
		push_error("Tried to retrieve resource but a type was not specified for file: " + fileName)
		return
		
	if resources.has(type) and resources[type].has(fileName):
		if resources[type][fileName] is String:#If it has not been loaded yet, do so now.
			resources[type][fileName] = load(fileName)
		return resources[type][fileName]
			
	else: push_error("Either category or the file doesn't exist . Name: "+fileName+" | Type: " + type)
	
	
