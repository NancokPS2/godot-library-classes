extends StaticBody3D
class_name VirtualTouchScreen3D
## A StaticBody3D that creates a small screen that mirrors a Viewport of your choice.
## You can interact with the mirrored viewport by clicking on it.


## Reference to the material used to display the viewport.
var material:=StandardMaterial3D.new()

## Size of the screen.
@export var meshSize:=Vector2(2,2):
	set(val):
		meshSize = val
		if meshInstanceRef.mesh is PlaneMesh:
			meshInstanceRef.mesh.size = meshSize
		else:
			push_error("meshSize had no effect, the mesh used is not a PlaneMesh.")

## The Viewport or SubViewport that will be displayed in this screen.
@export var viewportRef:Viewport:
	set(val):
		if val is Viewport:
			viewportRef = val
			if cursorLayer.get_parent(): cursorLayer.get_parent().remove_child(cursorLayer)
			viewportRef.add_child(cursorLayer)

## Direct reference to the MeshIsntance3D node in this scene that will be used, if none is set, one will be created on _ready().
## This is only for the node, the mesh that it will hold is created on runtime and will replace any already set.
@export var meshInstanceRef:MeshInstance3D: #= get_node_or_null(meshInstancePath) if get_node_or_null(meshInstancePath) is MeshInstance3D else MeshInstance3D.new():
	set(val):
		if val is MeshInstance3D:
			meshInstanceRef = val
			if meshInstanceRef.get_parent()==null: add_child(meshInstanceRef) 
			if meshInstanceRef.get_parent()!=self: push_warning("The parent of this Mesh is not self.")
			if meshInstanceRef.mesh == null: meshInstanceRef.mesh = PlaneMesh.new(); meshInstanceRef.mesh.size = meshSize
			if meshInstanceRef.mesh is PrimitiveMesh: 
				meshInstanceRef.mesh.material = material
			else:
				push_error("This meshInstanceRef does not use a PrimitiveMesh, it cannot use materials")
				

			
		elif val == null:
			push_error("Null mesh.")
		else:
			push_error("Tried to set non-MeshInstance3D.")

## Texture used for the cursor inside the screen. Can be left empty.
@export var cursorTexture:Texture#TEMP

## Reference to the CollisionShape3D node used by meshInstanceRef. Generally, this shouldn't be touched.
var collisionShape:=CollisionShape3D.new():
	set(val):
		collisionShape = val
		var shape := BoxShape3D.new()
		shape.size = Vector3(meshSize.x, 0.01, meshSize.y)
		collisionShape.shape = shape

## A reference to the CanvasLayer that parents the cursor, use cursorLayer.cursor to access the Sprite2D of the cursor
var cursorLayer := CursorLayer.new(viewportRef, cursorTexture, get_viewport())
var subScreenMousePos:Vector2


## Refreshes the ViewportTexture used by the material. Called automatically when setting a new viewportRef. 
func refresh_material():
	if viewportRef==null: push_error("Cannot refresh material, there is no viewportRef set."); return
	var _texture:ViewportTexture = viewportRef.get_texture() 
	if not material.resource_local_to_scene: material.setup_local_to_scene()
	material.albedo_texture = _texture
	
func _ready() -> void:
	if meshInstanceRef == null: meshInstanceRef = MeshInstance3D.new()
	collisionShape = CollisionShape3D.new(); add_child(collisionShape)
	
	refresh_material()
	cursorLayer.viewportRef = viewportRef
	
	mouse_entered.connect(Callable(cursorLayer,"set").bind("showCursor",true))
	mouse_exited.connect(Callable(cursorLayer,"set").bind("showCursor",false))
	
func _input_event(camera: Camera3D, event: InputEvent, eventPos: Vector3, normal: Vector3, shape_idx: int) -> void:
	var localMousePos:Vector3 = to_local(eventPos)
	var mouseVec2Coords:Vector2 = Vector2(localMousePos.x,localMousePos.z) 
	var mouseUVPos = (mouseVec2Coords + meshSize/2) / 2 #floats from 0 to 1. Percentage of position on the screen
	subScreenMousePos = mouseUVPos * viewportRef.get_visible_rect().size
	if event is InputEventMouse:
		event.position = subScreenMousePos
	viewportRef.push_input(event)
	
func _process(delta: float) -> void:
	cursorLayer.cursor.position = subScreenMousePos
	

class CursorLayer extends CanvasLayer:
	var cursor:=Sprite2D.new()
	var viewportRef:Viewport
	var mainViewportRef:Viewport
	var showCursor:bool = true:
		set(val):
			showCursor = val
			cursor.visible = showCursor
			
	func _init(_viewportRef:Viewport, _cursorTexture:Texture, _mainViewportRef:Viewport):
		cursor.texture = _cursorTexture
		cursor.centered = false
		mainViewportRef = _mainViewportRef
		viewportRef = _viewportRef
		layer += 1
	
	func _ready() -> void:
		add_child(cursor)
		
#	func reposition_mouse_from_event(camera:Camera3D,event:InputEvent, eventPos:Vector3, shapeID:int):
#		if event is InputEventMouseMotion:
#			cursor.position 
	
#	func _process(delta: float) -> void:
#		if viewportRef:
#			cursor.position = viewportRef.get_mouse_position() / Vector2(mainViewportRef.size)
#			pass
