extends AudioStreamPlayer


const MenuMusic = preload("res://Assets/Music/Menu.mp3")

const easyMusic  = preload("res://Assets/Music/Peasant.mp3")
const mediumMusic =  preload("res://Assets/Music/Knight.mp3")
const hardMusic = preload("res://Assets/Music/King.mp3")

func play_music(music: AudioStream, volume = 0.0):
	if stream == music:
		return
		
	stream = music
	volume_db = volume
	play()
	
func play_menu_music():
	play_music(MenuMusic)
	
	
func play_easy_music():
	play_music(easyMusic)
	
func play_medium_music():
	play_music(mediumMusic)

func play_hard_music():
	play_music(hardMusic)
