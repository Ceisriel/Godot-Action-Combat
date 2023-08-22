extends Control

var playerName = ""
func _physics_process(delta):
	if Input.is_action_just_pressed("inventory"):
		self.visible = !self.visible


# Called when the node enters the scene tree for the first time.
func _ready():
	# Find the LineEdit and Label nodes by their names
	var lineEdit = get_node("LineEdit")
	var label = get_node("../../Spatial/Viewport/Label")

	# Connect the LineEdit's text_changed signal to the onLineEditTextChanged function
	lineEdit.connect("text_changed", self, "onLineEditTextChanged", [label])

	# Load the player name from the file when the game starts
	loadPlayerNameFromFile()
	label.text = playerName

# Called when the LineEdit text is changed
func onLineEditTextChanged(new_text, label):
	playerName = new_text
	label.text = new_text

# Save the player name to a file
func savePlayerNameToFile():
	var file = File.new()
	if file.open("user://player_name.txt", File.WRITE) == OK:
		file.store_string(playerName)
		file.close()

# Load the player name from a file
func loadPlayerNameFromFile():
	var file = File.new()
	if file.open("user://player_name.txt", File.READ) == OK:
		playerName = file.get_as_text()
		file.close()	


func _on_Load_pressed():
	loadPlayerNameFromFile()



func _on_Save_pressed():
	savePlayerNameToFile()


