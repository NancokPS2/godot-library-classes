extends Node
class_name ComponentNode
##A base class for registering component-like nodes.
##WARNING: reparenting and/or removing nodes is not currently supported.

@export var targetNode:Node = get_parent()

func _ready() -> void:
	parent_update()

func parent_update():
	if is_node_valid_parent(get_parent()):
		targetNode = get_parent()
		_parent_update()
	else:
		push_error("Invalid parent.")

func is_node_valid_parent(node:Node)->bool:
	return _is_node_valid_parent(node)

func unparent():
	_unparent()

#Virtuals
## Used to check if the node is valid and this use it as a parent
func _is_node_valid_parent(node:Node)->bool:
	push_error("This function must be overriden.")
	return false
	

## Only called if the node is valid
func _parent_update():
	push_error("This function must be overriden.")
	pass

func _unparent():
	push_error("This function must be overriden.")
