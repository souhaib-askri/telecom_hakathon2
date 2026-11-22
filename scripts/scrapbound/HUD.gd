extends Control
class_name ScrapboundHUD

signal rematch_requested()

# Textures
const TEX_HEART_FULL = preload("res://assets/sprites/ui/minecraft/heart_full.png")
const TEX_HEART_EMPTY = preload("res://assets/sprites/ui/minecraft/heart_empty.png")
const TEX_ARMOR_FULL = preload("res://assets/sprites/ui/minecraft/armor_full.png")

# Minecraft Top Info
@onready var my_title_label: Label = %MyTitleLabel
@onready var my_score_label: Label = %MyScoreLabel
@onready var my_scrap_label: Label = %MyScrapLabel
@onready var my_mats_label: Label = %MyMatsLabel
@onready var match_title: Label = $TopHUD/CenterBox/MatchTitle

# Progress Bars (Preserved for compatibility)
@onready var my_health_bar: ProgressBar = %MyHealthBar
@onready var my_tower_bar: ProgressBar = %MyTowerBar

# Status Row (Hearts, Armor, XP & Timer)
@onready var health_hearts_container: HBoxContainer = %HealthHeartsContainer
@onready var my_health_val: Label = %MyHealthVal
@onready var tower_armor_container: HBoxContainer = %TowerArmorContainer
@onready var my_tower_val: Label = %MyTowerVal
@onready var xp_progress_bar: TextureProgressBar = %XPProgressBar
@onready var timer_label: Label = %TimerLabel

# Minecraft Hotbar
@onready var hotbar_active_frame: TextureRect = %HotbarActiveFrame
@onready var slot1_weapon: Button = %Slot1_Weapon
@onready var my_weapon_label: Label = %MyWeaponLabel
@onready var slot2_wall: Button = %Slot2_Wall
@onready var lbl_wall: Label = $MinecraftHotbarArea/HotbarHBox/Slot2_Wall/LblWall
@onready var slot3_tower: Button = %Slot3_Tower
@onready var lbl_tower: Label = $MinecraftHotbarArea/HotbarHBox/Slot3_Tower/LblTower
@onready var slot4_refine: Button = %Slot4_Refine
@onready var lbl_refine: Label = $MinecraftHotbarArea/HotbarHBox/Slot4_Refine/LblRefine
@onready var slot5_smg: Button = %Slot5_SMG
@onready var lbl_smg: Label = $MinecraftHotbarArea/HotbarHBox/Slot5_SMG/LblSMG
@onready var slot6_cannon: Button = %Slot6_Cannon
@onready var lbl_cannon: Label = $MinecraftHotbarArea/HotbarHBox/Slot6_Cannon/LblCannon
@onready var slot7_mats: Panel = %Slot7_Mats
@onready var lbl_mats_icon: Label = $MinecraftHotbarArea/HotbarHBox/Slot7_Mats/LblMatsIcon
@onready var btn_open_craft: Button = %BtnOpenCraft

# Minecraft D-Pad
@onready var joystick_base: Panel = %JoystickBase
@onready var joystick_knob: Panel = %JoystickKnob
@onready var btn_dpad_up: Button = %BtnDpadUp
@onready var btn_dpad_left: Button = %BtnDpadLeft
@onready var btn_dpad_center: Button = %BtnDpadCenter
@onready var btn_dpad_right: Button = %BtnDpadRight
@onready var btn_dpad_down: Button = %BtnDpadDown

# Minecraft Action Controls
@onready var btn_shoot: Button = %BtnShoot
@onready var btn_jump: Button = %BtnJump
@onready var btn_build: Button = %BtnBuild
@onready var btn_quick_tower: Button = %BtnQuickTower

# Aux Aliases for Compatibility
@onready var btn_switch_weapon: Button = %BtnSwitchWeapon
@onready var btn_refine: Button = %BtnRefine
@onready var btn_craft_rapid: Button = %BtnCraftRapid
@onready var btn_craft_cannon: Button = %BtnCraftCannon

