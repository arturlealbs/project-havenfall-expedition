extends Button

signal buraco_tapado # O manager vai escutar isso

func _ready():
	action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	pressed.connect(_ao_ser_clicado)

func _ao_ser_clicado():
	buraco_tapado.emit()
	queue_free() # Remove o nó da árvore de forma segura no próximo frame

var cached_image: Image

func definir_textura(textura: Texture2D):
	if textura != null:
		icon = textura
		cached_image = textura.get_image()
		flat = true
		expand_icon = true
		modulate = Color(0.6, 0.6, 0.6) # Deixa a textura inteira 60% mais escura

func _has_point(point: Vector2) -> bool:
	if not cached_image:
		return Rect2(Vector2.ZERO, size).has_point(point)
		
	var tex_size = cached_image.get_size()
	var x = int((point.x / size.x) * tex_size.x)
	var y = int((point.y / size.y) * tex_size.y)
	
	x = clamp(x, 0, tex_size.x - 1)
	y = clamp(y, 0, tex_size.y - 1)
	
	# Ignora cliques nas partes transparentes
	if cached_image.get_pixel(x, y).a < 0.1:
		return false
	return true
