extends Node
class_name ResourceManager

const cachePath:String = "user://cache/main.txt"
const NO_IDENTIFIER:String = "_RESOURCEMANAGER_INTERNAL_NO_IDENTIFIER_ASSIGNED_"
const ALL_POOLS:String = "_RESOURCEMANAGER_INTERNAL_ALL_POOLS_"

#Folders whose contents will be automatically added when this node is ready
@export var autoScanFolders:Dictionary = {} #Directory:group

## Automatically replaces paths with the file when added to a group
@export var keepLoadedDefault:bool = true

## Keeps any requested resources loaded for later. Forced if autoLoadResources is true. Careful with memory usage.
#@export var keepResourcesLoaded:bool:
#	set(val):
#		if autoLoadResources: val = true
#		keepResourcesLoaded = true

var resources:Dictionary
var resourcesUnidentified:Dictionary

var pools:Dictionary


#Loading
func _enter_tree() -> void:#Loading of files
	for folder in autoScanFolders:
		var group:String = autoScanFolders[folder]
		store_from_folder(folder,group)
	pass

func store_from_folder(folderPath:String,group:String, keepLoaded:bool=keepLoadedDefault):
	var files:PackedStringArray = DirAccess.get_files_at(folderPath)
	for fileName in files:
		store_single_resource(folderPath+fileName, group, keepLoaded)
	
func store_single_resource(filePath:String,group:String, keepLoaded:bool=keepLoadedDefault):
#	var fileName:String = filePath.get_file()
	if not filePath.get_extension() == "tres": push_error("Extension must be tres but it is " + filePath.get_extension()); return
	var resLoaded:Resource = load(filePath)
	
	var identifier:String = _get_identifier(resLoaded)
	
	assert(identifier is String)
	if identifier == NO_IDENTIFIER: 
		push_warning("No identifier could be set, pooling in unidentified section. File path: {0} | Identifier: {1} | Group: {2}".format([filePath, identifier, group])) 
		store_single_resource_unidentified(filePath, group, keepLoaded)
	
	#Ensure the group exists in resources
	if not resources.has(group): resources[group] = {}
	
	#Add it to the list of the corresponding group
	if keepLoaded:
		resources[group][identifier] = resLoaded
	else:
		resources[group][identifier] = filePath
	
#	resources[group][fileName] = fileName

func store_single_resource_unidentified(filePath:String, group:String, keepLoaded:bool=keepLoadedDefault):	
	if not resourcesUnidentified.has(group): resourcesUnidentified[group] = []
	if keepLoaded:
		resourcesUnidentified[group] = load(filePath)
	else:
		resourcesUnidentified[group] = filePath

func reload_from_folders():
#	var cache:=ConfigFile.new()
	clear()
	
	for folder in autoScanFolders:
		var group:String = autoScanFolders[folder]
		store_from_folder(folder,group)
	
## If check unidentified is true, a sweep will be made in an attempt to pull the resource from a group of unidentified resources.
func assign_identifier(resource:Resource, identifier:String, checkUnidentified:bool, priorityGroup:String):
	#TODO
	pass
	

## Attempts to retrieve a resource with the given identifier and keeps it loaded.
func get_resource(identifier:String,group:String)->Resource:

	if resources.has(group) and resources[group].has(identifier):
		
		#If it has not been loaded yet, do so now.
		if resources[group][identifier] is String:
			resources[group][identifier] = load(resources[group][identifier])
			
		return resources[group][identifier]
			
	else: 
		push_error("Could not find resource with name '{0}' in group '{1}'".format([identifier,group]))
		return null

func get_resources_unidentified(group:String)->Array:
	if not resourcesUnidentified.has(group): push_error("There's no group with this name.")
	return resourcesUnidentified.get(group,[])
	pass

## Used when registering a Resource to the main Dictionary
func _get_identifier(resource:Resource)->String:
	return resource.resource_path

	
func add_to_pool_by_identifier(identifier:String, group:String, targetPool:String):
	var res:Resource = get_resource(identifier, group)
	add_to_pool_by_resource(res, targetPool)
	
func add_to_pool_by_resource(resource:Resource, targetPool:String):
	if not pools.has(targetPool): pools[targetPool] = []
	
	if targetPool == ALL_POOLS:
		for pool in pools:
			pools[pool].append(resource)
	else:
		pools[targetPool].append(resource)

func remove_from_pool(resource:Resource, pool:String):
	pass

func get_all_in_group(group:String, includeUnidentified:bool = true)->Array:
	if not resources.has(group): 
		push_error("The group {0} does not exist.".format([group]))
		return []
	
	var returned:Array
	if includeUnidentified: returned.append_array(get_resources_unidentified(group))
	
	returned.append_array(resources[group].values())
		
	return returned

func clear():
	resources.clear()
	resourcesUnidentified.clear()
