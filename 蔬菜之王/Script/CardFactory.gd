extends Node2D
class_name CardFactory

const card := preload("res://Scene/Card.tscn") as PackedScene
const MAX_CARDS_IN_HAND := 5
@export var card_ress :Array[CardRes]

@onready var _0 = $"0"
@onready var _1 = $"1"
@onready var _2 = $"2"
@onready var _3 = $"3"
@onready var _4 = $"4"

var type_dict = {}
var card_in_hand : Array[Card] = []

func _ready():
	for res in card_ress:
		type_dict[res.card_type] = res
	await ready
	fill_hand()

func fill_hand()->void:
	for i in range(MAX_CARDS_IN_HAND-card_in_hand.size()):
		var card := random_create()
		card_in_hand.append(card)
	
	resort()

func on_card_leave_hand(card:Card)->void:
	card_in_hand.erase(card)
	
	resort()
	if card_in_hand.size() <= 1:
		fill_hand()

func on_card_release_holding(card:Card)->void:
	var index := card_in_hand.find(card)
	move_to(card,index)

func resort():
	for card_id in range(card_in_hand.size()):
		move_to(card_in_hand[card_id],card_id)
	
func move_to(card:Card,to_index:int):
	var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	var to_position = get_pos(to_index)
	tween.tween_property(card,"global_position",to_position,0.3)

func get_pos(index:int)->Vector2:
	#var node := get("_"+str(index)) as Node2D
	var node := get_child(index) as Node2D
	return node.global_position

func create_card(type,num)->Card:
	var temp_card := card.instantiate() as Card
	var res := type_dict[type] as CardRes
	temp_card.init_card(res,num)
	return temp_card
	
func random_create()->Card:
	var type := type_dict.keys().pick_random() as String
	var num := randi_range(1,4)
	var card = create_card(type,num)
	add_child(card)
	card.release_holding.connect(on_card_release_holding)
	card.card_leave_hand.connect(on_card_leave_hand)
	return card
