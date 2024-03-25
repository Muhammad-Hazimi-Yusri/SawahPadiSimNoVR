extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func show_status_popup(message: String, duration: float):
	self.text = message
	self.show()
	$Timer.wait_time = duration
	$Timer.start()

func _on_timer_timeout():
	self.hide()

