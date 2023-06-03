extends Node2D
class_name TieredTree

@export var items:Dictionary

func add_item(item:TieredItem, predecessor=null):
	assert(predecessor == null or predecessor is TieredItem)
	if predecessor is TieredItem:
		predecessor.removed.connect(Callable(item,"remove"))

func remove_item(item:TieredItem):
	item.remove()

class TieredItem extends Sprite2D:
	signal removed
	
	var sprite:Texture
	
	
	
	
	func remove():
		emit_signal("removed")
		queue_free()
	
