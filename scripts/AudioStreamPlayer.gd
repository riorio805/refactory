extends AudioStreamPlayer

var audios = ResourcePaths.audios

var prev_idx = -1

@export var min_quiet = 3
@export var max_quiet = 16.9
var quiet_time = 2
var quiet = true


func _ready():
	randomize()
	audios.shuffle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if quiet:
		quiet_time -= delta
		if quiet_time <= 0:
			quiet = false
			play_random_music()

func play_random_music():
	var next_idx = -1
	while (next_idx == -1 or next_idx == prev_idx):
		next_idx = randi_range(0, audios.size()-1)
	var audio_file = audios[next_idx]
	Globals.current_bgm_name = (audio_file
					.replacen(".mp3", "")
					.replacen("res://assets/bgm/", ""))
	stream = load(audio_file)
	prev_idx = next_idx
	play(0)

func _on_finished():
	print("i have stopped")
	quiet = true
	quiet_time = randf_range(min_quiet, max_quiet)
	Globals.current_bgm_name = "None"
