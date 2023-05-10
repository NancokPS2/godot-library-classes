extends Node3D
class_name MeshRenderer

const ValidFormats = {RES=".tres", PNG=".png", JPG=".jpg",WEBP=".webp"}

@export var environment:Environment
@export var optionalShader:Shader
@export var resolution:Vector2 = Vector2.ONE*64
@export var cameraSize:float=2
@export_dir var meshSaveDir:String
var subView:=SubViewport.new()
var camera:=Camera3D.new()
var meshInstance:=MeshInstance3D.new()
var environmentNode:=WorldEnvironment.new()


func _ready() -> void:
	add_child(subView); subView.size = resolution; 
	subView.transparent_bg = true; subView.render_target_update_mode = SubViewport.UPDATE_DISABLED;
	subView.gui_disable_input = true; subView.own_world_3d = true
	subView.add_child(meshInstance)
	subView.add_child(camera); camera.size = cameraSize
	subView.add_child(environmentNode); environmentNode.environment = environment
	
	
	#TEMP
	var image = await get_image(load("res://Assets/Models/Inventory/MeshNotFound.tres"))#TEMP
	generate_image_file(load("res://Assets/Models/Inventory/MeshNotFound.tres"), "res://image")


## Main method
func generate_image_file(mesh:Mesh, path:String, format:String=ValidFormats.RES):
	pose_mesh(mesh)
	save_screenshot(path,format)

## Main method
func get_image(mesh):
	pose_mesh(mesh)
	return await get_screenshot()

## Used to position the mesh and the camera
func pose_mesh(mesh:Mesh):
	if optionalShader: mesh.material = optionalShader
	meshInstance.mesh = mesh
	
	camera.current = true
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.position.z = 50

## Used to return the data
func get_screenshot(format:String=ValidFormats.RES):
	subView.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	await RenderingServer.frame_post_draw
	#Remove it's extension if it has one
	match format:
		ValidFormats.RES:
			var image:ImageTexture = ImageTexture.create_from_image( subView.get_texture().get_image() ) 
			return image
		ValidFormats.PNG:
			return subView.get_texture().get_image().save_png_to_buffer()
		ValidFormats.JPG:
			return subView.get_texture().get_image().save_jpg_to_buffer()
		ValidFormats.WEBP:
			return subView.get_texture().get_image().save_webp_to_buffer() 
			
	subView.render_target_update_mode = SubViewport.UPDATE_DISABLED

## Saves the current view into a file
func save_screenshot(path:String="res://image.png",format:String=ValidFormats.RES):
	subView.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	await RenderingServer.frame_post_draw
	#Remove it's extension if it has one
	if path.get_extension() != "": path = path.rstrip("."+path.get_extension())
	match format:
		ValidFormats.RES:
			var image:ImageTexture = ImageTexture.create_from_image( subView.get_texture().get_image() ) 
			print_debug( "Saved image with error code: " + str(ResourceSaver.save(image, path+format)) )
		ValidFormats.PNG:
			print_debug("Saved image with error code: " + str(subView.get_texture().get_image().save_png(path+format)) )
		ValidFormats.JPG:
			print_debug("Saved image with error code: " + str(subView.get_texture().get_image().save_jpg(path+format)) )
		ValidFormats.WEBP:
			print_debug("Saved image with error code: " + str(subView.get_texture().get_image().save_webp(path+format)) )
			
	subView.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
#	print_debug( $SubViewport.get_texture().get_image().save_png(path) )

	
#func save_mesh(path:String=meshSaveDir):
#	subView.transparent_bg = true
#	var image:Image = subView.get_texture().get_image()
#	image.save_png(path)
#	var imageTex = ImageTexture.create_from_image(image)
#	subView.transparent_bg = false
#	print_debug( "Saved with error code: " + str(ResourceSaver.save(image, path)) )
