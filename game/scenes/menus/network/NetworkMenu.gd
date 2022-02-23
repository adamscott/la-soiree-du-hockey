extends PopupDialog

onready var host_line_edit: LineEdit = $MarginContainer/VBoxContainer/Fields/GridContainer/HostLineEdit
onready var port_line_edit: LineEdit = $MarginContainer/VBoxContainer/Fields/GridContainer/PortLineEdit
onready var server_button: Button = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/ServerButton
onready var client_button: Button = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/ClientButton


func _on_ServerButton_pressed() -> void:
	PeerManager.init_server(int(port_line_edit.text))
	hide()


func _on_ClientButton_pressed() -> void:
	PeerManager.init_client(host_line_edit.text, int(port_line_edit.text))
	hide()


func _ready() -> void:
	pass
