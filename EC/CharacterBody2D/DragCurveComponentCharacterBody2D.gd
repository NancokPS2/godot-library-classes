extends ComponentNode
class_name CharacterBody2DComponentDragCurve
## Slows a CharacterBody2D by a variable amount per frame, using a curve.
## The end of the curve is reached at maxVelocity

@export var dragCurve:=Curve.new()
@export var maxVelocity:float = 200


func _is_node_valid_parent(node:Node)->bool:
	return node is CharacterBody2D
	
func _parent_update():
	if targetNode:
		set_physics_process(true)
	else:
		set_physics_process(false)
	
#New funcs
func _physics_process(delta: float) -> void:
	var samplePos:float = targetNode.velocity.length() / maxVelocity
	var sampledDrag:float = dragCurve.sample(samplePos)
	targetNode.velocity = targetNode.velocity.lerp(Vector2.ZERO, sampledDrag).limit_length(maxVelocity)

