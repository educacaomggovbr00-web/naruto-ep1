extends Node

var enabled := true
var indoors := false
var night := false
var day_stream:AudioStreamWAV
var night_stream:AudioStreamWAV
var voices: Array[AudioStreamPlayer] = []
var ambient: AudioStreamPlayer
var sounds: Dictionary = {}
var voice_index := 0
var startup_elapsed := 0.0
var ready_for_audio := false
var shutting_down := false

func _ready() -> void:
	for kind in ["kunai", "katon", "impact", "step", "focus"]:
		sounds[kind] = synth(kind)
	for i in range(4):
		var voice := AudioStreamPlayer.new()
		voice.volume_db = -15
		add_child(voice)
		voices.append(voice)
	ambient = AudioStreamPlayer.new()
	day_stream=synth("wind")
	night_stream=synth("night")
	ambient.stream = day_stream
	ambient.volume_db = -28
	add_child(ambient)

func _process(delta: float) -> void:
	if shutting_down: return
	startup_elapsed += delta
	if startup_elapsed >= 0.08:
		ready_for_audio = true
		if enabled and not ambient.playing:
			ambient.play()

func synth(kind: String) -> AudioStreamWAV:
	const RATE := 11025
	var duration := 6.0 if kind in ["wind","night"] else 0.55 if kind == "katon" else 0.075 if kind=="step" else 0.18
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
			"focus": value=(sin(TAU*660*t)*0.25+sin(TAU*990*t)*0.1)*envelope
			"step": value=(low*0.6+sin(TAU*105*t)*0.12)*envelope
			"night":
				var pulse:=pow(maxf(0,sin(t*TAU*7)),8)*maxf(0,sin(t*2.4))
				value=(low*0.25+sin(TAU*3100*t)*pulse*0.06)*pow(sin(PI*t/duration),2)
			"wind":
				var loop_envelope := pow(sin(PI * t / duration), 2)
				var chirp := maxf(0, sin(t * 2.2)) * maxf(0, sin(t * 8.7))
				value = (low * 0.8 + sin(TAU * (1700 * t + sin(t * 12) * 2)) * chirp * 0.035) * loop_envelope
		bytes.encode_s16(i * 2, int(clampf(value, -1, 1) * 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.data = bytes
	if kind in ["wind","night"]:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = count
	return stream

func play(kind: String) -> void:
	if not enabled or not sounds.has(kind):
		return
	var voice := voices[voice_index % voices.size()]
	voice_index += 1
	voice.volume_db=(-34 if indoors else -30) if kind=="step" else -24 if kind=="focus" else -15
	voice.stream = sounds[kind]
	voice.play()

func set_enabled(value: bool) -> void:
	enabled = value
	if ambient != null:
		if value and ready_for_audio and not ambient.playing:
			ambient.play()
		elif not value:
			ambient.stop()
			for voice in voices:
				voice.stop()

func set_indoor(value: bool) -> void:
	indoors=value
	if ambient != null: ambient.volume_db=-40 if value else -32 if night else -28

func set_night(value: bool) -> void:
	if night==value: return
	night=value
	ambient.stop()
	ambient.stream=night_stream if night else day_stream
	set_indoor(indoors)
	if enabled and ready_for_audio: ambient.play()

func shutdown() -> void:
	shutting_down = true
	enabled = false
	for voice in voices:
		voice.stop()
		voice.stream = null
	if ambient != null:
		ambient.stop()
		ambient.stream = null
	sounds.clear()

func _exit_tree() -> void:
	shutdown()
