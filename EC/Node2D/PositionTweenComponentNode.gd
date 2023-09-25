extends ComponentNode
class_name Node2DComponentPositionTween

signal finished_moving

@export var initialPos:Vector2
@export var finalPos:Vector2

@export_range(0,1) var targetProgress:float
@export_range(0,100) var progressPerSecond:float = 1

var progress:float:
	set = set_progress

func _is_node_valid_parent(node:Node)->bool:
	return node is Node2D

func _parent_update():
	progress = progress

#New funcs

func set_target_progress(prog:float):
	targetProgress = prog
	set_physics_process(true)

func set_progress(prog:float):
	progress = prog
	targetNode.position = initialPos.lerp(finalPos, prog)
	
	if progress == targetProgress: 
		finished_moving.emit()
		set_physics_process(false)

func _physics_process(delta: float) -> void:
	var change:float = move_toward(progress, targetProgress, progressPerSecond * delta)
	set_progress(change)
