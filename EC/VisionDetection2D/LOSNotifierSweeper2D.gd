extends Node2DComponentLOSNotifier
class_name Node2DComponentLOSNotifierSweeper
## More costly than it's base counterpart, sweeps an area to find the target


## The radius of the sweeping. It is not recommended to use a searchRadius higher than 45 degrees or 0.785398 radians
@export_range(0,3.14159) var searchRadius:float = 0.523599

## How many segments the radius will be split into, the higher the radius, the higher this should be to compensate.
## Setting this to a low value increases the chances of the sweeper failing to see trough a gap on obstructions in front of it.
@export var maxChecks:int = 20

func is_target_visible(target:Node2D)->bool:
	#Use the simple version first
	if super.is_target_visible(target): return true
	
	#If that doesn't work, continue
	var rotationCurrent:float = - searchRadius/2
	var rotationIncrements:float = searchRadius / maxChecks
	
	for check in maxChecks:
		var rayCast:=RayCast2D.new()
		add_child(rayCast)
		rayCast.target_position = to_local(target.global_position).rotated(rotationCurrent)
		
		rayCast.force_raycast_update()
		var collider = rayCast.get_collider()
		rayCast.queue_free()
		
		#Must not collide with anything but the target, if the target has no collision, reaching it's target position unimpeded counts.
		if collider == target: return true
		rotationCurrent += rotationIncrements
		
	return false
