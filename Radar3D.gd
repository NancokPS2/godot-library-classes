extends Node3D
class_name Radar3D

signal visual_generated(image:ImageTexture)
signal found_positions(positions:Array[Vector3])
signal found_targets(targets:Array[Node3D])

const RadarColors:Dictionary = {LEVELED=Color.GREEN, ABOVE=Color.RED, BELOW=Color.BLUE, EMPTY=Color.BLACK}

enum TrackingModes {
	SPECIFIC, ##Only track selected nodes, checks distance to self. Fastest
	ZONE, ##Detects ALL bodies in the given zone
	ZONE_FILTER ##Detects bodies after filtering them with _zone_filter(node)
	}

@export var trackingMode:TrackingModes:
	set(val):
		trackingMode = val
		if is_inside_tree() and trackingMode == TrackingModes.ZONE and not trackingZone.is_inside_tree():
			add_child(trackingZone)
## Time in seconds to atuomatically rescan, set to null to disable it entirely.
@export_range(0.1,10,0.1,"or_greater") var trackInterval:float=1.0:
	set(val):
		trackInterval = val
		if trackInterval == null: trackingTimer.stop()
		else: trackingTimer.start(trackInterval)
@export_range(0.1,100,0.1,"or_greater") var maxRange:float=30:
	set(val):
		maxRange = val
		if trackingZone.is_inside_tree():
			trackingZone.collShape.radius = maxRange
@export_flags_3d_physics var collision_mask:int=1:
	set(val):
		collision_mask = val
		if trackingZone.is_inside_tree():
			trackingZone.collision_mask = collision_mask
@export_flags_3d_physics var collision_layer:int=0:
	set(val):
		collision_layer = val
		if trackingZone.is_inside_tree():
			trackingZone.collision_layer = collision_layer

## If false, no visuals nor related signals will be generated/emitted. For performance reasons
@export var generateVisual:bool=false
@export var visualResolution:=Vector2i(128,128)
## If the difference in elevation is greater than this, the target will be considered above or below the radar
@export_range(0,100,0.2,"or_greater") var elevationSensitivity:float = 5

@onready var trackingZone:=RadarTrackingArea3D.new(maxRange, collision_mask, collision_layer)

## Only used in SPECIFIC mode. Sets which nodes will be tracked
var trackingNodes:Array[Node3D]

## Stores the timer used in-between checks.
var trackingTimer:=Timer.new()


func _ready() -> void:
	trackingTimer.timeout.connect(rescan)
	add_child(trackingTimer)
	add_child(trackingZone)
	trackInterval = trackInterval
	
## Called automatically every trackInterval seconds
func rescan():
	var positions:Array[Vector3]
	var nodes:Array[Node3D]
	
	match trackingMode:
		
		TrackingModes.SPECIFIC:
			for node in trackingNodes:
				if node.global_position.distance_to(self.global_position) <= maxRange:
					nodes.append(node)
					positions.append(node.global_position)
		
		TrackingModes.ZONE:
			nodes = trackingZone.get_overlapping_bodies()
			for node in nodes:
				positions.append(node.global_position)

		TrackingModes.ZONE_FILTER:
			for node in trackingZone.get_overlapping_bodies():
				if _zone_filter(node) == true:
					nodes.append(node)
					positions.append(node.global_position)

			
	assert(positions.size() == nodes.size())
	emit_signal("found_positions", positions)
	emit_signal("found_targets", nodes)
	if generateVisual:
		emit_signal("visual_generated",get_visual(positions))

func get_visual(positions:Array[Vector3])->Image:
	var visual:=RadarTexture3D.new(to_global(position), visualResolution, positions, elevationSensitivity, maxRange)
	return visual.image

func _zone_filter(_node:Node3D)->bool: return true

class RadarTrackingArea3D extends Area3D:
	var collShape:=SphereShape3D.new()
	var collNode:=CollisionShape3D.new()
	
	func _init(radius:float, coll_mask:int, coll_layer:int) -> void:
		collShape.radius = radius
		collNode.shape = collShape
		collision_layer = coll_layer
		collision_layer = coll_layer

	func _ready() -> void:
		add_child(collNode)

class RadarTexture3D extends Resource:
	var image:Image
	
	func _init(originPosition:Vector3, resolution:Vector2i, targetPositions:Array[Vector3], elevationSensitivity:float, maxRange:float) -> void:
		image = Image.create(resolution.x, resolution.y, false, Image.FORMAT_RGB8)
		image.fill(RadarColors.EMPTY)
		
		for pos in targetPositions:
			var color:Color
			if pos.y > originPosition.y+elevationSensitivity:
				color = RadarColors.ABOVE
			elif pos.y < originPosition.y-elevationSensitivity:
				color = RadarColors.BELOW
			else: 
				color = RadarColors.LEVELED
				
			var distance:Vector3 = pos - originPosition
			var pixelPos:=( Vector2i(distance.x, distance.z)/maxRange ) * Vector2(resolution.x,resolution.y)
			pixelPos = resolution/2 + Vector2i(pixelPos)
			pixelPos = Vector2i(pixelPos)
			
			image.set_pixelv(pixelPos, color)
			
		
	
	
	
	
