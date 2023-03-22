extends Node2D
class_name Weapon

#export (SpriteFrames) var animation
#var spriteNode:AnimatedSprite = AnimatedSprite.new()
#
#export (AudioStream) var fireSound
#export (AudioStream) var reloadSound
#export (AudioStream) var emptySound
#
#var fireSoundNode:AudioStreamPlayer2D = AudioStreamPlayer2D.new()
#var reloadSoundNode:AudioStreamPlayer2D = AudioStreamPlayer2D.new()
#var emptySoundNode:AudioStreamPlayer2D = AudioStreamPlayer2D.new()
export (String) var displayedName

const ammoTypes = {
	"BULLET":1<<1,
	"ENERGY":1<<2
}

export (Vector2) var barrelPosition

export (int) var damage = 1
export (int) var damageFlags = 0
export (int) var capacity = 1
export (int) var fireRange = 1000

var ammoLoaded:int = capacity
export (float) var cooldown = 1.0
export (float) var reloadTime = 3
export (ammoTypes) var ammoType

var cooldownTimer:Timer = Timer.new()
var reloadTimer:Timer = Timer.new()

var canAim:bool = true

func _physics_process(delta: float) -> void:
	if canAim:
		look_at(get_global_mouse_position())

func _ready() -> void:
	cooldownTimer.wait_time = cooldown
	cooldownTimer.one_shot = true
	add_child(cooldownTimer)

	
	reloadTimer.wait_time = reloadTime
	reloadTimer.one_shot = true
	add_child(reloadTimer)
	reloadTimer.connect("timeout",self,"reload")
#	spriteNode.frames = animation
#	spriteNode.centered = true
##	add_child(spriteNode)
#
#	fireSoundNode.set_stream(fireSound)
#	reloadSoundNode.set_stream(reloadSound)
#	emptySoundNode.set_stream(emptySound)
	
	
func start_fire():
	if cooldownTimer.is_stopped():
		fire()
	else:
		pass

func fire():
	print("BANG!")
	ammoLoaded -= 1
	cooldownTimer.start()
	pass

func start_reload(amount:int):
	reloadTimer.start()
	yield(reloadTimer,"timeout")
	reload(amount)

signal ammo_consumed
func reload(amount:int):
	var ammoUsed = clamp(amount,0,capacity)
	ammoLoaded += ammoUsed
	emit_signal("ammo_consumed",ammoUsed)
	pass

