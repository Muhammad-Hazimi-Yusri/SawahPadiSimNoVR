extends CharacterBody3D


const JUMP_VELOCITY = 4.5

var scaled_down = false
var current_size = 0

@export var speed = 5
@export var wheat_needed := 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta):
	if Globals.wheat_eaten >= wheat_needed and current_size < 1:
		current_size = 1
		speed += 2.5
		self.scale *= 1.25
	elif Globals.wheat_eaten >= 2.5 * wheat_needed and current_size < 2:
		current_size = 2
		speed += 2.5
		self.scale *= 1.25
	elif Globals.wheat_eaten >= 5 * wheat_needed and current_size < 3:
		current_size = 3
		speed += 2.5
		self.scale *= 1.25
	elif Globals.wheat_eaten >= 10 * wheat_needed and current_size < 4:
		current_size = 4
		speed += 2.5
		self.scale *= 1.25

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not Input.is_action_pressed("ctrl_speed"):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction or Input.is_action_pressed("ctrl_speed") or Input.is_action_just_released("ctrl_speed"):
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if Input.is_action_pressed("ctrl_speed"):
			if not scaled_down:
				self.scale /= 2
				scaled_down = true
			velocity *= 2
		else:
			if scaled_down:
				self.scale *= 2
				scaled_down = false
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	move_and_slide()

func increase_health(amount: int):
	var new_health = Globals.health_points + amount
	Globals.health_points = min(new_health, Globals.max_hp)

func _on_enemy_detector_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.is_in_group("enemies") and current_size >= 3 and not scaled_down:
		body.queue_free() # delete enemy
		print("enemy eaten")
		Globals.gold_collected += 25
		increase_health(10)
	elif body.is_in_group("enemies") and current_size <= 3:
		print("Ouch! Enemies hit!")
		Globals.health_points -= 10
	elif body.is_in_group("obstacles"):
		print("obstacles hit")
		if current_size == 4 and not scaled_down:
			print("smashing obstacles")
			body.get_parent().queue_free()
			if randf() < 0.05:
				Globals.gold_collected += 100
			if randf() < 0.2:
				Globals.health_points -= 2
	else:
		print("current size:" + str(current_size))
