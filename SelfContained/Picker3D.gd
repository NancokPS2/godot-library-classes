extends Node3D
class_name Picker3D

enum QueriedInfo {COLLIDER,POSITION}
var depth:float = 0.3

@export var viewport:Viewport 
@export var rayLength:float = 1000
@export_flags_3d_physics var collisionMask:int
var world3d:World3D


@export var debugPath:bool=false
var pathHolder:Path3D

func get_from_mouse(info:QueriedInfo):
	world3d = get_world_3d()
	if !viewport or !world3d:
		push_error("No Viewport or World3D has been set.")
		
	var camera = viewport.get_camera_3d()
	var from:Vector3 = camera.global_position
	var to:Vector3 = from + camera.project_ray_normal( viewport.get_mouse_position()  ) * rayLength
	if debugPath:
		if pathHolder != null: pathHolder.queue_free()
		pathHolder = Path3D.new()
		var _curve := Curve3D.new()
		_curve.add_point(from)
		_curve.add_point(to)
		pathHolder.curve = _curve
		add_child(pathHolder)

	var rayParams:= PhysicsRayQueryParameters3D.create(from, to)
	rayParams.collision_mask = collisionMask
	var collisionResult:Dictionary = world3d.direct_space_state.intersect_ray(rayParams)
	if collisionResult.is_empty():
		return false
		
	match info:
		QueriedInfo.COLLIDER:
			return collisionResult.collider if collisionResult.get("collider") else null
				
		QueriedInfo.POSITION:
			return collisionResult.position if collisionResult.get("position") else null


func get_from_mouse_orthogonal(info:QueriedInfo):
	if !viewport: push_error("No Viewport has been set.")
	var camera = viewport.get_camera_3d()
	var from = camera.project_ray_origin(viewport.get_mouse_position())
	var to = from + camera.project_ray_normal(viewport.get_mouse_position()) * rayLength
	
	var infoReturned
	match info:
		QueriedInfo.COLLIDER:
			push_error("Returning collider is unimplemented for orthogonal method.")

		QueriedInfo.POSITION:
			infoReturned = Plane(Vector3.UP, transform.origin.y).intersects_ray(from, to)
	
	pass
				
#func get_from_mouse_orthogonal(info:QueriedInfo):
#	if !viewport:
#		push_error("No Viewport has been set.")
#	var camera = viewport.get_camera_3d()
#
#	var rayOrigin = camera.project_ray_origin(viewport.get_mouse_position())
##	assert(rayOrigin == camera.position)
#	var rayDirection = camera.project_ray_normal(viewport.get_mouse_position())
#
#
#	var customLength = rayOrigin + rayDirection * rayLength
#	var rayEnd = rayOrigin + rayDirection * customLength
#
#	var ray:RayCast3D = RayCast3D.new()
#	ray.collision_mask = collisionMask
#	add_child(ray)
#	ray.target_position = rayEnd
#	ray.force_raycast_update()
#	if not ray.is_colliding(): 
#		ray.queue_free()
#		return false
#
#	var infoReturned
#	match info:
#		QueriedInfo.COLLIDER:
#			infoReturned = ray.get_collider()
#
#		QueriedInfo.POSITION:
#			infoReturned = ray.get_collision_point()
#
#	ray.queue_free()
#	return infoReturned
