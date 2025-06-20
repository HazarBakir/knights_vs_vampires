extends Area2D
@onready var bullet_particle: GPUParticles2D = $BulletParticle
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var particle_timer: Timer = $BulletParticle/Timer
var speed: float = 500.0
var target: CharacterBody2D
var direction: Vector2 = Vector2.ZERO
var follow_target: bool = true

func _ready() -> void:
	add_to_group("bullets")
	setup_follow_timer()
	scale = Vector2(1.3, 1.3)

func _physics_process(delta: float) -> void:
	if follow_target:
		move_to_player()
	else:
		look_at(global_position + direction)
	
	position += direction * speed * delta

func setup_follow_timer() -> void:
	var follow_timer = Timer.new()
	follow_timer.wait_time = 1.0
	follow_timer.one_shot = true
	follow_timer.timeout.connect(_stop_following)
	add_child(follow_timer)
	follow_timer.start()

func move_to_player() -> void:
	if follow_target and target:
		direction = (target.position - position).normalized()
		look_at(target.position)

func _stop_following() -> void:
	follow_target = false
	look_at(global_position + direction)
	setup_destroy_timer()

func setup_destroy_timer() -> void:
	var destroy_timer = Timer.new()
	destroy_timer.wait_time = 2.0
	destroy_timer.one_shot = true
	destroy_timer.timeout.connect(_destroy_projectile)
	add_child(destroy_timer)
	destroy_timer.start()

func _destroy_projectile() -> void:
	if not animated_sprite == null:
		follow_target = false
		particle_manager.emit_particle("bullet", position)
		queue_free()

func _on_bullet_destroy_timer_timeout() -> void:
	queue_free()
func screen_shake_on_collision(intensity: int, time: float):
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		var player = player_nodes[0]
		if player.has_node("Camera2D"):
			player.get_node("Camera2D").screen_shake(intensity, time)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") or area.get_parent().is_in_group("player") and area is HitboxComponent:
		if target.is_attacking == false:
		#PlayerStats.take_damage(10)
			screen_shake_on_collision(15, 0.5)
		else:
			screen_shake_on_collision(3, 0.2)
		_destroy_projectile()
