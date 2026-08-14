extends CanvasLayer

@export var max_respiracao: float = 100.0
@export var max_hidratacao: float = 100.0
@export var decaimento_por_segundo: float = 0.5

@onready var barra_respiracao = $MarginContainer/VBoxContainer/RespiracaoContainer/TextureRect/BarraRespiracao
@onready var barra_hidratacao = $MarginContainer/VBoxContainer/HidratacaoContainer/TextureRect/BarraHidratacao
@onready var label_pontos = $MarginContainer2/LabelPontos

var respiracao: float
var hidratacao: float
var jogo_pausado: bool = false

func _ready():
	respiracao = max_respiracao
	hidratacao = max_hidratacao
	
	barra_respiracao.max_value = max_respiracao
	barra_respiracao.value = respiracao
	barra_hidratacao.max_value = max_hidratacao
	barra_hidratacao.value = hidratacao
	
	var manager = get_node_or_null("../MinigameManager")
	if manager:
		manager.pontos_atualizados.connect(_on_pontos_atualizados)
		manager.estado_pausado_alterado.connect(_on_estado_pausado_alterado)

func _process(delta: float):
	if jogo_pausado:
		return
		
	respiracao -= decaimento_por_segundo * delta
	hidratacao -= decaimento_por_segundo * delta
	
	barra_respiracao.value = respiracao
	barra_hidratacao.value = hidratacao
	
	if respiracao <= 0 or hidratacao <= 0:
		get_tree().reload_current_scene()

func _on_estado_pausado_alterado(pausado: bool):
	jogo_pausado = pausado

func _on_pontos_atualizados(total: int):
	label_pontos.text = str(total)
