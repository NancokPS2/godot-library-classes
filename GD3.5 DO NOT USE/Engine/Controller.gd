extends Node
class_name Controller
#When attached to a node, it fires their controller_input method as long as it came from the correct device

var deviceID:int = -10
var active:bool = false
var target:Node

export (bool) var autoAttachParent = false

func _ready() -> void:
#	print_joypads()
	set_process_input(active)
	if autoAttachParent:
		attach_to_parent()

func change_device(ID:int):
	deviceID = ID

func attach(newTarget):#Sets who will receive the inputs
	if newTarget != null and newTarget.has_method("controller_input"):
		target = newTarget

	
func detach():
	target = null

		
func attach_to_parent():
	attach(get_parent())
	
func toggle(enabled):
	set_process_input(enabled)
	active = enabled
	
var awaitingDevice:bool = false
func device_query():#Pauses execution until a key is pressed
	var newDevice:InputEvent = yield(self,"button_pressed")
	change_device(newDevice.device)

func _process(delta: float) -> void:
		Input
		pass
		
signal button_pressed
func _input(event: InputEvent) -> void:
	if event.device == deviceID:
		target.controller_input(event)
		emit_signal("button_pressed",event)

func emulate_input(action:String,strength:float=1,pressed:bool=true):
	var event = InputEventAction.new()
	event.device = deviceID
	event.action = action
	event.strength = strength
	event.pressed = pressed
	target.input(event)
	
func print_joypads():
	for device in Input.get_connected_joypads():
		print(Input.get_joy_name(device))
