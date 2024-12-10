@tool
extends Node
class_name PropertyRegistry
## Creates files based on existing scripts, useful for automation of code duplication


const LB:String = "\n"
const TAB:String = "	"
const QUOTE:String = "\""

## Disables a filter.
const NO_FILTER:int = -1

enum Modes {
	SIMPLE, ##Creates a new script with all of the properties and signals of the originals 
	CONSTANT, ## Saves each script to it's own class with the provided properties
	SIGNAL_NAME_DICT, ##Creates a dictionary of all the signal names of the scripts
	}

@export_group("Actions")
## Creates the script with the selected settings, calls create_file(sourceScripts)
@export var createScript:bool:
	set(val):
		createScript = false
		create_file(sourceScripts)

@export var mode:Modes


@export_group("File")
@export var saveFolder:String = "res://RegistryOutput/"
@export var fileName:String = "Registry"

## What the resulting script will extend, leave empty for none.
@export var scriptExtends:StringName = ""
## The class_name of the resulting script, leave empty for none. Requires scriptExtends to not be empty.
@export var scriptClassName:StringName = ""

@export_group("Generation")

## From which scripts to take data from
@export var sourceScripts:Array[Script]

## Only considers properties of the given type.
@export var propertyTypeFilter:Variant.Type = NO_FILTER

func create_file_contents_simple(script:Script)->String:
	if DirAccess.make_dir_recursive_absolute(saveFolder) != OK: push_error("Cannot create folder " + saveFolder)
	var newFile := FileAccess.open(saveFolder+fileName+".gd", FileAccess.WRITE_READ)
	
	#Content
	
	#Signals
	var signals:Array[Dictionary] = script.get_script_signal_list()
	var signalText:String
	for signa in signals:
		var signalName:String = signa["name"]
		#TODO make it include arguments
		signalText += "signal " + signalName + LB
	signalText += LB
	
	#Properties
	var properties:Array[Dictionary] = script.get_script_property_list()
	var propertyText:String
	for property in properties:
		if _filter_property(property) == false: continue
		
		var propName:String = property["name"]
		var propType:String = get_type_name(property["type"])
		
		var text:String = "var " + propName + propType
		propertyText += text + LB
	propertyText += LB
			
	return signalText + propertyText

func create_file_contents_constant(script:Script)->String:
	if DirAccess.make_dir_recursive_absolute(saveFolder) != OK: push_error("Cannot create folder " + saveFolder)
	var newFile := FileAccess.open(saveFolder+fileName+".gd", FileAccess.WRITE_READ)
	
	#Content
	
	#Signals
	var signals:Array[Dictionary] = script.get_script_signal_list()
	var signalText:String
	for signa in signals:
		var signalName:String = signa["name"]
		#TODO make it include arguments
		signalText += "signal " + signalName + LB
	signalText += LB
	
	#Properties
	var properties:Array[Dictionary] = script.get_script_property_list()
	var propertyText:String
	for property in properties:
		if _filter_property(property) == false: continue
		
		var propName:String = property["name"]
		var propType:String = get_type_name(property["type"])
		
		var text:String = "var " + propName + propType
		propertyText += text + LB
	propertyText += LB
			
	return signalText + propertyText

## Creates the file using all the properties set.
func create_file(scripts:Array[Script]=sourceScripts):
	if DirAccess.make_dir_recursive_absolute(saveFolder) != OK: push_error("Cannot create folder " + saveFolder)
	var newFile := FileAccess.open(saveFolder+fileName+".gd", FileAccess.WRITE_READ)
	
	newFile.store_string(get_header_text())
	
	match mode:
		Modes.SIMPLE:
			for script in scripts:
				print("SIMPLE MODE")
				newFile.store_string(create_file_contents_simple(script))
				
		Modes.CONSTANT:
			for script in scripts:
				print("CONSTANT MODE")
				
				newFile.store_line( "class " + get_script_class_name(script) + " extends RefCounted:")
				
				var contents:String = create_file_contents_simple(script)
				newFile.store_string( contents.indent(TAB) )
				
		Modes.SIGNAL_NAME_DICT:
			for script in scripts:
				newFile.store_string( create_file_contents_signal(script) )
	
	newFile.close()

func create_file_contents_signal(script:Script)->String:
	if DirAccess.make_dir_recursive_absolute(saveFolder) != OK: push_error("Cannot create folder " + saveFolder)
	var newFile := FileAccess.open(saveFolder+fileName+".gd", FileAccess.WRITE_READ)
	
	#Content
	
	#Signals
	var signals:Array[Dictionary] = script.get_script_signal_list()
	var signalText:String = "const " + get_script_class_name(script) + "Signals:Dictionary = {" + LB
	for signa in signals:
		var signalName:String = signa["name"]
		#TODO make it include arguments
		signalText += QUOTE + signalName+QUOTE+ ":"+ QUOTE + signalName +QUOTE+","+ LB
	signalText += "}"
			
	return signalText

	
## Returns the type of the given Variant.Type in string format, as used for typecasting (eg. ":bool" ). Not all types are supported.
func get_type_name(type:Variant.Type)->String:
	match type:
		Variant.Type.TYPE_BOOL:
			return ":bool"
			
		Variant.Type.TYPE_INT:
			return ":int"

		Variant.Type.TYPE_STRING:
			return ":String"
			
		Variant.Type.TYPE_BOOL:
			return ":float"
		
		Variant.Type.TYPE_OBJECT:
			return ":Object"
		
		Variant.Type.TYPE_NIL:
			return ""
			
		_:
			return ""
			push_warning("Unrecognized type {0}. No casting was performed.".format([type]))

## Attempts to get the class_name defined on the given script. Generates a unique name if it can't.	
func get_script_class_name(script:Script)->String:
	var className:String = ""
	
	var lines:PackedStringArray = script.source_code.split("\n")
	for line in lines:
		if line.match("class_name "):
			className = line
			break
			
	if className != "":
		className = className.lstrip("class_name ")
		print(className)
	
	
	if className == "": return script.resource_path.get_file().replace(".gd","")
	else: return className

func get_header_text()->String:
	var content:String = ""
	if scriptExtends!="":
		content+= "extends " + scriptExtends + LB
		if scriptClassName!="":
			content += "class_name " + scriptClassName + LB
	return content


func _filter_property(property:Dictionary)->bool:
	if propertyTypeFilter == -1 or property["type"] == propertyTypeFilter:
		return true
	else: 
		return false
	
func _filter_signal(signa:Dictionary)->bool:
	return true
