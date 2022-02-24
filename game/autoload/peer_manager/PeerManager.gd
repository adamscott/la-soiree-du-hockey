extends Node


func _on_network_peer_connected(peer_id: int) -> void:
	add_peer(peer_id)


func _on_network_peer_disconnected(peer_id: int) -> void:
	remove_peer(peer_id)


func _on_server_disconnected() -> void:
	remove_peer(1)


func _on_SyncManager_sync_started() -> void:
	Console.write_line("Sync started!")
	
	var peer_id: = get_tree().get_network_unique_id()
	match peer_id:
		1:
			SyncManager.start_logging("res://peer_server.log")
		_:
			SyncManager.start_logging("res://peer_client.log")
	


func _on_SyncManager_sync_stopped() -> void:
	Console.write_line("Sync stopped")


func _on_SyncManager_sync_lost() -> void:
	Console.write_line("Sync lost")


func _on_SyncManager_sync_regained() -> void:
	Console.write_line("Sync regained")


func _on_SyncManager_sync_error(msg: String) -> void:
	Console.write_line("Sync error: %s" % [msg])
	clear_peers()


func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	SyncManager.connect("sync_started", self, "_on_SyncManager_sync_started")
	SyncManager.connect("sync_stopped", self, "_on_SyncManager_sync_stopped")
	SyncManager.connect("sync_lost", self, "_on_SyncManager_sync_lost")
	SyncManager.connect("sync_regained", self, "_on_SyncManager_sync_regained")
	SyncManager.connect("sync_error", self, "_on_SyncManager_sync_error")


func init_server(port: int) -> void:
	var peer: = NetworkedMultiplayerENet.new()
	peer.create_server(port, 1)
	get_tree().network_peer = peer
	Console.write_line("Listening to port %s..." % [port])


func init_client(address: String, port: int) -> void:
	var peer: = NetworkedMultiplayerENet.new()
	peer.create_client(address, port)
	get_tree().network_peer = peer
	Console.write_line("Connecting to address %s:%s" % [address, port])


func add_peer(peer_id: int) -> void:
	Console.write_line("Connected!")
	SyncManager.add_peer(peer_id)
	
	if get_tree().is_network_server():
		start_server()
	elif peer_id == get_tree().get_network_unique_id():
		SyncManager.start_logging("res://client.log")


func remove_peer(peer_id: int) -> void:
	Console.write_line("Disconnected")
	SyncManager.remove_peer(peer_id)


func start_server() -> void:
	Console.write_line("Starting...")
	# Give a little time to get ping data
	yield(get_tree().create_timer(2.0), "timeout")
	SyncManager.start()


func clear_peers() -> void:
	SyncManager.clear_peers()
	var peer: = get_tree().network_peer
	if peer:
		peer.close_connection()


func reset_connection() -> void:
	SyncManager.stop()
	SyncManager.stop_logging()
	clear_peers()
	get_tree().reload_current_scene()
