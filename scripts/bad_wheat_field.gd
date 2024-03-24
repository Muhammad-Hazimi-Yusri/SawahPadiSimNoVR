extends Node3D

#signal wheat_ate

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func bad_wheat_eat():
	#wheat_ate.emit()
	Globals.wheat_eaten -= 1
	Globals.health_points -= 0.1
	print("Bad wheat eaten, now at: " + str(Globals.wheat_eaten))
	print("HP - 0.1, now at: " + str(Globals.health_points))
	queue_free()


func _on_player_detector_body_entered(body):
	bad_wheat_eat()
