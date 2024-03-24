extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var scaled_down = false
var current_size = 0

@export var wheat_needed := 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta):
	if Globals.wheat_eaten > wheat_needed and current_size < 1:
		current_size += 1
		self.scale *= 1.5
	elif Globals.wheat_eaten > 5 * wheat_needed and current_size < 2:
		current_size += 1
		self.scale *= 1.5
	elif Globals.wheat_eaten > 10 * wheat_needed and current_size < 3:
		current_size += 1
		self.scale *= 1.5

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction or Input.is_action_pressed("ctrl_speed") or Input.is_action_just_released("ctrl_speed"):
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
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
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	move_and_slide()
