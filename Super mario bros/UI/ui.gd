extends CanvasLayer

@onready var coin_num: Label = $"Control/HBoxContainer/coin/coin num"
@onready var score_num: Label = $"Control/HBoxContainer/score/score num"
@onready var time_num: Label = $"Control/HBoxContainer/time/time num"

func _ready() -> void:
	global.play_coin_sound.connect(coin_text_handle)
	
func _process(delta: float) -> void:
	score_num.text = str(global.point)
	
func coin_text_handle():
	var coin = global.coin
	if coin >= 10:
		coin_num.text = str(coin)
	else:
		coin_num.text = "0" + str(coin)
