extends Node

const NetworkMenu: = preload("res://scenes/menus/network/NetworkMenu.gd")
const HockeyPlayer: = preload("res://scenes/entities/hockey_player/HockeyPlayer.gd")

onready var network_menu: NetworkMenu = $CenterContainer/NetworkMenu
onready var player_1: HockeyPlayer = $Player1
onready var player_2: HockeyPlayer = $Player2


func _on_Console_reset_connection() -> void:
	PeerManager.reset_connection()


func _ready() -> void:
	player_1.current_player = Players.player_1
	player_2.current_player = Players.player_2
	
	add_reset_command()
	network_menu.popup()


func add_reset_command() -> void:
	Console\
		.add_command("reset_connection", self, "_on_Console_reset_connection")\
		.set_description("Resets the connection")\
		.register()