# Crafting Inventory Panel
@onready var crafting_panel: Panel = %CraftingPanel
@onready var btn_close_craft: Button = %BtnCloseCraft
@onready var craft_mats_label: Label = %CraftMatsLabel
@onready var btn_tab_weapons: Button = %BtnTabWeapons
@onready var btn_tab_towers: Button = %BtnTabTowers
@onready var vbox_weapons: VBoxContainer = %VBoxWeapons
@onready var vbox_towers: VBoxContainer = %VBoxTowers
@onready var btn_inv_craft_smg: Button = %BtnInvCraftSMG
@onready var btn_inv_craft_cannon: Button = %BtnInvCraftCannon
@onready var btn_inv_craft_shotgun: Button = %BtnInvCraftShotgun
@onready var btn_inv_craft_sniper: Button = %BtnInvCraftSniper
@onready var btn_inv_build_tower: Button = %BtnInvBuildTower
@onready var btn_inv_repair_tower: Button = %BtnInvRepairTower
@onready var btn_inv_deploy_wall: Button = %BtnInvDeployWall

# Results Panel
@onready var results_panel: Panel = %ResultsPanel
@onready var winner_label: Label = %WinnerLabel
@onready var results_detail: Label = %ResultsDetail
@onready var btn_rematch: Button = %BtnRematch

var is_dragging_joy: bool = false
var joy_touch_id: int = -1
var joy_radius: float = 48.0
var move_vector: Vector2 = Vector2.ZERO

var dpad_up: bool = false
var dpad_down: bool = false
var dpad_left: bool = false
var dpad_right: bool = false

var local_player_id: int = 1
var current_unlocked_weapons: Array = ["Basic"]
var heart_icons: Array[TextureRect] = []
var armor_icons: Array[TextureRect] = []

func _ready() -> void:
	if results_panel:
		results_panel.visible = false
	if crafting_panel:
		crafting_panel.visible = false
	if btn_rematch:
		btn_rematch.pressed.connect(_on_rematch_pressed)
		
	# Setup Minecraft Hearts (10 pixel hearts)
	_setup_minecraft_hearts()
	# Setup Minecraft Armor (10 pixel shields)
	_setup_minecraft_armor()
	
	# Connect D-Pad Buttons
	_setup_dpad_buttons()
	
	# Connect Action Buttons
	if btn_shoot:
		btn_shoot.button_down.connect(func(): _set_shooting(true))
		btn_shoot.button_up.connect(func(): _set_shooting(false))
		
	if btn_jump:
		btn_jump.pressed.connect(_on_jump_pressed)
		
	if btn_build:
		btn_build.pressed.connect(_on_build_pressed)
		
	if btn_quick_tower:
		btn_quick_tower.pressed.connect(_on_build_tower_pressed)
		
	# Connect Hotbar Slots
	if slot1_weapon:
		slot1_weapon.pressed.connect(_on_switch_weapon_pressed)
	if slot2_wall:
		slot2_wall.pressed.connect(_on_build_pressed)
	if slot3_tower:
		slot3_tower.pressed.connect(_on_build_tower_pressed)
	if slot4_refine:
		slot4_refine.pressed.connect(func(): _on_refine_pressed("random"))
	if slot5_smg:
		slot5_smg.pressed.connect(_on_craft_rapid_pressed)
	if slot6_cannon:
		slot6_cannon.pressed.connect(_on_craft_cannon_pressed)
	if btn_open_craft:
		btn_open_craft.pressed.connect(toggle_crafting_panel)
		
	# Aux backward compatibility connections
	if btn_switch_weapon:
		btn_switch_weapon.pressed.connect(_on_switch_weapon_pressed)
	if btn_refine:
		btn_refine.pressed.connect(func(): _on_refine_pressed("random"))
	if btn_craft_rapid:
		btn_craft_rapid.pressed.connect(_on_craft_rapid_pressed)
	if btn_craft_cannon:
		btn_craft_cannon.pressed.connect(_on_craft_cannon_pressed)
		
	if btn_close_craft:
		btn_close_craft.pressed.connect(func(): if crafting_panel: crafting_panel.visible = false)
		
	if btn_tab_weapons:
		btn_tab_weapons.pressed.connect(func():
			if vbox_weapons: vbox_weapons.visible = true
			if vbox_towers: vbox_towers.visible = false
		)
		
	if btn_tab_towers:
		btn_tab_towers.pressed.connect(func():
			if vbox_towers: vbox_towers.visible = true
			if vbox_weapons: vbox_weapons.visible = false
		)
		
	if btn_inv_craft_smg:
		btn_inv_craft_smg.pressed.connect(func(): _on_craft_weapon_clicked("RapidFire"))
	if btn_inv_craft_cannon:
		btn_inv_craft_cannon.pressed.connect(func(): _on_craft_weapon_clicked("HighDamage"))
	if btn_inv_craft_shotgun:
		btn_inv_craft_shotgun.pressed.connect(func(): _on_craft_weapon_clicked("Shotgun"))
	if btn_inv_craft_sniper:
		btn_inv_craft_sniper.pressed.connect(func(): _on_craft_weapon_clicked("PlasmaSniper"))
	if btn_inv_build_tower:
		btn_inv_build_tower.pressed.connect(_on_build_tower_pressed)
	if btn_inv_repair_tower:
		btn_inv_repair_tower.pressed.connect(_on_repair_tower_pressed)
	if btn_inv_deploy_wall:
		btn_inv_deploy_wall.pressed.connect(_on_build_pressed)

