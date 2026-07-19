extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_text: Label = $HealthLabel

func _ready() -> void:
	health_bar.show_percentage = false
	_on_craft_hp_changed(GameState.get_craft_hp(), GameState.get_craft_max_hp())

	if not GameState.craft_hp_changed.is_connected(_on_craft_hp_changed):
		GameState.craft_hp_changed.connect(_on_craft_hp_changed)

func _on_craft_hp_changed(new_hp: int, max_hp: int) -> void:
	health_bar.max_value = float(maxi(1, max_hp))
	health_bar.value = float(clampi(new_hp, 0, max_hp))
	health_text.text = "%d / %d" % [new_hp, max_hp]
