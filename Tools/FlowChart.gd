extends Node2D
class_name FlowChart

signal nodes_changed
@export_group("Visual")
@export var actions:Dictionary = {
	"Select":"primary_click",
	"Deselect":"secondary_click",
	"Move":"primary_with_shift",
	"Delete":"primary_with_ctrl",
	"Edit":"primary_with_alt",
	"Help":"show_help"
}
@export var defaultNodeTexture:Texture
@export var connectionColor:=Color.YELLOW
@export var hoverColor:=Color.BLUE

@export_group("Debug")
@export var debugMode:bool = true

@export var debugLabel:Label



var startedConnectionOrigin:ChartNode = null

var nodes:Dictionary #Rect2:ChartNode
var connections:Dictionary

var nodeBeingMoved:ChartNode
var hoveredNode:ChartNode:
	set(val):
		if hoveredNode is ChartNode:
			hoveredNode.modulate = Color.WHITE
			
		hoveredNode = val
		
		if hoveredNode is ChartNode:
			hoveredNode.modulate = Color.WHITE * 1.5

var helpLabel:=Label.new()

func _init() -> void:
	nodes_changed.connect(queue_redraw)
	
func _ready() -> void:
	add_child(helpLabel)
	for action in actions:
		var actionIdentifier:String = actions[action]
		helpLabel.text += action + ": " + InputMap.action_get_events(actionIdentifier)[0].as_text() + "\n"

func add_chart_node(pos:Vector2, size:Vector2, text:String):
	var node:=ChartNode.new()
	node.position = pos
	node.text = text
	node.texture = defaultNodeTexture
	node.size = size
	#Do not let them overlap
	while nodes.has(node.rect): node.position+=Vector2.ONE*0.01
	
	nodes[node.rect] = node
	nodes_changed.emit()
	
func remove_chart_node(rect:Rect2):
	
	remove_node_connections(rect)
	nodes.erase(rect)
	
	nodes_changed.emit()

func resize_chart_node(rect:Rect2):
	var node:ChartNode = get_chart_node(rect)
	nodes_changed.emit()
	
func move_chart_node(rect:Rect2, newPosition:Vector2)->bool:
	var node:ChartNode = get_chart_node(rect)
	
	remove_chart_node(rect)
	node.position = newPosition
	nodes[Rect2(node.position, node.size)] = node
	nodes_changed.emit()
	if not node.is_valid_rect_in_dict(nodes): push_error( "Mismatch of rect in dictionary. " + str(node.rect) )
	return true

func get_chart_node(rect:Rect2)->ChartNode:
	var node:ChartNode = nodes[rect]
	if not node is ChartNode: push_error("Could not get a node with that rect."); return null
	return node

func remove_node_connections(rect:Rect2):
	var node:ChartNode = nodes[rect]
	for connection in node.connections:
		connections.erase(connection.rect)
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		queue_redraw()
		hoveredNode = get_current_node()
		
	elif event.is_action_pressed(actions.Help):
		helpLabel.visible = !helpLabel.visible
		

func get_current_node()->ChartNode:
	for rect in nodes:
		if rect.has_point(get_local_mouse_position()): return nodes[rect]
	return null

func connection_attempt(originRect:Rect2, targetRect:Rect2):
	if targetRect is Rect2 and originRect is Rect2 and originRect != targetRect: 
			connections[startedConnectionOrigin.rect] = hoveredNode.rect
			nodes[targetRect].connections.append(nodes[originRect])
			nodes[originRect].connections.append(nodes[targetRect])
			print("Connected {0} to {1}".format([str(startedConnectionOrigin.rect),str(hoveredNode.rect)]) )
	else: 
		print("Dropped connection")
	



func _process(delta: float) -> void:
	input_logic()
	if debugMode:
		if hoveredNode is ChartNode: debugLabel.text = hoveredNode.get_name()
		else: debugLabel.text = "none"

		
func input_logic():
	
	#Started moving a node
	if Input.is_action_just_pressed(actions.Move) and hoveredNode:
		nodeBeingMoved = hoveredNode
		
	#Finished moving a node
	elif Input.is_action_just_released(actions.Move) and nodeBeingMoved:
		move_chart_node(nodeBeingMoved.rect, get_local_mouse_position())
		nodeBeingMoved = null
		
	elif Input.is_action_just_pressed(actions.Delete) and hoveredNode:
		remove_chart_node(hoveredNode.rect)
	
	
	#Select on empty space.
	elif Input.is_action_just_pressed(actions.Select) and hoveredNode == null:
		add_chart_node(get_local_mouse_position(), Vector2.ONE*32, "NEW")
	
	#Select is being held, it wasn't just pressed.
	elif Input.is_action_pressed(actions.Select):
		queue_redraw()
		if hoveredNode is ChartNode and startedConnectionOrigin == null:
			startedConnectionOrigin = hoveredNode
	
	
	
	#Select was released while a connection origin was defined
	if startedConnectionOrigin is ChartNode and Input.is_action_just_released(actions.Select):
		if hoveredNode: connection_attempt(startedConnectionOrigin.rect, hoveredNode.rect)
#		if hoveredNode is ChartNode and hoveredNode != startedConnectionOrigin: 
#			connections[startedConnectionOrigin.rect] = hoveredNode.rect
#			print("Connected {0} to {1}".format([str(startedConnectionOrigin.rect),str(hoveredNode.rect)]) )
#		else: 
#			print("Dropped connection")
		queue_redraw()
		startedConnectionOrigin = null
		

func _draw() -> void:
	if startedConnectionOrigin != null:
		draw_line(startedConnectionOrigin.center, get_local_mouse_position(), connectionColor)
	if debugMode: draw_circle(get_local_mouse_position(),5,Color.WHITE)
	
	#Draw nodes
	for node in nodes.values():
		if node is ChartNode:
			draw_texture_rect(node.texture, node.rect, false)
	
	#Draw their connections
	for connection in connections:
		var target:Rect2 = connections[connection]
		
		var centerFrom:Vector2 = connection.position + (connection.size/2)
		var centerTo:Vector2 = target.position + (target.size/2)
		draw_line(centerFrom, centerTo, connectionColor)
		
#		var dir:Vector2 = centerFrom.direction_to(centerTo)
#		var arrowPoints:PackedVector2Array = [centerTo, centerTo+dir.rotated(deg_to_rad(140)), centerTo+dir.rotated(deg_to_rad(-140))]
#		draw_polygon(arrowPoints, PackedColorArray([connectionColor,connectionColor,connectionColor]) )
		
	if hoveredNode:
		draw_rect(hoveredNode.rect, hoverColor)

func save_to_file(filePath:String):
	pass
	
func load_from_file(filePath:String):
	pass

class ChartNode extends Resource:
	@export var position:Vector2
	@export var size:Vector2
	@export var texture:Texture
	@export var text:String
	@export var modulate:Color
	
	var rect:Rect2:
		get: return Rect2(position, size)
		
	var center:Vector2:
		get: return position + (size/2)
#	var label:=Label.new()
#	var area:=Area2D.new()
	
	var connections:Array[ChartNode]
	
	func is_valid_rect_in_dict(dict:Dictionary)->bool:
		return true if dict.has(rect) else false
		
#	func _ready() -> void:
#		var newShape:=CollisionShape2D.new()
#		newShape.shape = RectangleShape2D.new()
#		newShape.shape.size = size
#		add_child(label)
#		add_child(area)
#		area.add_child(newShape)
