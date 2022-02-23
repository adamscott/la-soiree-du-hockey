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


func get_player_hockey_player_path_by_id(id: int) -> NodePath:
	return get_player_by_id(id).hockey_player


func get_player_hockey_player_id_by_path(path: NodePath) -> int:
	var player_1_path: = get_player_hockey_player_path_by_id(1)
	var player_2_path: = get_player_hockey_player_path_by_id(2)
	var player_3_path: = get_player_hockey_player_path_by_id(3)
	var player_4_path: = get_player_hockey_player_path_by_id(4)
	var player_5_path: = get_player_hockey_player_path_by_id(5)
	var player_6_path: = get_player_hockey_player_path_by_id(6)
	var player_7_path: = get_player_hockey_player_path_by_id(7)
	var player_8_path: = get_player_hockey_player_path_by_id(8)
	
	match path:
		player_1_path:
			return 1
		player_2_path:
			return 2
		player_3_path:
			return 3
		player_4_path:
			return 4
		player_5_path:
			return 5
		player_6_path:
			return 6
		player_7_path:
			return 7
		player_8_path:
			return 8
		_:
			return -1


func is_player_hockey_player_path(path: NodePath) -> bool:
	return get_player_hockey_player_id_by_path(path) != -1
