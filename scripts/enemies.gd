extends CharacterBody3D

var movement_speed: float = 2.0
var new_target: Vector3 = Vector3(self.position.x + randf_range(-20,20), self.position.y, self.position.z + randf_range(-20,20))

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target()

func set_movement_target():
	var new_target = Vector3(global_position.x + randf_range(-20,20), global_position.y, global_position.z + randf_range(-20,20))
	navigation_agent.set_target_position(new_target)

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		#print("nav finished")
		if navigation_agent.is_target_reached():
			#print("target reached")
			actor_setup()
		else:
			#print("target not reached! restarting nav")
			actor_setup()

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	#print("move enemy")
	move_and_slide()

