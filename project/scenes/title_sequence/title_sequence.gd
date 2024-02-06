extends Setting

@export var main_menu = preload("res://scenes/menu/main_menu.tscn")
@onready var sprite: AnimatedSprite2D = $LogoAnimation

signal transition(new_scene: PackedScene, animation: String)

func _ready():
	sprite.play("logo")
	await sprite.animation_finished
	await get_tree().create_timer(0.5).timeout
	transition.emit(main_menu, "")

func _input(event):
	print(event)
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		transition.emit(main_menu, "")
