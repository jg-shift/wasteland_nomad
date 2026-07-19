extends AudioStreamPlayer2D
class_name MusicController

@export var tracks: Array[AudioStream] = []

var _random := RandomNumberGenerator.new()


func _ready() -> void:
	if tracks.is_empty():
		push_warning("MusicController: playlist is empty")
		return

	_random.randomize()
	stream = tracks[_random.randi_range(0, tracks.size() - 1)]
	play()
