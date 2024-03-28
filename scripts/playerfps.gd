@tool
extends CharacterBody3D

var BasicFPSPlayerScene : PackedScene = preload("res://scenes/basic_player_head.tscn")
var addedHead = false

func _enter_tree():
	
	if find_child("Head"):
		addedHead = true
	
	if Engine.is_editor_hint() && !addedHead:
		var s = BasicFPSPlayerScene.instantiate()
		add_child(s)
		s.owner = get_tree().edited_scene_root
		addedHead = true

## PLAYER MOVMENT SCRIPT ##
###########################

@export_category("Mouse Capture")
@export var CAPTURE_ON_START := true

@export_category("Movement")
@export_subgroup("Settings")
@export var SPEED := 5.0
@export var ACCEL := 50.0
@export var IN_AIR_SPEED := 3.0
@export var IN_AIR_ACCEL := 5.0
@export var JUMP_VELOCITY := 4.5
@export_subgroup("Head Bob")
@export var HEAD_BOB := true
@export var HEAD_BOB_FREQUENCY := 0.3
@export var HEAD_BOB_AMPLITUDE := 0.01
@export_subgroup("Clamp Head Rotation")
@export var CLAMP_HEAD_ROTATION := true
@export var CLAMP_HEAD_ROTATION_MIN := -90.0
@export var CLAMP_HEAD_ROTATION_MAX := 90.0

@export_category("Key Binds")
@export_subgroup("Mouse")
@export var MOUSE_ACCEL := true
@export var KEY_BIND_MOUSE_SENS := 0.005
@export var KEY_BIND_MOUSE_ACCEL := 50
@export_subgroup("Movement")
@export var KEY_BIND_UP := "ui_up"
@export var KEY_BIND_LEFT := "ui_left"
@export var KEY_BIND_RIGHT := "ui_right"
@export var KEY_BIND_DOWN := "ui_down"
@export var KEY_BIND_JUMP := "ui_accept"

@export_category("Advanced")
@export var UPDATE_PLAYER_ON_PHYS_STEP := true	# When check player is moved and rotated in _physics_process (fixed fps)
												# Otherwise player is updated in _process (uncapped)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# To keep track of current speed and acceleration
var speed = SPEED
var accel = ACCEL

# Used when lerping rotation to reduce stuttering when moving the mouse
var rotation_target_player : float
var rotation_target_head : float

# Used when bobing head
var head_start_pos : Vector3

# Current player tick, used in head bob calculation
var tick = 0

var scaled_down = false

@export var wheat_needed := 10

@onready var status_popup = get_parent().get_node("Control/StatusPopup")

var is_main_menu_visible = false


func _ready():
	if Engine.is_editor_hint():
		return

	# Capture mouse if set to true
	if CAPTURE_ON_START:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	head_start_pos = $Head.position
	
func _on_mainfps_main_menu_shown():
	is_main_menu_visible = true
	#print("Main Menu shown")

func _on_mainfps_main_menu_hidden():
	is_main_menu_visible = false

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	
	if is_main_menu_visible:
		# Main menu is visible, disable player movement
		return
	
	# Increment player tick, used in head bob motion
	tick += 1
	
	if UPDATE_PLAYER_ON_PHYS_STEP:
		move_player(delta)
		rotate_player(delta)
	
	if HEAD_BOB:
		# Only move head when on the floor and moving
		if velocity && is_on_floor():
			head_bob_motion()
		reset_head_bob(delta)

func _process(delta):
	if Engine.is_editor_hint():
		return

	if !UPDATE_PLAYER_ON_PHYS_STEP:
		move_player(delta)
		rotate_player(delta)

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
		status_popup.show_status_popup("You can now eat the enemies! They give coins and HP when eaten.", 5)
		speed += 2.5
		self.scale *= 1.25
	elif Globals.wheat_eaten >= 10 * wheat_needed and Globals.current_size < 4 and not scaled_down:
		Globals.current_size = 4
		status_popup.show_status_popup("You can now destroy obstacles, there is random chance for it to hurt you\n and/or give you lots of golds. ", 5)
		speed += 2.5
		self.scale *= 1.25
		
	Globals.player = self
	
func _input(event):
	if Engine.is_editor_hint():
		return
		
	# Listen for mouse movement and check if mouse is captured
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		set_rotation_target(event.relative)

func set_rotation_target(mouse_motion : Vector2):
	# Add player target to the mouse -x input
	rotation_target_player += -mouse_motion.x * KEY_BIND_MOUSE_SENS
	# Add head target to the mouse -y input
	rotation_target_head += -mouse_motion.y * KEY_BIND_MOUSE_SENS
	# Clamp rotation
	if CLAMP_HEAD_ROTATION:
		rotation_target_head = clamp(rotation_target_head, deg_to_rad(CLAMP_HEAD_ROTATION_MIN), deg_to_rad(CLAMP_HEAD_ROTATION_MAX))
	
func rotate_player(delta):
	if MOUSE_ACCEL:
		# Shperical lerp between player rotation and target
		quaternion = quaternion.slerp(Quaternion(Vector3.UP, rotation_target_player), KEY_BIND_MOUSE_ACCEL * delta)
		# Same again for head
		$Head.quaternion = $Head.quaternion.slerp(Quaternion(Vector3.RIGHT, rotation_target_head), KEY_BIND_MOUSE_ACCEL * delta)
	else:
		# If mouse accel is turned off, simply set to target
		quaternion = Quaternion(Vector3.UP, rotation_target_player)
		$Head.quaternion = Quaternion(Vector3.RIGHT, rotation_target_head)
	
func move_player(delta):
	# Check if not on floor
	if not is_on_floor():
		# Reduce speed and accel
		speed = IN_AIR_SPEED
		accel = IN_AIR_ACCEL
		# Add the gravity
		velocity.y -= gravity * delta
	else:
		# Set speed and accel to defualt
		speed = SPEED
		accel = ACCEL

	# Handle Jump.
	if Input.is_action_just_pressed(KEY_BIND_JUMP) and is_on_floor() and not Input.is_action_pressed("ctrl_speed"):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector(KEY_BIND_LEFT, KEY_BIND_RIGHT, KEY_BIND_UP, KEY_BIND_DOWN)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	velocity.x = move_toward(velocity.x, direction.x * speed, accel * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, accel * delta)

	if Input.is_action_pressed("ctrl_speed") or Input.is_action_just_released("ctrl_speed"):
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
				
	move_and_slide()

func head_bob_motion():
	var pos = Vector3.ZERO
	pos.y += sin(tick * HEAD_BOB_FREQUENCY) * HEAD_BOB_AMPLITUDE
	pos.x += cos(tick * HEAD_BOB_FREQUENCY/2) * HEAD_BOB_AMPLITUDE * 2
	$Head.position += pos

func reset_head_bob(delta):
	# Lerp back to the staring position
	if $Head.position == head_start_pos:
		pass
	$Head.position = lerp($Head.position, head_start_pos, 2 * (1/HEAD_BOB_FREQUENCY) * delta)
	
	
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
	new_label.position.z = -2
	
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

