extends Control

signal venceu(pontos: int)
signal perdeu

@export var pontuacao_total = 100
@export var fases: Array[MinigameLevelOrder] = []
@export var button_scene: PackedScene

var numero_de_instrucoes = 1
var id_atual: int = 1
var tempo = 0.0
@onready var grid = $GridContainer
@onready var painel_ajuda = $PainelAjuda
@onready var lista_textos_ajuda = $PainelAjuda/ScrollContainer/VBoxContainer

func _ready():
	preparar_jogo()

func _process(delta: float) -> void:
	tempo += delta

func preparar_jogo():
	id_atual = 1
	numero_de_instrucoes = 0
	
	if fases.size() == 0:
		print("Nenhuma fase configurada!")
		return
		
	var fase_atual = fases.pick_random()
	
	if not button_scene:
		print("Cena do botão não configurada!")
		return
		
	for i in range(fase_atual.imagens_passos.size()):
		var b = button_scene.instantiate()
		grid.add_child(b)
		b.id = i + 1
		if fase_atual.imagens_passos[i] != null:
			b.icon = fase_atual.imagens_passos[i]
			b.flat = true
		else:
			b.text = str(b.id)
		b.clicado.connect(_ao_botao_clicado)
		numero_de_instrucoes += 1
		
		var label = Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if i < fase_atual.descricoes_passos.size():
			label.text = str(i + 1) + ". " + fase_atual.descricoes_passos[i]
		else:
			label.text = str(i + 1) + ". (Sem descrição)"
		lista_textos_ajuda.add_child(label)
		
	embaralhar_botoes()

func embaralhar_botoes():
	var botoes = grid.get_children()
	botoes.shuffle()
	for b in botoes:
		grid.move_child(b, -1)

func _ao_botao_clicado(botao, id_recebido):
	if id_atual == id_recebido:
		botao.disabled = true
		botao.modulate = Color(0.5, 1.0, 0.5)
		id_atual += 1
		if id_atual > numero_de_instrucoes:
			pontuacao_total -= int(tempo)
			print("Voce venceu! Sua pontuaçao foi ", pontuacao_total)
			venceu.emit(pontuacao_total)
	else:
		print("deu errado")
		botao.modulate = Color(1.0, 0.5, 0.5)
		var tween = create_tween()
		tween.tween_property(botao, "modulate", Color(1,1,1), 0.5)

func _on_botao_ajuda_pressed():
	painel_ajuda.visible = !painel_ajuda.visible
