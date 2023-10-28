extends ComponentNode
class_name Area2DComponentHitbox
#A simply node that uses an Area2D's collisions for dealing and receiving "damage"

enum Types {HITTER, RECEIVER}

#const GROUP_NAME:String = "_AREA2D_HITBOX_COMPONENT_GROUP"
const NO_INDIVIDUAL_INVUL_TIMER:float = 0

static var hitboxDict:Dictionary

signal hit_dealt
signal damage_dealt(amount:float)

signal hit_taken
signal damage_taken(amount:float)

signal invulnerability_expired





@export_category("Trigger")
@export var type:Types#:
#	set(val):
#		type = val
#		match type:
#			Types.HITTER:
#				targetNode.monitoring = true
#				targetNode.monitorable = false
#			Types.RECEIVER:
#				targetNode.monitoring = false
#				targetNode.monitorable = true
				
				
@export var enabled:bool = true
@export var oneOff:bool = false ## If false, it will only trigger once per object that enters it's area.


@export_category("Hitbox")
@export var damage:float = 1 ## Innefective if it isn't a hitter
@export var triggerFlagsRequired:Array[StringName]
@export var triggerFlagsExcluded:Array[StringName]

@export_category("Hurtbox")
@export var invulTime:float = 1 ## The time that must pass before this hitbox can be hit again. Set to 0 or lower to disable.
@export var individualInvulTime:float = NO_INDIVIDUAL_INVUL_TIMER ## If higher than 0, every Hitter will get it's own cooldown between hits to the same Receiver. This still respects invulTime
@export var triggerFlags:Array[StringName] ## If any of these are in the hitter, trigger.

var exclusionList:Array[Area2DComponentHitbox]

var invulTimer:Timer = Timer.new()


func _is_node_valid_parent(node:Node)->bool:
	return node is Area2D

func _parent_update():
	#Basic signal setup
	targetNode.area_entered.connect(on_area_entered)
	hit_taken.connect(on_hit_taken)
	
	#Register parent
	hitboxDict[targetNode] = self
	
	#Add invulnerability timer
	invulTimer.one_shot = true
	add_child(invulTimer)
	

#New funcs
func can_be_hit_by(by:Area2DComponentHitbox)->bool:
	assert(by.type == Types.HITTER)
	
	if not enabled: return false
	if not type == Types.RECEIVER: return false
	if not invulTimer.is_stopped(): return false
	if by in exclusionList: return false
	
	#Must not have any excluded flag
	if triggerFlags.any(func(flag:StringName): return flag in by.triggerFlagsExcluded): return false
	
	#Must have all the required flags (if there's any)
	if not by.triggerFlagsRequired.is_empty() and not triggerFlags.all(func(flag:StringName): return flag in by.triggerFlagsRequired): return false
	
	return true
	
func hit_other(hurtbox:Area2DComponentHitbox):
	hurtbox.damage_taken.emit(damage)
	hurtbox.hit_taken.emit()
	
	damage_dealt.emit(damage)
	hit_dealt.emit()
	
	
func on_area_entered(area:Area2D):
	#Cannot react if not a HITTER
	if type != Types.HITTER: 
		push_warning("RECEIVER types should not be detecting anything.")
		return
	
	var componentHit:Area2DComponentHitbox = hitboxDict.get(area, null)
	
	if componentHit is Area2DComponentHitbox and componentHit.can_be_hit_by(self): 
		hit_other(componentHit)
	



func on_hit_taken():
	if oneOff: enabled = false
	
	invulTimer.start(invulTime)
	pass
