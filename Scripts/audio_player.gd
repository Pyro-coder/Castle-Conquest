extends AudioStreamPlayer


const MenuMusic = preload("res://Assets/Music/Menu.mp3")

const easyMusic  = preload("res://Assets/Music/Peasant.mp3")
const mediumMusic =  preload("res://Assets/Music/Knight.mp3")
const hardMusic = preload("res://Assets/Music/King.mp3")

var whatIsPlaying = "menu"



func play_music(music: AudioStream, linear_volume = 1.0):
	if stream == music:
		return
		
	stream = music
	volume_db = clamp(value_to_db(linear_volume), -80.0, 0.0)
	play()

func value_to_db(value: float) -> float:
	if value <= 0.0:
		return -80.0
	return clamp(20.0 * (log(value) / log(10)), -80.0, 0.0)

func play_menu_music():
	play_music(MenuMusic)
	whatIsPlaying = "menu"
	
func play_easy_music():
	play_music(easyMusic)
	
	
func play_medium_music():
	play_music(mediumMusic)
	
func play_hard_music():
	play_music(hardMusic)
	
