extends Node

@onready var player = $Player

@export var enemy_repath_timer = 1;
var timer: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.start:
		print("starto ready")
		get_tree().paused = false
		$Control/MainMenu.hide()
	elif not Globals.start:
		get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.health_points < 0:
		$Control/MainMenu.show()
		$Control/MainMenu/Label.hide()
		$Control/MainMenu/Label2.hide()
		var retry:Label = $Control/MainMenu/Start_Retry
		retry.vertical_alignment = 0
		retry.add_theme_color_override("font_color", Color.CRIMSON)
		retry.text = "YOU DIED!!! \nPress Enter/Spacebar to retry!"
		get_tree().paused = true
	
	if get_tree().get_nodes_in_group("enemies").size() == 0 and get_tree().get_nodes_in_group("wheats").size() == 0:
		$Control/MainMenu.show()
		$Control/MainMenu/Label.hide()
		$Control/MainMenu/Label2.hide()
		var retry:Label = $Control/MainMenu/Start_Retry
		retry.vertical_alignment = 0
		retry.add_theme_color_override("font_color", Color.GOLD)
		retry.text = "YOU WIN!!! \nPress Enter/Spacebar to play again!"
		get_tree().paused = true
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $Control/MainMenu.visible:
		print("starto!")
		
		Globals.health_points = 100
		Globals.gold_collected = 0
		Globals.wheat_eaten = 0
		Globals.current_size = 0
		
		Globals.start = true
		# This restarts the current scene.
		get_tree().reload_current_scene()
		
		


func _physics_process(delta):
	timer += delta
	if timer >= enemy_repath_timer:  # Check if it's been at least 1 second
		timer = 0.0  # Reset the timer
		get_tree().call_group("enemies", "actor_setup", player.global_position)
