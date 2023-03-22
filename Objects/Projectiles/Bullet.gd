extends Projectile
class_name BulletProjectile

func _init(initDirection:Vector2 = Vector2.ZERO,initSpeed:int=0) -> void:
	._init(initDirection,initSpeed)

	hitBox = DamageHitBox.new(damage,damageFlags)#Replace the HitBox with a DamageHitBox


func _movement(delta:float,params:Dictionary={}):
	move_and_slide(direction*speed)
	pass

func hit_something(body):
	hitBox.trigger(body)
	queue_free()
	pass
