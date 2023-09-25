extends ComponentNode

##UNUSED

#class_name Area2DComponentInteractable
## A way to easily emit a signal when an action is done on an Area2D (requires input_pickable to be true on the parent)

signal interacted

#These are used if the interaction requires a certain amount of time.
signal interaction_interrupted
signal interaction_completed
signal interaction_ended

@export var interactionAction:StringName = "interact"
@export var interactionProgressRequired:float = 0

var interactionInProgress:bool:
	set(val):
		interactionInProgress = val
		set_physics_process(interactionInProgress)
		
var interactionProgress:float



func _is_node_valid_parent(node:Node)->bool:
	return node is Area2D
	
func _parent_update():
	if targetNode:
		targetNode.input_event.connect(on_input_event)

#New funcs

func _physics_process(delta: float) -> void:
	interactionProgress += delta
	if interactionProgress >= interactionProgressRequired:
		interaction_end(true)
		

func interaction_start():
	if interactionProgressRequired > 0:
		interactionInProgress = true
	interacted.emit()

func interaction_end(success:bool):
	interactionInProgress = false
	if success:
		interaction_completed.emit()
	else:
		interaction_interrupted.emit()
	interaction_ended.emit()
	pass

func on_input_event(viewport:Node, event:InputEvent, shapeIDX:int):
	if event.is_action_pressed(interactionAction) or event is Area2DComponentInteractableForcedEvent: 
		interaction_start()


class Area2DComponentInteractableForcedEvent extends InputEventAction: pass
		
		
