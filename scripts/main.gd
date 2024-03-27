extends Node

@onready var player = $Player
@onready var Name = $Control/MainMenu/Name.text

@export var enemy_repath_timer = 1;

var timer: float = 0.0

signal main_menu_shown
signal main_menu_hidden

# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.start:
		print("game started, player name is: " + str(Name))
		get_tree().paused = false
		$Control/MainMenu.hide()
		emit_signal("main_menu_hidden")
	elif not Globals.start:
		emit_signal("main_menu_shown")
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

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
		emit_signal("main_menu_shown")
		
	
	if get_tree().get_nodes_in_group("enemies").size() == 0 and get_tree().get_nodes_in_group("wheats").size() == 0:
		$Control/MainMenu.show()
		$Control/MainMenu/Label.hide()
		$Control/MainMenu/Label2.hide()
		var retry:Label = $Control/MainMenu/Start_Retry
		retry.vertical_alignment = 0
		retry.add_theme_color_override("font_color", Color.GOLD)
		retry.text = "YOU WIN!!! \nPress Enter/Spacebar to play again!"
		await Leaderboards.post_guest_score("rfratio-wheat-5caJ", Globals.wheat_eaten, str(Name))
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		emit_signal("main_menu_shown")
	
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
		
	if event.is_action_pressed("ui_cancel"):
		if not $Control/MainMenu.visible:
			get_tree().paused = true
			emit_signal("main_menu_shown")
			$Control/MainMenu/Start_Retry.text = "Game is paused. Press ESC to resume or Enter/Spacebar to retry!"
			$Control/MainMenu.show()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif $Control/MainMenu.visible:
			$Control/MainMenu.hide()
			emit_signal("main_menu_hidden")
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		


func _physics_process(delta):
	timer += delta
	if timer >= enemy_repath_timer:  # Check if it's been at least 1 second
		timer = 0.0  # Reset the timer
		get_tree().call_group("enemies", "actor_setup", player.global_position)



func _on_timer_timeout():
	$Control/MainMenu/WheatLeaderboard.hide()
	print("Reshowing leaderboard")
	$Control/MainMenu/WheatLeaderboard.show()

