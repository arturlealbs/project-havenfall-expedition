extends Area3D


func _ready() -> void:
	body_entered.connect(func (body: Node3D) -> void:
		if body is CharacterBody3D or body.name.begins_with("Player"):
			await get_tree().process_frame
			Events.kill_plane_touched.emit()
	)
