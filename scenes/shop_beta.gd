extends Control

@onready var repair_button: TextureButton = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Repair
@onready var add_damage_button: TextureButton = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/AddDamage
@onready var add_health_button: TextureButton = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/AddHealth
@onready var continue_button: TextureButton = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Continue
@onready var status_label: RichTextLabel = $MarginContainer/VBoxContainer/HBoxContainer/Control/RichTextLabel


func _ready() -> void:
	GameState.enter_hub()
	_configure_mouse_filters()
	repair_button.pressed.connect(_on_repair_pressed)
	add_damage_button.pressed.connect(_on_add_damage_pressed)
	add_health_button.pressed.connect(_on_add_health_pressed)
	continue_button.pressed.connect(_on_continue_pressed)

	if not GameState.craft_hp_changed.is_connected(_on_craft_hp_changed):
		GameState.craft_hp_changed.connect(_on_craft_hp_changed)
	if not GameState.craft_weapon_damage_upgrade_changed.is_connected(_on_craft_weapon_damage_upgrade_changed):
		GameState.craft_weapon_damage_upgrade_changed.connect(_on_craft_weapon_damage_upgrade_changed)

	_update_workshop_ui()


func _configure_mouse_filters() -> void:
	repair_button.mouse_filter = Control.MOUSE_FILTER_STOP
	add_damage_button.mouse_filter = Control.MOUSE_FILTER_STOP
	add_health_button.mouse_filter = Control.MOUSE_FILTER_STOP
	continue_button.mouse_filter = Control.MOUSE_FILTER_STOP
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_repair_pressed() -> void:
	GameState.reset_craft_hp()


func _on_add_damage_pressed() -> void:
	GameState.add_craft_weapon_damage_upgrade(1)


func _on_add_health_pressed() -> void:
	GameState.add_craft_max_hp(10)


func _on_continue_pressed() -> void:
	if GameState.get_craft_hp() <= 0:
		return
	_start_game()


func _on_craft_hp_changed(_new_hp: int, _max_hp: int) -> void:
	_update_workshop_ui()


func _on_craft_weapon_damage_upgrade_changed(_upgrade: int) -> void:
	_update_workshop_ui()


func _update_workshop_ui() -> void:
	var craft_hp := GameState.get_craft_hp()
	var craft_max_hp := GameState.get_craft_max_hp()
	repair_button.disabled = craft_hp >= craft_max_hp
	continue_button.disabled = craft_hp <= 0
	status_label.text = "CRAFT HP: %d / %d\nDAMAGE MOD: x%d" % [
		craft_hp,
		craft_max_hp,
		GameState.get_craft_weapon_damage_upgrade() + 1,
	]


func _start_game(flight_duration_sec: float = 120.0, final_speed_multiplier: float = 3.0) -> void:
	SceneRouter.start_flight(flight_duration_sec, final_speed_multiplier)
