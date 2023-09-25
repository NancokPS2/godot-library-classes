extends Node2D
class_name Node2DComponentLOSNotifier
## Can check if something is visible

signal target_out_of_sight
signal target_in_sight

@export var defaultTarget:Node2D: 
	set(val):
		defaultTarget = val
		
		#If there's no target, there's nothing to process.
		if defaultTarget is Node2D:
			set_physics_process(true)
		else:
			set_physics_process(false)

@export var maxDistance:float = 200
@export var forgetOnOutOfRange:bool = false
@export var continuous:bool = false

var targetIsSeen:bool:
	set(val):
		if targetIsSeen != val or continuous:
			if val:
				target_in_sight.emit()
			else:
				target_out_of_sight.emit()
				
				if forgetOnOutOfRange:
					defaultTarget = null

		targetIsSeen = val
		
func _ready() -> void:
	defaultTarget = defaultTarget
		
func _physics_process(delta: float) -> void:
	check_for_target(defaultTarget)

func check_for_target(target:Node2D):
	##Skip raycast check if too far away
	if global_position.distance_to(target.global_position) > maxDistance: 
		targetIsSeen = false
		
	targetIsSeen = is_target_visible(target)
	pass

func is_target_visible(target:Node2D)->bool:
	var rayCast:=RayCast2D.new()
	add_child(rayCast)
	rayCast.target_position = to_local(target.global_position)
	rayCast.force_raycast_update()
	var collider = rayCast.get_collider()
	rayCast.queue_free()
	
	#Must not collide with anything but the target, if the target has no collision, reaching it's target position unimpeded counts.
	return collider == target or null
	
