extends CharacterBody2D

class_name Player

"""|||||||||||||||||||||||||||||||||||| NODES |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

@onready var state_machine = $FiniteStateMachine

@onready var damage_area_collision = $DamageArea/CollisionShape2D

@onready var normal_sprite = $Normal
@onready var disguised_sprite = $Disguised

@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree["parameters/playback"]

var save_system

"""|||||||||||||||||||||||||||||||||||| VARs |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

@export var speed = 300.0
@export var attack_damage = 10.0
@export var hp = 100:
	set(value):
		hp = value
	get:
		return hp
signal hp_changed(new_hp)

@export var gold = 0.0:
	set(value):
		gold = value
	get:
		return gold
signal gold_changed(new_gold)

const FRICTION = 10
var stopwatch = 0.0

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
	
	save_system = get_tree().get_first_node_in_group("Save")
	animation_tree.active = true
	is_ready = true
	
func _process(delta):
	stopwatch += delta

func _physics_process(_delta):
	movement_input(_delta)
	actions_input()
	move_and_slide()

func collect_points(points: int):
	var levelName = "One"  # Assuming the level scene name is used as the level identifier
	var totalPoints = save_system.load_points(levelName)
	totalPoints += points
	save_system.save_points(levelName, totalPoints)
	emit_signal("gold_changed", totalPoints)

func _on_load_save_system_timer_timeout():
	collect_points(0)

"""|||||||||||||||||||||||||||||||||||| INPUT |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func movement_input(delta):
	var move_dir = Input.get_vector("left", "right", "up", "down")
	
	if move_dir != Vector2.ZERO:
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

func _on_damage_area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(attack_damage, body.global_position - global_position, 25)
	
func interact():
	is_interacting = true

func disguise(is_dis: bool):
	is_disguised = is_dis
	normal_sprite.visible = !is_dis
	disguised_sprite.visible = is_dis

func add_gold(amount):
	gold += amount
	collect_points(amount)
	#emit_signal("gold_changed", gold)

"""|||||||||||||||||||||||||||||||||||| HEALTH |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func set_hp(new_hp):
	hp = new_hp
	emit_signal("hp_changed", new_hp)
	

func take_damage(damage, push_direction, force):
	
	velocity += push_direction * force
	move_and_slide()
	
	self.hp -= damage
	state_machine.set_state(state_machine.states.Damaged if hp > 0 else state_machine.states.Dead)
	
	emit_signal("hp_changed", hp)
	

func die():
	#FX FOR DEATH
	pass

