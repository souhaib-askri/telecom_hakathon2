extends Control
class_name MobileControls

@onready var joystick_base: Control = $Joystick/Base
@onready var joystick_knob: Control = $Joystick/Base/Knob

@onready var btn_shoot: Button = $ActionButtons/BtnShoot
@onready var btn_purify: Button = $ActionButtons/BtnPurify
@onready var btn_trade: Button = $ActionButtons/BtnTrade
@onready var btn_craft: Button = $ActionButtons/BtnCraft
@onready var btn_night: Button = $ActionButtons/BtnNight

@onready var btn_dpad_up: Button = %BtnDpadUp
@onready var btn_dpad_down: Button = %BtnDpadDown
@onready var btn_dpad_left: Button = %BtnDpadLeft
@onready var btn_dpad_right: Button = %BtnDpadRight
@onready var btn_dpad_center: Button = %BtnDpadCenter

var is_dragging_joystick: bool = false
var joystick_touch_id: int = -1
var joystick_radius: float = 48.0
var move_vector: Vector2 = Vector2.ZERO

var dpad_up: bool = false
var dpad_down: bool = false
var dpad_left: bool = false
var dpad_right: bool = false

var player_node: SamiPlayer = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Connect Action buttons
	if btn_shoot:
		btn_shoot.button_down.connect(_on_shoot_down)
		btn_shoot.button_up.connect(_on_shoot_up)
		
	if btn_purify:
		btn_purify.button_down.connect(_on_purify_down)
		btn_purify.button_up.connect(_on_purify_up)
		
	if btn_trade:
		btn_trade.pressed.connect(_on_trade_pressed)
		
	if btn_craft:
		btn_craft.pressed.connect(_on_craft_pressed)
		
	if btn_night:
		btn_night.pressed.connect(_on_night_pressed)
		
	# Connect Minecraft D-Pad buttons
	if btn_dpad_up:
		btn_dpad_up.button_down.connect(func(): dpad_up = true; _update_dpad_vector())
		btn_dpad_up.button_up.connect(func(): dpad_up = false; _update_dpad_vector())
	if btn_dpad_down:
		btn_dpad_down.button_down.connect(func(): dpad_down = true; _update_dpad_vector())
		btn_dpad_down.button_up.connect(func(): dpad_down = false; _update_dpad_vector())
	if btn_dpad_left:
		btn_dpad_left.button_down.connect(func(): dpad_left = true; _update_dpad_vector())
		btn_dpad_left.button_up.connect(func(): dpad_left = false; _update_dpad_vector())
	if btn_dpad_right:
		btn_dpad_right.button_down.connect(func(): dpad_right = true; _update_dpad_vector())
		btn_dpad_right.button_up.connect(func(): dpad_right = false; _update_dpad_vector())
	if btn_dpad_center:
		btn_dpad_center.pressed.connect(func():
			if player_node and is_instance_valid(player_node):
				player_node.velocity += (player_node.aim_direction if player_node.aim_direction != Vector2.ZERO else Vector2.RIGHT) * 60.0
		)
		
	_find_player()

func _update_dpad_vector() -> void:
	var vec = Vector2.ZERO
	if dpad_up: vec.y -= 1.0
	if dpad_down: vec.y += 1.0
	if dpad_left: vec.x -= 1.0
	if dpad_right: vec.x += 1.0
	if vec != Vector2.ZERO:
		vec = vec.normalized()
	move_vector = vec
	if player_node:
		player_node.mobile_move_vector = move_vector

func _find_player() -> void:
	if not player_node or not is_instance_valid(player_node):
		player_node = get_tree().get_first_node_in_group("Player") as SamiPlayer

func _process(_delta: float) -> void:
	_find_player()
	if player_node:
		player_node.mobile_move_vector = move_vector
		
		# Contextual button glow
		if btn_purify:
			var near_scrap = (player_node.current_scrap_pile != null and is_instance_valid(player_node.current_scrap_pile))
			btn_purify.modulate = Color(1.2, 1.2, 1.5) if near_scrap else Color(1.0, 1.0, 1.0, 0.75)

func _gui_input(event: InputEvent) -> void:
	_handle_touch(event)

func _unhandled_input(event: InputEvent) -> void:
	_handle_touch(event)

func _handle_touch(event: InputEvent) -> void:
	if not joystick_base:
		return
		
	var base_center = joystick_base.global_position + joystick_base.size * 0.5
	
	if event is InputEventScreenTouch:
		if event.pressed:
			var d = event.position.distance_to(base_center)
			if d <= joystick_radius * 1.8 and joystick_touch_id == -1:
				joystick_touch_id = event.index
				is_dragging_joystick = true
				_update_knob(event.position, base_center)
		else:
			if event.index == joystick_touch_id:
				_reset_joystick()
				
	elif event is InputEventScreenDrag:
		if event.index == joystick_touch_id:
			_update_knob(event.position, base_center)
			
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var d = event.position.distance_to(base_center)
				if d <= joystick_radius * 1.8 and not is_dragging_joystick:
					is_dragging_joystick = true
					_update_knob(event.position, base_center)
			else:
				if is_dragging_joystick:
					_reset_joystick()
					
	elif event is InputEventMouseMotion:
		if is_dragging_joystick and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			_update_knob(event.position, base_center)

func _update_knob(touch_pos: Vector2, center: Vector2) -> void:
	var diff = touch_pos - center
	var dist = diff.length()
	var dir = diff.normalized() if dist > 0 else Vector2.ZERO
	
	var clamped_dist = min(dist, joystick_radius)
	var knob_offset = dir * clamped_dist
	
	if joystick_knob:
		joystick_knob.position = (joystick_base.size * 0.5) - (joystick_knob.size * 0.5) + knob_offset
		
	# Normalized movement vector
	move_vector = dir * (clamped_dist / joystick_radius)
	if move_vector.length() < 0.15:
		move_vector = Vector2.ZERO

func _reset_joystick() -> void:
	is_dragging_joystick = false
	joystick_touch_id = -1
	move_vector = Vector2.ZERO
	if joystick_knob and joystick_base:
		joystick_knob.position = (joystick_base.size * 0.5) - (joystick_knob.size * 0.5)
	if player_node:
		player_node.mobile_move_vector = Vector2.ZERO

# Button Handlers
func _on_shoot_down() -> void:
	Input.action_press("shoot")

func _on_shoot_up() -> void:
	Input.action_release("shoot")

func _on_purify_down() -> void:
	Input.action_press("interact_purify")

func _on_purify_up() -> void:
	Input.action_release("interact_purify")

func _on_trade_pressed() -> void:
	var ev = InputEventAction.new()
	ev.action = "repair_build"
	ev.pressed = true
	Input.parse_input_event(ev)

func _on_craft_pressed() -> void:
	var ev = InputEventAction.new()
	ev.action = "open_crafting"
	ev.pressed = true
	Input.parse_input_event(ev)

func _on_night_pressed() -> void:
	if GameManager.is_night_phase():
		GameManager.start_day_phase()
	else:
		GameManager.start_night_phase()
