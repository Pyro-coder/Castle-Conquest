extends AudioStreamPlayer


const MenuMusic = preload("res://Assets/Music/Menu.mp3")
const easyMusic  = preload("res://Assets/Music/Peasant.mp3")


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
