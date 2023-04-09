extends Area2D

signal is_hit

@export var speed: float = 400.0

@onready var sprite: AnimatedSprite2D = $sprite
@onready var collision: CollisionShape2D = $collision

var screen_size: Vector2 


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	self.body_entered.connect(_on_player_body_entered)
	
func _process(delta):
	var velocity: Vector2 = Vector2.ZERO

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
		sprite.play()
	else:
		sprite.stop()

	if velocity.x != 0:
		sprite.animation = "walk"
		sprite.flip_v = false
		sprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		sprite.animation = "up"
		sprite.flip_v = velocity.y > 0

	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)


func _on_player_body_entered(_body: Node):
	hide()
	emit_signal("is_hit")
	collision.set_deferred("disabled", true)
	
func start(pos: Vector2):
	position = pos
	show()
	collision.disabled = false
