@tool
extends Node
class_name PropertyRegistry

const LB:String = "\n"
const TAB:String = "	"
const QUOTE:String = "\""

enum Modes {
	SIMPLE, ##Creates a new script with all of the properties and signals of the originals 
	CONSTANT, ## Saves each script to it's own class with the provided properties
	SIGNAL_NAME_DICT, ##Creates a dictionary of all the signal names of the scripts
	}

@export_group("Actions")
#@export var saveToConfigFile:bool
## Creates the script with the selected settings
@export var createScript:bool:
	set(val):
		createScript = false
		save_scripts(sourceScripts)

@export var mode:Modes



@export_group("File")
@export var saveFolder:String = "res://RegistryOutput/"
@export var fileName:String = "Registry"

## What the resulting script will extend, leave empty for none
@export var scriptExtends:StringName = ""
## The class_name of the resulting script, leave empty for none. Requires scriptExtends to not be empty.
@export var scriptClassName:StringName = ""

@export_group("Property Config")
@export var sourceScripts:Array[Script]
@export var propertyTypeFilter:String = ""
#@export var signalNameFilters:Array[StringName]
#@export var propertyNameFilters:Array[StringName]

## Header not included
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

func save_scripts(scripts:Array[Script]=sourceScripts):
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



#func save_script():
#	if DirAccess.make_dir_recursive_absolute(saveFolder) != OK: push_error("Cannot create folder " + saveFolder)
#	var newFile := FileAccess.open(saveFolder+fileName+".gd", FileAccess.WRITE_READ)
#	#Script initials
#	newFile.store_line("extends " + scriptClass)
#
#	#Content
#
#	for script in sourceScripts:
#		var signals:Array[Dictionary] = script.get_script_signal_list()
#
#		for signa in signals:
#			print(signa)
#			var signalName:String = signa["name"]
#			#TODO make it include arguments
#			newFile.store_line("signal " + signalName)
#
#		newFile.store_line("")
#
#		var properties:Array[Dictionary] = script.get_script_property_list()
#		for property in properties:
#			if _filter_property(property) == false: continue
#
#			var propName:String = property["name"]
#			var propType:String = get_type_name(property["type"])
#
#			var text:String = "var " + propName + propType
#			newFile.store_line( text )
#
#	newFile.close()
	

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

	pass
	
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
	return true
	
func _filter_signal(signa:Dictionary)->bool:
	return true
