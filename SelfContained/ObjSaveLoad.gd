extends Resource
class_name ObjSaveLoad

@export var objClass:String
#@export var propertiesToSave:Array[String]
@export var propertiesSaved:Dictionary
@export var storedScript:Script
@export var propertiesToLoad:Array[String]

func save_object_here(_object:Object, _propertiesSaved:Array[String], _propertiesToLoad:Array[String]=[]):
	propertiesSaved.clear(); propertiesToLoad.clear(); storedScript = null; objClass = "null"
	save_properties(_object, _propertiesSaved, _propertiesToLoad)
	objClass = _object.get_class()
	storedScript = _object.get_script()

func save_properties(_object:Object, _propertiesSaved:Array[String], _propertiesToLoad:Array[String]=[]):
	objClass = _object.get_class()
	for property in _propertiesSaved:
		var propertyValue = _object.get(property)
		if propertyValue is Node:
			var packedScene:=PackedScene.new()
			var errCode:Error = packedScene.pack(propertyValue)
			if errCode != OK: push_error("Failed packing with code: "+str(errCode))
			propertiesSaved[property] = packedScene
		else:
			propertiesSaved[property] = _object.get(property)

func apply_properties(_object:Object):
	for property in propertiesSaved:
		var propertyValue = propertiesSaved[property]
		if propertyValue is PackedScene:
			var node:Node = propertyValue.instantiate()
			_object.set(property, node)
		else: 
			_object.set(property, propertyValue)

func get_object()->Object:
	var object:Object = ClassDB.instantiate(objClass)
	object.set_script(storedScript)
	apply_properties(object)
	return object
