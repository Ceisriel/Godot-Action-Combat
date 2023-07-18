# Displays the cardinal directions in a 3D space.
# (North, South, East and West)
#
# Textures for Needle and Dial are provided in ```addon/Compass/Assets/```.
# Best resolution for custom textures are 512x512.
#
# Camera Node should be the active camera used to view the 3d space.
#
# **Note**: Advanced Settings are options that may require a more restrictive project layout
# to utilize effectively. Use with caution.
#
### Property
# | Type          | Name                      | Default Value           |
# | ------------- | ------------------------- | ----------------------- |
# | Color         | Background Color          | ```Color(1,1,1,0.25)``` |
# | Texture       | Dial Texture              | ```null```              |
# | Texture       | Needle Texture            | ```null```              |
# | NodePath      | Camera                    | ```null```              |
# | bool          | Advanced Settings Enabled | ```false```             |
# | float         | True North                | ```0.0```               |

tool
extends Control

# Default Color of Background

# Texture resource for the Ring around the Compass
export(Texture) var DialTexture = null setget _SetDialTexture, _GetDialTexture

# Texture resource for the Needle that points the direction the Camera is facing
export(Texture) var NeedleTexture = null setget _SetNeedleTexture, _GetNeedleTexture

# Enable to view Advance Settings in Inspector
export(bool) var AdvancedSettingsEnabled = false setget _SetAdvanceSettings

# The degree offset of the North direction.
var TrueNorth: float = 0.0

# Override path to the Active 3D Camera
var CameraPath: NodePath = ""

onready var _CameraNode = get_viewport().get_camera()
onready var _Bg: ColorRect = $Bg
onready var _Needle: TextureRect = $Needle
onready var _Dial: TextureRect = $Dial

func _ready():

	
	# Override Camera if path is specified
	if CameraPath:
		_CameraNode = get_node(CameraPath)
	
	pass
	
	# Center the textures
	_Needle.rect_pivot_offset = _Needle.rect_size / 2
	_Dial.rect_pivot_offset = _Dial.rect_size / 2
	
func _input(_event):
	_Dial.rect_rotation = rad2deg(_CameraNode.global_transform.basis.get_euler().y) + TrueNorth
	
func _get_configuration_warning() -> String:
	var message = ""
	
	if not DialTexture:
		message = "Missing Texture for Dial"
	elif not NeedleTexture:
		message = "Missing Texture for Needle"
	else:
		message = ""
		
	return message
	
func _get_property_list() -> Array:
	var PropertyList: Array = []
	
	if AdvancedSettingsEnabled:
		PropertyList.append({
			"name": "Advanced Settings/True North",
			"type": TYPE_REAL,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0,360"
		})
		PropertyList.append({
			"name": "Advanced Settings/Camera Path",
			"type": TYPE_NODE_PATH
		})
			
	return PropertyList
	
func _set(prop_name: String, val) -> bool:
	match prop_name:
		"Advanced Settings/True North":
			TrueNorth = val
			if Engine.editor_hint:
				$Ring.rect_rotation = TrueNorth
		"Advanced Settings/Camera Path":
			CameraPath = val
		_:
			# If here, trying to set a property we are not manually dealing with.
			return false
	return true
	
func _get(prop_name: String):
	match prop_name:
		"Advanced Settings/True North":
			return TrueNorth
		"Advanced Settings/Camera Path":
			return CameraPath
	return null


	
func _SetDialTexture(t: Texture):

	update_configuration_warning()
		
func _SetNeedleTexture(t: Texture):

	update_configuration_warning()
	
func _SetAdvanceSettings(b: bool):
	AdvancedSettingsEnabled = b
	property_list_changed_notify()


	
func _GetDialTexture() -> Texture: 
	return DialTexture

func _GetNeedleTexture() -> Texture:
	return NeedleTexture

