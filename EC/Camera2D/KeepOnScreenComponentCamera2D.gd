extends ComponentNode
class_name Camera2DComponentKeepOnScreen
## WIP
## Attempts to keep a camera with a position and zoom that keeps all indicated nodes on-screen.

@export var nodesToKeep:Array[Node2D]
@export var zoomPadding:float

func _parent_update():
	pass

func _is_node_valid_parent(node:Node)->bool:
	return node is Camera2D



#New funcs
func _process(delta: float) -> void:
	assert(nodesToKeep.find(null) == -1, "Null value found.")
	
	targetNode.position = 0
	var nodePositions:Array[Vector2] = get_node_positions()
	
	center_between(nodePositions)
	
	
func center_between(positions:Array[Vector2]):
	if positions.is_empty(): return
	
	for pos in positions:
		targetNode.position += pos
	targetNode.position /= positions.size()
	pass

func adjust_zoom(positions:Array[Vector2]):
	var longestDist:float = get_longest_distance(positions)
	var viewportSize:Vector2 = get_viewport().get_visible_rect().size
	
	#WIP	
	#targetNode.zoom = longestDist / viewportSize

func get_longest_distance(positions:Array[Vector2])->float:
	var distances:Array[float]
	for pos in positions:
		distances.append( pos.distance_to(targetNode.global_position) )
		
	return distances.max()

func get_node_positions()->Array[Vector2]:
	var positions:Array[Vector2]
	positions.assign( nodesToKeep.map(
		func(node:Node2D):
			return node.global_position
	)
	)
	return positions

