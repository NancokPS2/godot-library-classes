extends ComponentNode
class_name NodeComponentInputHelper
## WIP
## Used to filter inputs from specific devices, for split screen games.

const MOUSE_AND_KEYBOARD_PREFIX:String = "M&K"
const MOUSE_AND_KEYBOARD:int = -1

const UNHANDLED_INPUT_METHOD:String = "_unhandled_input"


@export var active:bool=true:
	set(val):
		active = val
		perFrame = perFrame

## Check per frame instead of per input
@export var perFrame:bool:
	set(val):
		perFrame = val
		set_process_unhandled_input(!perFrame)
		set_process(perFrame)

## Which controller to answer to, if -1, the mouse and keyboard are chosen.
@export var controllerID:int = MOUSE_AND_KEYBOARD

## Actions named here will be copied and the copy will only retain events with this device
@export var actionsIsolated:Array[StringName] = InputMap.get_actions()

## Used to set targets from the editor
@export var inputReceivers:Array[Node]
			
## Name of the method that will receive the event on the node, must have a single InputEvent argument
@export var inputMethodName:String = UNHANDLED_INPUT_METHOD

var prefixedToNormalActions:Dictionary

var parentID:String

func _is_node_valid_parent(node:Node)->bool:
	return node is Node

func _parent_update():
	parentID = str(get_parent().get_instance_id())
	
	#Disable _unhandled_input if this node is going to use it.
	if inputMethodName == UNHANDLED_INPUT_METHOD:
		targetNode.set_process_unhandled_input(false)
	
	isolate_actions()
		


#New funcs
func get_full_prefix()->String:
	if controllerID != MOUSE_AND_KEYBOARD and not controllerID in Input.get_connected_joypads():
		push_error("No controller with this device ID connected.")
		return "ERROR"

	var controllerName:String
	if controllerID == MOUSE_AND_KEYBOARD:
		controllerName = MOUSE_AND_KEYBOARD_PREFIX

	else:
		controllerName = Input.get_joy_name(controllerID)

	return controllerName+"_"+parentID

func is_event_from_this_component(event:InputEvent):
	InputMap

func get_original_action_name(prefixedAction:String)->String:
	if not prefixedToNormalActions.has(prefixedAction): 
		push_error("This action does not exist.")
		return "ERROR"
	else: 
		return prefixedToNormalActions[prefixedAction]

func get_all_compatible_events(action:String)->Array[InputEvent]:
	var compatibleEvents:Array[InputEvent]
	for event in InputMap.action_get_events(action):
		if event.device == controllerID:
			compatibleEvents.append(event)

	return compatibleEvents
#
func isolate_actions():
	prefixedToNormalActions.clear()

	for action in actionsIsolated:
		if not InputMap.has_action(action): 
			push_error("Cannot isolate {0} action because it doesn't exist in the InputMap")
			continue

		var newActionName:String = get_full_prefix()+action
		prefixedToNormalActions[newActionName] = action

		InputMap.add_action(newActionName)

		#Add a new version of the events tuned to only respond to a certain device
		for event in InputMap.action_get_events(action).duplicate():
			event.device = controllerID if controllerID != MOUSE_AND_KEYBOARD else 0

			#If using M&K but the event is for a controller, ignore.
			if controllerID == MOUSE_AND_KEYBOARD and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
				continue

			#If it's for a controller but the event isn't from one, ignore.
			if controllerID != MOUSE_AND_KEYBOARD and not (event is InputEventJoypadButton or event is InputEventJoypadMotion):
				continue

			InputMap.action_add_event(newActionName, event)
		
func attach_to_node(node:Node):
	if not node.has_method(inputMethodName): push_error("This node lacks the required method."); return
	if not node in inputReceivers: inputReceivers.append(node)
	
	if inputMethodName == UNHANDLED_INPUT_METHOD:
		node.set_process_unhandled_input(false)
	

func detach_from_node(node:Node):
	if node in inputReceivers: inputReceivers.erase(node)
	
	if inputMethodName == UNHANDLED_INPUT_METHOD:
		node.set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
#	if event == returnControlInput: return_control()
	if not active:  return
	
	var actionEvent:=InputEventAction.new()
	
	#Check all saved actions
	for action in actionsIsolated:
		
		#If it corresponds to one of the saved actions
		if event.is_action(action):
			actionEvent.action = get_original_action_name(action)
			actionEvent.pressed = event.is_pressed()
			actionEvent.strength = event.get_action_strength(get_original_action_name(action))
			
			#Send it
			for node in inputReceivers:
				Callable(node, inputMethodName).call(actionEvent)
			break
	
#	#If using keyboard and the event is not from a controller
#	if controllerID == MOUSE_AND_KEYBOARD and not (event is InputEventJoypadButton or event is InputEventJoypadMotion):
#		assert(event.device == 0)
#		for node in inputReceivers:
#			Callable(node, inputMethodName).call(event)
#
#	#If using a controller and the device ID matches the controller used.
#	elif controllerID != MOUSE_AND_KEYBOARD and event.device == controllerID: 
#		for node in inputReceivers:
#			Callable(node, inputMethodName).call(event)
			


