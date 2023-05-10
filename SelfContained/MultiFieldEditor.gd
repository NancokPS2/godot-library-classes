extends HBoxContainer
class_name MultiFieldEditor
enum SpecialTypes {NONE, TYPE_VEC3I, TYPE_AABB}
@export var fields:Array[Dictionary]# = [{"fieldName":"x", "type":Field.ValueTypes.INT}]
var fieldRefs:Dictionary
@export var maxFieldWidth:int = 3
@export var specialType:SpecialTypes


func _ready() -> void:
	refresh_fields()

func refresh_fields():
	if specialType != SpecialTypes.NONE: create_special_type()
	assert(fields.size()<=6)
	
	for field in fieldRefs.values(): field.queue_free()
	fieldRefs.clear()
	
	for field in fields:
		var newField:=Field.new(field.fieldName, field.type)
		newField.add_theme_constant_override("minimum_character_width",maxFieldWidth)
		fieldRefs[field.fieldName]=newField
		add_child(newField)


func create_special_type():
	fields.clear()
	
	match specialType:
		SpecialTypes.NONE:
			push_error("Tried creating a special field editor with no type set."); return
			
		SpecialTypes.TYPE_VEC3I:
			fields = [{"fieldName":"x", "type":Field.ValueTypes.INT},
			{"fieldName":"y", "type":Field.ValueTypes.INT},
			{"fieldName":"z", "type":Field.ValueTypes.INT}]
			
		SpecialTypes.TYPE_AABB:
			fields=[{"fieldName":"x", "type":Field.ValueTypes.INT},
			{"fieldName":"y", "type":Field.ValueTypes.INT},
			{"fieldName":"z", "type":Field.ValueTypes.INT},
			{"fieldName":"xd", "type":Field.ValueTypes.INT},
			{"fieldName":"yd", "type":Field.ValueTypes.INT},
			{"fieldName":"zd", "type":Field.ValueTypes.INT}]
			var a = 1

func get_value():
	match specialType:
		SpecialTypes.NONE:
			var arrayOfVars:Array
			for field in fieldRefs:
				arrayOfVars.append(field.placeholder_text)
			return arrayOfVars
			
		SpecialTypes.TYPE_VEC3I:
			return Vector3i(int(fieldRefs["x"].text), int(fieldRefs["y"].text), int(fieldRefs["z"].text) )
		
		SpecialTypes.TYPE_AABB:
			var vecOne:=Vector3i(int(fieldRefs["x"].text), int(fieldRefs["y"].text), int(fieldRefs["z"].text) )
			var vecTwo:=Vector3i(int(fieldRefs["xd"].text), int(fieldRefs["yd"].text), int(fieldRefs["zd"].text) )
			return AABB(vecOne, vecTwo)
		
		_:
			push_error("Invalid type set, cannot return.")
			

class Field extends LineEdit:
	enum ValueTypes {INT, FLOAT}
	var lastAcceptedString:String = ""
#	var fieldName:String
	var acceptedType:ValueTypes
	
	
	func sanitize_text(string:String):
		var accepted:bool
		match acceptedType:
			ValueTypes.INT:
				accepted = true if string.is_valid_int() else false 
			
			ValueTypes.FLOAT:
				accepted = true if string.is_valid_float() else false 
					
		if accepted: lastAcceptedString = string
		else: string = lastAcceptedString
	
	func _init(_fieldName:String, _acceptedType:ValueTypes) -> void:
		placeholder_text = _fieldName
		acceptedType = _acceptedType
		text_changed.connect(sanitize_text)
	pass
