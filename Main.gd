extends Node

@onready var player: Area2D = $Player
@onready var mob_timer: Timer = $MobTimer
@onready var score_timer: Timer =$ScoreTimer
@onready var start_timer: Timer = $StartTimer
@onready var start_position: Marker2D = $StartPosition
@onready var mob_path: Path2D = $MobPath
@onready var mob_spawn_location: PathFollow2D = $MobPath/MobSpawnLocation

@export var mob_scene: PackedScene = preload("res://Mob.tscn")

var score: int


# Called when the node enters the scene tree for the first time.
func _ready():
	player.is_hit.connect(game_over)
	score_timer.timeout.connect(increase_score)
	start_timer.timeout.connect(start_game)
	mob_timer.timeout.connect(spawn_mob)
	
	randomize()
	
	new_game()

func game_over():
	score_timer.stop()
	mob_timer.stop()
	
func new_game():
	score = 0
	player.start(start_position.position)
	start_timer.start()
	
func increase_score():
	score += 1

func start_game():
	mob_timer.start()
	score_timer.start()

func spawn_mob():
	var mob: RigidBody2D = mob_scene.instantiate()

	mob_spawn_location.progress_ratio = randi()
	
	# Set the mob's direction perpendicular to the path direction.
	var direction: float = mob_spawn_location.rotation + PI / 2
	direction += randf_range(-PI / 4, PI / 4)
	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	
	mob.position = mob_spawn_location.position
	mob.rotation = direction
	mob.linear_velocity = velocity.rotated(direction)
	
	add_child(mob)
