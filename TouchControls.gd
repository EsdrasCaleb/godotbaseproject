extends Control

@export var joystick_radius: float = 100.0

@export var joystick_bg:Node2D
@export var joystick_handle:Node2D
@export var actions = {"up":"up","down":"down","right":"right","left":"left"}
@export var use_precision = false

var drag_position = Vector2.ZERO
var is_dragging = false
var initial_position:Vector2
var center:Vector2
func _ready():
	initial_position = joystick_handle.position
	center = global_position+(joystick_bg.position+joystick_handle.position)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			var local_pos = event.position
			if local_pos.distance_to(center) <= joystick_radius:
				is_dragging = true
				var direction = (local_pos - center).normalized()
				var distance = min(local_pos.distance_to(center), joystick_radius)
				drag_position = direction * distance
				joystick_handle.position = drag_position +initial_position
		else:
			is_dragging = false
			joystick_handle.position = initial_position
			drag_position = Vector2.ZERO
		_emit_joypad_motion_events(drag_position)
	elif event is InputEventScreenDrag and is_dragging:
		var local_pos = event.position 
		var direction = (local_pos - center).normalized()
		var distance = min(local_pos.distance_to(center), joystick_radius)
		drag_position = direction * distance
		joystick_handle.position = drag_position+initial_position
		_emit_joypad_motion_events(drag_position)



func _emit_joypad_motion_events(joypos):
		print(joypos)
		var normalized_pos = (joypos / joystick_radius).limit_length(1.0)
		var power = Vector2(1,1)
		if(use_precision):
			power = normalized_pos
		if(normalized_pos.x>0):
			create_input_action(actions.left)
			create_input_action(actions.right,power.x)
		elif(normalized_pos.x<0):
			create_input_action(actions.right)
			create_input_action(actions.left,power.x)
		else:
			create_input_action(actions.left)
			create_input_action(actions.right)
		if(normalized_pos.y>0):
			create_input_action(actions.up)
			create_input_action(actions.down,power.y)
		elif(normalized_pos.y<0):
			create_input_action(actions.dwo)
			create_input_action(actions.left,power.y)
		else:
			create_input_action(actions.left)
			create_input_action(actions.right)

func create_input_action(action,press=0,power=1):
	var action_event = InputEventAction.new()
	action_event.action = action
	action_event.pressed = press
	action_event.strength = power
	Input.parse_input_event(action_event)

func get_joystick_direction():
	if is_dragging:
		return (drag_position / joystick_radius).limit_length(1.0)
	return Vector2.ZERO


