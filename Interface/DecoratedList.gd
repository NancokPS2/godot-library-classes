extends VBoxContainer
class_name DecoratedList


@export var entries:Array[NodePath]
@export var icons:Array[Texture] #entryIndex:Texture
@export var defaultObject:Node

#func _ready():
	

#func get_properties()->Array:
#	var props:Array
#	for entry in entries:
#		defaultObject.get_indexed(entry)
#		props.append(1)
#	return props
func update_from_entries(objectUsed:Object = defaultObject):
	for child in get_children(): child.queue_free()
	
	var index:int=0
	for entry in entries:
		var icon:Texture
		if icons.size() < index: 
			icon = icons[index]
		else:
			icon = null
			
		add_entry_node(objectUsed, entry, "", icon)
		index+=1

	
func add_entry_node(object:Object, entry:NodePath, displayedName:String = "", icon:Texture = Texture.new()):
	
	var entryName:String 
	if displayedName == "":
		entryName = entry.get_subname(entry.get_subname_count()-1)
	else:
		entryName = displayedName
	var entryObj:=Entry.new(object, entry, entryName, icon)
	add_child(entryObj)
	
	
	
	




class Entry extends Control:
	
	var objectTracked:Object
	var propertyPath:NodePath
	var iconTexture:Texture
	
	var iconNode:=TextureRect.new()
	
	var nameLabel:=Label.new()
	var valLabel:=Label.new()
	
	var entryName:String
	
	func _init(_objectTracked:Object, _propertyPath:NodePath, _entryName:String, _iconTexture:Texture) -> void:
		objectTracked = _objectTracked 
		propertyPath = _propertyPath
		entryName = _entryName
		iconTexture = _iconTexture
	
	
	func update_entry():
		nameLabel.text = entryName
		valLabel.text = str(objectTracked.get_indexed(propertyPath))
