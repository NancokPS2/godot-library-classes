extends ComponentNode
class_name Area2DComponentDragCharacterBodies
#Applies "drag" to CharacterBody3Ds that enter the area, slowing them down.

@export var dragCurve:=Curve.new()
@export var maxVelocity:float = 200


func _is_node_valid_parent(node:Node)->bool:
	return node is Area2D
	
func _parent_update():
	if targetNode:
		set_physics_process(true)
	else:
		set_physics_process(false)
	
#New funcs
func _physics_process(delta: float) -> void:
	for body in targetNode.get_overlapping_bodies():
		if body is CharacterBody2D:
			var samplePos:float = body.velocity.length() / maxVelocity
			var sampledDrag:float = dragCurve.sample(samplePos)
			body.velocity = body.velocity.lerp(Vector2.ZERO, sampledDrag)
		
