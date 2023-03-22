extends Entity
class_name Mecha

var upgrades:MechUpgrades = MechUpgrades.new()

enum states{AIRBORNE,GROUNDED,CLING_LEDGE}
var state:int

var accelerationDirection:Vector2#Player movement direction
var velocity:Vector2#Total velocity

var groundAccel = Const.groundAccelBase
var airAccel = Const.airAccelBase
var maxSpeed = Const.maxSpeedBase

const buttonStates = {
	"RUN":1<<0
}
var buttonState:int = 0

func _init() -> void:#Temp
	senses.sight = 100

func update_upgrades():
	groundAccel = Const.groundAccelBase + upgrades.groundAccelBonus
	maxSpeed = Const.maxSpeedBase + upgrades.maxSpeedBonus
	pass

func _take_damage(amount,flags):
	pass
	
func _physics_process(delta: float) -> void:
	basic_movement(delta)
	currentInput = buttonState

var currentInput
func input_proc():
	accelerationDirection.x = Input.get_axis("move_left","move_right")
	accelerationDirection.y = Input.get_axis("move_up","move_down")
	accelerationDirection = accelerationDirection.normalized()
	
	buttonState = 0
	buttonState += int( Input.is_action_pressed("run") ) * buttonStates.RUN
	
	
	

func basic_movement(delta):#accelerationDirection is provided by controller_input
	var maxSpeedFinal = maxSpeed


	if is_on_floor():#Set state
		state = states.GROUNDED
	else:
		state = states.AIRBORNE
	
	input_proc()

	match state:
		states.GROUNDED:#Is on the ground?
			velocity.y = 0.1#Keeps you on the ground as you move side to side
			
			if accelerationDirection != Vector2.ZERO:#If not moving
				velocity.x = lerp(velocity.x,0,Global.groundDrag)
			else:
				velocity.x = lerp(velocity.x,0,0.8+Global.groundDrag)
				
			accelerationDirection *= groundAccel#Increase acceleration to it's acceleration speed
			
			velocity += accelerationDirection#Add the acceleration to the velocity
			

		states.AIRBORNE:#Is on the air?

			if buttonState && buttonStates.RUN:
				if accelerationDirection != Vector2.ZERO:#If not moving
					accelerationDirection = accelerationDirection*1.2
					if velocity.y > 0:#WIP Should cancel downwards velocity
						accelerationDirection += Vector2.UP
				else:#Else, brake
					accelerationDirection = -velocity.limit_length(airAccel)
					if velocity.length() < 1:#Stops moving entirely if steady enough
						velocity = Vector2.ZERO

			accelerationDirection *= airAccel#Increase acceleration to it's acceleration speed

			accelerationDirection = accelerationDirection.limit_length(airAccel)#Limit acceleration
			
			velocity += accelerationDirection#Add the acceleration to the velocity

			velocity = lerp(velocity,Vector2.ZERO,Global.airDrag)#Air drag application

			velocity.y += Global.gravity#Gravity

		states.CLING_LEDGE:
			pass


	velocity = velocity.limit_length(maxSpeedFinal)

	velocity = move_and_slide(velocity, Vector2.UP)	
	
	accelerationDirection = Vector2.ZERO#Reset acceleration

func unused():	
#var accelerationDirection
#func _physics_process(delta: float) -> void:
#var acceleration = get_modified_acceleration()
##	assert(acceleration == Vector2.ZERO)
#movement(acceleration,100,Global.gravity,Global.airDrag)
#
#func controller_input(event: InputEvent) -> void:
#if event.is_action_released("ui_accept"):
#	use_object()
#
#elif event.is_action_released("interact"):
#	interact()
#
#accelerationDirection.x = Input.get_axis("move_left","move_right") 
#accelerationDirection.y = Input.get_axis("move_up","move_down")
#
#const moveFlags = {
#"MOVING":1<<1
#}
#var moveFlag
#func movement(impulse:Vector2,maxSpeed:float=100,gravity:float=0, drag:float=0.01, flags:int=0):
#
#if flags && moveFlags.MOVING:#Drag while moving, slow down
#	velocity = lerp(velocity,Vector2.ZERO,drag*0.1)#Air drag application
#else:
#	velocity = lerp(velocity,Vector2.ZERO,drag)#Air drag application
#
#velocity += impulse
#
#velocity.y += gravity
#
#velocity = velocity.limit_length(maxSpeed)
#
#velocity = move_and_slide(velocity, Vector2.UP)
#
#if is_on_floor():#Set state
#	state = states.GROUNDED
#else:
#	state = states.AIRBORNE
#
#
#
#func get_modified_acceleration()->Vector2:#Modifies accelerationDirection
#moveFlag = 0
#var finalAccel = accelerationDirection
#match state:
#	states.GROUNDED:#Is on the ground?
#		velocity.y = 0.1#Keeps you GROUNDED as you move side to side
#
#		if finalAccel != Vector2.ZERO:
#			moveFlag = moveFlags.MOVING
#			finalAccel *= groundAccel
#
#	states.AIRBORNE:#Is on the air?
#
#		if finalAccel != Vector2.ZERO:
#			moveFlag = moveFlags.MOVING
#
#		if Input.is_action_pressed("run"):
#			if moving:#If moving, go faster
#				finalAccel = finalAccel * 1 #MechUpgrades.thrusterPower
#			else:#Else, brake
#				finalAccel = -velocity * 1 #MechUpgrades.thrusterPower #Move in the oposite direction
#
#		finalAccel *= airAccel
#
#return finalAccel
	pass
