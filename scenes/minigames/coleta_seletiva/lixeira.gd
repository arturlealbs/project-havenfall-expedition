extends TextureRect

signal lixo_coletado

var tipo_id: String = ""

func _ready():
	# Ajusta o pivot para a animação de stretch and squash ficar na base
	pivot_offset = Vector2(size.x / 2, size.y)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) == TYPE_DICTIONARY and data.has("tipo"):
		return true
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data["tipo"] == tipo_id:
		animacao_acerto()
		data["node"].queue_free()
		lixo_coletado.emit()
	else:
		animacao_erro()

func animacao_acerto():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.1)
	tween.tween_property(self, "scale", Vector2(0.9, 1.1), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func animacao_erro():
	var tween = create_tween()
	var pos_original = position
	tween.tween_property(self, "position", position + Vector2(10, 0), 0.05)
	tween.tween_property(self, "position", position - Vector2(10, 0), 0.05)
	tween.tween_property(self, "position", pos_original, 0.05)
	
	modulate = Color(1, 0.5, 0.5)
	var color_tween = create_tween()
	color_tween.tween_property(self, "modulate", Color(1, 1, 1), 0.3)
