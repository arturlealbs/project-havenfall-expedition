extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var is_opened := false
# Called when the node enters the scene tree for the first time.

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		animation_player.play("abrir")

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		animation_player.play("fechar")
