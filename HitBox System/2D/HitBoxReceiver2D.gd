extends Area2D
class_name HitBoxReceiver2D

signal hit_received(hitter:HitBoxHitter2D)
signal invulnerability_expired
signal took_damage(amount:float)


#const INFINITE_TRIGGERS:int = -2
const NO_INDIVIDUAL_INVUL_TIMER:float = 0


@export_category("Trigger")
@export var invulTime:float = 1 ## The time that must pass before this hitbox can be hit again. Set to 0 or lower to disable.
@export var oneOff:bool = false ## If false, it will only trigger once per object that enters it's area.
#@export var triggersLeft:int = INFINITE_TRIGGERS ## If not INFINITE_TRIGGERS, it can only hit this amount of times
#@export var freeOnTriggerExhaustion:bool = true ## If true and triggersLeft reaches 0, this object is freed
@export var triggerFlags:Array[String] ## If any of these are in the hitter, trigger.
@export var individualInvulTime:float = NO_INDIVIDUAL_INVUL_TIMER ## If higher than 0, every Hitter will get it's own cooldown between hits to the same Receiver. This still respects invulTime

var exclusionHolder:Array[Node2D]

var invulTimer:=Timer.new()

func _init() -> void:
	invulTimer.timeout.connect(emit_signal.bind("invulnerability_expired"))
	invulnerability_expired.connect(on_invul_change)
	
	
func _ready() -> void:
	invulTimer.one_shot = true
	add_child(invulTimer)

func on_invul_change():
	if invulTimer.is_stopped():
		monitorable = true
		monitoring = true
	else:
		monitorable = false
		monitoring = false

func trigger(hitter:Node2D):
	assert(hitter is HitBoxHitter2D or hitter is HitBoxHitter2DRayCast)
	if not can_be_hit(hitter): return
		
	hit_received.emit()
	took_damage.emit(hitter.damage)

	if oneOff: queue_free(); return
	
	#Start the invul timer
	if invulTime > 0: invulTimer.start(invulTime); on_invul_change()
	
	#Exclude the hitbox if individual timers are enabled.
	if individualInvulTime != NO_INDIVIDUAL_INVUL_TIMER:
		set_hitter_exclusion(hitter, individualInvulTime)

func set_hitter_exclusion(hitter:Node2D, duration:float):
	exclusionHolder.append(hitter)
	var individualInvulTimer:=get_tree().create_timer(duration)
	var removeExclusion:Callable = func(exclusion:HitBoxHitter2D):
		exclusionHolder.erase(exclusion)
		
	individualInvulTimer.timeout.connect(removeExclusion.bind(hitter))
	
func can_be_hit(hitter:Node2D)->bool:
	#Must be of the right type
	if not (hitter is HitBoxHitter2D or hitter is HitBoxHitter2DRayCast):
		return false
	
	#The invul timer must be stopped
	if not invulTimer.is_stopped(): return false
	
	#Is it currently being excluded?
	if hitter in exclusionHolder: return false
	
	#Must share at least 1 flag or have none
	if triggerFlags.is_empty() or not triggerFlags.any(func(flag:String): return flag in hitter.triggerFlags):
		return false
	
	return true


func _custom_filter(_node:Area2D)->bool:
	return true