func _setup_minecraft_hearts() -> void:
	if not health_hearts_container: return
	for child in health_hearts_container.get_children():
		child.queue_free()
	heart_icons.clear()
	for i in range(10):
		var tr = TextureRect.new()
		tr.custom_minimum_size = Vector2(11, 11)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		tr.texture = TEX_HEART_FULL
		health_hearts_container.add_child(tr)
		heart_icons.append(tr)

func _setup_minecraft_armor() -> void:
	if not tower_armor_container: return
	for child in tower_armor_container.get_children():
		child.queue_free()
	armor_icons.clear()
	for i in range(10):
		var tr = TextureRect.new()
		tr.custom_minimum_size = Vector2(11, 11)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		tr.texture = TEX_ARMOR_FULL
		tower_armor_container.add_child(tr)
		armor_icons.append(tr)

func _setup_dpad_buttons() -> void:
	if joystick_base:
		joystick_base.gui_input.connect(_on_joystick_gui_input)
		
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
		btn_dpad_center.pressed.connect(_on_jump_pressed)

func _update_dpad_vector() -> void:
	var vec = Vector2.ZERO
	if dpad_up: vec.y -= 1.0
	if dpad_down: vec.y += 1.0
	if dpad_left: vec.x -= 1.0
	if dpad_right: vec.x += 1.0
	if vec != Vector2.ZERO:
		vec = vec.normalized()
	move_vector = vec
	_send_move_to_player(move_vector)

func _on_jump_pressed() -> void:
	# Minecraft jump / action feedback
	var main = get_tree().get_first_node_in_group("Main") as ScrapboundMain
	if not main:
		main = get_parent().get_parent() as ScrapboundMain
	if main:
		var p = main.p1 if local_player_id == 1 else main.p2
		if is_instance_valid(p):
			p.velocity += (p.aim_direction if p.aim_direction != Vector2.ZERO else Vector2.RIGHT) * 80.0
			p.show_floating_text("JUMP!", Color(0.3, 1.0, 0.4))

func set_local_player(p_id: int) -> void:
	local_player_id = p_id
	if p_id == 1:
		my_title_label.text = "PLAYER 1 (BLUE)"
		my_title_label.modulate = Color(0.2, 0.85, 1.0)
	else:
		my_title_label.text = "PLAYER 2 (ORANGE)"
		my_title_label.modulate = Color(1.0, 0.6, 0.2)

func update_timer(time_left: float) -> void:
	var t = max(0.0, time_left)
	if timer_label:
		timer_label.text = "%02d:%02d" % [int(t) / 60, int(t) % 60]
		timer_label.modulate = Color(1.0, 0.25, 0.25) if t <= 10.0 else Color(0.33, 1.0, 0.33)
	if xp_progress_bar:
		xp_progress_bar.value = (t / 120.0) * 100.0

