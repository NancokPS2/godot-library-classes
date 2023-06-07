extends Node2D
class_name MultiTextureDrawer

#const Directions:Dictionary = {UP=Vector2.UP, DOWN=Vector2.DOWN, RIGHT=Vector2.RIGHT, LEFT=Vector2.LEFT}
@export var direction:Side = SIDE_BOTTOM
@export var textureSize:=Vector2(64,64)
@export var atlasTexture:AtlasTexture

@export_group("Scaling")
@export var scaleToViewport:bool=true
@export var baseViewSize:=Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),ProjectSettings.get_setting("display/window/size/viewport_height"))

var queuedTextures:Array[Vector2]

func _draw() -> void:
	if scaleToViewport:
		scale.x = get_viewport_rect().size.x / baseViewSize.x
		scale.y = get_viewport_rect().size.y / baseViewSize.y
		
	var currDrawPos:=Vector2.ONE
	var usedDirection:Vector2
	match direction:
		SIDE_TOP:
			usedDirection = Vector2.UP
		SIDE_BOTTOM:
			usedDirection = Vector2.DOWN
		SIDE_LEFT:
			usedDirection = Vector2.LEFT
		SIDE_RIGHT:
			usedDirection = Vector2.RIGHT
	
	for vector in queuedTextures:
		atlasTexture.region = Rect2(vector*textureSize, textureSize)
		draw_texture_rect(atlasTexture, Rect2(currDrawPos, textureSize), true)
		
		if direction == SIDE_TOP or direction == SIDE_BOTTOM:
			currDrawPos += usedDirection * textureSize.y
		else:
			currDrawPos += usedDirection * textureSize.x
	
	
