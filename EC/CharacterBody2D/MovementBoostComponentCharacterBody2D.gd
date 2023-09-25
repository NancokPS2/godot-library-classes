extends ComponentNode
class_name CharacterBody2DComponentMovementBoost
## Increases velocity of a CharacterBody2D when active.

@export var enabled:bool
@export var boostFactor:float
#@export var boostAction:String

var boosting:bool

func _is_node_valid_parent(node:Node)->bool:
	return node is CharacterBody2D
	
func _parent_update():
	if targetNode:
		set_physics_process(true)
	else:
		set_physics_process(false)
	
#New funcs
func _physics_process(_delta: float) -> void:
	if boosting:
		targetNode.velocity *= boostFactor

#func _unhandled_input(event: InputEvent) -> void:
#	if event.is_action_pressed(boostAction):
#		boosting = true
#	elif event.is_action_released(boostAction):
#		boosting = false

func set_enabled(val:bool):
	enabled = val
	pass

#func enable():
#	enabled = true
#
#func disable():
#	enabled = false
