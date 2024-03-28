extends Node

@onready var player = $Player
@onready var Name = $Control/MainMenu/Name

@export var enemy_repath_timer = 1;

var timer: float = 0.0


var speedrun_timer: float = 0.0
var start_time: int = 0
var elapsed_time: int = 0
var timer_running: bool = false
var timer_paused: bool = false
var paused_time: int = 0
var pause_start_time = 0

signal main_menu_shown
signal main_menu_hidden

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Globals.player_name == "":
		Name.text = Globals.player_name
	if Globals.start:
		print("game started, player name is: " + str(Globals.player_name))
		get_tree().paused = false
		Globals.won = false
		start_timer()
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
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		retry.text = "YOU DIED!!! \nPress Enter/Spacebar to retry!"
		stop_timer()
		get_tree().paused = true
		emit_signal("main_menu_shown")
		print("U died in: " + str(speedrun_timer) + "s")
		
	
	if get_tree().get_nodes_in_group("enemies").size() == 0 and get_tree().get_nodes_in_group("wheats").size() == 0 and not Globals.won:
		$Control/MainMenu.show()
		$Control/MainMenu/Label.hide()
		$Control/MainMenu/Label2.hide()
		var retry:Label = $Control/MainMenu/Start_Retry
		retry.vertical_alignment = 0
		retry.add_theme_color_override("font_color", Color.GOLD)
		retry.text = "YOU WIN!!! \nPress Enter/Spacebar to play again!"
		Globals.won = true
		stop_timer()
		print("Submitting score as:" + Globals.player_name)
		if await Leaderboards.post_guest_score("rfratio-wheat-fr-yGPl", Globals.wheat_eaten, Globals.player_name):
			print("Wheat score posted")
		if await Leaderboards.post_guest_score("rfratio-gold-fr-2mXs", Globals.gold_collected, Globals.player_name):
			print("Gold score posted")
		if await Leaderboards.post_guest_score("rfratio-speedrun-fr-EBQW", speedrun_timer, Globals.player_name):
			print("Time score posted")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		emit_signal("main_menu_shown")
	
	if timer_running:
		print("Time ticks is: " + str(Time.get_ticks_msec()))
		if timer_paused:
			print("Paused time is: " + str(paused_time))
		else:
			print("Paused time offset is: " + str(paused_time))
			elapsed_time = Time.get_ticks_msec() - start_time - paused_time
			update_time_label()

func start_timer():
	timer_running = true
	start_time = Time.get_ticks_msec()
	timer_paused = false

func stop_timer():
	print("timer stopped")
	timer_running = false
	elapsed_time = 0.0
	
func resume_timer():
	paused_time += Time.get_ticks_msec() - pause_start_time
	timer_paused = false

func pause_timer():
	pause_start_time = Time.get_ticks_msec()
	timer_paused = true
	print("pause timer called")

func update_time_label():
	var elapsed_milliseconds = elapsed_time
	var minutes = elapsed_milliseconds / 60000
	var seconds = (elapsed_milliseconds % 60000) / 1000
	var milliseconds = elapsed_milliseconds % 1000
	
	speedrun_timer = float(seconds + elapsed_milliseconds)/1000
	Globals.time_string = "%02d:%02d:%03d" % [minutes, seconds, milliseconds]
	
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
			pause_timer()
			get_tree().paused = true
			emit_signal("main_menu_shown")
			$Control/MainMenu/Start_Retry.text = "Game is paused. Press ESC to resume or Enter/Spacebar to retry!"
			$Control/MainMenu.show()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif $Control/MainMenu.visible:
			$Control/MainMenu.hide()
			emit_signal("main_menu_hidden")
			get_tree().paused = false
			resume_timer()
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



func _on_name_text_changed(new_text):
	Globals.player_name = new_text
