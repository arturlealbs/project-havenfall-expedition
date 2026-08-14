extends Node

@export var minigames_disponiveis: Array[MinigameData]
@export var minigame_orb_scene: PackedScene

signal pontos_atualizados(total: int)
signal estado_pausado_alterado(pausado: bool)

@onready var ui_layer = $CanvasLayer
@onready var fundo_menu = $CanvasLayer/MenuPanel/FundoMenu
@onready var vbox_container = $CanvasLayer/MenuPanel/FundoMenu/VBoxContainer
@onready var imagem = $CanvasLayer/MenuPanel/FundoMenu/VBoxContainer/Imagem
@onready var titulo_label = $CanvasLayer/MenuPanel/FundoMenu/VBoxContainer/Titulo
@onready var descricao_label = $CanvasLayer/MenuPanel/FundoMenu/VBoxContainer/Descricao
@onready var btn_comecar = $CanvasLayer/MenuPanel/FundoMenu/VBoxContainer/BtnComecar
@onready var minigame_container = $CanvasLayer/MenuPanel/FundoMenu/MinigameContainer

var orb_atual: Node3D = null
var minigame_instancia: Node = null
var dados_atuais: MinigameData = null

var pontos_totais: int = 0

func _ready():
	ui_layer.visible = false
	btn_comecar.pressed.connect(_on_btn_comecar_pressed)
	set_process(true)
	
	call_deferred("spawn_orbs")

func _process(_delta):
	if ui_layer.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func spawn_orbs():
	if minigames_disponiveis.size() == 0:
		print("Nenhum minigame configurado no manager!")
		return
		
	var spawn_group = get_tree().get_first_node_in_group("spawn_minigames")
	if spawn_group:
		var marcadores = spawn_group.get_children()
		marcadores.shuffle()
		
		var qtd = max(1, marcadores.size() / 2)
		for i in range(qtd):
			if i < marcadores.size() and minigame_orb_scene:
				var m = marcadores[i]
				var orb = minigame_orb_scene.instantiate()
				m.add_child(orb)
				orb.global_position = m.global_position
				
				var data = minigames_disponiveis.pick_random()
				orb.setup(data)
				orb.player_entered.connect(_on_orb_entered)
				orb.player_exited.connect(_on_orb_exited)

func _on_orb_entered(orb):
	if minigame_instancia != null:
		return 
		
	orb_atual = orb
	dados_atuais = orb.data
	
	if dados_atuais.imagem_menu:
		imagem.texture = dados_atuais.imagem_menu
	titulo_label.text = dados_atuais.nome
	descricao_label.text = dados_atuais.descricao
		
	ui_layer.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	estado_pausado_alterado.emit(true)
	
	# Desabilita o controle do jogador 3D para ele não roubar o mouse
	var player = get_node_or_null("../Player3DTemplate")
	if player:
		player.set_process_input(false)
		player.set_process_unhandled_input(false)

func _on_orb_exited(orb):
	if orb_atual == orb and minigame_instancia == null:
		ui_layer.visible = false
		orb_atual = null
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		estado_pausado_alterado.emit(false)
		
		# Devolve o controle pro jogador 3D
		var player = get_node_or_null("../Player3DTemplate")
		if player:
			player.set_process_input(true)
			player.set_process_unhandled_input(true)

func _on_btn_comecar_pressed():
	print("Botão começar clicado!")
	if not dados_atuais:
		print("ERRO: dados_atuais esta nulo!")
		return
	if not dados_atuais.minigame_scene:
		print("ERRO: minigame_scene nao esta configurado no resource!")
		return
		
	vbox_container.visible = false
	
	minigame_instancia = dados_atuais.minigame_scene.instantiate()
	
	if minigame_instancia.has_signal("venceu"):
		minigame_instancia.venceu.connect(_on_minigame_venceu)
	if minigame_instancia.has_signal("perdeu"):
		minigame_instancia.perdeu.connect(_on_minigame_perdeu)
		
	minigame_container.add_child(minigame_instancia)
	print("Minigame instanciado e adicionado ao container!")
	
	get_tree().create_timer(60.0).timeout.connect(fechar_minigame)

func _on_minigame_venceu(pontos: int):
	pontos_totais += pontos
	pontos_atualizados.emit(pontos_totais)
	fechar_minigame()

func _on_minigame_perdeu():
	fechar_minigame()

func fechar_minigame():
	if minigame_instancia:
		minigame_instancia.queue_free()
		minigame_instancia = null
		
	for c in minigame_container.get_children():
		c.queue_free()
		
	vbox_container.visible = true
	ui_layer.visible = false
	estado_pausado_alterado.emit(false)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var player = get_node_or_null("../Player3DTemplate")
	if player:
		player.set_process_input(true)
		player.set_process_unhandled_input(true)
	
	if orb_atual:
		orb_atual.queue_free()
		orb_atual = null
