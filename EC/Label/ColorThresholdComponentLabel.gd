extends ComponentNode
class_name LabelComponentColorThreshold
## Automatically changes the color of a parent label.

@export_group("Thresholds")
@export var thresholdLow:float = 25
@export var thresholdHigh:float = 100

@export_group("Colors")
@export var colorNormalSetOnReady:bool = true ## Use the parent's original color when this node was readied
@export var colorNormal:Color = Color.WHITE
@export var colorLow:Color = Color.RED
@export var colorHigh:Color = Color.GREEN

#Overrides
func _is_node_valid_parent(node:Node = get_parent())->bool:
	return node.get("text") and node.get("modulate")

	
func _parent_update():
	if colorNormalSetOnReady:
		colorNormal = targetNode.modulate
	
	targetNode.draw.connect(update_color)
			
		
		
#New funcs
#func _process(delta: float) -> void:
#	update_color()
	
func update_color():
	var currentValue:float = targetNode.text.to_float()
	if currentValue > thresholdHigh: 
		targetNode.modulate = colorHigh
	elif currentValue < thresholdLow:
		targetNode.modulate = colorLow
	else: 
		targetNode.modulate = colorNormal
	

