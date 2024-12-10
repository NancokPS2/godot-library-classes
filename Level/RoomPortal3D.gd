extends Resource
class_name RoomPortal3D

signal portal_triggered(thisPortal:RoomPortal3D)

@export var active:bool = true

## Used by Room to know that it has to wait before transitioning.
@export var triggerDelay:float = 0.2


@export var area3D:Area3D:
	set(val):
		if area3D is Area3D:
			area3D.body_entered.disconnect(entered_receiver)
			area3D.area_entered.disconnect(entered_receiver)
			
		area3D = val
		
		if area3D is Area3D:
			area3D.body_entered.connect(entered_receiver)
			area3D.area_entered.connect(entered_receiver)

@export_group("Scene")
@export var scene:PackedScene
@export var targetLocation:=Vector3.ZERO
@export var globalPositioning:bool = true	
			
func entered_receiver(node:Node3D):
	if active and _entered_filter(node):
		assert(scene is PackedScene)
		_proc_functionality()
		emit_signal("portal_triggered",self, node)
	
func _entered_filter(node:Node3D)->bool:
	return false
	
func _proc_functionality():
	pass
	

