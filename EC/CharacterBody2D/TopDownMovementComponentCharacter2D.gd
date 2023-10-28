extends ComponentNode
class_name CharacterBody2DComponentTopDownMovement
## A simple top-down movement controller. It moves the node by acceleration * currentDirection and applies drag when no direction is given to make the node stop moving.


@export var acceleration:float = 1000  
#@export_range(1,5, 0.1, "or_greater") var accelerationCounterBonus:float = 1.
@export_range(0,1) var dragFactorOnStop:float = 0.8

var currentDirection:Vector2


func _is_node_valid_parent(node:Node)->bool:
	return node is CharacterBody2D
	
func _parent_update():
	if targetNode:
		set_physics_process(true)
	else:
		set_physics_process(false)

	
#New funcs
func set_currentDirection(dir:Vector2):
	currentDirection = dir

func set_acceleration(accel:float):
	acceleration = accel
				
func _physics_process(delta: float) -> void:
	var velocityAdded:Vector2 = currentDirection * acceleration * delta
	
	targetNode.velocity += velocityAdded
	if currentDirection == Vector2.ZERO:
		targetNode.velocity *= dragFactorOnStop
		

	
