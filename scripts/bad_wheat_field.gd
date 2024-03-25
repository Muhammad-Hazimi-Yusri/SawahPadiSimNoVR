extends Node3D

signal bad_wheat_ate

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func bad_wheat_eat():
	bad_wheat_ate.emit()
	Globals.wheat_eaten -= 1
	Globals.health_points -= 0.1
	print("Bad wheat eaten, now at: " + str(Globals.wheat_eaten))
	print("HP - 0.1, now at: " + str(Globals.health_points))
	create_label("-1 Wheat", 1, Color.WEB_PURPLE)
	queue_free()


func _on_player_detector_body_entered(body):
	bad_wheat_eat()

func create_label(text: String, duration: float, color: Color):
	var new_label = Label3D.new()
	new_label.text = text
	new_label.modulate = color
	new_label.offset.x = 0 + randf_range(-20,20)
	new_label.offset.y = 50 + randf_range(-20,20)
	#new_label.billboard = true
	new_label.pixel_size = 0.025
	new_label.position.x = Globals.player.position.x
	new_label.position.y = Globals.player.position.y
	new_label.position.z = Globals.player.position.z
	new_label.billboard = true
	
	get_parent().add_child(new_label)
	var label_timer = Timer.new()
	
	# Connect the timeout signal of the label_timer
	label_timer.wait_time = duration
	get_parent().add_child(label_timer)
	label_timer.timeout.connect(new_label.queue_free)
	label_timer.start()
	print("new label created")

func _on_label_timer_timeout(label: Label3D):
	label.queue_free()
