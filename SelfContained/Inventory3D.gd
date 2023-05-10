extends GridMap
class_name GridMapInventory
## The node should be inside a Viewport container with physics_object_picking set to true

signal hovering_slot(slot:int)
signal input_event_on_slot(slot:int, event:InputEvent)
signal camera_moved(to:Vector3)

## The camera that will display the inventory
@export var viewport:Viewport:
	set(val):
		viewport = val
		if viewport == null: viewport = get_viewport()
		if viewport.get_parent() is SubViewportContainer: viewportContainer = viewport.get_parent()
var viewportContainer:SubViewportContainer
@export var camera:Camera3D

## Max amount of slots horizontally
@export_range(1,9,1,"or_greater") var xLimits:int=9
#@export_range(0,9,1,"or_greater") var yLimits:int=4
@export_range(1,1,1,"or_greater") var slotAmount:int = 9:
	set(val):
		slotAmount = val
		update_pos_of_slots()

## If a box is used, it will be stretched to take up the entirety of the cell
@export var slotShape:=BoxShape3D.new():
	set(val):
		slotShape = val
		if slotShape == null: slotShape = BoxShape3D.new()
		if slotShape is BoxShape3D:
			slotShape.size = cell_size
		
## Used to store and delete the collisions used
var collisionRefs:Array[StaticBody3D]

var posOfSlots:Dictionary

func _init() -> void:
	cell_size_changed.connect(set.bind("slotShape",BoxShape3D.new()))




	pass

func _ready() -> void:
	if camera is Camera3D: update_view()
	else: push_error("No camera has been set.")

## Creates a camera for use with this Inventory3D. Automatically called if no camera has been chosen.
#func create_camera():
#	if camera: push_warning("A camera was created but there was already one assigned, it has not been freed.")
#	camera = Camera3D.new()
#	add_child(camera)
#	camera.current = true
#
#	update_view()

## Sets the camera to fit the entire inventory. Called automatically when changing inventory size.
func update_view():
#	var cameraZ:float = slotAmount * ( (cell_size.x + cell_size.y) / 2 )
	if not camera is Camera3D or not viewport is Viewport: push_error("There is no camera or viewport referenced, cannot update it's position."); return
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.current = true
	
	var viewSize = Vector2( xLimits * cell_size.x, ceil(slotAmount/xLimits) * cell_size.y )
	
	camera.position = Vector3(viewSize.x/2, viewSize.y/2, 50)
	camera.far = camera.position.z*2.5
	
	#Adjust viewport
	if viewportContainer is SubViewportContainer: 
		viewportContainer.stretch = true
		viewportContainer.size = viewSize * 64
		viewportContainer.pivot_offset.x = viewportContainer.size.x/2
#		viewportContainer.position.x = viewportContainer.get_viewport_rect().size.x
	else: 
		viewport.size = viewSize

#	camera.size = max(viewSize.x, viewSize.y)/2
	emit_signal("camera_moved",camera.position)
	
## Updates posOfSlots as a pair of int:Vector3 == slot:position
func update_pos_of_slots():
	posOfSlots.clear()
	var currentPos:=Vector3i.ZERO
	
	for slot in slotAmount:
		posOfSlots[slot]=currentPos
		currentPos.x += 1
		if currentPos.x == xLimits: 
			currentPos.x = 0
			currentPos.y -= 1
			var ass
	

## Unused
func generate_meshes(meshArray:Array[Mesh]):
	mesh_library = MeshLibrary.new()
	
	for mesh in meshArray:
		var meshID:int=mesh_library.get_last_unused_item_id()
		mesh_library.create_item(meshID)
		mesh_library.set_item_mesh(meshID, mesh)
	pass

## Creates a collision for each slot, as to be clickable
func setup_collision(shape:Shape3D=slotShape):
	#Setup collisions
	for slot in posOfSlots:
			var staticObj:=StaticBody3D.new(); staticObj.position = map_to_local(posOfSlots[slot])
			var collision:=CollisionShape3D.new(); collision.shape = shape
			staticObj.add_child(collision); add_child(staticObj)
			
			staticObj.collision_layer = collision_layer; staticObj.collision_mask = collision_mask
			
			staticObj.input_event.connect(input_on_slot.bind(slot))
			collisionRefs.append(staticObj)
			
#		mesh_library.set_item_shapes(meshID, [shape, Transform3D.IDENTITY])
#		mesh_library.set_item_navigation_layers(meshID, collision_mask)
	
## Logic for handling input_event signals from the collisions. The related signals are emitted from here.
func input_on_slot(camera:Node, event:InputEvent, pos:Vector3, normal:Vector3, shape_idx:int, slotID:int):
	emit_signal("input_event_on_slot",slotID,event)
	if event is InputEventMouseMotion:
		emit_signal("hovering_slot",slotID)
