extends Control
class_name PauseControl

@export var quitScene:PackedScene
@export var paused:bool = false:
	set(val):
		if canPause: paused = val
		else: return
		
		if paused:
			mouse_filter = Control.MOUSE_FILTER_STOP
			process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		else:
			mouse_filter = Control.MOUSE_FILTER_IGNORE
			process_mode = Node.PROCESS_MODE_INHERIT
		visible = paused
		get_tree().paused = paused
		
@export var canPause:bool=true

@export var shortcutAction:StringName

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(shortcutAction):
		paused = !paused

func _ready():
	paused = paused

func quit():
	paused = false
	get_tree().change_scene_to_packed(quitScene)

func resume():
	paused = false
