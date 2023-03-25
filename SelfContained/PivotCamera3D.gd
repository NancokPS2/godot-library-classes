extends Node3D
class_name PivotCamera3D
const defaultCameraPos:=Vector3(0,0,15)
const defaultCameraRot:=Vector3(0,0,0)

const defaultRotation:=Vector3(-30,0,0)
signal camera_ready(cameraRef)

@onready var camera:Camera3D
@export_range(0.01,10.0) var speed:float=1

@export var fov:float = 90.0
@export var controlsActive:bool=true
@export var cameraActive:bool=true:
	set(value):
		cameraActive = value
		camera.current = value

func _ready() -> void:
	setup_camera()
	rotation_degrees = defaultRotation
	cameraActive = true
	


func setup_camera(cameraPos:Vector3=defaultCameraPos, cameraRot:Vector3=defaultCameraPos):
	camera = Camera3D.new()
	rotate_x(deg_to_rad(defaultCameraRot.x))
	camera.position = cameraPos
	rotation_degrees = cameraRot
	camera.fov = fov
	
	add_child(camera)
	emit_signal("camera_ready", camera)

func _process(delta: float) -> void:
	if controlsActive:
		if Input.is_action_pressed("rotate_left"): rotation.y -= speed * delta
		elif Input.is_action_pressed("rotate_right"): rotation.y += speed * delta
		if Input.is_action_pressed("rotate_up"): rotation.x -= speed * delta
		elif Input.is_action_pressed("rotate_down"): rotation.x += speed * delta
		
		
		
