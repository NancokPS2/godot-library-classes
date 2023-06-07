extends BodyMover3D

@export_enum("X","Y","Z") var lockedAxis:int

func _movement_physics(delta):
	
	bodyToMove.velocity = inputDir * speed
	
	match lockedAxis:
		0: bodyToMove.velocity.x = 0
		1: bodyToMove.velocity.y = 0
		2: bodyToMove.velocity.z = 0
	
	bodyToMove.move_and_slide()
	
