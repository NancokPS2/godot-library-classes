extends GridContainer
class_name TSCNSelectContainer
## Simple container that can display packed scenes and emit a signal when one is chosen or even automatically load one.
## Note: _init and _ready are already overriden. If you want to override them, include super._ready() or super._init() to execute their original implemetations. 

## Emitted when a scene is selected trough pressing on it's display, returns the scene stored in the display.
signal scene_selected(scene:PackedScene)

## Used to access the created displays
signal created_display(display:SceneDisplay)

## If enabled, clicking on a scene will attempt to load it directly after emitting it's signal. Turn this off if you intend to use your own behaviour.
@export var autonomousMode:bool = false

## Automatically loads the scenes from the paths specified in this array into sceneScenes
@export var scenePaths:Array[String]

## The custom_minimum_size applied to the displays.
@export var displayMinSize:Vector2 = Vector2(240,120)

## Store the loaded PackedScenes, overwritten by scenePaths.
var sceneArray:Array[PackedScene]

## Array of references to created displays. For internal purposes.
var displayRefs:Array[SceneDisplay]

func _init(_scenePaths:Array[String] = []) -> void:
	scenePaths = _scenePaths
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _ready() -> void:
	load_scenes()
	generate_displays()

## Used to handle behaviour of buttons for autonomous mode, it's not recommended to call this manually. Use the signal instead.
func select_scene(scene:PackedScene):
	emit_signal("scene_selected",scene)
	if autonomousMode:
		load_single_scene(scene)

## Simply loads a scene if autonomousMode is enabled, can be safely overriden to do something else when attempting to load. It is recommended to use the scene_select signal instead.
func load_single_scene(scene:PackedScene):
	get_tree().change_scene_to_packed(scene)
	

## Load all scenes in scenePaths and stores them on sceneScenes, you may specificy a different array if desired.
func load_scenes(scenes:Array[String]=scenePaths):
	print_debug("Loading scenes: " + str(scenes))
	sceneArray.clear()
	for path in scenes:
		var scene:PackedScene = load(path)
		assert(scene is PackedScene)
		sceneArray.append(scene)
	
## Fills this GridContainer with scene displays taken from sceneScenes.
func generate_displays(_sceneArray:Array[PackedScene]=sceneArray, optionalMetadata:={}):
	for display in displayRefs: display.queue_free(); displayRefs.clear()
	
	for scene in _sceneArray:
		var sceneName:String = _get_scene_name(scene)
		var sceneDescription:String = _get_scene_description(scene)
		var sceneIcon:Texture = _get_scene_icon(scene)
		var displayNode:=SceneDisplay.new( scene, sceneName, sceneIcon, Vector2(size.x, displayMinSize.y), sceneDescription )
		
		add_child(displayNode)
		emit_signal("created_display",displayNode)
		for metaKey in optionalMetadata: displayNode.set_meta(metaKey, optionalMetadata[metaKey])
		displayRefs.append(displayNode)
		
		displayNode.pressed.connect(select_scene.bind(displayNode.storedScene))

## Virtual method for getting the scene's name, should be overriden with a method that reads and acquires the name of the scene from the PackedScene
func _get_scene_name(_scene:PackedScene)->String:
	return "scene"
	
func _get_scene_description(_scene:PackedScene)->String:
	return ""
## Same as _get_scene_name but for the icon
func _get_scene_icon(_scene:PackedScene)->Texture:
	return load("res://icon.svg")




class SceneDisplay extends Button:
	var dimensions:Vector2

	var iconTex:Texture:
		set(val):
			iconTex = val
			if iconNode: iconNode.texture = iconTex
	var nameDisplayed:String:
		set(val):
			nameDisplayed = val
			if nameNode: nameNode.text = nameDisplayed
	var descriptionDisplayed:String:
		set(val):
			descriptionDisplayed = val
			if descriptionNode: descriptionNode.text = descriptionDisplayed
	var storedScene:PackedScene
	
	var iconNode:=TextureRect.new()
	var nameNode:=Label.new()
	var descriptionNode:=Label.new()
	
	func _init(_storedScene:PackedScene, _nameDisplayed:String, _iconTex:Texture, _dimensions:Vector2, _descriptionDisplayed:String = "") -> void:
		nameDisplayed = _nameDisplayed
		iconTex = _iconTex
		dimensions = _dimensions
		storedScene = _storedScene

	func _ready() -> void:
		iconNode.texture = iconTex
		nameNode.text = nameDisplayed
		
		add_child(iconNode)
		add_child(nameNode)
		add_child(descriptionNode)
		
		custom_minimum_size = dimensions
		size = custom_minimum_size
		
		iconNode.expand_mode = TextureRect.EXPAND_IGNORE_SIZE#Ignore scaling, for forcing manual size.
		iconNode.set_anchors_preset(Control.PRESET_TOP_LEFT)
		iconNode.custom_minimum_size = Vector2(dimensions.y, dimensions.y)
		iconNode.size = iconNode.custom_minimum_size
		
		nameNode.position = Vector2(iconNode.size.x,0)
		nameNode.autowrap_mode = TextServer.AUTOWRAP_WORD
		nameNode.custom_minimum_size = Vector2(dimensions.x-iconNode.size.x - 2.0, dimensions.y/2)		
		
		descriptionNode.position = Vector2(iconNode.size.x, nameNode.size.y)
		descriptionNode.size = Vector2(dimensions.x - position.x, dimensions.y - position.y)
#		nameNode.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
#		nameNode.set_anchors_preset(Control.PRESET_TOP_WIDE)
#		nameNode.set_anchor_and_offset(SIDE_LEFT,0.0, iconNode.size.x)

#		nameNode.size = nameNode.custom_minimum_size
		
		
