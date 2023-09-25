extends ComponentNode
class_name Node2DComponentLookAtMouse

@export var enabled:bool = true:
	set(val):
		enabled = val
		set_physics_process(enabled)

@export_range(0,1) var turnRate:float = 0.8

@export var defaultRotation:Vector2 = Vector2.UP
		

func _is_node_valid_parent(node:Node)->bool:
	return node is Node2D
	
func _parent_update():
	enabled = enabled


func _physics_process(delta: float) -> void:
	if targetNode is Node2D:
		targetNode.rotation = lerp_angle(targetNode.rotation, defaultRotation.angle_to(targetNode.get_local_mouse_position() - targetNode.position), turnRate)
