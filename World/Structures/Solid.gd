extends Structure
class_name SolidStruct

var occluderNode:LightOccluder2D = LightOccluder2D.new()

func _init(polygon = []) -> void:
	._init(polygon)
	update_occlusion()

func update_occlusion():
	occluderNode.occluder = OccluderPolygon2D.new()
	occluderNode.occluder.polygon = collision.polygon
	
