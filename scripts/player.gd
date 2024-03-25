extends CharacterBody3D


const JUMP_VELOCITY = 4.5

var scaled_down = false

@export var speed = 5
@export var wheat_needed := 10

@onready var status_popup = get_parent().get_node("Control/StatusPopup")
@onready var player_popup = $CameraPivot/Camera3D/PlayerPopup

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	pass
	
func _process(delta):
	if Globals.wheat_eaten >= wheat_needed and Globals.current_size < 1 and not scaled_down:
		Globals.current_size = 1
		speed += 2.5
		self.scale *= 1.25
	elif Globals.wheat_eaten >= 2.5 * wheat_needed and Globals.current_size < 2 and not scaled_down:
		Globals.current_size = 2
		speed += 2.5
		self.scale *= 1.25
	elif Globals.wheat_eaten >= 5 * wheat_needed and Globals.current_size < 3 and not scaled_down:
		Globals.current_size = 3
		status_popup.show_status_popup("You can now eat the enemies! They give coins when eaten.\nUsing CTRL will still hurt you though.", 5)
		speed += 2.5
		self.scale *= 1.25
	elif Globals.wheat_eaten >= 10 * wheat_needed and Globals.current_size < 4 and not scaled_down:
		Globals.current_size = 4
		status_popup.show_status_popup("You can now destroy obstacles, there is random chance for it to hurt you\n and/or give you lots of golds. ", 5)
		speed += 2.5
		self.scale *= 1.25
	Globals.player = self
	
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
		if Input.is_action_pressed("ctrl_speed") and is_on_floor():
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
	create_label("+%s HP" % amount, 1, Color.LAWN_GREEN)
	Globals.health_points = min(new_health, Globals.max_hp)

func _on_enemy_detector_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	
	if body.is_in_group("enemies") and Globals.current_size >= 3 and not scaled_down:
		body.queue_free() # delete enemy
		print("enemy eaten")
		Globals.gold_collected += 25
		create_label("+25 G", 1, Color.GOLD)
		increase_health(10)
	
	elif body.is_in_group("enemies") and Globals.current_size <= 3:
		print("Ouch! Enemies hit!")
		Globals.health_points -= 10
		create_label("-10 HP", 1.0, Color.DARK_RED) # Display for 1 second
	
	elif body.is_in_group("obstacles"):
		print("obstacles hit")
		
		if Globals.current_size == 4 and not scaled_down:
			print("smashing obstacles")
			body.get_parent().queue_free()
		
			if randf() < 0.05:
				Globals.gold_collected += 100
				create_label("+100 G", 1, Color.GOLD)
		
			if randf() < 0.2:
				Globals.health_points -= 5
				create_label("-5 HP", 1, Color.DARK_RED)
	else:
		print("current size:" + str(Globals.current_size))

func create_label(text: String, duration: float, color: Color):
	var new_label = Label3D.new()
	new_label.text = text
	new_label.modulate = color
	new_label.offset.x = 0 + randf_range(-20,20)
	new_label.offset.y = 50 + randf_range(-20,20)
	#new_label.billboard = true
	new_label.pixel_size = 0.025
	new_label.position.y = 0.2
	new_label.position.z = 0.5
	
	self.add_child(new_label)
	var label_timer = Timer.new()
	
	# Connect the timeout signal of the label_timer
	label_timer.wait_time = duration
	self.add_child(label_timer)
	label_timer.timeout.connect(new_label.queue_free)
	label_timer.start()
	print("new label created")

func _on_label_timer_timeout(label: Label3D):
	label.queue_free()
