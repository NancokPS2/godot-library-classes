extends ComponentNode
class_name Area2DComponentInputActionReceiver

signal interacted

signal interaction_finished

@export var actionName:StringName = &"interact"


func _is_node_valid_parent(node:Node)->bool:
	return node is Area2D

func _parent_update():
	targetNode.input_event.connect(input_event_receiver)
	targetNode.mouse_exited.connect( set.bind("actionHeld",false) )
	
	
#New funcs
func input_event_receiver(_viewport:Node, event:InputEvent, _shape:int):
	if event.is_action_pressed(actionName):
		interacted.emit()
		
#		if canBeHeld: 
#			actionHeld = true
	
	
