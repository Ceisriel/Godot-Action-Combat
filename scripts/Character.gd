extends Control

var playerName = ""
var save_path = "user://saves/save.dat"

func _physics_process(delta):
	if Input.is_action_just_pressed("inv"):
		self.visible = !self.visible

# Called when the node enters the scene tree for the first time.
func _ready():
	var lineEdit = get_node("LineEdit")
	var label = get_node("../../Spatial/Viewport/Label")

	# Load the saved player name from the saved data
	playerName = loadSavedPlayerName()  # Make sure to implement this function in your save script

	lineEdit.text = playerName  # Set the LineEdit's text to the loaded player name
	label.text = playerName

	# Connect the LineEdit's text_changed signal to the onLineEditTextChanged function
	lineEdit.connect("text_changed", self, "onLineEditTextChanged", [label])

# Called when the LineEdit text is changed
func onLineEditTextChanged(new_text, label):
	playerName = new_text
	label.text = new_text

# You should implement the following function in your save script
func loadSavedPlayerName():
	var file = File.new()
	if file.file_exists(save_path):
		var error = file.open_encrypted_with_pass(save_path, File.READ, "P@paB3ar6969")
		if error == OK:
			var player_data = file.get_var()
			file.close()

			if "playerName" in player_data:
				return player_data["playerName"]

	return ""  # Return an empty string if no saved player name is found

