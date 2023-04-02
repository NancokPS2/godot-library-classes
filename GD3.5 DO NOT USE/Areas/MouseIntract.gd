extends Area2D
class_name MouseInteractable

var hovered:bool
var collision:CollisionShape2D = CollisionShape2D.new()
var shape = RectangleShape2D.new()
	
#func _init() -> void:
#	collision_layer = 0
#	collision_mask = 0
#	set_collision_mask_bit(6,true)
#	set_collision_layer_bit(6,true)

func _ready() -> void:
	add_to_group("WORLD INTERACTABLE")
	add_child(collision)
	shape.extents = Vector2(1,1)
	collision.shape = shape



func toggle(enable=true):
	set_process_input(enable)
	
func use():
		print("DO NOT TOUCHA DA BUTTON!")
