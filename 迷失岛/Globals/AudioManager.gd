extends Node2D

@onready var bgm_player = $Bgm_Player


const DEFAULT_BGM = "res://游戏素材/音乐/PaperWings.mp3"

func play(BGM:=DEFAULT_BGM):
	if BGM == "" :
		BGM = DEFAULT_BGM
		
	if bgm_player.playing and bgm_player.stream.resource_path == BGM :
		return
	
	bgm_player.stream = load(BGM)
	bgm_player.play()
