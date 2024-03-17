class_name CustomStateMachine

var states : Array[String]
@export var current_state : String


func set_state_array(state_array : Array[String]):
	states = state_array

func set_state(state : String):
	assert(states.find(state) != -1)
	current_state = state
	
func reset():
	current_state = states[0]
