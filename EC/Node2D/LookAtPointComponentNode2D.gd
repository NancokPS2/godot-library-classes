extends ComponentNode
class_name Node2DComponentLookAtPoint

@export var enabled:bool = true:
	set(val):
		enabled = val
		set_physics_process(enabled)

@export_range(0,1) var turnFactor:float = 0.8

@export var defaultRotation:Vector2 = Vector2.RIGHT

## Keep in mind that as the body rotates, the point does as well.
## Use global_position to ignore this.
var point:Vector2

func _is_node_valid_parent(node:Node)->bool:
	return node is Node2D
	
func _parent_update():
	if targetNode is Node2D:
		enabled = enabled
	else:
		enabled = false

#New funcs
func _physics_process(_delta: float) -> void:
	var targetAngle:float = point.angle() - defaultRotation.angle()
	targetNode.rotation = lerp_angle(targetNode.rotation, targetAngle, turnFactor)
	
