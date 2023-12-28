extends FlagSwitcher

@onready var interactable = $close/Interactable

# Called when the node enters the scene tree for the first time.
@export var key:Item

func _on_interactable_interact():
	var item = Game.inventory.active_item
	
	if item:
		if item == key :
			Game.flags.add(flag)
			Game.inventory.del(key)
		else:
			return
			
			

