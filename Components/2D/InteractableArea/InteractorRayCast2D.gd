extends RayCast2D
class_name InteractableRayCast2D

## Triggers an InteractableArea2D with certain conditions. Meant to be used as a gateway for characters to interact with world objects.

@export var user:Node
@export var maxDistance:float = 200
@export var interactActions:Array[String]

func _init() -> void:
	collide_with_areas = true
	collide_with_bodies = true

func _physics_process(delta: float) -> void:
	target_position = get_local_mouse_position()
	target_position = target_position.limit_length(maxDistance)
	
	var collider = get_collider()
	if collider is InteractableArea2D:
		collider.hovered.emit()
		if is_interaction_attempt():
			collider.interacted.emit()
			collider.interacted_by.emit(user)
	

func is_interaction_attempt()->bool:
	for action in interactActions:
		if Input.is_action_just_pressed(action): 
			return true
		
	return false
