extends Node3D
class_name MovementSystem

@export var bodyToMove:CharacterBody3D

@export var speed = 5.0


@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var inputDir:Vector2
var lookDir:Vector2


const InputActions = {
	"JUMP":1<<0,
	"CROUCH":1<<1,
	"RUN":1<<2
}

func _unhandled_input(_event: InputEvent) -> void:
	inputDir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

func _physics_process(delta: float) -> void:
	if bodyToMove == null: return
	_movement_physics(delta)

func _movement_physics(_delta: float) -> void:
	pass
