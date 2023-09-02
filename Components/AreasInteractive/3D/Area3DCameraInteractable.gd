extends Area3D
class_name Area3DCameraInteractable
## Camera based interactable area

signal interacted
signal hovered

@export var minimumCameraProximity:float 
@export var clickActions:Array[String]
@export var allowedCameras:Array[Camera3D]

#@export_category("Line of Sight")
#@export var lineOfSightRequired:float
#@export_flags_3d_physics var lineOfSightLayers:int

var rayCastHolder:RayCast3D

func _input_event(camera: Camera3D, event: InputEvent, eventPos: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (allowedCameras.is_empty() or camera in allowedCameras) and to_global(eventPos).distance_to(to_global(camera.position)):
		hovered.emit()
		
		for actionEvent in clickActions:
			if event.is_action(actionEvent):
				interacted.emit()
				break
		


#func los_check(clickOrigin:Vector3, clickedPoint:Vector3):
#	if rayCastHolder: rayCastHolder.queue_free()
#	rayCastHolder = RayCast3D.new()
#
#	rayCastHolder.position = to_global(clickOrigin) + to_global(position)
#	rayCastHolder.target_position = clickedPoint
#	rayCastHolder.force_raycast_update()
	
	
