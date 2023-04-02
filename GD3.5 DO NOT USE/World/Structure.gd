extends StaticBody2D
class_name Structure

const PropertyFlags = {
	"TRANSPARENT":1<<1
}

const materialFlag = {
	"METAL":1<<1,
	"GLASS":1<<2
}

export (Texture) var texture

var sprite:Sprite = Sprite.new()

export (int) var properties = 0

var collision:CollisionPolygon2D = CollisionPolygon2D.new()

export (bool) var autoCollisionGeneration = false#If true, generates collision from the sprite

export (bool) var collisionFromVars = false

func _init(polygon = []) -> void:
	collision.polygon = polygon
	sprite.texture = texture

func _ready() -> void:
	if collisionFromVars:
		add_child(collision)
		add_child(sprite)
	if autoCollisionGeneration:
		collision.polygon = get_collision_from_sprite(sprite.texture)

static func get_collision_from_sprite(tex:Texture, alphaThreshold:float=0.1)->Array:
	var bitMap = BitMap.new()
	bitMap.create_from_image_alpha(tex.get_data(), alphaThreshold)
	return bitMap.opaque_to_polygons( Rect2(0, 0, tex.get_width(), tex.get_width()) )
