extends Control

# Core multiplayer node references
@onready var ip_edit: LineEdit = %IPEdit
@onready var port_edit: LineEdit = %PortEdit
@onready var btn_host: Button = %BtnHost
@onready var btn_join: Button = %BtnJoin
@onready var btn_start: Button = %BtnStart
@onready var btn_disconnect: Button = %BtnDisconnect
@onready var status_label: Label = %StatusLabel
@onready var player_list_label: Label = %PlayerListLabel

# Start menu navigation references
@onready var main_nav_container: Control = %MainNavContainer
@onready var multiplayer_panel: Control = %MultiplayerPanel
@onready var briefing_modal: Control = %BriefingModal
@onready var settings_modal: Control = %SettingsModal

@onready var btn_solo: Button = %BtnSolo
@onready var btn_multiplayer: Button = %BtnMultiplayer
@onready var btn_briefing: Button = %BtnBriefing
@onready var btn_settings: Button = %BtnSettings
@onready var btn_quit: Button = %BtnQuit

@onready var btn_back_multiplayer: Button = %BtnBackMultiplayer
@onready var btn_close_briefing: Button = %BtnCloseBriefing
@onready var btn_close_settings: Button = %BtnCloseSettings
@onready var btn_copy_ip: Button = %BtnCopyIP

# LAN Discovery elements
@onready var lan_banner: Control = %LanBanner
@onready var lan_host_label: Label = %LanHostLabel
@onready var btn_lan_quick_join: Button = %BtnLanQuickJoin

# Visual & Animation references
@onready var parallax_bg: TextureRect = %ParallaxBg
@onready var hero_keyart: TextureRect = %HeroKeyart
@onready var crt_overlay: ColorRect = %CrtOverlay
@onready var status_dot: ColorRect = %StatusDot

# Settings controls
@onready var slider_master: HSlider = %SliderMaster
@onready var slider_music: HSlider = %SliderMusic
@onready var slider_sfx: HSlider = %SliderSfx
@onready var lbl_master_val: Label = %LblMasterVal
@onready var lbl_music_val: Label = %LblMusicVal
@onready var lbl_sfx_val: Label = %LblSfxVal
@onready var check_fullscreen: CheckBox = %CheckFullscreen
@onready var check_crt: CheckBox = %CheckCrt

# Audio players
@onready var bgm_player: AudioStreamPlayer = %BGMPlayer
@onready var sfx_hover: AudioStreamPlayer = %SfxHover
@onready var sfx_click: AudioStreamPlayer = %SfxClick
@onready var sfx_launch: AudioStreamPlayer = %SfxLaunch

var local_lan_ip: String = "127.0.0.1"
var discovered_lan_ip: String = ""
var discovered_lan_port: int = 7777

var parallax_dir: float = 1.0
var parallax_offset_x: float = -100.0
var hero_base_pos_y: float = 10.0
var net_node: Node = null

func _get_net() -> Node:
	if net_node == null and has_node("/root/NetworkManager"):
		net_node = get_node("/root/NetworkManager")
	return net_node

