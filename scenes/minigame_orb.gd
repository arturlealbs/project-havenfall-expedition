extends Node3D

signal player_entered(orb)
signal player_exited(orb)

var data: MinigameData
@onready var sprite_3d = $Sprite3D

func setup(minigame_data: MinigameData):
	data = minigame_data
	if data and data.simbolo_3d:
		sprite_3d.texture = data.simbolo_3d

func _on_area_3d_body_entered(body):
	if "Player" in body.name:
		player_entered.emit(self)

func _on_area_3d_body_exited(body):
	if "Player" in body.name:
		player_exited.emit(self)
