extends KinematicBody2D
class_name PlayerCharacter

var movementVector:Vector2#Player movement
var velocity:Vector2#Total velocity

var acceleration:float = 10 
var maxSpeed:float = 40#Maximum speed
var jump:float = 200#Jump force
var movementFriction = 0.2

var sliding:bool
var moving:bool#Is the player trying to move?

func _input(event: InputEvent) -> void:
	pass


func _physics_process(delta: float) -> void:
	basic_movement()

func basic_movement():
	moving = false#Reset states
	sliding = false
	
	#Increase momentum
	if Input.is_action_pressed("move_up") and is_on_floor():#Apply up force
		velocity += Vector2.UP * jump
		
	if Input.is_action_pressed("move_right"):#Apṕply movement right
		movementVector += Vector2.RIGHT * acceleration
		moving = true
		
	elif Input.is_action_pressed("move_left"):#Apṕply movement left
		movementVector += Vector2.LEFT * acceleration
		moving = true
		
	
	if Input.is_action_pressed("move_down") and is_on_floor():#Slide
		sliding = true
		
	movementVector = movementVector.clamped(maxSpeed)#Limit speed
	
	velocity += movementVector#Add movement to the velocity
	
	#Acceleration and max speed
	if is_on_floor():#When grounded
		acceleration = 15
		if sliding:
			acceleration = 8
			maxSpeed = 40
		elif Input.is_action_pressed("run"):#If also running, increase max speed
			maxSpeed = 70
	else:#If airborne
		acceleration = 0.9
		
		
		
	#Stopping
	if not moving and is_on_floor():
		movementVector.x = lerp(movementVector.x,0,0.5)
		

	
	
	velocity.y += Global.gravity#Gravity
	if is_on_floor() and velocity.y > 0:#Do not add downwards momentum while grounded
		velocity.y = 0
		
		
	velocity.y = lerp(velocity.y,0,0.02)#Vertical drag
	velocity.x = lerp(velocity.x,0,horizontalFriction)#Horizontal drag
	
	move_and_slide(velocity, Vector2.UP)
