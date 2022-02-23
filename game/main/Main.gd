extends Node

const NetworkMenu: = preload("res://scenes/menus/network/NetworkMenu.gd")
const Player: = preload("res://scenes/entities/player/Player.gd")

onready var network_menu: NetworkMenu = $CenterContainer/NetworkMenu
onready var server_player: Player = $ServerPlayer
onready var client_player: Player = $ClientPlayer


func _on_network_peer_connected(peer_id: int) -> void:
	prints("on network peer connected")
	
	server_player.set_network_master(1)
	if get_tree().is_network_server():
		prints("is server", peer_id)
		client_player.set_network_master(peer_id)
	else:
		prints("is client", peer_id)
		client_player.set_network_master(get_tree().get_network_unique_id())


func _on_Console_reset_connection() -> void:
	PeerManager.reset_connection()


func _ready() -> void:
	add_reset_command()
	network_menu.popup()
	
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")


func add_reset_command() -> void:
	Console\
		.add_command("reset_connection", self, "_on_Console_reset_connection")\
		.set_description("Resets the connection")\
		.register()
