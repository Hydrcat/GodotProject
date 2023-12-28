extends Node2D

@onready var card_factory = $CardFactory as CardFactory

func creat_card()->void:
	var type_dict := card_factory.type_dict as Dictionary
	var type := type_dict.keys().pick_random() as String
	var num := randi_range(1,5)
	var card = card_factory.create_card(type,num)
	add_child(card)

