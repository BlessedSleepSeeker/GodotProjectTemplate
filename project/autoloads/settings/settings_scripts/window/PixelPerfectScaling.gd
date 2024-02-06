extends Setting

@export var base_value: bool = true

func _ready():
	value = base_value
	default = base_value

# called when settings.apply_settings() is triggered
func apply():
	if value:
		get_window().set_content_scale_stretch(Window.CONTENT_SCALE_STRETCH_INTEGER)
	else:
		get_window().set_content_scale_stretch(Window.CONTENT_SCALE_STRETCH_FRACTIONAL)