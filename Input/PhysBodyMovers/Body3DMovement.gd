extends Node3D
class_name BodyMover3D

@export var bodyToMove:CharacterBody3D

@export var speed = 5.0

@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var inputDir:Vector3
var lookDir:Vector3


const InputActions = {
	"JUMP":1<<0,
	"CROUCH":1<<1,
	"RUN":1<<2
}

func _unhandled_input(_event: InputEvent) -> void:
	input_update(_event)
	
func input_update(event:InputEvent):
	inputDir.x = Input.get_axis("move_left", "move_right")
	inputDir.y = Input.get_axis("move_down", "move_up")
	inputDir.z = Input.get_axis("move_back", "move_forward")
	
	if event is InputEventMouseMotion:
		lookDir = event.relative

func _physics_process(delta: float) -> void:
	if bodyToMove == null: return
	_movement_physics(delta)

func _movement_physics(_delta: float) -> void:
	pass

