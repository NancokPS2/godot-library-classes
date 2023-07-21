extends HitBox
class_name HitBoxReceiver

signal hit_received
signal invulnerability_expired
signal took_damage(amount:float)


#const INFINITE_TRIGGERS:int = -2
const NO_INDIVIDUAL_INVUL_TIMER:float = 0


@export_category("Trigger")
@export var invulTime:float = 1 ## The time that must pass before this hitbox can be hit again. Set to 0 or lower to disable.
@export var oneOff:bool = false ## If false, it will only trigger once per object that enters it's area.
#@export var triggersLeft:int = INFINITE_TRIGGERS ## If not INFINITE_TRIGGERS, it can only hit this amount of times
#@export var freeOnTriggerExhaustion:bool = true ## If true and triggersLeft reaches 0, this object is freed
@export var triggerFlags:Array[String]
@export var individualInvulTime:float = NO_INDIVIDUAL_INVUL_TIMER ## If higher than 0, every Hitter will get it's own cooldown between hits to the same Receiver. This still respects invulTime

var exclusionHolder:Array[HitBoxHitter]

var invulTimer:=Timer.new()

func _init() -> void:
#	collision_mask = DEFAULT_LAYER
#	collision_layer = DEFAULT_LAYER
	area_entered.connect(on_area_entered)
	invulTimer.timeout.connect(emit_signal.bind("invulnerability_expired"))
	
func _ready() -> void:
	invulTimer.one_shot = true
	add_child(invulTimer)
	

func on_area_entered(area:Area3D):
	if filter(area) and _custom_filter(area):
		
		hit_received.emit()
		took_damage.emit(area.damage)
		area.trigger(self)
		
		
		
		if oneOff: queue_free(); return
			
		#Queue a re-check.
		invulnerability_expired.connect(re_check, CONNECT_ONE_SHOT + CONNECT_DEFERRED)
		
		#Start the invul timer
		if invulTime > 0: invulTimer.start(invulTime)
		
		#Exclude the hitbox if individual timers are enabled.
		if individualInvulTime > 0:
			exclusionHolder.append(area)
			
			var removeExclusion:Callable = func(exclusion:HitBoxHitter):
				exclusionHolder.erase(exclusion)
				
			get_tree().create_timer(individualInvulTime).timeout.connect(removeExclusion)
		
#		#Trigger cap
#		if triggersLeft != INFINITE_TRIGGERS: 
#			triggersLeft -= 1
#
#			if triggersLeft <= 0: 
#				if freeOnTriggerExhaustion: queue_free()
#				else: monitorable = false; monitoring = false
				

func re_check():
#	var hitBoxes:Array
#	hitBoxes = get_overlapping_areas().filter(func(area:Area3D): return area is HitBoxHitter)
	for hitBox in get_overlapping_areas(): 
		on_area_entered(hitBox)
		
		#The timer is ticking, prevent further damage.
		if not invulTimer.is_stopped(): break
	


func _physics_process(delta: float) -> void:
	var foundHitboxes:Array = get_overlapping_areas().filter(filter)
	
	for hitbox in foundHitboxes:
		on_area_entered(hitbox)
	
	if foundHitboxes.is_empty(): set_physics_process(false)

func filter(hitter:Area3D)->bool:
	#Must be a HitBoxHitter
	if not hitter is HitBoxHitter: return false
	
	#The invul timer must be stopped
	if not invulTimer.is_stopped(): return false
	
	#Is it currently being excluded?
	if hitter in exclusionHolder: return false
	#Must have triggers left
#	if triggersLeft != INFINITE_TRIGGERS and triggersLeft <= 0: return false
	
	return true

#func sort_by_priority(hitBoxA:HitBoxHitter,hitBoxB:HitBoxHitter)->bool:
#	return true
#	pass

func _custom_filter(_node:HitBoxHitter)->bool:
	return true

