extends FiniteStateMachine

func _init():
	_add_state("Idle")
	_add_state("Walk")
	_add_state("Attack")
	_add_state("Damaged")
	_add_state("Dead")

func _ready():
	set_state(states.Idle)
	
func _state_logic(_delta):
	if state != states.Dead:
		#print(state)
		pass

func _get_transition():
	match state:

		states.Idle:
			if parent.is_attacking:
				return states.Attack
				
			elif parent.player_detected:
				#get_parent().get_node("SoundFX/Walk").playing = true
				return states.Walk
				
		states.Walk:
			if parent.is_attacking:
				return states.Attack
			
			elif !parent.player_detected:
				#get_parent().get_node("SoundFX/Walk").playing = false
				return states.Idle
		
		states.Attack:
			if not animation_player.is_playing():
				parent.start_attack_timer()
				return states.Idle

		states.Damaged:
			#get_parent().get_node("SoundFX/Walk").playing = false
			#get_parent().get_node("SoundFX/Damaged").play()
			if parent.is_attacking:
				return states.Attack
				
			elif not animation_player.is_playing():
				return states.Idle

		states.Dead:
			#get_parent().get_node("SoundFX/Walk").playing = false
			if !parent.is_dead:
				parent.is_dead = true
				parent.die()
			if not animation_player.is_playing():
				return states.Idle
			
	return -1

func _enter_state(_previous_state, new_state):
	match new_state:
		states.Idle:
			animation_player.play("Idle")
		states.Walk:
			animation_player.play("Walk")
		states.Attack:
			animation_player.play("Attack")
		states.Damaged:
			animation_player.play("Damaged")
		states.Dead:
			animation_player.play("Dead")
			
