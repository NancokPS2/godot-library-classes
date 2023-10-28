extends ComponentNode
class_name Area2DComponentInputActionReceiver
#Can be used by an area to receive inputs filtered by the type name of the action in question

signal interacted

@export var actionName:StringName = &"interact"


func _is_node_valid_parent(node:Node)->bool:
	return node is Area2D

func _parent_update():
	targetNode.input_event.connect(input_event_receiver)
	
#New funcs
func input_event_receiver(_viewport:Node, event:InputEvent, _shape:int):
	if event.is_action_pressed(actionName):
		interacted.emit()
		
	
	
