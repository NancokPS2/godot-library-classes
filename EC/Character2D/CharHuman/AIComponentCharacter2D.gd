extends ComponentNode
class_name Character2DComponentAI
## From a different project...
## Depending on which aiCompRef components the character has, it will enable different methods to use them.
## To override how a character uses a component, override it's process_

@export var enabled:bool:
	set(val):
		enabled = val
		set_physics_process(enabled)
		

## Used to store which callables will be called every physics frame
var callablesPhysics:Array[Callable]  
  
## These are executed every lowPriorityProcessInterval
var callablesLowPriority:Array[Callable]

var lowPriorityProcessInterval:float = 1.0/60 * 10 #10 times per second at 60 FPS.

## Used by process_topDownMovement
var _targetLocation:Vector2

func _is_node_valid_parent(node:Node)->bool:
	return node is Character2D
	
func _parent_update():
	if targetNode is Character2D:
		enabled = enabled
		
		if targetNode.aiCompRefTopDownMovement:
			call_add_to_physics_proc(process_topDownMovement)
	else:
		enabled = false



#New funcs
func _physics_process(delta: float) -> void:
	for callable in callablesPhysics:
		callable.call(delta)

func low_priority_processing(delta:float=lowPriorityProcessInterval):
	for callable in callablesLowPriority:
		callable.call(delta)
		
	if enabled:
		low_priority_timer_start()
	
func low_priority_timer_start():
	get_tree().create_timer(lowPriorityProcessInterval).timeout.connect(low_priority_processing)
	

func call_add_to_physics_proc(callable:Callable):
	callablesPhysics.append(callable)
	
func call_add_to_low_priority_proc(callable:Callable):
	callablesLowPriority.append(callable)	
	

#Component processing

#CharacterBody2DComponentTopDownMovement
func process_topDownMovement(_delta:float):
	targetNode.aiCompRefTopDownMovement.currentDirection = targetNode.position.direction_to(_targetLocation)
