extends CharacterBody2D

class_name Player

"""|||||||||||||||||||||||||||||||||||| NODES |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

@onready var state_machine = $FiniteStateMachine

@onready var damage_area_collision = $DamageArea/CollisionShape2D

@onready var normal_sprite = $Normal
@onready var disguised_sprite = $Disguised

@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree["parameters/playback"]


@onready var starting_point = global_position

var is_level_finished = false
var next_level
var save_system

@onready var black_screen = $ScreenEffects/FadeToBlackScreen
var b_screen_tween : Tween

@onready var vignette = $ScreenEffects/VignetteEffect
var vignette_m = 1.8
var vignette_s = 1.8

var rng

"""|||||||||||||||||||||||||||||||||||| VARs |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

@export var speed = 150.0
@export var attack_damage = 10.0
@export var hp = 100:
	set(value):
		hp = value
	get:
		return hp
signal hp_changed(new_hp)
@onready var max_hp = hp

@onready var gold = Scoring.s_gold:
	set(value):
		gold = value
	get:
		return gold
signal gold_changed(new_gold)

const FRICTION = 10
@onready var stopwatch = Scoring.s_time:
	set(value):
		stopwatch = value
	get:
		return stopwatch

@onready var enemy_kill_count = Scoring.s_enemies


signal level_timer_changed(new_time)

"""|||||||||||||||||||||||||||||||||||| ACTIONS |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

var is_dead = false
var is_attacking = false
var is_interacting = false
var is_disguised = false

var is_moving = false
var idle = true


var is_ready = false

"""|||||||||||||||||||||||||||||||||||| CALLBACK |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func _ready():
	damage_area_collision.disabled = true
	disguised_sprite.visible = false
	
	animation_tree.active = true
	
	save_system = get_tree().get_first_node_in_group("Save")
	
	is_ready = true
	
	vignette.material.set("shader_parameter/multiplier", vignette_m);
	vignette.material.set("shader_parameter/softness", vignette_s);
	
	emit_signal("gold_changed", gold)
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
func _process(delta):
	update_level_timer(delta)

func _physics_process(_delta):
	movement_input(_delta)
	actions_input()
	move_and_slide()

func update_enemy_kill_count(kills):
	enemy_kill_count += kills

func _on_load_save_system_timer_timeout():
	pass

"""|||||||||||||||||||||||||||||||||||| INPUT |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func movement_input(delta):
	var move_dir = Input.get_vector("left", "right", "up", "down")
	
	if move_dir != Vector2.ZERO:
		animation_tree.set("parameters/Attack/blend_position", move_dir)
		animation_tree.set("parameters/Idle/blend_position", move_dir)
		animation_tree.set("parameters/Walk/blend_position", move_dir)
	
	var desired_vel = move_dir * speed
	var steering = (desired_vel - velocity) * delta * FRICTION
	velocity += steering
	
func actions_input():
	if(Input.is_action_just_pressed("attack")):
		attack()
	if(Input.is_action_just_pressed("interact")):
		interact()

"""|||||||||||||||||||||||||||||||||||| ACTIONS |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func attack():
	is_attacking = true
	var random_num = rng.randf_range(0.5, 0.9)
	$SFX/Attack.pitch_scale = random_num
	$SFX/Attack.play()

func _on_damage_area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(attack_damage, Vector2(body.global_position.x, body.global_position.y) - Vector2(global_position.x -5, global_position.y-5), 50)
	
func interact():
	is_interacting = true

func disguise(is_dis: bool):
	is_disguised = is_dis
	normal_sprite.visible = !is_dis
	disguised_sprite.visible = is_dis

func add_gold(amount):
	$SFX/GetTreasure.play()
	gold += amount
	emit_signal("gold_changed", gold)
	#emit_signal("gold_changed", gold)

"""|||||||||||||||||||||||||||||||||||| HEALTH |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func set_hp(new_hp):
	hp = new_hp
	vignette.material.set("shader_parameter/softness", vignette_s - (max_hp-hp));
	emit_signal("hp_changed", new_hp)
	

func take_damage(damage, push_direction, force):
	$SFX/Damaged.play()
	velocity += push_direction * force
	move_and_slide()
	
	self.hp -= damage
	var soft = vignette.material.get("shader_parameter/softness")
	vignette.material.set("shader_parameter/softness", soft - 0.1);
	state_machine.set_state(state_machine.states.Damaged if hp > 0 else state_machine.states.Dead)
	
	set_hp(hp)
	

func die():
	$SFX/Death.play()
	vignette.material.set("shader_parameter/multiplier", vignette.material.get("shader_parameter/multiplier") - 0.1);
	fade_to_black_screen(1,0.5)

func respawn():
	if is_dead:
		is_dead = false
		global_position = starting_point
		set_hp(max_hp)
		
		fade_to_black_screen(0,0.5)
		vignette.material.set("shader_parameter/softness", vignette_s);
		vignette.material.set("shader_parameter/multiplier", vignette_m);
		
		
	vignette.visible = false
	#fade_to_black_screen(1,0.5)
	

"""|||||||||||||||||||||||||||||||||||| TIME |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func update_level_timer(delta):
	if !is_level_finished:
		stopwatch += delta
		emit_signal("level_timer_changed", seconds2hhmmss(stopwatch))

func seconds2hhmmss(total_seconds: float) -> String:
	var seconds:float = fmod(total_seconds , 60.0)
	var minutes:int   =  int(total_seconds / 60.0) % 60
	#var hours:  int   =  int(total_seconds / 3600.0)
	var hhmmss_string:String = "%02d:%04.1f" % [minutes, seconds]
	return hhmmss_string
	
"""|||||||||||||||||||||||||||||||||||| LEVEL |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func change_level(level):
	
	Scoring.s_gold = gold
	Scoring.s_enemies = enemy_kill_count
	Scoring.s_time = stopwatch
	
	Scoring.s_score = (gold - (enemy_kill_count * 10))/stopwatch
	
	
	next_level = level
	fade_to_black_screen(1,1)
	is_level_finished = true
#
#	var save_dict = {
#			"level" : save_system.level,
#	}
#	var json_string = JSON.stringify(save_dict)
#	save_system.save_data(json_string)
	

func change_scene():
	if is_level_finished and next_level:
		get_tree().change_scene_to_packed(next_level)
	elif is_dead:
		respawn()
	
	
func fade_to_black_screen(final, duration):
	if b_screen_tween: b_screen_tween.kill()
	
	b_screen_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	b_screen_tween.connect("finished",change_scene)
	
	b_screen_tween.tween_property(black_screen, "modulate", Color(1,1,1,final), duration)


