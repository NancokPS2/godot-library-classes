extends Node
class_name InputController

signal input_relayed(event:InputEvent)

@export var deviceIDs:Array[int] = [0]
@export var exportedTarget:Node
@export var listenToMouseMovement:bool
@onready var target:Node=exportedTarget:
	set(val):		
		if target == null or not target.is_inside_tree(): return
		if target.has_method("_unhandled_input"):
			if input_relayed.is_connected(Callable(target,"_unhandled_input")): disconnect("input_relayed",Callable(target,"_unhandled_input"))
			target.set_process_unhandled_input(true)
			target = val
			target.set_process_unhandled_input(false)
			input_relayed.connect(Callable(target,"_unhandled_input"))
#		else:
#			push_error("This target cannot receive inputs.")
@export var active:bool=true:
	set(val):
		active = val
		set_process_unhandled_input(active)

func _ready():
	var temp = active
	active = false
	await get_tree().root.ready
	target = target
	active = temp

func _unhandled_input(event: InputEvent) -> void:
	if deviceIDs.has(event.device) and active:
#		target.call("_unhandled_input",event)
		emit_signal("input_relayed",event)

