extends VBoxContainer
class_name DecoratedList


@export var entries:Array[StringName]
@export var icons:Array[Texture] #entryIndex:Texture
@export var entryNameOverrides:Array[String]
@export var defaultObject:Node

func _ready():
	if defaultObject:
		update_from_entries()
	
func set_fonts(nameFont:Font, valFont:Font):
	for child in get_children():
		if child is Entry:
			child.nameFont = nameFont
			child.valFont = valFont
			child.update_entry()

func update_from_entries(objectUsed:Object = defaultObject):
	for child in get_children(): child.queue_free()
	
	var index:int=0
	for entry in entries:
		var icon:Texture
		if not icons.is_empty() and index < icons.size(): 
			icon = icons[index]
		else:
			icon = null
		
		var displayedText:String
		if not entryNameOverrides.is_empty() and index < entryNameOverrides.size(): 
			displayedText = entryNameOverrides[index]
		else:
			displayedText = entry
		
		
		add_entry_node(objectUsed, entry, displayedText, icon)
		index+=1

	
func add_entry_node(object:Object, entry:StringName, displayedName:String = "", icon:Texture = Texture.new()):
	
	var entryName:String 
	if displayedName == "":
		entryName = entry.split(":")[-1]
	else:
		entryName = displayedName
	var entryObj:=Entry.new(object, entry, entryName, icon)
	add_child(entryObj)
	
	
	
	




class Entry extends HBoxContainer:
	
	var nameFont:Font
	var valFont:Font
	
	var objectTracked:Object
	var propertyPath:StringName
	var iconTexture:Texture
	
	var iconNode:=TextureRect.new()
	
	var nameLabel:=Label.new()
	var valLabel:=Label.new()
	
	var entryName:String
	
	func _init(_objectTracked:Object, _propertyPath:StringName, _entryName:String, _iconTexture:Texture) -> void:
		objectTracked = _objectTracked 
		propertyPath = _propertyPath
		entryName = _entryName
		iconTexture = _iconTexture
	
	func _ready() -> void:
		add_child(iconNode)
		add_child(nameLabel)
		add_child(valLabel)
		update_entry()
	
	func update_entry():
		nameLabel.text = entryName
		valLabel.text = str(objectTracked.get_indexed(NodePath(propertyPath)))
		iconNode.texture = iconTexture
		if nameFont is Font: nameLabel.add_theme_font_override("font",nameFont)
		if valFont is Font: valLabel.add_theme_font_override("font",valFont)
		
		
