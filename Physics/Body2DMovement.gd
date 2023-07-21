extends Node2D
class_name BodyMover2D

@export var bodyToMove:CharacterBody2D

@export var speed = 5.0

@export var dragFactor:float = 0.05

@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var inputDir:Vector2:
	set(val):
		inputDir = val.normalized()


func _unhandled_input(_event: InputEvent) -> void:
	input_update(_event)
	
func input_update(event:InputEvent):
	inputDir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

func _physics_process(delta: float) -> void:
	if bodyToMove == null: return
	_movement_physics(delta)

func _movement_physics(_delta: float) -> void:
	pass

