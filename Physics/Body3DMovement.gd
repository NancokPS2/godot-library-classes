extends Node3D
class_name BodyMover3D

@export var bodyToMove:CharacterBody3D

@export var inputActions:Dictionary = {
	"MOVE_FORWARD":"ui_up",
	"MOVE_BACKWARD":"ui_down",
	"MOVE_LEFT":"ui_left",
	"MOVE_RIGHT":"ui_right",
	"MOVE_UP":"ui_select",
	"MOVE_DOWN":"",
	"CAM_UP":"",
	"CAM_DOWN":"",
	"CAM_LEFT":"",
	"CAM_RIGHT":"",
}

#@export var gravity: float = 0#ProjectSettings.get_setting("physics/3d/default_gravity")

@export_range(0.01,2.0,0.05) var mouseSensitivity:float = 0.8



var inputDir:Vector3:
	set(val):
		inputDir = val.normalized()
		
var mouseMovement:Vector2

#func _unhandled_input(_event: InputEvent) -> void:
#	input_update(_event)
	
func input_update(event:InputEvent):
	inputDir.x = Input.get_axis(inputActions["MOVE_LEFT"], inputActions["MOVE_RIGHT"])
	inputDir.y = Input.get_axis(inputActions["MOVE_DOWN"], inputActions["MOVE_UP"])
	inputDir.z = Input.get_axis(inputActions["MOVE_BACKWARD"], inputActions["MOVE_FORWARD"])
	
	if event is InputEventMouseMotion:
		mouseMovement = event.relative * mouseSensitivity
	elif event is InputEventJoypadMotion:
		mouseMovement = Input.get_vector(inputActions["CAM_LEFT"],inputActions["CAM_RIGHT"],inputActions["CAM_DOWN"],inputActions["CAM_UP"])
		
	

func _physics_process(delta: float) -> void:
	if bodyToMove == null: return
	_movement_physics(delta)


## Used for camera restrictions, set an axis to 0 to ignore it.
func clamp_vec3_to_constraints(node:Node3D, constraints:AABB):
	if not (constraints.position.x == 0 and constraints.size.x == 0):
		node.rotation.x = clamp(node.rotation.x, constraints.position.x, constraints.size.x)
	if not (constraints.position.y == 0 and constraints.size.y == 0):
		node.rotation.y = clamp(node.rotation.y, constraints.position.y, constraints.size.y)
	if not (constraints.position.z == 0 and constraints.size.z == 0):
		node.rotation.z = clamp(node.rotation.z, constraints.position.z, constraints.size.z)

func _movement_physics(_delta: float) -> void:
	pass