func update_player_ui(
	p1_hp: int, p1_score: int, p1_kills: int, p1_tower: int, p1_wpn: String, p1_inv: Dictionary,
	p2_hp: int, p2_score: int, p2_kills: int, p2_tower: int, p2_wpn: String, p2_inv: Dictionary,
	p1_unl: Array = ["Basic"], p2_unl: Array = ["Basic"]
) -> void:
	var my_hp = p1_hp if local_player_id == 1 else p2_hp
	var my_score = p1_score if local_player_id == 1 else p2_score
	var my_kills = p1_kills if local_player_id == 1 else p2_kills
	var my_tower = p1_tower if local_player_id == 1 else p2_tower
	var my_wpn = p1_wpn if local_player_id == 1 else p2_wpn
	var my_inv = p1_inv if local_player_id == 1 else p2_inv
	var my_unl = p1_unl if local_player_id == 1 else p2_unl
	current_unlocked_weapons = my_unl
	
	# Update Minecraft Top HUD
	if my_score_label:
		my_score_label.text = "SCORE: %d (Kills: %d)" % [my_score, my_kills]
	if my_scrap_label:
		my_scrap_label.text = "GARBAGE: %d  |  BATTERY: %d" % [my_inv.get("scrap", 0), my_inv.get("battery", 0)]
	if my_mats_label:
		my_mats_label.text = "RAW: [Wood:%d Iron:%d Plas:%d]  CRAFT: [A:%d B:%d C:%d D:%d]" % [
			my_inv.get("wood", 0), my_inv.get("iron", 0), my_inv.get("plastic", 0),
			my_inv.get("material_a", 0), my_inv.get("material_b", 0),
			my_inv.get("material_c", 0), my_inv.get("material_d", 0)
		]
		
	# Update Hidden Bars
	if my_health_bar:
		my_health_bar.value = my_hp
	if my_tower_bar:
		my_tower_bar.value = my_tower
		
	# Update Minecraft 10 Hearts
	var full_hearts = clamp(int(ceil(float(my_hp) / 10.0)), 0, 10)
	for i in range(heart_icons.size()):
		var icon = heart_icons[i]
		if i < full_hearts:
			icon.texture = TEX_HEART_FULL
			icon.modulate = Color.WHITE
		else:
			icon.texture = TEX_HEART_EMPTY
			icon.modulate = Color(1.0, 1.0, 1.0, 0.5)
	if my_health_val:
		my_health_val.text = "%d HP" % my_hp
		
	# Update Minecraft 10 Shields/Armor
	var full_shields = clamp(int(ceil(float(my_tower) / 100.0)), 0, 10)
	for i in range(armor_icons.size()):
		var icon = armor_icons[i]
		if i < full_shields:
			icon.modulate = Color.WHITE
		else:
			icon.modulate = Color(1.0, 1.0, 1.0, 0.2)
	if my_tower_val:
		my_tower_val.text = "%d/1000" % my_tower
		
	# Update Minecraft Hotbar Slots
	if my_weapon_label:
		my_weapon_label.text = "🗡️\n" + my_wpn
		
	var can_wall = (my_inv.get("wood", 0) >= 2 or my_inv.get("plastic", 0) >= 2 or my_inv.get("iron", 0) >= 2)
	if lbl_wall:
		lbl_wall.modulate = Color.WHITE if can_wall else Color(0.6, 0.6, 0.6, 0.5)
	if btn_build:
		btn_build.disabled = !can_wall
		btn_build.modulate = Color.WHITE if can_wall else Color(0.65, 0.65, 0.65, 0.5)
		
	var can_tower = (my_inv.get("iron", 0) >= 2 and my_inv.get("plastic", 0) >= 1)
	if lbl_tower:
		lbl_tower.modulate = Color.WHITE if can_tower else Color(0.6, 0.6, 0.6, 0.5)
	if btn_quick_tower:
		btn_quick_tower.disabled = !can_tower
		btn_quick_tower.modulate = Color.WHITE if can_tower else Color(0.65, 0.65, 0.65, 0.5)
		
	var scrap_held = my_inv.get("scrap", 0)
	var main_node = get_tree().get_first_node_in_group("Main") as ScrapboundMain
	if not main_node:
		main_node = get_parent().get_parent() as ScrapboundMain
	var is_near_refinery = false
	if main_node:
		var p_local = main_node.p1 if local_player_id == 1 else main_node.p2
		var r_local = main_node.recycler1 if local_player_id == 1 else main_node.recycler2
		if is_instance_valid(p_local) and is_instance_valid(r_local):
			is_near_refinery = (p_local.global_position.distance_to(r_local.global_position) <= 130.0)

	if lbl_refine:
		if scrap_held < 10:
			lbl_refine.text = "♻\n%d/10" % scrap_held
			lbl_refine.modulate = Color(0.6, 0.6, 0.6, 0.5)
		elif not is_near_refinery:
			lbl_refine.text = "🏃\nNEAR (%d)" % scrap_held
			lbl_refine.modulate = Color(1.0, 0.85, 0.3)
		else:
			lbl_refine.text = "♻\nRECYCLE (%d)" % scrap_held
			lbl_refine.modulate = Color(0.25, 1.0, 0.4)
			
	var can_rapid = (my_inv.get("iron", 0) >= 1 and my_inv.get("plastic", 0) >= 1) or (my_inv.get("material_a", 0) >= 1 and my_inv.get("material_b", 0) >= 1)
	if lbl_smg:
		lbl_smg.modulate = Color.WHITE if can_rapid else Color(0.6, 0.6, 0.6, 0.5)
		
	var can_cannon = (my_inv.get("iron", 0) >= 2 and my_inv.get("wood", 0) >= 1) or (my_inv.get("material_a", 0) >= 1 and my_inv.get("material_c", 0) >= 1)
	if lbl_cannon:
		lbl_cannon.modulate = Color.WHITE if can_cannon else Color(0.6, 0.6, 0.6, 0.5)
		
	if lbl_mats_icon:
		lbl_mats_icon.text = "🌲%d ⚙%d\n🧪%d" % [my_inv.get("wood", 0), my_inv.get("iron", 0), my_inv.get("plastic", 0)]

	# Update Crafting Inventory Panel elements
	if craft_mats_label:
		craft_mats_label.text = "YOUR RAW MATERIALS: 🌲 Wood: %d  |  ⚙ Iron: %d  |  🧪 Plastic: %d" % [
			my_inv.get("wood", 0), my_inv.get("iron", 0), my_inv.get("plastic", 0)
		]
	if btn_inv_craft_smg:
		_update_weapon_card_btn(btn_inv_craft_smg, "RapidFire", my_wpn, my_unl, can_rapid)
	if btn_inv_craft_cannon:
		_update_weapon_card_btn(btn_inv_craft_cannon, "HighDamage", my_wpn, my_unl, can_cannon)
	if btn_inv_craft_shotgun:
		var can_shotgun = (my_inv.get("wood", 0) >= 1 and my_inv.get("iron", 0) >= 1 and my_inv.get("plastic", 0) >= 1)
		_update_weapon_card_btn(btn_inv_craft_shotgun, "Shotgun", my_wpn, my_unl, can_shotgun)
	if btn_inv_craft_sniper:
		var can_sniper = (my_inv.get("plastic", 0) >= 2 and my_inv.get("iron", 0) >= 1)
		_update_weapon_card_btn(btn_inv_craft_sniper, "PlasmaSniper", my_wpn, my_unl, can_sniper)
	if btn_inv_build_tower:
		btn_inv_build_tower.disabled = !can_tower
		btn_inv_build_tower.modulate = Color(1.0, 1.0, 1.0, 1.0) if can_tower else Color(0.65, 0.65, 0.65, 0.45)
	if btn_inv_repair_tower:
		var can_repair = (my_inv.get("wood", 0) >= 2 and my_inv.get("iron", 0) >= 1 and my_tower < 1000)
		btn_inv_repair_tower.disabled = !can_repair
		btn_inv_repair_tower.modulate = Color(1.0, 1.0, 1.0, 1.0) if can_repair else Color(0.65, 0.65, 0.65, 0.45)
		if my_tower >= 1000:
			btn_inv_repair_tower.text = "FULL HP"
		else:
			btn_inv_repair_tower.text = "REPAIR (+250)"
	if btn_inv_deploy_wall:
		btn_inv_deploy_wall.disabled = !can_wall
		btn_inv_deploy_wall.modulate = Color(1.0, 1.0, 1.0, 1.0) if can_wall else Color(0.65, 0.65, 0.65, 0.45)

