extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100

func _ready():
	StartServer()
	
func StartServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server Started")
	
	network.connect('peer_connected', self,'_Peer_Connected')
	network.connect('peer_disconnected', self,'_Peer_Disconnected')
	
	
func _Peer_connected(player_id):
	print("user " + str(player_id)+ " connected")	
func _Peer_disconnected(player_id):
	print("user " + str(player_id)+ " disconnected")	
		
