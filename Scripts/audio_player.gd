extends AudioStreamPlayer


const MenuMusic = preload("res://Assets/Music/Menu.mp3")

const easyMusic  = preload("res://Assets/Music/Peasant.mp3")
const mediumMusic =  preload("res://Assets/Music/Knight.mp3")
const hardMusic = preload("res://Assets/Music/King.mp3")

var whatIsPlaying = "menu"



func play_music(music: AudioStream, linear_volume = 0.2):
	if stream == music:
		return
		
	stream = music
	volume_db = clamp(value_to_db(linear_volume), -80.0, 0.0)
	play()

func value_to_db(value: float) -> float:
	if value <= 0.0:
		return -80.0
	return clamp(20.0 * (log(value) / log(10)), -40.0, -10.0)

func play_menu_music():
	play_music(MenuMusic, 0.2)
	whatIsPlaying = "menu"
	
func play_easy_music():
	play_music(easyMusic, 0.2)
	
	
func play_medium_music():
	play_music(mediumMusic, 0.2)
	
func play_hard_music():
	play_music(hardMusic, 0.2)
	
