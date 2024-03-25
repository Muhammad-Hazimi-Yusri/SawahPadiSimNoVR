extends CharacterBody3D

var movement_speed: float = 2.0
var new_target: Vector3 = Vector3(self.position.x + randf_range(-20,20), self.position.y, self.position.z + randf_range(-20,20))
var original_position = Vector3(0,0,0)

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	original_position = self.position
	#print("original position is:" + str(original_position))
	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup(target_location):
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(target_location)

func set_movement_target(target_location):
	var new_target
	if (self.position.distance_to(target_location) < 15):
		new_target = Vector3(target_location.x + randf_range(-1, 1), global_position.y, target_location.z + randf_range(-1, 1))
		movement_speed = 6.0
		#print("target near! going to: " + str(new_target))
	else:
		#print("target far")
		new_target = Vector3(original_position.x + randf_range(-5, 5), global_position.y, original_position.z + randf_range(-5, 5))
		movement_speed = 4.0
	navigation_agent.set_target_position(new_target)
	 

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	#print("move enemy")
	navigation_agent.set_velocity(new_velocity)




func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = safe_velocity.move_toward(safe_velocity, .25)
	move_and_slide()
