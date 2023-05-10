extends Camera3D
class_name FPSCamera

signal pre_movement(dir:Vector2)
signal looking_at(collisionResults:Dictionary)

@export_category("Camera Movement")
@export var invertXAxis:bool=false
@export var invertYAxis:bool=false
@export var sensibility:float = 0.3
@export var ignoreXAxis:bool=true
@export var ignoreYAxis:bool=false
@export var captureMouse:bool=true:
	set(val):
		captureMouse = val
		if captureMouse: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE		
		
@export_category("Raycasting")
@export var rayCastReach:float = 20
@export var rayCanTouchAreas:bool
@export var rayCanTouchBodies:bool
@export_flags_3d_physics var rayCollisionMask:int = Global.Layers.INTERACTABLE



func _ready() -> void:
	captureMouse = captureMouse

func get_seen_target():
	var viewport = get_viewport()
	var world3d = get_world_3d()
	if !viewport or !world3d:
		push_error("No Viewport or World3D could be set."); return {}
		
	var from:Vector3 = global_transform.origin
	var to:Vector3 = from + (-global_transform.basis.z*rayCastReach)
	var rayParams:= PhysicsRayQueryParameters3D.create(from, to)
	
	rayParams.collide_with_areas = true if rayCanTouchAreas else false
	rayParams.collide_with_bodies = true if rayCanTouchBodies else false
	rayParams.collision_mask = rayCollisionMask
	
	var collisionResult:Dictionary = world3d.direct_space_state.intersect_ray(rayParams)
#	assert(collisionResult.is_empty())
	emit_signal("looking_at",collisionResult)
	return collisionResult

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var cameraMove:Vector2 = event.relative
		
		if not invertYAxis: cameraMove.y = -cameraMove.y		
		if not invertXAxis: cameraMove.x = -cameraMove.x
		
		emit_signal("pre_movement",Vector2(cameraMove.x*get_physics_process_delta_time()*sensibility,cameraMove.y*get_physics_process_delta_time()*sensibility))

		var rotationToApply:=Vector2(cameraMove.x*get_physics_process_delta_time()*sensibility,cameraMove.y*get_physics_process_delta_time()*sensibility)
		if not ignoreXAxis: rotation_degrees.y += rotationToApply.x
		if not ignoreYAxis: rotation_degrees.x += rotationToApply.y
		emit_signal("looking_at",get_seen_target())
#		var collision:Dictionary = lookTarget
#		if not collision.is_empty() and collision.collider is RayCastTarget:
#			collision.collider.seen = true
			
		
