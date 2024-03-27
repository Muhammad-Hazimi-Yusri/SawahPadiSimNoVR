extends ColorRect

@export var wheat_leaderboard : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_packed(wheat_leaderboard)
