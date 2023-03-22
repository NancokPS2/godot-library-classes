extends Label
class_name LabelWIcon

enum iconModes {SPRITE,ANIMATED_SPRITE,TEXTURE_RECT}

export (Texture) var iconTexture
export (iconModes) var iconMode
var iconReference = Node.new()

	
func _ready() -> void:
	update_icon()

func update_icon():
	if iconTexture == null:
		return
		
	iconReference.free()
	
	var iconNode
	if iconMode == iconModes.SPRITE:
		iconNode = Sprite.new()
		iconNode.centered = true
		iconNode.texture = iconTexture
		
	elif iconMode == iconModes.ANIMATED_SPRITE:#Unfinished
		iconNode = AnimatedSprite.new()
		iconNode.centered = true
		iconNode.texture = iconTexture
		
	elif iconMode == iconModes.TEXTURE_RECT:#Unfinished
		iconNode = TextureRect.new()
		iconNode.texture = iconTexture
	
	add_child(iconNode)
	
	iconNode.position.x = -iconNode.texture.get_width() / 2
	iconNode.position.y = self.get_rect().size.y / 2
	rect_position.x += iconNode.texture.get_width()
	
	
