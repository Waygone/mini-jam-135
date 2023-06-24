extends CharacterBody2D

class_name Player

"""|||||||||||||||||||||||||||||||||||| NODES |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

@onready var state_machine = $FiniteStateMachine

@onready var damage_area_collision = $DamageArea/CollisionShape2D

"""|||||||||||||||||||||||||||||||||||| VARs |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

@export var speed = 500.0
@export var attack_damage = 10.0
@export var hp = 100:
	set(value):
		hp = value
	get:
		return hp
signal hp_changed(new_hp)

const FRICTION = 10


"""|||||||||||||||||||||||||||||||||||| ACTIONS |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

var is_dead = false
var is_attacking = false
var is_interacting = false

"""|||||||||||||||||||||||||||||||||||| CALLBACK |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func _ready():
	damage_area_collision.disabled = true


func _physics_process(_delta):
	movement_input(_delta)
	actions_input()
	move_and_slide()
	look_at(get_global_mouse_position())

"""|||||||||||||||||||||||||||||||||||| INPUT |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"""

func movement_input(delta):
	var move_dir = Input.get_vector("left", "right", "up", "down")
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
		body.take_damage(attack_damage, body.global_position - global_position, 15)
	
func interact():
	is_interacting = true
	
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