func _on_joystick_gui_input(event: InputEvent) -> void:
	if not joystick_base: return
	var center = joystick_base.size * 0.5
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging_joy = true
			_update_joystick(event.position, center)
		else:
			_reset_joystick()
	elif event is InputEventMouseMotion and is_dragging_joy:
		_update_joystick(event.position, center)
	elif event is InputEventScreenTouch:
		if event.pressed and joy_touch_id == -1:
			joy_touch_id = event.index
			is_dragging_joy = true
			_update_joystick(event.position, center)
		elif not event.pressed and event.index == joy_touch_id:
			_reset_joystick()
	elif event is InputEventScreenDrag and event.index == joy_touch_id:
		_update_joystick(event.position, center)

func _input(event: InputEvent) -> void:
	if not is_dragging_joy or not joystick_base:
		return
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_reset_joystick()
	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
		var local_pos = joystick_base.get_global_transform().affine_inverse() * event.position
		_update_joystick(local_pos, joystick_base.size * 0.5)
	elif event is InputEventScreenTouch and not event.pressed and event.index == joy_touch_id:
		_reset_joystick()
	elif event is InputEventScreenDrag and event.index == joy_touch_id:
		var local_pos = joystick_base.get_global_transform().affine_inverse() * event.position
		_update_joystick(local_pos, joystick_base.size * 0.5)

