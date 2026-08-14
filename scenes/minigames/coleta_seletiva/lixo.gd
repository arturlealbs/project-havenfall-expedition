extends TextureRect

var tipo_id: String = ""
var cached_image: Image

func _ready():
	if texture:
		cached_image = texture.get_image()

func _has_point(point: Vector2) -> bool:
	if not cached_image:
		return Rect2(Vector2.ZERO, size).has_point(point)
		
	var tex_size = cached_image.get_size()
	var x = int((point.x / size.x) * tex_size.x)
	var y = int((point.y / size.y) * tex_size.y)
	
	x = clamp(x, 0, tex_size.x - 1)
	y = clamp(y, 0, tex_size.y - 1)
	
	# Ignora cliques nas partes transparentes (alpha baixo)
	if cached_image.get_pixel(x, y).a < 0.1:
		return false
	return true

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview = TextureRect.new()
	preview.texture = texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.size = size
	preview.modulate = Color(1, 1, 1, 0.7)
	
	var control = Control.new()
	control.add_child(preview)
	preview.position = -0.5 * size
	
	set_drag_preview(control)
	
	return {"node": self, "tipo": tipo_id}
