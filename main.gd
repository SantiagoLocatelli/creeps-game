extends Node

@export var mob_scene: PackedScene
var score
var is_player_alive = true


var min_speed = 200
var max_speed = 300

func _ready():
	var config = ConfigFile.new()
	var err = config.load("res://docs/config.cfg")
	if err == OK:
		min_speed = config.get_value("creeps", "min_speed", min_speed)
		max_speed = config.get_value("creeps", "max_speed", max_speed)
		print("Creep velocidad mínima:", min_speed, ", máxima:", max_speed)
	else:
		print("No se pudo cargar config.cfg, usando velocidades por defecto.")

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	is_player_alive = false

func new_game():
	get_tree().call_group("mobs", "queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()
	is_player_alive = true

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(min_speed, max_speed), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	
func _on_score_timer_timeout():
	if is_player_alive:
		score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
