extends Area2D
signal hit

@export var speed = 200 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var velocity := Vector2.ZERO
var swipe_threshold := 0


func _ready():
	screen_size = get_viewport_rect().size
	Input.set_use_accumulated_input(false)
	hide()
	
	var config = ConfigFile.new()
	var err = config.load("res://docs/config.cfg")
	if err == OK:
		speed = config.get_value("player", "speed", speed)
		print("Velocidad cargada:", speed)
	else:
		print("No se pudo cargar config.cfg, usando valor por defecto.")
	
func _physics_process(delta):
	position += velocity * delta
	var sprite_size = get_current_sprite_size($AnimatedSprite2D) * $AnimatedSprite2D.scale
	var limits = get_movement_limits(screen_size, sprite_size)
	position = position.clamp(limits["min"], limits["max"])
	
func _unhandled_input(event):
	if event is InputEventScreenDrag:
		if event.relative.length() > swipe_threshold:
			velocity = event.relative.normalized() * speed

	elif event is InputEventScreenTouch and not event.pressed:
		velocity = Vector2.ZERO
		
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

func _process(delta):
	
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	var sprite_size = get_current_sprite_size($AnimatedSprite2D) * $AnimatedSprite2D.scale
	var limits = get_movement_limits(screen_size, sprite_size)
	position = position.clamp(limits["min"], limits["max"])

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0


func get_current_sprite_size(animated_sprite: AnimatedSprite2D) -> Vector2:
	var current_anim = animated_sprite.animation
	var current_frame = animated_sprite.frame
	var frame_texture = animated_sprite.sprite_frames.get_frame_texture(current_anim, current_frame)
	return frame_texture.get_size()

func get_movement_limits(map_size: Vector2, sprite_size: Vector2) -> Dictionary:
	var half_size = sprite_size / 2
	var min_limit = Vector2(0, 0) + half_size
	var max_limit = map_size - half_size
	return {
		"min": min_limit,
		"max": max_limit
	}

func _on_body_entered(body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
