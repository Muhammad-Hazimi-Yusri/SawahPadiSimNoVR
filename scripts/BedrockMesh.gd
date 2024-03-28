# WheatField.gd
extends Node3D

# Properties
@export var field_size := Vector2(45, 45)  # Size of the wheat field (x, y)
@export var wheat_density := 0.5  # Density of wheat stalks (0.0 to 1.0)
@export var wheat_height_range := Vector2(1.0, 2.0)  # Minimum and maximum height of wheat stalks
@export var wheat_spawn_chance := 0.2

# Wheat stalk scene
@export var wheat_stalk_scene: PackedScene
@export var bad_wheat_stalk_scene : PackedScene
@export var obstacles: PackedScene
@export var enemies: PackedScene

func _ready():
	generate_wheat_field()

func generate_wheat_field():
	# Clear any existing wheat stalks
	for child in get_children():
		child.queue_free()

	# Generate wheat stalks
	for x in range(field_size.x):
		for y in range(field_size.y):
			var random_num = randf()
			if Vector3(x - field_size.x / 2, 1.25, y - field_size.y / 2) == global_position:
				continue
			# spawn enemies at /15 the chance
			elif random_num < wheat_spawn_chance/15:
				# Determine position within the grid
				var position = Vector3(x - field_size.x / 2, 1.25, y - field_size.y / 2)
				var enemy = enemies.instantiate()
				enemy.transform.origin = position
				add_child(enemy)
				
			# elif spawn obstacles at /3 the chance
			elif random_num < wheat_spawn_chance/3:
				# Determine position within the grid
				var position = Vector3(x - field_size.x / 2, 0.5, y - field_size.y / 2)

				# Determine random height
				var height = randf_range(wheat_height_range.x + 0.5, wheat_height_range.y + 0.5)

				# Instance wheat stalk
				var wheat_stalk = obstacles.instantiate()
				wheat_stalk.transform.origin = position
				wheat_stalk.scale.y = height
				add_child(wheat_stalk)
			# elif no obstacles, spawn bad wheat at half the chance
			elif random_num < wheat_spawn_chance/2:
				# Determine position within the grid
				var position = Vector3(x - field_size.x / 2, 0.5, y - field_size.y / 2)

				# Determine random height
				var height = randf_range(wheat_height_range.x + 0.5, wheat_height_range.y + 0.5)

				# Instance wheat stalk
				var wheat_stalk = bad_wheat_stalk_scene.instantiate()
				wheat_stalk.transform.origin = position
				wheat_stalk.scale.y = height
				add_child(wheat_stalk)
			# Generate randomly based on 20% chance
			elif random_num < wheat_spawn_chance:
				# Determine position within the grid
				var position = Vector3(x - field_size.x / 2, 0.5, y - field_size.y / 2)

				# Determine random height
				var height = randf_range(wheat_height_range.x + 0.5, wheat_height_range.y + 0.5)

				# Instance wheat stalk
				var wheat_stalk = wheat_stalk_scene.instantiate()
				wheat_stalk.transform.origin = position
				wheat_stalk.scale.y = height
				add_child(wheat_stalk)


