extends Control

@export var pontuacao_total = 100

var numero_de_instrucoes = 1
var id_atual: int = 0
var tempo = 0.0
@onready var grid = $GridContainer
@onready var label_instrucao = $Label


func _ready():
	preparar_jogo()

func _process(delta: float) -> void:
	tempo = tempo + delta

func preparar_jogo():
	id_atual = 1
	# 1. Instancia os botões baseados no Resource
	for child in grid.get_children():
		child.clicado.connect(_ao_botao_clicado)
		child.text = str(child.id)
		numero_de_instrucoes += 1
	
	# 2. Aleatoriza a posição na Grid
	embaralhar_botoes()

func embaralhar_botoes():
	var botoes = grid.get_children()
	botoes.shuffle() # Função nativa do Godot para embaralhar Arrays
	for b in botoes:
		grid.move_child(b, -1) # Move para o final, mudando a ordem visual na grid

func _ao_botao_clicado(botao, id_recebido):
	if(id_atual == id_recebido):
		botao.disabled = true
		id_atual = id_atual + 1
		if(id_atual == numero_de_instrucoes):
			pontuacao_total -= tempo
			print("Voce venceu! Sua pontuaçao foi ", pontuacao_total)
		
	else:
		print("deu errado")
