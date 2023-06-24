extends CharacterBody2D

class_name BasicEnemy

"""|||||||||||||||||||||||||||||||||||| NODES |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

@onready var state_machine = $FiniteStateMachine
enum{
	Idle,
	Walk,
	Attack,
	Damaged,
}


@onready var damage_area_collision = $Rotate/Area2Ds/DamageArea/CollisionShape2D
@onready var attack_area_collision = $Rotate/Area2Ds/AttackDetectionArea/CollisionShape2D
@onready var attack_rate_timer = $Timers/AttackRate
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

"""|||||||||||||||||||||||||||||||||||| VARs |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

@export var speed = 100.0
@export var max_hp = 100.0
@export var damage = 10.0
@export var attack_rate = 0.8
@export var update_path = 0.9


const RADIUS_AROUND_PLAYER = 40


@onready var hp = max_hp:
	set(value):
		hp = value
	get:
		return hp

var player: Player
var random_num

"""|||||||||||||||||||||||||||||||||||| ACTIONS |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

var is_dead = false
var is_attacking = false
@export var can_attack = true

var player_detected = false

"""|||||||||||||||||||||||||||||||||||| CALLBACK |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func _ready():
	damage_area_collision.disabled = true
	attack_area_collision.disabled = false
	
	attack_rate_timer.wait_time = attack_rate
	attack_rate_timer.autostart = false
	
	player = get_tree().get_first_node_in_group("Player")
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	random_num = rng.randf()


func _physics_process(delta):
	movement_handler(delta)

"""|||||||||||||||||||||||||||||||||||| HANDLERS |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func movement_handler(delta: float):
	var move_direction = to_local(nav_agent.get_next_path_position()).normalized()

	var desired_vel = move_direction * speed
	var steering = (desired_vel - velocity) * delta * 5
	
	velocity = desired_vel
	move_and_slide()
	if(player_detected):
		$Rotate.look_at(player.global_position)
	
func actions_handler():
	pass

func create_path(target):
	nav_agent.target_position = target


func _on_navigation_timer_timeout():
	if(nav_agent.distance_to_target() >= 500.0):
		create_path(global_position)
		player_detected = false

	elif(player_detected and !is_attacking and nav_agent.is_target_reachable()):
		create_path(player.global_position)
	
func get_circle_position(random):
	var kill_circle_centre = player.global_position
	
	#Distance from center to circumference of circle
	var angle = random * PI * 3;
	var x = kill_circle_centre.x + cos(angle) * RADIUS_AROUND_PLAYER;
	var y = kill_circle_centre.y + sin(angle) * RADIUS_AROUND_PLAYER;

	return Vector2(x, y)

"""|||||||||||||||||||||||||||||||||||| DETECTION |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func _on_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		player_detected = true
	
func _on_attack_area_body_entered(body):
	if body.is_in_group("Player"):
		attack()

func _on_attack_area_body_exited(body):
	if body.is_in_group("Player"):
		is_attacking = false
	
func _on_damage_area_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(damage, body.global_position - global_position, 10)
	

"""|||||||||||||||||||||||||||||||||||| ACTIONS |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func attack():
	is_attacking = can_attack
	
func start_attack_timer():
	attack_rate_timer.start()

func _on_attack_rate_timeout():
	can_attack = true
	attack_area_collision.disabled = false

"""|||||||||||||||||||||||||||||||||||| DAMAGE |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func take_damage(dmg, push_direction, force):
	#is_attacking = false
	force = force if hp > 0 else force * 2
	velocity += push_direction * force
	move_and_slide()
	
	self.hp -= dmg
	state_machine.set_state(state_machine.states.Damaged if hp > 0 else state_machine.states.Dead)

func die():
	$CollisionShape2D.set_deferred("disabled", true)














func _on_could_not_reach_player_timeout():
	pass # Replace with function body.
