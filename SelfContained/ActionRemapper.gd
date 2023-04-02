 #This node MUST be in the tree in order to work. Simply change remappingAction to the name of the action you want to change and press an input for it.
#You may also use the SimpleControls subclass to generate a simple UI that can control this.
#To add a SimpleControls, use: add_child( ActionRemapper.SimpleControls.new($ActionRemapperNode) )
extends Node
class_name ActionRemapper

signal remap_initiated(action)#Emitted when actionRemapping has been successfully set
signal remap_aborted
signal successful_remap(action, event)#action is the name of the action, event is the InputEvent object assigned to it
const KeyLists = {#Definitions for certain key categories
	"NUMBERS":[KEY_0,KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6,KEY_7,KEY_8,KEY_9,KEY_KP_0,KEY_KP_1,KEY_KP_2,KEY_KP_3,KEY_KP_4,KEY_KP_5,KEY_KP_6,KEY_KP_7,KEY_KP_8,KEY_KP_9],
	"MODIFIERS":[KEY_CTRL, KEY_SHIFT],
	"FUNCTIONS":[KEY_F1,KEY_F2,KEY_F3,KEY_F4,KEY_F5,KEY_F7,KEY_F8,KEY_F9,KEY_F10,KEY_F11,KEY_F12],
	"TOGGLES":[KEY_NUMLOCK, KEY_SCROLLLOCK, KEY_CAPSLOCK]
}

enum InputTypes {MOUSE_AXIS=1<<0, MOUSE_BUTTONS=1<<1, NUMBERS=1<<2, MODIFIERS=1<<3, FUNCTIONS=1<<4, JOYPAD=1<<5, TOGGLES=1<<6}

#What kind of inputs should not be taken into account for remapping, should be set from the inspector
#BUG: JOYPAD mappings are always excluded at the moment, due to engine bugs
@export_flags("MOUSE_AXIS:1", "MOUSE_BUTTONS:2", "NUMBERS:4", "MODIFIERS:8", "FUNCTIONS:16","JOYPAD:32", "TOGGLES:64") var inputTypeExcluded:int = InputTypes.MOUSE_AXIS + InputTypes.JOYPAD ## test

#If true, prints information of what is happening to the Output
@export var debugMode:bool=true

#Keys that will cancel the remap attempt once initiated
@export var abortKeys:Array[int] = [KEY_ESCAPE]

#How many events are allowed per action
@export var maxEventsPerAction:int = 2

#If true and the max amount of events are reached for the given action, replace the last one
@export var autoReplace:bool = true

#Set this to the name of an action to start the process
var remappingAction:String = "":
	set(value):
		if not get_tree():
			push_error("ActionRemapper must be in the scene tree in order to work.")
		else:
			await get_tree().process_frame
			remappingAction = value
			if debugMode and remappingAction != "": print("Remapper is ready for input.")
			if remappingAction != "": emit_signal("remap_initiated", remappingAction)

	

func get_events_from_action(action:StringName):
	InputMap.action_get_events(action)
	
func remap_action(action:String,input:InputEvent, maxInputs:int = maxEventsPerAction, forceReplace:bool = autoReplace):
	if not InputMap.has_action(action): 
		push_error("'" + action + "' is not an existant action. Resetting var remappingAction.")
		emit_signal("remap_aborted")
		remappingAction = ""
		return

	if InputMap.action_get_events(action).size() >= maxInputs:#Too many inputs
		if forceReplace:#Instructed to just replace them
			var eventsInThisAction = InputMap.action_get_events(action)
			InputMap.action_erase_event(action, eventsInThisAction[0])
		else:
		#InputMap.action_erase_events(action):
			push_error("Too many events assigned to" + action + " remap aborted.")
			emit_signal("remap_aborted")
			return
	
	InputMap.action_add_event(action,input)
	if debugMode: print("Successfully mapped: " + str(input) + " to action: " + action + ". Using device " + str(input.device) )
	emit_signal("successful_remap", action, input)
	remappingAction = ""

func _input(event: InputEvent) -> void:
	if remappingAction == "" or !is_valid_event(event): return
	if debugMode: print("Attempted remap using event: " + str(event))
	remap_action(remappingAction, event)

func is_valid_event(event:InputEvent)-> bool:
	if event is InputEventKey and abortKeys.has(event.keycode): #Cancel input
		emit_signal("remap_aborted")
		remappingAction = ""
		if debugMode: print("Remapping aborted with cancel key.")
		return false
	
	if event is InputEventMouseMotion and (inputTypeExcluded & InputTypes.MOUSE_AXIS): return false
	
	if event is InputEventMouseButton and (inputTypeExcluded & InputTypes.MOUSE_BUTTONS): return false
	
#	if event is InputEventJoypadButton or InputEventJoypadMotion and (inputTypeExcluded & InputTypes.JOYPAD): return false
	
	if event is InputEventKey:
		if KeyLists.NUMBERS.has(event.keycode) and (inputTypeExcluded & InputTypes.NUMBERS): return false
		if KeyLists.MODIFIERS.has(event.keycode) and (inputTypeExcluded & InputTypes.MODIFIERS): return false
		if KeyLists.FUNCTIONS.has(event.keycode) and (inputTypeExcluded & InputTypes.FUNCTIONS): return false
		if KeyLists.TOGGLES.has(event.keycode) and (inputTypeExcluded & InputTypes.TOGGLES): return false
			
	return true

class SimpleControls extends Panel: #Creates a series of control nodes that allow for easy usage of the ActionRemapper, must be initialized with a reference to a remapper
	
	## These strings can be replaced by actions of your project
	const defaultActions:Array[String] = ["move_forward", "move_backward", "move_left", "move_right", "primary_click", "secondary_click"]
	
	## The actions that will be shown in the list, setup() should be called after this is changed
	var validActions:Array[String] = defaultActions

	## Automatically set with new()
	var remapperReference:ActionRemapper
	
	func _init(remapper:ActionRemapper) -> void:
		remapperReference = remapper
		set_anchors_preset(Control.PRESET_FULL_RECT)
		
	func _ready() -> void:
		setup()
	
	func filter_valid_actions():
		validActions = validActions.filter( func(action): if InputMap.has_action(action): return true )
		
	func setup():
		for child in get_children(): child.queue_free()
		filter_valid_actions()
		
		var container := VBoxContainer.new()
		add_child(container)
		container.set_anchors_preset(Control.PRESET_FULL_RECT)
		for action in validActions:
			var splitter := HSplitContainer.new()
			var label := Label.new()
			var button := Button.new()
			
			container.add_child(splitter)
			splitter.add_child(label); splitter.add_child(button)
			splitter.set_anchors_preset(Control.PRESET_FULL_RECT); label.set_anchors_preset(Control.PRESET_FULL_RECT); button.set_anchors_preset(Control.PRESET_CENTER)
			button.custom_minimum_size = Vector2(16,16)
			splitter.dragger_visibility = SplitContainer.DRAGGER_HIDDEN
			
			label.text = action
			button.pressed.connect( Callable(remapperReference,"set").bind("remappingAction",action) )
			