func _ready() -> void:
	var net = _get_net()
	if net:
		net.player_connected.connect(_on_network_player_connected)
		net.player_disconnected.connect(_on_network_player_disconnected)
		net.connection_succeeded.connect(_on_connection_succeeded)
		net.connection_failed.connect(_on_connection_failed)
		net.server_disconnected.connect(_on_server_disconnected)
		net.host_discovered.connect(_on_host_discovered)
		local_lan_ip = net.get_lan_ip()
	
	# Multiplayer panel buttons
	btn_host.pressed.connect(_on_host_pressed)
	btn_join.pressed.connect(_on_join_pressed)
	btn_start.pressed.connect(_on_start_pressed)
	btn_disconnect.pressed.connect(_on_disconnect_pressed)
	btn_back_multiplayer.pressed.connect(_on_back_multiplayer_pressed)
	btn_copy_ip.pressed.connect(_on_copy_ip_pressed)
	btn_lan_quick_join.pressed.connect(_on_lan_quick_join_pressed)
	
	# Main navigation buttons
	btn_solo.pressed.connect(_on_solo_pressed)
	btn_multiplayer.pressed.connect(_on_nav_multiplayer_pressed)
	btn_briefing.pressed.connect(_on_nav_briefing_pressed)
	btn_settings.pressed.connect(_on_nav_settings_pressed)
	btn_quit.pressed.connect(_on_nav_quit_pressed)
	
	# Modals close buttons
	btn_close_briefing.pressed.connect(_on_close_briefing_pressed)
	btn_close_settings.pressed.connect(_on_close_settings_pressed)
	
	# Settings signals
	slider_master.value_changed.connect(_on_master_slider_changed)
	slider_music.value_changed.connect(_on_music_slider_changed)
	slider_sfx.value_changed.connect(_on_sfx_slider_changed)
	check_fullscreen.toggled.connect(_on_fullscreen_toggled)
	check_crt.toggled.connect(_on_crt_toggled)
	
	# Setup audio feedback on all buttons
	_hook_button_sfx(self)
	
	# Init positions
	if hero_keyart:
		hero_base_pos_y = hero_keyart.position.y
		
	_reset_ui()
	
	# Start ambient menu music if not playing
	if bgm_player and not bgm_player.playing:
		bgm_player.play()
		
	# Check batch/cmdline parameters (--host, --join)
	var all_args = OS.get_cmdline_args() + OS.get_cmdline_user_args()
	for a in all_args:
		if a == "--host" or a == "host":
			DisplayServer.window_set_title("SCRAPBOUND - PLAYER 1 [HOST]")
			DisplayServer.window_set_size(Vector2i(640, 520))
			DisplayServer.window_set_position(Vector2i(20, 60))
			_show_multiplayer_view()
			get_tree().create_timer(0.4).timeout.connect(_on_host_pressed)
			break
		elif a == "--join" or a == "join":
			DisplayServer.window_set_title("SCRAPBOUND - PLAYER 2 [CLIENT]")
			DisplayServer.window_set_size(Vector2i(640, 520))
			DisplayServer.window_set_position(Vector2i(675, 60))
			_show_multiplayer_view()
			get_tree().create_timer(0.9).timeout.connect(_on_join_pressed)
			break

func _process(delta: float) -> void:
	# Atmospheric parallax panoramic drift
	if parallax_bg:
		parallax_offset_x += parallax_dir * delta * 12.0
		if parallax_offset_x < -360.0:
			parallax_offset_x = -360.0
			parallax_dir = 1.0
		elif parallax_offset_x > -20.0:
			parallax_offset_x = -20.0
			parallax_dir = -1.0
		parallax_bg.position.x = parallax_offset_x
		
	# Subtle hero breathing/floating
	if hero_keyart:
		var time_now = Time.get_ticks_msec() / 1000.0
		hero_keyart.position.y = hero_base_pos_y + sin(time_now * 1.8) * 3.5
		
	# Pulsing green status dot
	if status_dot:
		var dot_time = Time.get_ticks_msec() / 1000.0
		status_dot.modulate.a = 0.45 + 0.55 * (0.5 + 0.5 * sin(dot_time * 4.0))

