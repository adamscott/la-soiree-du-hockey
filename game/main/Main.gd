extends Node

const NetworkMenu: = preload("res://scenes/menus/network/NetworkMenu.gd")
const HockeyPlayer: = preload("res://scenes/entities/hockey_player/HockeyPlayer.gd")

onready var network_menu: NetworkMenu = $CenterContainer/NetworkMenu
onready var player_1: HockeyPlayer = $Player1
onready var player_2: HockeyPlayer = $Player2


func _on_network_peer_connected(peer_id: int) -> void:
	player_1.set_network_master(1)
	if get_tree().is_network_server():
		prints("is server", peer_id)
		player_2.set_network_master(peer_id)
	else:
		prints("is client", peer_id)
		player_2.set_network_master(get_tree().get_network_unique_id())


func _on_Console_reset_connection() -> void:
	PeerManager.reset_connection()


func _ready() -> void:
	Players.get_player_by_id(1).hockey_player = player_1.get_path()
	Players.get_player_by_id(2).hockey_player = player_2.get_path()
	
	add_reset_command()
	network_menu.popup()
	
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")


func add_reset_command() -> void:
	Console\
		.add_command("reset_connection", self, "_on_Console_reset_connection")\
		.set_description("Resets the connection")\
		.register()
