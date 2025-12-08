extends AudioStreamPlayer
class_name EngineSound


var playback: AudioStreamGeneratorPlayback
var time: float = 0

func _ready() -> void:
	if not stream is AudioStreamGenerator:
		stream = AudioStreamGenerator.new()
		stream.mix_rate = 44100
	play()
	playback = get_stream_playback()

func _process(_delta: float) -> void:
	if playing:
		playback = get_stream_playback()
	else:
		time = 0
	if playback.get_frames_available() > 2048:
		_fill_buffer()

func _fill_buffer():
	for i in range(1024):
		time += 1.0 / 44100.0
		var base_freq: float = 80.0
		var hum: float = sin(2.0 * PI * base_freq * time) * min(time * 4.0, 1)
		var noise: float = randf() * 0 * min(time, 1)
		var sample: float = hum * 0.5 + noise
		sample = tanh(sample * 1.5)
		playback.push_frame(Vector2(sample, sample))
