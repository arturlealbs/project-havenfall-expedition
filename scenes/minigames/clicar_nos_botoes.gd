extends Control

@export var buraco_scene: PackedScene
@export var imagens_fundo: Array[Texture2D]
@export var imagens_buraco: Array[Texture2D]
@export var tamanho_base_buraco: Vector2 = Vector2(400, 400) # Tamanho configurável para compensar bordas transparentes
@export var quantidade: int = 50
@export var tentativas_maximas: int = 200 # Para evitar loop infinito
@onready var background_rect = $Background
@onready var play_area = $PlayArea
@onready var timer = $GameTimer
@onready var time_bar = $TimeBar


var buracos_restantes: int = 0

var buracos_colocados: Array[Rect2] = []

func _ready():
	if imagens_fundo.size() > 0:
		background_rect.texture = imagens_fundo.pick_random()
	time_bar.max_value = timer.wait_time
	time_bar.value = timer.wait_time
	
	quantidade = randi_range(5, 15)
	preparar_jogo()
	# Conecta o sinal de timeout do Timer para a derrota
	timer.timeout.connect(_ao_tempo_acabar)
	print(buracos_restantes)

func _process(delta):
	time_bar.value = timer.time_left

func gerar_buracos():
	var area_size = play_area.size
	 # Tamanho estimado do seu buraco

	for i in range(quantidade):
		var pos_valida = false
		var nova_pos = Vector2.ZERO
		var buraco_scale =  randf_range(0.5, 0.9)
		var buraco_size = tamanho_base_buraco * buraco_scale
		
		# Tenta encontrar uma posição que não sobreponha
		for tentativa in range(tentativas_maximas):
			nova_pos = Vector2(
				randf_range(0, area_size.x - buraco_size.x),
				randf_range(0, area_size.y - buraco_size.y)
			)
			
			var novo_rect = Rect2(nova_pos, buraco_size)
			if !checar_sobreposicao(novo_rect):
				pos_valida = true
				buracos_colocados.append(novo_rect)
				break
		
		if pos_valida:
			instanciar_buraco(nova_pos, buraco_scale)

func checar_sobreposicao(novo_rect: Rect2) -> bool:
	for rect_existente in buracos_colocados:
		# O Godot já tem uma função nativa pra isso!
		if novo_rect.intersects(rect_existente):
			return true
	return false

func instanciar_buraco(pos: Vector2, buraco_scale: float):
	var b = buraco_scene.instantiate()
	b.custom_minimum_size = tamanho_base_buraco
	b.size = tamanho_base_buraco
	play_area.add_child(b)
	b.position = pos
	b.scale = Vector2(buraco_scale, buraco_scale)
	
	if imagens_buraco.size() > 0:
		b.definir_textura(imagens_buraco.pick_random())
		
	b.buraco_tapado.connect(_on_buraco_tapado)
	
func preparar_jogo():
	buracos_restantes = quantidade
	gerar_buracos()

func _on_buraco_tapado():
	buracos_restantes -= 1
	print(buracos_restantes)
	if buracos_restantes <= 0:
		vencer_jogo()

func vencer_jogo():
	timer.stop() # Para o tempo para não disparar derrota
	print("Vitória! Rua asfaltada com sucesso.")
	# Aqui você chamaria o sinal para fechar o minigame no mapa principal

func _ao_tempo_acabar():
	if buracos_restantes > 0:
		perder_jogo()

func perder_jogo():
	print("Derrota! O asfalto rachou nos buracos restantes.")
	# Feedback visual de rachadura ou som de erro
