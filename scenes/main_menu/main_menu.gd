extends Node

## Ожидаемая структура сцены:
## MainMenu (Node)
##   CanvasLayer
##     TextureRect          ← фон (stretch_mode = STRETCH_SCALE, anchors = full rect)
##     CenterContainer      ← anchors = full rect
##       VBoxContainer
##         Label            ← название игры
##         Button (name="StartButton")
##         Button (name="SettingsButton")
##         Button (name="QuitButton")

@onready var start_btn:    Button = $CanvasLayer/CenterContainer/VBoxContainer/StartButton
@onready var settings_btn: Button = $CanvasLayer/CenterContainer/VBoxContainer/OptionsButton
@onready var quit_btn:     Button = $CanvasLayer/CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	start_btn.pressed.connect(_on_start_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)


func _on_start_pressed() -> void:
	_start_game()


func _start_game(flight_duration_sec: float = 120.0, final_speed_multiplier: float = 3.0) -> void:
	GameState.reset_craft_hp()
	SceneRouter.start_flight(flight_duration_sec, final_speed_multiplier)


func _on_settings_pressed() -> void:
	# Заглушка — добавь сцену настроек когда будет готова
	print("Settings — coming soon")


func _on_quit_pressed() -> void:
	get_tree().quit()
