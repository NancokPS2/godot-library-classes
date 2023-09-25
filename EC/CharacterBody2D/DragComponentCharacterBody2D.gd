extends ComponentNode
class_name CharacterBody2DComponentDrag
## Slows down a CharacterBody2D by a set amount per frame.

@export var dragFactor:float

func _is_node_valid_parent(node:Node)->bool:
	return node is CharacterBody2D
	
func _parent_update():
	if targetNode:
		set_physics_process(true)
	else:
		set_physics_process(false)
	
#New funcs
func _physics_process(delta: float) -> void:
	targetNode.velocity *= dragFactor
