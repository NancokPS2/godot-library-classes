extends Area2D
class_name TransitionArea

const transitionModes = {"PACKED_SCENE":0,"POSITION":1}

export (transitionModes) var transitionMode

export (PackedScene) var packedScene

export (Vector2) var destination

export (bool) var active = true

#"body_entered" is sent whenever anything enters this transition zone
	  
func send_to_room(body):
	if not active:
		return
		
	if transitionMode == transitionModes.PACKED_SCENE and packedScene != null:
		packedScene
		get_tree().change_scene_to(packedScene)
		
	elif destination != null:
		body.position = destination
	
func can_change_room(body)->bool:
	if body is Entity:
		return true
	else:
		return false
