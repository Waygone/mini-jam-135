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


@onready var damage_area_collision = $Area2Ds/DamageArea/CollisionShape2D
@onready var attack_area_collision = $Area2Ds/AttackDetectionArea/CollisionShape2D
@onready var alert_enemies_collision = $Area2Ds/AlertOtherEnemy/CollisionShape2D
@onready var attack_rate_timer = $Timers/AttackRate
@onready var could_not_reach_timer = $Timers/CouldNotReachPlayer
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree["parameters/playback"]

"""|||||||||||||||||||||||||||||||||||| VARs |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

@export var speed = 120.0

@export var hp = 40:
	set(value):
		hp = value
	get:
		return hp
@export var damage = 8.0

@export var attack_rate = 0.9
@export var max_time_reach = 20.0

@export var drops_disguise = false
var disguise_scene = preload("res://Assets/Prefabs/Pickables/Disguise.tscn")

@export var waypoints: Array[NodePath]
var waypoint_index = 0
@onready var starting_point = global_position

@export var doors_to_open: Array[NodePath]

const RADIUS_AROUND_PLAYER = 40

var rotation_tween : Tween


var player: Player
var random_num

"""|||||||||||||||||||||||||||||||||||| ACTIONS |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

var is_dead = false
var is_attacking = false
var is_roaming = false
var can_attack = true

var is_ready = false

var rng

var player_detected = false

"""|||||||||||||||||||||||||||||||||||| CALLBACK |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func _ready():
	animation_tree.active = true
	
	damage_area_collision.disabled = true
	alert_enemies_collision.disabled = true
	attack_area_collision.disabled = false
	
	attack_rate_timer.wait_time = attack_rate
	attack_rate_timer.autostart = false
	
	could_not_reach_timer.wait_time = max_time_reach
	could_not_reach_timer.autostart = false
	
	player = get_tree().get_first_node_in_group("Player")
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	random_num = rng.randf()
	
	roam()
	
	is_ready = true


func _process(_delta):
	if !is_dead and !player.is_level_finished:
		detect_player()

func _physics_process(_delta):
	if !is_dead and !player.is_level_finished:
		movement_handler()

"""|||||||||||||||||||||||||||||||||||| HANDLERS |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func movement_handler():
	var move_direction = to_local(nav_agent.get_next_path_position()).normalized()

	if move_direction != Vector2.ZERO:
		animation_tree.set("parameters/Attack/blend_position", move_direction)
		animation_tree.set("parameters/Idle/blend_position", move_direction)
		animation_tree.set("parameters/Walk/blend_position", move_direction)

	#var steering = (desired_vel - velocity) * delta * 5
	velocity = move_direction * speed if player_detected else move_direction * speed / 3
	move_and_slide()
	
	#$Rotate.look_at(nav_agent.target_position)
	_update_roation()
	if(player_detected):
		if(could_not_reach_timer.is_stopped()):
			could_not_reach_timer.start()

func _update_roation():

	var dir = $Rotate.global_position.angle_to_point(nav_agent.target_position)

	if rotation_tween: rotation_tween.kill()

	rotation_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	rotation_tween.tween_property($Rotate, "global_rotation", dir, 0.1)

func actions_handler():
	pass

func create_path(target):
	nav_agent.set_navigation_layer_value(1,true)
	nav_agent.target_position = target


func _on_navigation_timer_timeout():
	if(player_detected and !is_attacking and !player.is_dead):# and nav_agent.is_target_reachable()):
		create_path(player.global_position)

	elif !is_roaming and player_detected:
		stop_agent_following()

	elif(nav_agent.distance_to_target() >= 1000.0):
		if !is_roaming:
			roam()

	
func get_circle_position(random):
	var kill_circle_centre = player.global_position
	
	#Distance from center to circumference of circle
	var angle = random * PI * 3;
	var x = kill_circle_centre.x + cos(angle) * RADIUS_AROUND_PLAYER;
	var y = kill_circle_centre.y + sin(angle) * RADIUS_AROUND_PLAYER;

	return Vector2(x, y)

