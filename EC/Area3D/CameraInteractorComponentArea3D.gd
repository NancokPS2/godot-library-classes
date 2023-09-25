extends ComponentNode
class_name Area3DComponentMouseInteractable
## Camera based interactable area. It can filter inputs received by distance, InputEventAction and camera of origin.

signal interacted
signal hovered

@export var maximumCameraDistance:float 
@export var clickActions:Array[String] = ["primary_click"]
@export var allowedCameras:Array[Camera3D]

func _is_node_valid_parent(node:Node)->bool:
	return node is Area3D

func _parent_update():
	assert(targetNode is Area3D)
	assert(targetNode.has_method("_input_event"))
	targetNode.input_event.connect(_input_event)
	pass
	


func _input_event(camera: Camera3D, event: InputEvent, eventPos: Vector3, normal: Vector3, shape_idx: int) -> void:
	#Allowed camera
	if (allowedCameras.is_empty() or camera in allowedCameras):  
		#Close enough
		if targetNode.to_global(eventPos).distance_to(targetNode.to_global(camera.position) < maximumCameraDistance):
			hovered.emit()
			
			for actionEvent in clickActions:
				if event.is_action(actionEvent):
					interacted.emit()
					break
		

	
