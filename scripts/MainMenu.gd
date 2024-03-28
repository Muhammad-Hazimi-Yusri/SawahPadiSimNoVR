extends ColorRect

@export var wheat_leaderboard : PackedScene
@export var gold_leaderboard : PackedScene
@export var time_leaderboard : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_wheat_leaderboard_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_packed(wheat_leaderboard)


func _on_gold_leaderboard_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_packed(gold_leaderboard)


func _on_time_leaderboard_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_packed(time_leaderboard)
