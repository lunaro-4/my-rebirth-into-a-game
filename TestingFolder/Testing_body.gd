extends CharacterBody2D


const SPEED = 300.0

func _physics_process(_delta):
	
	velocity.x = 0
	velocity.y = 0
	if Input.is_action_pressed("W_Button"):
		velocity.y -= SPEED
	if Input.is_action_pressed("A_Button"):
		velocity.x -= SPEED
	if Input.is_action_pressed("D_Button"):
		velocity.x += SPEED
	if Input.is_action_pressed("S_Button"):
		velocity.y += SPEED
	move_and_slide()
