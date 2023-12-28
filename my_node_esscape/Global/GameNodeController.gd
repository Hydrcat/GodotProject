extends Node
class_name GameNodeController

# 节点被单击的信号
signal game_node_clicked(game_node:GameNode)
# 节点进入另一个节点的信号
signal game_node_interact(game_node_handle:GameNode,game_node_in:GameNode)

var focus_node :GameNode
