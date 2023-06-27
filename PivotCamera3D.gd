extends Node3D
class_name PivotCamera3D
const DefaultCameraPos:=Vector3(0,0,15)
const DefaultCameraRot:=Vector3(0,0,0)
const DefaultRotation:=Vector3(-30,0,0)

signal camera_ready(cameraRef)

@onready var camera:Camera3D
@export_range(0.01,999) var rotationSpeed:float=2
@export_range(0.01,999) var zoomSpeed:float=10
@export_range(1,999) var maxZoom:float=300
#	set(val):
#		maxZoom = max(val,minZoom)
@export_range(0.1,999) var minZoom:float=1
#	set(val):
#		minZoom = min(val,maxZoom)

@export var defaultRotation:Vector3 = DefaultRotation
@export var cameraPos:Vector3 = DefaultCameraPos:
	set(val):
		val.z = clamp(val.z, minZoom, maxZoom)
		cameraPos = val
		if camera: camera.position = cameraPos
@export var cameraRot:Vector3 = DefaultCameraRot:
	set(val):
		val.x = clamp(val.x,-30,30)
		cameraRot = val
		if camera: camera.rotation_degrees = cameraRot
@export var fov:float = 90.0
@export var controlsActive:bool=true
@export var cameraActive:bool=true:
	set(value):
		cameraActive = value
		camera.current = value

@export var controlActions:Dictionary = {
	"rotate_left":"",
	"rotate_right":"",
	"rotate_up":"",
	"rotate_down":"",
	"zoom_in":"",
	"zoom_out":"",
}

func _ready() -> void:
	setup_camera()
	rotation_degrees = defaultRotation
	cameraActive = true
	


func setup_camera(_cameraPos:Vector3=cameraPos, _cameraRot:Vector3=cameraRot):
	camera = Camera3D.new()
	rotate_x(deg_to_rad(_cameraRot.x))
	camera.position = _cameraPos
	rotation_degrees = defaultRotation
	camera.fov = fov
	
	add_child(camera)
	emit_signal("camera_ready", camera)

func _process(delta: float) -> void:
	if controlsActive:
		if Input.is_action_pressed(controlActions["rotate_left"]): rotation.y -= rotationSpeed * delta
		elif Input.is_action_pressed(controlActions["rotate_right"]): rotation.y += rotationSpeed * delta
		if Input.is_action_pressed(controlActions["rotate_up"]): rotation.x -= rotationSpeed * delta
		elif Input.is_action_pressed(controlActions["rotate_down"]): rotation.x += rotationSpeed * delta
		if Input.is_action_pressed(controlActions["zoom_in"]): cameraPos.z -= zoomSpeed * delta
		elif Input.is_action_pressed(controlActions["zoom_out"]): cameraPos.z += zoomSpeed * delta
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)
		
		
		
