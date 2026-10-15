extends Node

var enabled := true
var voices: Array[AudioStreamPlayer] = []
var ambient: AudioStreamPlayer
var sounds: Dictionary = {}
var voice_index := 0

func _ready() -> void:
	for kind in ["kunai", "katon", "impact"]:
		sounds[kind] = synth(kind)
	for i in range(4):
		var voice := AudioStreamPlayer.new()
		voice.volume_db = -15
		add_child(voice)
		voices.append(voice)
	ambient = AudioStreamPlayer.new()
	ambient.stream = synth("wind")
	ambient.volume_db = -28
	add_child(ambient)
	ambient.play()

func synth(kind: String) -> AudioStreamWAV:
	const RATE := 11025
	var duration := 6.0 if kind == "wind" else 0.55 if kind == "katon" else 0.18
	var count := int(duration * RATE)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 9057
	var low := 0.0
	for i in range(count):
		var t := float(i) / RATE
		var noise := rng.randf_range(-1, 1)
		low = lerpf(low, noise, 0.06)
		var value := 0.0
		var envelope := sin(PI * t / duration) * exp(-t * 5)
		match kind:
			"kunai": value = (noise * 0.35 + sin(TAU * (1700 * t - 2800 * t * t)) * 0.2) * envelope
			"katon": value = (low * 2.0 + noise * 0.16 + sin(TAU * 68 * t) * 0.12) * envelope
			"impact": value = (noise * 0.5 + sin(TAU * 320 * t) * 0.25) * exp(-t * 26)
			"wind":
				var loop_envelope := pow(sin(PI * t / duration), 2)
				var chirp := maxf(0, sin(t * 2.2)) * maxf(0, sin(t * 8.7))
				value = (low * 0.8 + sin(TAU * (1700 * t + sin(t * 12) * 2)) * chirp * 0.035) * loop_envelope
		bytes.encode_s16(i * 2, int(clampf(value, -1, 1) * 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.data = bytes
	if kind == "wind":
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = count
	return stream

func play(kind: String) -> void:
	if not enabled or not sounds.has(kind):
		return
	var voice := voices[voice_index % voices.size()]
	voice_index += 1
	voice.stream = sounds[kind]
	voice.play()

func set_enabled(value: bool) -> void:
	enabled = value
	if ambient != null:
		if value and not ambient.playing:
			ambient.play()
		elif not value:
			ambient.stop()
			for voice in voices:
				voice.stop()

func shutdown() -> void:
	for voice in voices:
		voice.stop()
		voice.stream = null
	if ambient != null:
		ambient.stop()
		ambient.stream = null
	sounds.clear()

func _exit_tree() -> void:
	shutdown()
