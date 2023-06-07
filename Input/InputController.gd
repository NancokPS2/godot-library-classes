extends Node
class_name InputController

signal input_relayed(event:InputEvent)

## Called when giving up it's input to another InputController, this input is NEVER sent to the target
signal input_lent(toWhat:InputController)

## Called to signal that the input is ready to return to it's original owner
signal input_returned()

## If this isn't null, it will emit input_returned. The device set will be replaced by the first device that this InputController listens to.
@export var returnControlInput:InputEvent:
	set(val):
		returnControlInput = val
		returnControlInput.device = deviceIDs[0]

## Which devices this responds to, should never be empty.
@export var deviceIDs:Array[int] = [0]

## Used to set targets from the editor
@export var exportedTarget:Node

## Whether to listen to MouseMotion or not (UNUSED)
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
		else:
			push_error("This target cannot receive inputs.")
@export var active:bool=true:
	set(val):
		active = val
#		set_process_unhandled_input(active)

func _ready():
	var temp = active
	active = false
	await get_tree().root.ready
	target = target
	active = temp

## Used to lend control to a differe InputController, once said controller it's done, this one regains it
func lend_input(controller:InputController):
	if not active: push_error("Cannot lend control when already inactive."); return
	#If it was off, turn it off when it's done
	if not controller.active:
		controller.input_returned.connect(Callable(controller,"set").bind("active",false), CONNECT_ONE_SHOT)

	controller.active = true
	active = false
	
	controller.input_returned.connect(Callable(self,"set").bind("active",true), CONNECT_ONE_SHOT)
	
	emit_signal("input_lent",controller)
	
## Gives control back to any InputController that may have lent it to it.
func return_control():
	if input_returned.get_connections().is_empty(): push_error("No one was awaiting for this InputController"); return
	
	emit_signal("input_returned")

func _unhandled_input(event: InputEvent) -> void:
	if event == returnControlInput: return_control()
	elif deviceIDs.has(event.device) and active:
#		target.call("_unhandled_input",event)
		emit_signal("input_relayed", event)

