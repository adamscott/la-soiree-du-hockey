extends Node

const Player: = preload("res://scenes/entities/player/Player.gd")

onready var player_1: Player = $Player1 as Player
onready var player_2: Player = $Player2 as Player
onready var player_3: Player = $Player3 as Player
onready var player_4: Player = $Player4 as Player
onready var player_5: Player = $Player5 as Player
onready var player_6: Player = $Player6 as Player
onready var player_7: Player = $Player7 as Player
onready var player_8: Player = $Player8 as Player


func _on_network_peer_connected(peer_id: int) -> void:
	player_1.set_network_master(1)
	if get_tree().is_network_server():
		prints("is server")
		player_2.set_network_master(peer_id)
	else:
		prints("is client")
		player_2.set_network_master(get_tree().get_network_unique_id())


func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")


func get_player_by_id(id: int) -> Player:
	match id:
		1:
			return Players.player_1
		2:
			return Players.player_2
		3:
			return Players.player_3
		4:
			return Players.player_4
		5:
			return Players.player_5
		6:
			return Players.player_6
		7:
			return Players.player_7
		8:
			return Players.player_8
		_:
			return null
