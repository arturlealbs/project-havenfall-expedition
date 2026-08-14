extends Control

signal venceu(pontos: int)
signal perdeu

@export var fogo_scene: PackedScene

@onready var game_timer = $GameTimer
@onready var spread_timer = $SpreadTimer
@onready var water_jet = $WaterJet
@onready var water_hitbox = $WaterHitbox
@onready var cenarios_container = $Cenarios

var cenario_ativo: TextureRect
var marcadores_ativos: Array = []
var fogos_ativos: Array = []
var jogando = false
var pontuacao = 100

func _ready():
	_escolher_cenario()
	if marcadores_ativos.size() > 0:
		_iniciar_fogos()
		
	game_timer.timeout.connect(_on_tempo_acabou)
	spread_timer.timeout.connect(_on_spread_fogo)
	jogando = true

func _escolher_cenario():
	var cenarios = cenarios_container.get_children()
	for c in cenarios:
		c.visible = false
	
	cenario_ativo = cenarios.pick_random()
	cenario_ativo.visible = true
	
	var pontos_fogo = cenario_ativo.get_node_or_null("PontosDeFogo")
	if pontos_fogo:
		for m in pontos_fogo.get_children():
			if m is Marker2D:
				marcadores_ativos.append(m)

func _iniciar_fogos():
	var qtd_inicial = randi_range(max(1, marcadores_ativos.size() / 3), max(2, marcadores_ativos.size() / 2))
	var marcadores_embaralhados = marcadores_ativos.duplicate()
	marcadores_embaralhados.shuffle()
	
	for i in range(qtd_inicial):
		if i < marcadores_embaralhados.size():
			_spawnar_fogo_em(marcadores_embaralhados[i])

func _spawnar_fogo_em(marcador: Marker2D):
	for f in fogos_ativos:
		if f.global_position == marcador.global_position:
			return 
			
	if fogo_scene:
		var fogo = fogo_scene.instantiate()
		fogo.global_position = marcador.global_position
		fogo.apagado.connect(_on_fogo_apagado)
		add_child(fogo)
		fogos_ativos.append(fogo)

func _on_fogo_apagado(fogo):
	if fogo in fogos_ativos:
		fogos_ativos.erase(fogo)
		pontuacao += 10
		
	if fogos_ativos.size() == 0 and jogando:
		_vencer_jogo()

func _on_spread_fogo():
	if not jogando or fogos_ativos.size() == 0:
		return
		
	var marcadores_livres = []
	for m in marcadores_ativos:
		var tem_fogo = false
		for f in fogos_ativos:
			if f.global_position == m.global_position:
				tem_fogo = true
				break
		if not tem_fogo:
			marcadores_livres.append(m)
			
	if marcadores_livres.size() > 0:
		_spawnar_fogo_em(marcadores_livres.pick_random())

func _physics_process(_delta):
	if not jogando:
		water_jet.visible = false
		return
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		water_jet.visible = true
		var mouse_pos_global = get_global_mouse_position()
		var mouse_pos_local = get_local_mouse_position()
		
		var start_pos = Vector2(size.x / 2.0, size.y)
		water_jet.points[0] = start_pos
		water_jet.points[1] = mouse_pos_local
		
		# Aplica dano por distância simples (mais confiável que o Area2D)
		for f in fogos_ativos:
			if is_instance_valid(f) and f.global_position.distance_to(mouse_pos_global) < 60.0:
				f.receber_agua()
	else:
		water_jet.visible = false
		
func _vencer_jogo():
	jogando = false
	water_jet.visible = false
	print("Venceu! Pontuação: ", pontuacao)
	venceu.emit(pontuacao)

func _on_tempo_acabou():
	jogando = false
	water_jet.visible = false
	print("Derrota! O fogo se espalhou.")
	perdeu.emit()
