extends RayCast3D
class_name HitBoxHitterHitscanShape
## To be used as a replacement for a HitBoxHitter CollisionShape's. Enables usage of a RayCast with the hitbox system.

static var hitBoxRequired:Script = HitBox

var hitBoxUsed:HitBoxHitter

func _init() -> void:
#	collision_mask = HitBox.DEFAULT_LAYER
	collide_with_areas = true
	collide_with_bodies = false
	hit_from_inside = true
	
func _enter_tree() -> void:
	if get_parent() is HitBoxHitter: 
		hitBoxUsed = get_parent()
		collision_mask = hitBoxUsed.collision_mask
	else: push_error("This node requires that it's parent is a HitBoxHitter and otherwise does nothing.")

func _physics_process(delta: float) -> void:
	force_raycast_update()
	process_collision()

func project_to(pos:Vector3):
	target_position = pos
	force_raycast_update()

func process_collision():
	assert(not get_collider() is HitBoxHitter)
	if get_collider() is HitBoxReceiver: 
		get_collider().area_entered.emit(hitBoxUsed)
	
