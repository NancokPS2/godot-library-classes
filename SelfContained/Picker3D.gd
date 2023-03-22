extends Node
class_name Picker3D
enum QueriedInfo {COLLIDER,POSITION}
var depth:float = 0.3

var viewport:Viewport 
var world3d:World3D

var debugPath:bool=false
var pathHolder:Path3D

func get_from_mouse(info:QueriedInfo):
	if !viewport or !world3d:
		push_error("No Viewport or World3D has been set.")
		
	var camera = viewport.get_camera_3d()
	var from:Vector3 = camera.global_position
	var to:Vector3 = from + camera.project_ray_normal( viewport.get_mouse_position()  ) * 1000
	if debugPath:
		if pathHolder != null: pathHolder.queue_free()
		pathHolder = Path3D.new()
		var _curve := Curve3D.new()
		_curve.add_point(from)
		_curve.add_point(to)
		pathHolder.curve = _curve
		add_child(pathHolder)

	var rayParams:= PhysicsRayQueryParameters3D.create(from, to)
	var collisionResult:Dictionary = world3d.direct_space_state.intersect_ray(rayParams)
	if collisionResult.is_empty():
		return false
		
	match info:
		QueriedInfo.COLLIDER:
			return collisionResult.collider if collisionResult.get("collider") else false
				
		QueriedInfo.POSITION:
			return collisionResult.position if collisionResult.get("position") else false
				
