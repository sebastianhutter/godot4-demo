extends RigidBody2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var collision: CollisionShape2D = $collision
@onready var visible_notifier: VisibleOnScreenNotifier2D = $visible
sdawd@onready var mob_types: PackedStringArray = sprite.frames.get_animation_names()


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.playing = true
	sprite.animation = mob_types[randi() % mob_types.size()]
	visible_notifier.screen_exited.connect(queue_free)

