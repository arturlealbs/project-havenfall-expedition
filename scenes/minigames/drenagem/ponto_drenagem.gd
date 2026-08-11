extends Control
class_name PontoDrenagem

signal iniciou_conexao(ponto: PontoDrenagem)
signal finalizou_conexao(ponto: PontoDrenagem)
signal mouse_entrou(ponto: PontoDrenagem)
signal mouse_saiu(ponto: PontoDrenagem)

@export var id_tubulacao: int = 0 # Define qual cor/tipo de água conecta com qual
@export var eh_origem: bool = true # True para o lado esquerdo, False para o direito

var conectado: bool = false:
	set(val):
		conectado = val
		_atualizar_aparencia_conectado()

var cor_do_ponto: Color

const NOMES_TUBULACAO: Array[String] = ["A", "B", "C", "D"]

const CORES_POR_ID: Array[Color] = [
	Color(0.2, 0.5, 0.85),   # ID 0 - Azul chuva
	Color(0.1, 0.35, 0.65),  # ID 1 - Azul rio fundo
	Color(0.28, 0.55, 0.35), # ID 2 - Verde canal/vegetação
	Color(0.55, 0.4, 0.2)    # ID 3 - Marrom terra (extra)
]

@onready var color_rect: ColorRect = $ColorRect if has_node("ColorRect") else null
@onready var outer_ring: ColorRect = $OuterRing if has_node("OuterRing") else null
@onready var glow_ring: ColorRect = $GlowRing if has_node("GlowRing") else null
@onready var label_id: Label = $LabelID if has_node("LabelID") else null
@onready var check_icon: Label = $CheckIcon if has_node("CheckIcon") else null

var tween_hover: Tween

func _ready() -> void:
	pivot_offset = size / 2.0
	
	if id_tubulacao >= 0 and id_tubulacao < CORES_POR_ID.size():
		cor_do_ponto = CORES_POR_ID[id_tubulacao]
	else:
		cor_do_ponto = Color.WHITE
		
	if color_rect:
		color_rect.color = cor_do_ponto
	if outer_ring:
		outer_ring.color = Color(0.3, 0.35, 0.28, 1) # Cimento / concreto
	if glow_ring:
		glow_ring.color = Color(cor_do_ponto.r * 0.6, cor_do_ponto.g * 0.6, cor_do_ponto.b, 0.25)
	if label_id:
		var nome = NOMES_TUBULACAO[id_tubulacao] if id_tubulacao < NOMES_TUBULACAO.size() else str(id_tubulacao + 1)
		label_id.text = "💧" + nome
		label_id.modulate = Color(0.9, 0.95, 1.0, 1.0)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	_atualizar_aparencia_conectado()

func _on_mouse_entered() -> void:
	mouse_entrou.emit(self)
	if not conectado:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_animar_scale(Vector2(1.15, 1.15))
		if glow_ring:
			glow_ring.color.a = 0.6

func _on_mouse_exited() -> void:
	mouse_saiu.emit(self)
	if not conectado:
		mouse_default_cursor_shape = Control.CURSOR_ARROW
		_animar_scale(Vector2(1.0, 1.0))
		if glow_ring:
			glow_ring.color.a = 0.3

func _animar_scale(target_scale: Vector2) -> void:
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_hover.tween_property(self, "scale", target_scale, 0.15)

func _atualizar_aparencia_conectado() -> void:
	if check_icon:
		check_icon.visible = conectado
	if conectado:
		mouse_default_cursor_shape = Control.CURSOR_ARROW
		if glow_ring:
			glow_ring.color.a = 0.8
		modulate = Color(1.2, 1.2, 1.2, 1.0)
	else:
		modulate = Color.WHITE

func animar_sucesso() -> void:
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tw.tween_property(self, "scale", Vector2(1.3, 1.3), 0.1)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)

func animar_erro() -> void:
	var pos_orig = position
	var tw = create_tween()
	tw.tween_property(self, "position:x", pos_orig.x - 8, 0.04)
	tw.tween_property(self, "position:x", pos_orig.x + 8, 0.04)
	tw.tween_property(self, "position:x", pos_orig.x - 4, 0.04)
	tw.tween_property(self, "position:x", pos_orig.x, 0.04)

func _gui_input(event: InputEvent) -> void:
	if conectado or not eh_origem:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			iniciou_conexao.emit(self)
		else:
			finalizou_conexao.emit(self)
