extends Control

func UpdateMainLabel(textInput):
	var Main_Banner = $"Banners-large-cropped-main/MainLabel"
	Main_Banner.text = textInput

func UpdateP1Label(input):
	var P1Label = $BlueWood/blueLabel
	P1Label.text = input
	
func UpdateP2Label(input):
	var P2Label = $RedWood/redLabel
	P2Label.text = input