func _update_joystick(pos: Vector2, center: Vector2) -> void:
	var diff = pos - center
	var dist = diff.length()
	if dist > joy_radius:
		diff = diff.normalized() * joy_radius
	if joystick_knob:
		joystick_knob.position = center + diff - (joystick_knob.size * 0.5)
	move_vector = diff / joy_radius
	_send_move_to_player(move_vector)

func _reset_joystick() -> void:
	is_dragging_joy = false
	joy_touch_id = -1
	move_vector = Vector2.ZERO
	if joystick_base and joystick_knob:
		var center = joystick_base.size * 0.5
		joystick_knob.position = center - (joystick_knob.size * 0.5)
	_send_move_to_player(Vector2.ZERO)

func _send_move_to_player(vec: Vector2) -> void:
	var main = get_tree().get_first_node_in_group("Main") as ScrapboundMain
	if not main:
		main = get_parent().get_parent() as ScrapboundMain
	if main:
		var p = main.p1 if local_player_id == 1 else main.p2
		if is_instance_valid(p):
			p.mobile_move_vector = vec

func _set_shooting(shooting: bool) -> void:
	var main = get_tree().get_first_node_in_group("Main") as ScrapboundMain
	if not main:
		main = get_parent().get_parent() as ScrapboundMain
	if main:
		var p = main.p1 if local_player_id == 1 else main.p2
		if is_instance_valid(p):
			p.is_mobile_shooting = shooting

func _on_craft_rapid_pressed() -> void:
	var main = get_tree().get_first_node_in_group("Main") as ScrapboundMain
	if not main:
		main = get_parent().get_parent() as ScrapboundMain
	if main:
		main.request_craft_recipe.rpc_id(1, local_player_id, "RapidFire")

func _on_craft_cannon_pressed() -> void:
	var main = get_tree().get_first_node_in_group("Main") as ScrapboundMain
	if not main:
		main = get_parent().get_parent() as ScrapboundMain
	if main:
		main.request_craft_recipe.rpc_id(1, local_player_id, "HighDamage")

func toggle_crafting_panel() -> void:
	if crafting_panel:
		crafting_panel.visible = not crafting_panel.visible

func _on_refine_pressed(mat: String = "random") -> void:
	var main = get_tree().get_first_node_in_group("Main") as ScrapboundMain
	if not main:
		main = get_parent().get_parent() as ScrapboundMain
	if main:
		var p = main.p1 if local_player_id == 1 else main.p2
		var r = main.recycler1 if local_player_id == 1 else main.recycler2
		if is_instance_valid(p) and is_instance_valid(r):
			if p.global_position.distance_to(r.global_position) > 130.0:
				p.show_floating_text("🏃 BRING SCRAP TO REFINERY!", Color(1.0, 0.85, 0.2))
				return
		main.request_refine.rpc_id(1, local_player_id, mat)

func _on_switch_weapon_pressed() -> void:
	var main = get_tree().get_first_node_in_group("Main") as ScrapboundMain
	if not main:
		main = get_parent().get_parent() as ScrapboundMain
	if main:
		main.request_switch_weapon.rpc_id(1, local_player_id)

