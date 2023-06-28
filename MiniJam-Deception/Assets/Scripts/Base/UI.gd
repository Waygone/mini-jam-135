extends CanvasLayer

@onready var player: Player = get_parent().get_node("Player")


@onready var hp_bar = $HpBar/TextureProgressBar
var hp_tween : Tween
var max_hp = 0.0

@onready var attack_bar = $AttackBar/TextureProgressBar
var attack_tween : Tween
var max_attack_rate = 0.0

@onready var counter = $Counter/CounterText

@onready var timer = $Control/Timer

func _ready():
	max_hp = player.hp
	hp_bar.max_value = max_hp
	
	_update_health(max_hp)
	
	max_attack_rate = player.attack_rate
	attack_bar.max_value = max_attack_rate
	_update_attack_rate(max_attack_rate)
	
func _update_health(target):

	if hp_tween: hp_tween.kill()
	
	hp_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	hp_tween.tween_property(hp_bar, "value", target, 0.4)


func _update_attack_rate(target):

	if attack_tween: attack_tween.kill()
	
	attack_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	attack_tween.tween_property(attack_bar, "value", target, 0.01)
		

func _on_player_hp_changed(new_hp):
	max_hp = player.hp
	if new_hp >= max_hp:
		new_hp = max_hp
	_update_health(new_hp)

func _on_player_level_timer_changed(new_time):
	timer.text = str(new_time)


func _on_player_gold_changed(new_gold):
	if counter:
		counter.text = "x"+str(new_gold)


func _on_player_attack_time_left(attack_time):
	_update_attack_rate(attack_time)
