extends Node
class_name Room3D
## A node suitable for holding a level and handling transitions between areas.
## Each PortalRoom3D holds an Area3D that it listens to in order to activate.


## Node to replace when a portal with a scene is entered. If null, it changes the entire scene.
@export var levelNode:Node = self
@export var portals:Array[RoomPortal3D] = [RoomPortal3D.new()]: 
	set(val):
		portals = val
		for portal in portals:
			portal.portal_triggered.connect(trigger_transition)


func add_portal(portal:RoomPortal3D):
	portal.portal_triggered.connect(trigger_transition)
	if not portals.has(portal):
		portals.append(portal)
	
func remove_portal(portal:RoomPortal3D):
	portal.portal_triggered.disconnect(trigger_transition)
	portals.erase(portal)
	
func trigger_transition(portal:RoomPortal3D, what:Node):
	var level:Node = portal.scene.instantiate()
	assert(level is Node)
	
	if level == null: push_error("The portal has no scene attached."); return
	
	_pre_transition()
	
	var delayTimer:Timer = get_tree().create_timer(portal.triggerDelay)
	
	if levelNode is Node:
		delayTimer.timeout.connect( Callable(levelNode, "replace_by").bind(level) )
	else:
		delayTimer.timeout.connect( Callable(get_tree(),"change_scene_to_packed").bind(level) )
		
	delayTimer.timeout.connect(node_post_positioning.bind(what, portal.targetLocation))
		
## Virtual. Called just as the transition was started. Good place to use tweens or animations.
func _pre_transition():
	pass
	
func node_post_positioning(node:Node, pos:Vector3):
	if portal.globalPositioning: node.global_position = pos
	else: node.position = pos
		