extends Control
class_name ControlPopup

signal popped(value)

@export var exclusive:bool = true #If true, everything else is paused when this appears

func _ready() -> void:
	pop_up(visible)

func pop_up(active:bool=true):
	process_mode = Node.PROCESS_MODE_ALWAYS if active else Node.PROCESS_MODE_DISABLED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if exclusive and get_tree(): get_tree().paused = active
	visible = active
	emit_signal("popped",active)
	
	
