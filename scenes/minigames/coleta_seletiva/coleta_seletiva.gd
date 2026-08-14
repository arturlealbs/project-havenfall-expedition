extends Control

signal venceu(pontos: int)
signal perdeu

@export var categorias_de_lixo: Array[TipoLixoData] = []
@export var quantidade_de_lixeiras: Array[int] = [4, 6, 8, 10]

@export var lixeira_scene: PackedScene
@export var lixo_scene: PackedScene

@onready var container_lixeiras = $VBoxContainer/ContainerLixeiras
@onready var area_lixos = $VBoxContainer/AreaLixos
@onready var time_bar = $VBoxContainer/TopBar/TimeBar
@onready var game_timer = $GameTimer

@onready var painel_ajuda = $PainelAjuda
@onready var botao_ajuda = $BotaoAjuda
@onready var lista_ajuda = $PainelAjuda/ScrollContainer/VBoxContainer

var lixos_restantes = 0

var textos_ajuda_cores = [
	"Azul: Papel",
	"Vermelho: Plástico",
	"Amarelo: Metal",
	"Verde: Vidro",
	"Marrom: Orgânico",
	"Preto: Madeira",
	"Cinza: Não Reciclável",
	"Branco: Hospitalar",
	"Laranja: Perigoso",
	"Roxo: Radioativo"
]

func _ready():
	if categorias_de_lixo.size() == 0:
		print("Nenhuma categoria configurada!")
		return
		
	time_bar.max_value = game_timer.wait_time
	preparar_jogo()
	preencher_ajuda()
	
	painel_ajuda.visible = false
	botao_ajuda.pressed.connect(_on_botao_ajuda_pressed)
	game_timer.timeout.connect(_on_tempo_acabou)

func preencher_ajuda():
	for texto in textos_ajuda_cores:
		var label = Label.new()
		label.text = texto
		#label.theme_override_colors.font_outline_color = Color(0, 0, 0, 1)
		label.add_theme_constant_override("outline_size", 4)
		label.add_theme_font_size_override("font_size", 24)
		lista_ajuda.add_child(label)

func _on_botao_ajuda_pressed():
	painel_ajuda.visible = !painel_ajuda.visible

func _process(_delta):
	time_bar.value = game_timer.time_left

func preparar_jogo():
	var categorias_embaralhadas = categorias_de_lixo.duplicate()
	categorias_embaralhadas.shuffle()
	
	var qtd_lixeiras = quantidade_de_lixeiras.pick_random()
	if qtd_lixeiras > categorias_embaralhadas.size():
		qtd_lixeiras = categorias_embaralhadas.size()
		
	var categorias_escolhidas = categorias_embaralhadas.slice(0, qtd_lixeiras)
	
	for categoria in categorias_escolhidas:
		var lixeira = lixeira_scene.instantiate()
		lixeira.texture = categoria.imagem_lixeira
		lixeira.tipo_id = categoria.nome_categoria
		lixeira.lixo_coletado.connect(_on_lixo_coletado)
		container_lixeiras.add_child(lixeira)
		
		var min_lixos = 3
		var max_lixos = 5
		
		match qtd_lixeiras:
			10:
				min_lixos = 1
				max_lixos = 2
			8:
				min_lixos = 1
				max_lixos = 2
			6:
				min_lixos = 1
				max_lixos = 3
			4:
				min_lixos = 2
				max_lixos = 4
				
		var qtd_lixos = randi_range(min_lixos, max_lixos)
		for i in range(qtd_lixos):
			var lixo = lixo_scene.instantiate()
			if categoria.imagens_lixos.size() > 0:
				lixo.texture = categoria.imagens_lixos.pick_random()
			lixo.tipo_id = categoria.nome_categoria
			area_lixos.add_child(lixo)
			
			call_deferred("_posicionar_lixo_aleatoriamente", lixo)
			lixos_restantes += 1

func _posicionar_lixo_aleatoriamente(lixo):
	var padding = 20
	var max_x = max(padding, area_lixos.size.x - lixo.size.x - padding)
	var max_y = max(padding, area_lixos.size.y - lixo.size.y - padding)
	
	lixo.position = Vector2(
		randf_range(padding, max_x),
		randf_range(padding, max_y)
	)

func _on_lixo_coletado():
	lixos_restantes -= 1
	if lixos_restantes <= 0:
		vencer_jogo()

func vencer_jogo():
	game_timer.stop()
	print("Vitória! Todos os lixos foram recolhidos.")
	venceu.emit(100)

func _on_tempo_acabou():
	if lixos_restantes > 0:
		print("Derrota! O tempo acabou.")
		perdeu.emit()