func _on_craft_weapon_clicked(weapon_name: String) -> void:
	var main = get_tree().get_first_node_in_group("Main") as ScrapboundMain
	if not main:
		main = get_parent().get_parent() as ScrapboundMain
	if not main: return
	if weapon_name in current_unlocked_weapons:
		main.request_equip_weapon.rpc_id(1, local_player_id, weapon_name)
	else:
		main.request_craft_recipe.rpc_id(1, local_player_id, weapon_name)

func _update_weapon_card_btn(btn: Button, wpn_id: String, active_wpn: String, unl: Array, affordable: bool) -> void:
	if not btn: return
	if active_wpn == wpn_id:
		btn.text = "EQUIPPED"
		btn.disabled = true
		btn.modulate = Color(0.3, 1.0, 0.4)
	elif wpn_id in unl:
		btn.text = "EQUIP"
		btn.disabled = false
		btn.modulate = Color(0.3, 0.85, 1.0)
	else:
		btn.text = "CRAFT"
		btn.disabled = !affordable
		btn.modulate = Color(1.0, 1.0, 1.0) if affordable else Color(0.6, 0.6, 0.6, 0.5)

func _on_recycle_pressed() -> void:
	_on_refine_pressed("random")

func _on_build_pressed() -> void:
	var main = get_tree().get_first_node_in_group("Main") as ScrapboundMain
	if not main:
		main = get_parent().get_parent() as ScrapboundMain
	if main:
		var p = main.p1 if local_player_id == 1 else main.p2
		if is_instance_valid(p):
			var pos = p.global_position + p.aim_direction * 36.0
			main.request_build_barrier.rpc_id(1, local_player_id, pos)

func _on_build_tower_pressed() -> void:
	var main = get_tree().get_first_node_in_group("Main") as ScrapboundMain
	if not main:
		main = get_parent().get_parent() as ScrapboundMain
	if main:
		var p = main.p1 if local_player_id == 1 else main.p2
		if is_instance_valid(p):
			var pos = p.global_position + p.aim_direction * 36.0
			main.request_build_tower.rpc_id(1, local_player_id, pos)

func _on_repair_tower_pressed() -> void:
	var main = get_tree().get_first_node_in_group("Main") as ScrapboundMain
	if not main:
		main = get_parent().get_parent() as ScrapboundMain
	if main:
		main.request_repair_tower.rpc_id(1, local_player_id)

func show_results(p1_kills: int, p1_score: int, p1_tower_hp: int, p2_kills: int, p2_score: int, p2_tower_hp: int) -> void:
	if not results_panel:
		return
		
	var p1_total = p1_score + p1_tower_hp * 2
	var p2_total = p2_score + p2_tower_hp * 2
	
	results_panel.visible = true
	
	var is_p1 = (local_player_id == 1)
	var my_win = false
	var opp_win = false
	
	if p1_tower_hp <= 0 and p2_tower_hp > 0:
		if is_p1: opp_win = true
		else: my_win = true
	elif p2_tower_hp <= 0 and p1_tower_hp > 0:
		if is_p1: my_win = true
		else: opp_win = true
	elif p1_total > p2_total:
		if is_p1: my_win = true
		else: opp_win = true
	elif p2_total > p1_total:
		if is_p1: opp_win = true
		else: my_win = true
		
	if my_win:
		winner_label.text = "VICTORY! YOU WIN! 🏆"
		winner_label.modulate = Color(0.2, 0.9, 0.4)
	elif opp_win:
		winner_label.text = "DEFEAT! OPPONENT WON! 💀"
		winner_label.modulate = Color(1.0, 0.3, 0.3)
	else:
		winner_label.text = "DRAW MATCH! 🤝"
		winner_label.modulate = Color(1.0, 1.0, 1.0)
		
	if results_detail:
		results_detail.text = (
			"=== FINAL MATCH REPORT ===\n\n" +
			"PLAYER 1 (Blue):\n" +
			"  Kills: %d (%d pts) | Tower HP: %d (+%d bonus) | TOTAL: %d\n\n" % [p1_kills, p1_score, p1_tower_hp, p1_tower_hp * 2, p1_total] +
			"PLAYER 2 (Orange):\n" +
			"  Kills: %d (%d pts) | Tower HP: %d (+%d bonus) | TOTAL: %d" % [p2_kills, p2_score, p2_tower_hp, p2_tower_hp * 2, p2_total]
		)

func _on_rematch_pressed() -> void:
	rematch_requested.emit()
