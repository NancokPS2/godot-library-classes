extends ComponentNode
class_name AreaInteractorComponentCamera3D
## Sends input events to an Area3D from the camera's center using a RayCast3D. Ignores Area3D.input_pickable.

@export_flags_3d_physics var collisionMask:int
@export var maxDistance:float = 10000:
	set(val):
		maxDistance = val
		rayCast.target_position = Vector3.FORWARD * maxDistance

var rayCast:=RayCast3D.new()
var currentEvent:InputEvent

func _parent_update():
	if rayCast.get_parent() == null:
		targetNode.add_child(rayCast)
		
	elif rayCast.get_parent() != targetNode: 
		rayCast.get_parent().remove_child(rayCast)
		targetNode.add_child(rayCast)
	
	rayCast.collide_with_areas = true
	rayCast.collide_with_bodies = false
	rayCast.collision_mask = collisionMask
	
	rayCast.target_position = Vector3.FORWARD * maxDistance

func _is_node_valid_parent(node:Node)->bool:
	return node is Camera3D
	
#New funcs
func _physics_process(delta: float) -> void:
	var collidingArea:Area3D = rayCast.get_collider()
	if collidingArea is Area3D and currentEvent:
		send_input_to_area(
			collidingArea,
			currentEvent,
			rayCast.get_collision_point(),
			rayCast.get_collision_normal(),
			0#???
		)
	currentEvent = null
		
		
	
func send_input_to_area(area:Area3D, event:InputEvent, collPoint:Vector3, collNormal:Vector3, shapeIdx:int):
	area.input_event.emit(targetNode, event, collPoint, collNormal, shapeIdx)

func _unhandled_input(event: InputEvent) -> void:
	currentEvent = event
