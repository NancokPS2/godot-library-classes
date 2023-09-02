extends Node2D
class_name ProximityNotifier2D

signal target_outside_range
signal target_inside_range

@export var target:Node2D:
	set(val):
		target = val
		if target is Node2D:
			set_physics_process(true)
		else:
			set_physics_process(false)

@export var maxDistance:float = 200
@export var forgetOnOutOfRange:bool = false ## If true, the target will be cleared if it gets out of range
@export var continuous:bool = false ## Causes the signal to be constantly emitted instead of only when the target moves in or out of range.


var targetIsNear:bool:
	set(val):
		if targetIsNear != val or continuous:
			if val:
				target_inside_range.emit()
			else:
				target_outside_range.emit()
				if forgetOnOutOfRange: 
					target = null
					
		targetIsNear = val
		
		
func _ready() -> void:
	target = target

func _physics_process(delta: float) -> void:
	
	targetIsNear = global_position.distance_to(target.global_position) <= maxDistance
		
#	if targetIsNear:
#		target_inside_range.emit()
#
#	else:
#		target_outside_range.emit()
#		if forgetOnOutOfRange: target = null
		
