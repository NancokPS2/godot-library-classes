extends ComponentNode
class_name CharacterBody2DComponentTopDownMovement
## A simple top-down movement controller.

#@export var inputActions:Dictionary = {
#	UP = "move_up",
#	DOWN = "move_down",
#	LEFT = "move_left",
#	RIGHT = "move_right"
#
#}
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
#func get_direction()->Vector2:
#	return Input.get_vector("move_left","move_right","move_up","move_down").normalized()
func set_currentDirection(dir:Vector2):
	currentDirection = dir

func set_acceleration(accel:float):
	acceleration = accel
				
func _physics_process(delta: float) -> void:
	var velocityAdded:Vector2 = currentDirection * acceleration * delta
	
	#If trying to turn from high speeds, do it faster.
#	if (velocityAdded + targetNode.velocity).length() < targetNode.velocity.length() and targetNode.velocity.length() > acceleration / 2:
#		velocityAdded *= accelerationCounterBonus
	
	targetNode.velocity += velocityAdded
	if currentDirection == Vector2.ZERO:
		targetNode.velocity *= dragFactorOnStop
		

	
