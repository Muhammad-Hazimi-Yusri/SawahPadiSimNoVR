extends Button


@export var gameScene : PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():		
	Globals.health_points = 100
	Globals.gold_collected = 0
	Globals.wheat_eaten = 0
	Globals.current_size = 0
	Globals.start = false
	
	get_tree().change_scene_to_file("res://scenes/mainfps.tscn")
	
