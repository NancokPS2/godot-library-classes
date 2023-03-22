extends KinematicBody2D
class_name Projectile

export (Texture) var sprite
var spriteNode:Sprite = Sprite.new()

export (int) var damage = 1
export (int) var damageFlags = 0

export (Array,Vector2) var shape
var hitBox = HitBox.new()

export (Vector2) var direction = Vector2.ZERO
export (int) var speed = 0
	

func _init(initDirection:Vector2 = Vector2.ZERO,initSpeed:int=0) -> void:
	if initSpeed>0:
		speed = initSpeed
		
	if initDirection!=Vector2.ZERO:
		direction = initDirection
	

	
func hit_something(body):#Called when colliding with something
	pass

func _ready() -> void:
	add_child(spriteNode)
	add_child(hitBox)
	hitBox.connect("body_entered",self,"hit_something")
	
	spriteNode.texture = sprite
	spriteNode.centered = true

	hitBox.shape = shape
	
	
func toggle_active(enabled:bool):
	set_physics_process(enabled)
	
func movement(moveDelta:float,parameters:Dictionary = {}):
	_movement(moveDelta,parameters)
	
func _movement(delta,params):
	pass
	
func _physics_process(delta: float) -> void:
	movement(delta)

static func get_collision_from_sprite(tex:Texture, alphaThreshold:float=0.1)->Array:
	var bitMap = BitMap.new()
	bitMap.create_from_image_alpha(tex.get_data(), alphaThreshold)
	return bitMap.opaque_to_polygons( Rect2(0, 0, tex.get_width(), tex.get_width()) )
