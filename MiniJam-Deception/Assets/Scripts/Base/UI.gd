extends CanvasLayer

@onready var player: Player = get_parent().get_node("Player")


@onready var hp_bar = $HpBar/TextureProgressBar
var hp_tween : Tween
var max_hp = 0.0

@onready var counter = $Counter/CounterText
var counter_tween : Tween
var gold = 0.0


func _ready():
	max_hp = player.hp
	hp_bar.max_value = max_hp
	_update_health(max_hp)
	
func _update_health(target):

	if hp_tween: hp_tween.kill()
	
	hp_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	hp_tween.tween_property(hp_bar, "value", target, 0.4)
	
func _update_gold(target):

	if counter_tween: counter_tween.kill()
	
	counter_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	counter_tween.tween_property(counter, "text", target, 0.1)
	

func _on_player_hp_changed(new_hp):
	max_hp = player.hp
	if new_hp >= max_hp:
		new_hp = max_hp
	_update_health(new_hp)


func _on_player_gold_changed(new_gold):
	counter.text = "x"+str(new_gold)