"""|||||||||||||||||||||||||||||||||||| DETECTION |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func detect_player():
	if !player_detected:
		for i in $Rotate/Raycasts.get_children():
			var temp = i.get_collider()
			if temp:
				if temp.is_in_group("Player"):
					if !temp.is_disguised:
						on_player_detected()

func _on_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		on_player_detected()
#		if !body.is_disguised:
#			player_detected = true
#			alert_other_enemies(true)
	
func on_player_detected():
	player_detected = true && !player.is_dead
	is_roaming = false
	alert_other_enemies(true)

func alert_other_enemies(alert):
	alert_enemies_collision.set_deferred("disabled", !alert)

func _on_alert_other_enemy_body_entered(body):
	if body.is_in_group("Enemy"):
		if !body.player_detected:
			print("alerted: "+body.name)
			body.on_player_detected()
	
func _on_attack_area_body_entered(body):
	if body.is_in_group("Player"):
		attack()

func _on_attack_area_body_exited(body):
	if body.is_in_group("Player"):
		is_attacking = false
	
func _on_damage_area_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(damage, Vector2(body.global_position.x, body.global_position.y) - Vector2(global_position.x -5, global_position.y-5) , 10)
		body.disguise(false)

func stop_agent_following():
	nav_agent.set_navigation_layer_value(1,false)


"""|||||||||||||||||||||||||||||||||||| ACTIONS |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func attack():
	random_num = rng.randf_range(0.5, 1.5)
	$SFX/Attack.pitch_scale = random_num
	$SFX/Attack.play()
	is_attacking = can_attack
	could_not_reach_timer.stop()
	
func start_attack_timer():
	attack_rate_timer.start()

func _on_attack_rate_timeout():
	can_attack = true
	attack_area_collision.disabled = false

func _on_could_not_reach_player_timeout():
	roam()

func roam():
	player_detected = false
	if len(waypoints) > 0:
		is_roaming = true
		alert_other_enemies(false)
		if waypoint_index < len(waypoints):
			create_path(get_node(waypoints[waypoint_index]).global_position)
			waypoint_index += 1
		else:
			waypoint_index = 0
			create_path(get_node(waypoints[waypoint_index]).global_position)
	else:
		create_path(starting_point)


func _on_navigation_agent_2d_navigation_finished():
	if !player_detected:
		roam()

func _on_navigation_agent_2d_target_reached():
	pass

"""|||||||||||||||||||||||||||||||||||| DAMAGE |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func take_damage(dmg, push_direction, force):
	is_attacking = false
	force = force if hp > 0 else force * 2
	velocity += push_direction * force
	move_and_slide()
	
	if !player_detected:
		state_machine.set_state(state_machine.states.Dead)
	else:
		self.hp -= dmg
		state_machine.set_state(state_machine.states.Damaged if hp > 0 else state_machine.states.Dead)

func die():
	player.update_enemy_kill_count(1)
	$CollisionShape2D.set_deferred("disabled", true)
	light_mask
	open_doors_on_death()
	alert_other_enemies(true)
	
	if !player.is_disguised and drops_disguise:
		var disguise_instance = disguise_scene.instantiate()
		disguise_instance.global_position = global_position
		get_tree().get_root().get_node("World/Treasures").add_child(disguise_instance)
	
	$Timers/DeathTimer.start()
	$DeathParticles.set_deferred("emitting", true)
	$AnimatedSprite2D.visible = false
	
	rng.randomize()
	random_num = rng.randf_range(0.5, 1.5)
	$SFX/Die.pitch_scale = random_num
	$SFX/Die.play()

func open_doors_on_death():
	if len(doors_to_open) > 0:
		for i in doors_to_open:
			get_node(i).open()

func _on_death_timer_timeout():
	queue_free()