func _hook_button_sfx(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			child.mouse_entered.connect(_on_btn_mouse_entered)
			child.pressed.connect(_on_btn_pressed_sfx)
		_hook_button_sfx(child)

func _on_btn_mouse_entered() -> void:
	if sfx_hover:
		sfx_hover.pitch_scale = randf_range(0.96, 1.04)
		sfx_hover.play()

func _on_btn_pressed_sfx() -> void:
	if sfx_click:
		sfx_click.pitch_scale = randf_range(0.98, 1.02)
		sfx_click.play()

# -------------------------------------------------------------
# Main Navigation Handlers
# -------------------------------------------------------------
func _on_solo_pressed() -> void:
	if sfx_launch:
		sfx_launch.play()
	status_label.text = "⚡ Launching Solo Survival Sector..."
	status_label.modulate = Color(0.2, 0.95, 0.45)
	
	var net = _get_net()
	if net:
		var err = net.host_game(7777)
		if err == OK:
			get_tree().create_timer(0.3).timeout.connect(func():
				net.start_match()
			)
		else:
			net.host_game(7779)
			get_tree().create_timer(0.3).timeout.connect(func():
				net.start_match()
			)
	else:
		get_tree().change_scene_to_file("res://scenes/scrapbound/ScrapboundMain.tscn")

func _on_nav_multiplayer_pressed() -> void:
	_show_multiplayer_view()

func _show_multiplayer_view() -> void:
	main_nav_container.visible = false
	multiplayer_panel.visible = true
	briefing_modal.visible = false
	settings_modal.visible = false

func _on_back_multiplayer_pressed() -> void:
	var net = _get_net()
	if net and net.peer != null:
		net.disconnect_game()
	_reset_ui()
	multiplayer_panel.visible = false
	main_nav_container.visible = true

func _on_nav_briefing_pressed() -> void:
	briefing_modal.visible = true
	settings_modal.visible = false

func _on_close_briefing_pressed() -> void:
	briefing_modal.visible = false

func _on_nav_settings_pressed() -> void:
	settings_modal.visible = true
	briefing_modal.visible = false
	_refresh_settings_ui()

func _on_close_settings_pressed() -> void:
	settings_modal.visible = false

func _on_nav_quit_pressed() -> void:
	get_tree().quit()

# -------------------------------------------------------------
# Multiplayer / Network Logic
# -------------------------------------------------------------
func _reset_ui() -> void:
	btn_host.disabled = false
	btn_join.disabled = false
	btn_start.visible = false
	btn_start.disabled = true
	btn_disconnect.visible = false
	ip_edit.editable = true
	port_edit.editable = true
	
	var net = _get_net()
	if net:
		local_lan_ip = net.get_lan_ip()
		net.start_lan_listener()
		
	status_label.text = "Your LAN IP: %s\nSelect HOST (P1) or JOIN (P2) to begin." % local_lan_ip
	status_label.modulate = Color(0.85, 0.9, 1.0)
	player_list_label.text = "Connected Players: 0 / 2"

func _on_copy_ip_pressed() -> void:
	DisplayServer.clipboard_set(local_lan_ip)
	btn_copy_ip.text = "✓ COPIED!"
	get_tree().create_timer(1.5).timeout.connect(func():
		if is_instance_valid(btn_copy_ip):
			btn_copy_ip.text = "📋 COPY MY LAN IP"
	)

func _on_host_discovered(discovered_ip: String, discovered_port: int) -> void:
	var net = _get_net()
	if net and not net.is_host and not multiplayer.multiplayer_peer:
		discovered_lan_ip = discovered_ip
		discovered_lan_port = discovered_port
		ip_edit.text = discovered_ip
		port_edit.text = str(discovered_port)
		
		lan_banner.visible = true
		lan_host_label.text = "✨ LAN Host detected: %s:%d" % [discovered_ip, discovered_port]
		
		status_label.text = "LAN Host detected at %s:%d!\nClick QUICK JOIN or JOIN GAME (P2)." % [discovered_ip, discovered_port]
		status_label.modulate = Color(0.25, 0.95, 0.45)

func _on_lan_quick_join_pressed() -> void:
	if discovered_lan_ip != "":
		ip_edit.text = discovered_lan_ip
		port_edit.text = str(discovered_lan_port)
		_on_join_pressed()

func _on_host_pressed() -> void:
	var port = int(port_edit.text) if port_edit.text != "" else 7777
	var net = _get_net()
	if net:
		var err = net.host_game(port)
		if err == OK:
			btn_host.disabled = true
			btn_join.disabled = true
			btn_disconnect.visible = true
			btn_start.visible = true
			btn_start.disabled = false
			ip_edit.editable = false
			port_edit.editable = false
			lan_banner.visible = false
			status_label.text = "Hosting on Port %d | LAN IP: %s\nWaiting for Player 2 or click START MATCH." % [port, local_lan_ip]
			status_label.modulate = Color(0.2, 0.85, 1.0)
			_update_player_list()
		else:
			status_label.text = "Failed to host: %s\n(Check if port %d is already in use)" % [err, port]
			status_label.modulate = Color(1.0, 0.3, 0.3)

func _on_join_pressed() -> void:
	var raw_ip = ip_edit.text.strip_edges()
	var port = int(port_edit.text) if port_edit.text != "" else 7777
	
	if ":" in raw_ip and not "[" in raw_ip:
		var parts = raw_ip.split(":")
		raw_ip = parts[0].strip_edges()
		if parts.size() > 1 and parts[1].strip_edges().is_valid_int():
			port = int(parts[1].strip_edges())
			port_edit.text = str(port)
			
	if raw_ip == "":
		raw_ip = "127.0.0.1"
		
	ip_edit.text = raw_ip
	
	var net = _get_net()
	if net:
		var err = net.join_game(raw_ip, port)
		if err == OK:
			btn_host.disabled = true
			btn_join.disabled = true
			btn_disconnect.visible = true
			ip_edit.editable = false
			port_edit.editable = false
			lan_banner.visible = false
			if raw_ip == "127.0.0.1":
				status_label.text = "Connecting to 127.0.0.1 (Localhost)..."
			else:
				status_label.text = "Connecting to %s:%d...\n(Ensure Host has clicked HOST GAME)" % [raw_ip, port]
			status_label.modulate = Color(1.0, 0.75, 0.2)
		else:
			status_label.text = "Failed to initiate connection: %s" % err
			status_label.modulate = Color(1.0, 0.3, 0.3)

func _on_connection_succeeded() -> void:
	status_label.text = "Connected as Player 2! Waiting for Host to start match..."
	status_label.modulate = Color(0.2, 0.9, 0.4)
	_update_player_list()

func _on_connection_failed() -> void:
	status_label.text = "Connection failed!\nCheck Host IP & Port, and ensure Firewall allows UDP 7777."
	status_label.modulate = Color(1.0, 0.3, 0.3)
	_reset_ui()

func _on_server_disconnected() -> void:
	status_label.text = "Host disconnected or connection lost."
	status_label.modulate = Color(1.0, 0.3, 0.3)
	_reset_ui()

func _on_network_player_connected(_id: int) -> void:
	_update_player_list()
	var net = _get_net()
	if net and net.is_host:
		var count = net.players.size()
		if count >= 2:
			status_label.text = "Player 2 joined! Ready to launch match."
			status_label.modulate = Color(0.2, 0.9, 0.4)
			btn_start.disabled = false
		else:
			status_label.text = "Waiting for Player 2 to join..."

func _on_network_player_disconnected(_id: int) -> void:
	_update_player_list()
	var net = _get_net()
	if net and net.is_host:
		status_label.text = "Player 2 disconnected. Waiting for connection..."
		status_label.modulate = Color(1.0, 0.6, 0.2)

func _update_player_list() -> void:
	var net = _get_net()
	if net:
		var count = net.players.size()
		player_list_label.text = "Connected Players: %d / 2\n" % count
		for pid in net.players:
			var pinfo = net.players[pid]
			player_list_label.text += "• %s (Peer %d)\n" % [pinfo["name"], pid]
	else:
		player_list_label.text = "Connected Players: 0 / 2"

func _on_start_pressed() -> void:
	var net = _get_net()
	if net and net.is_host:
		if sfx_launch:
			sfx_launch.play()
		net.start_match()

func _on_disconnect_pressed() -> void:
	var net = _get_net()
	if net:
		net.disconnect_game()
	_reset_ui()

# -------------------------------------------------------------
# Settings Handlers
# -------------------------------------------------------------
func _refresh_settings_ui() -> void:
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		var db = AudioServer.get_bus_volume_db(master_idx)
		var linear = db_to_linear(db) * 100.0
		slider_master.value = linear
		lbl_master_val.text = "%d%%" % int(linear)
		
	var is_full = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	check_fullscreen.button_pressed = is_full
	check_crt.button_pressed = crt_overlay.visible if crt_overlay else true

func _on_master_slider_changed(value: float) -> void:
	lbl_master_val.text = "%d%%" % int(value)
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		if value <= 0.0:
			AudioServer.set_bus_mute(master_idx, true)
		else:
			AudioServer.set_bus_mute(master_idx, false)
			AudioServer.set_bus_volume_db(master_idx, linear_to_db(value / 100.0))

func _on_music_slider_changed(value: float) -> void:
	lbl_music_val.text = "%d%%" % int(value)
	if bgm_player:
		if value <= 0.0:
			bgm_player.volume_db = -80.0
		else:
			bgm_player.volume_db = linear_to_db(value / 100.0) - 6.0

func _on_sfx_slider_changed(value: float) -> void:
	lbl_sfx_val.text = "%d%%" % int(value)
	var db_val = linear_to_db(value / 100.0) if value > 0.0 else -80.0
	if sfx_hover: sfx_hover.volume_db = db_val - 6.0
	if sfx_click: sfx_click.volume_db = db_val
	if sfx_launch: sfx_launch.volume_db = db_val + 2.0

func _on_fullscreen_toggled(is_full: bool) -> void:
	if is_full:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_crt_toggled(enabled: bool) -> void:
	if crt_overlay:
		crt_overlay.visible = enabled
