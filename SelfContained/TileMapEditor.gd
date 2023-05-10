extends TileMap
class_name TileMapEditor

signal tile_filled(vector:Vector3i)
signal tile_removed(vector:Vector3i)
signal layer_changed(layerNum:int)

@export var cameraRef:Camera2D
@export var tiles = {
	"fill":[1,Vector2.ZERO,0],
	"hover":[1,Vector2.RIGHT*2,0]
}
@export var inputMapActions = {
	"layer_up":"go_up",
	"layer_down":"go_down",
	"paint":"primary_click",
	"remove":"secondary_click",
	"camera_drag":"tertiary_click"
}
@export var maxSize:Vector2 = Vector2.ONE * 20
var _mousePos:Vector2
@onready var drawnGrid:=DrawnGrid.new(self)

func _ready():
	add_child(drawnGrid,false,Node.INTERNAL_MODE_BACK)

var currentLayer:int:
	set(val):
		val = min(val,50)
		currentLayer = clamp(val,0,get_layers_count())

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		var mousePos:Vector2 = (event.position + get_viewport().get_camera_2d().position) / scale
		_mousePos = mousePos
		var tileHighlighted:Vector2 = local_to_map(mousePos)
#		var IDOfHovered:int = get_cell_source_id(currentLayer, tileHighlighted)#DEBUG
		
		if event is InputEventMouseMotion and Input.is_action_pressed(inputMapActions.camera_drag) and cameraRef:
			cameraRef.position -= event.relative
		
		if (tileHighlighted.x >= 0 and tileHighlighted.x <= maxSize.x) and (tileHighlighted.y >= 0 and tileHighlighted.x <= maxSize.y):
			for layer in get_all_layers():
				for pos in get_used_cells_by_id(layer,tiles.hover[0],tiles.hover[1],tiles.hover[2]):
					set_cell(layer, pos,-1)
			
			if get_cell_source_id(currentLayer, tileHighlighted) == -1:
				set_cell(currentLayer,tileHighlighted,tiles.hover[0],tiles.hover[1],tiles.hover[2])
			
			if event.is_action_pressed(inputMapActions.paint):
				set_cell(currentLayer,tileHighlighted,tiles.fill[0],tiles.fill[1],tiles.fill[2])
				emit_signal("tile_filled",Vector3i(tileHighlighted.x,currentLayer,tileHighlighted.y))
			
			elif event.is_action_pressed(inputMapActions.remove):
				set_cell(currentLayer,tileHighlighted,-1)
				emit_signal("tile_removed",Vector3i(tileHighlighted.x,currentLayer,tileHighlighted.y))

	if event.is_action_pressed(inputMapActions.layer_up):
		currentLayer += 1
		change_layer(currentLayer)
		
	elif event.is_action_pressed(inputMapActions.layer_down):
		currentLayer -= 1
		change_layer(currentLayer)
		
func get_all_layers()->Array:
	var returnal = range(get_layers_count())
	return returnal
		
func change_layer(layerNum:int):
	if get_layers_count() == 0: return
	for layer in get_all_layers(): 
		set_layer_enabled(layer, false)
		set_layer_modulate(layer,Color.TRANSPARENT)
	
	if layerNum > 0 and not get_all_layers().has(layerNum):
		add_layer(layerNum)

	set_layer_enabled(layerNum, true)
	set_layer_modulate(layerNum,Color.WHITE)
	emit_signal("layer_changed",layerNum)

func set_from_vec3(vector:Vector3i, sourceID:int, atlasCoords:Vector2i=Vector2i.ZERO, alt:int=0):
	var allLayers = get_all_layers()
	if not allLayers.has(vector.y): 
		push_error("Invalid layer.")
		return null
		
	set_cell(vector.y, Vector2i(vector.x, vector.z),sourceID, atlasCoords, alt)

func get_from_vec3(vector:Vector3):
	if not get_all_layers().has(vector.y): push_error("Invalid layer."); return null
	return get_cell_source_id(vector.y, Vector2i(vector.x, vector.z))

func fill_from_vec3_array(vectors:Array[Vector3i], sourceID:int=tiles.fill[0], atlasCoords:Vector2i=tiles.fill[1], alt:int=tiles.fill[2]):
	for layer in get_all_layers(): remove_layer(layer)
	
	var layersNeeded:int=0
	for vector in vectors:
		layersNeeded = max(layersNeeded, vector.y)
		
	for layerCount in layersNeeded:
		add_layer(-1)
	add_layer(-1)
	
	for vec in vectors: set_from_vec3(vec, sourceID, atlasCoords, alt)
	drawnGrid.queue_redraw()

func get_as_vec3_array()->Array[Vector3i]:
	var vecArray:Array[Vector3i]
	for layer in get_all_layers():
		for pos in get_used_cells_by_id(layer, tiles.fill[0], tiles.fill[1], tiles.fill[2]):
			vecArray.append(Vector3i(pos.x,layer,pos.y))
	return vecArray

class DrawnGrid extends Node2D:
	var lineThickness:float
	var lineColor:Color
	var tileMapRef:TileMapEditor
	
	func _init(_tileMapRef, _lineColor=Color.BLACK, _lineThickness:float=-1.0) -> void:
		tileMapRef = _tileMapRef
		lineColor = _lineColor
		lineThickness = _lineThickness
	
	func _draw() -> void:
		var verLines = tileMapRef.get_used_rect().size.x + 1
		var horLines = tileMapRef.get_used_rect().size.y + 1
		if verLines + horLines == 0: return
		
		var cellSize = abs( tileMapRef.map_to_local(Vector2.ZERO) - tileMapRef.map_to_local(Vector2.ONE) )

		for row in horLines:
			var startingPos:Vector2 = Vector2( 0, cellSize.y * row )
			var finalPos:Vector2 = Vector2( cellSize.x* (verLines-1), cellSize.y * row )
			draw_line(startingPos, finalPos, lineColor, lineThickness)
			
		for column in verLines:
			var startingPos:Vector2 = Vector2( cellSize.x * column, 0 )
			var finalPos:Vector2 = Vector2( cellSize.x * column, cellSize.y * (horLines-1) )
			draw_line(startingPos, finalPos, lineColor, lineThickness)
