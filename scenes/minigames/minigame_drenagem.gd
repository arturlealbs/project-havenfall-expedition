extends Control

signal minigame_concluido(sucesso: bool)

@onready var lado_esquerdo: VBoxContainer = $ShakeContainer/MainPanel/LadoEsquerdo
@onready var lado_direito: VBoxContainer = $ShakeContainer/MainPanel/LadoDireito
@onready var container_linhas: Node2D = $ShakeContainer/MainPanel/ContainerLinhas
@onready var container_particulas: Node2D = $ShakeContainer/MainPanel/ContainerParticulas
@onready var status_label: Label = $ShakeContainer/MainPanel/HeaderPanel/StatusCounterLabel
@onready var shake_container: Control = $ShakeContainer
@onready var vitoria_overlay: Control = $VitoriaOverlay
@onready var btn_reiniciar: Button = $VitoriaOverlay/VictoryCard/VBoxContainer/BtnReiniciar if has_node("VitoriaOverlay/VictoryCard/VBoxContainer/BtnReiniciar") else null

var ponto_origem_atual: PontoDrenagem = null
var linha_glow_atual: Line2D = null
var linha_core_atual: Line2D = null
var linha_inner_atual: Line2D = null
var grupo_linha_atual: Node2D = null

var total_conexoes_feitas: int = 0
var conexoes_para_vencer: int = 3

var ponto_target_hover: PontoDrenagem = null

func _ready() -> void:
	if vitoria_overlay:
		vitoria_overlay.visible = false
		
	if btn_reiniciar:
		btn_reiniciar.pressed.connect(resetar_minigame)
		
	_atualizar_status_ui()
	
	# Conecta os sinais dos pontos de origem (lado esquerdo)
	for ponto in lado_esquerdo.get_children():
		if ponto is PontoDrenagem:
			ponto.iniciou_conexao.connect(_on_ponto_iniciou_conexao)
			ponto.finalizou_conexao.connect(_on_ponto_finalizou_conexao)
			
	# Conecta hover nos pontos de destino (lado direito)
	for ponto in lado_direito.get_children():
		if ponto is PontoDrenagem:
			ponto.mouse_entrou.connect(_on_ponto_destino_mouse_entrou)
			ponto.mouse_saiu.connect(_on_ponto_destino_mouse_saiu)

func _process(_delta: float) -> void:
	if grupo_linha_atual and ponto_origem_atual:
		var pos_mouse_local = container_linhas.get_local_mouse_position()
		
		# Se estiver passando o mouse por cima de um ponto de destino válido, faz um "snap" magnético
		if ponto_target_hover and not ponto_target_hover.conectado:
			var centro_target = ponto_target_hover.global_position + (ponto_target_hover.size / 2.0)
			pos_mouse_local = container_linhas.to_local(centro_target)
			
		if linha_glow_atual:
			linha_glow_atual.set_point_position(1, pos_mouse_local)
		if linha_core_atual:
			linha_core_atual.set_point_position(1, pos_mouse_local)
		if linha_inner_atual:
			linha_inner_atual.set_point_position(1, pos_mouse_local)

func _on_ponto_destino_mouse_entrou(ponto: PontoDrenagem) -> void:
	if ponto_origem_atual and not ponto.eh_origem:
		ponto_target_hover = ponto
		if ponto.id_tubulacao == ponto_origem_atual.id_tubulacao and not ponto.conectado:
			tocar_som("click")

func _on_ponto_destino_mouse_saiu(ponto: PontoDrenagem) -> void:
	if ponto_target_hover == ponto:
		ponto_target_hover = null

func _on_ponto_iniciou_conexao(ponto: PontoDrenagem) -> void:
	ponto_origem_atual = ponto
	tocar_som("click")
	
	# Pega o centro do ponto de origem
	var centro_ponto = ponto.global_position + (ponto.size / 2.0)
	var pos_inicial_local = container_linhas.to_local(centro_ponto)
	
	grupo_linha_atual = Node2D.new()
	
	# Linha Externa (Glow)
	linha_glow_atual = Line2D.new()
	linha_glow_atual.width = 34.0
	linha_glow_atual.default_color = Color(ponto.cor_do_ponto.r, ponto.cor_do_ponto.g, ponto.cor_do_ponto.b, 0.35)
	linha_glow_atual.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linha_glow_atual.end_cap_mode = Line2D.LINE_CAP_ROUND
	linha_glow_atual.add_point(pos_inicial_local)
	linha_glow_atual.add_point(pos_inicial_local)
	grupo_linha_atual.add_child(linha_glow_atual)
	
	# Linha Principal (Core)
	linha_core_atual = Line2D.new()
	linha_core_atual.width = 20.0
	linha_core_atual.default_color = ponto.cor_do_ponto
	linha_core_atual.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linha_core_atual.end_cap_mode = Line2D.LINE_CAP_ROUND
	linha_core_atual.add_point(pos_inicial_local)
	linha_core_atual.add_point(pos_inicial_local)
	grupo_linha_atual.add_child(linha_core_atual)
	
	# Linha Brilho Central (Inner White Core)
	linha_inner_atual = Line2D.new()
	linha_inner_atual.width = 6.0
	linha_inner_atual.default_color = Color(1.0, 1.0, 1.0, 0.7)
	linha_inner_atual.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linha_inner_atual.end_cap_mode = Line2D.LINE_CAP_ROUND
	linha_inner_atual.add_point(pos_inicial_local)
	linha_inner_atual.add_point(pos_inicial_local)
	grupo_linha_atual.add_child(linha_inner_atual)
	
	container_linhas.add_child(grupo_linha_atual)
	
	emitir_particulas(centro_ponto, ponto.cor_do_ponto, 12)

func _on_ponto_finalizou_conexao(_ponto: PontoDrenagem) -> void:
	if not ponto_origem_atual or not grupo_linha_atual:
		return
		
	var ponto_destino = _get_ponto_sob_mouse()
	var pos_mouse = get_global_mouse_position()
	
	if ponto_destino and not ponto_destino.eh_origem and ponto_destino.id_tubulacao == ponto_origem_atual.id_tubulacao and not ponto_destino.conectado:
		# Sucesso na Conexão!
		var centro_destino = ponto_destino.global_position + (ponto_destino.size / 2.0)
		var pos_final_local = container_linhas.to_local(centro_destino)
		
		linha_glow_atual.set_point_position(1, pos_final_local)
		linha_core_atual.set_point_position(1, pos_final_local)
		linha_inner_atual.set_point_position(1, pos_final_local)
		
		# Animação elástica da linha ao conectar
		var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tw.tween_property(linha_core_atual, "width", 26.0, 0.15)
		tw.tween_property(linha_core_atual, "width", 20.0, 0.2)
		
		ponto_origem_atual.conectado = true
		ponto_destino.conectado = true
		
		ponto_origem_atual.animar_sucesso()
		ponto_destino.animar_sucesso()
		
		total_conexoes_feitas += 1
		_atualizar_status_ui()
		
		# Partículas e Efeitos de Som
		emitir_particulas(centro_destino, ponto_origem_atual.cor_do_ponto, 30)
		tocar_som("connect")
		tremer_tela(5.0, 0.15)
		
		if total_conexoes_feitas >= conexoes_para_vencer:
			_iniciar_vitoria()
	else:
		# Falhou a Conexão
		emitir_particulas_erro(pos_mouse)
		ponto_origem_atual.animar_erro()
		if ponto_destino:
			ponto_destino.animar_erro()
			
		grupo_linha_atual.queue_free()
		tocar_som("error")
		tremer_tela(10.0, 0.25)
		
	ponto_origem_atual = null
	linha_glow_atual = null
	linha_core_atual = null
	linha_inner_atual = null
	grupo_linha_atual = null
	ponto_target_hover = null

func _get_ponto_sob_mouse() -> PontoDrenagem:
	var pos_mouse_global = get_global_mouse_position()
	for ponto in lado_direito.get_children():
		if ponto is PontoDrenagem:
			if ponto.get_global_rect().has_point(pos_mouse_global):
				return ponto
	return null

func _atualizar_status_ui() -> void:
	if status_label:
		status_label.text = "%d / %d CANAIS CONECTADOS" % [total_conexoes_feitas, conexoes_para_vencer]

func _iniciar_vitoria() -> void:
	tocar_som("victory")
	tremer_tela(12.0, 0.4)
	
	# Animação de pulso em todas as linhas conectadas
	for grupo in container_linhas.get_children():
		var tw = create_tween().set_loops(3)
		tw.tween_property(grupo, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.2)
		tw.tween_property(grupo, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
		
	# Explosão de celebração de partículas (ondas de água / enxurrada)
	var center_screen = get_viewport_rect().size / 2.0
	emitir_particulas(center_screen, Color(0.2, 0.5, 0.85), 70) # Azul chuva
	emitir_particulas(center_screen, Color(0.35, 0.7, 1.0), 70) # Azul água clara
	
	await get_tree().create_timer(0.4).timeout
	
	if vitoria_overlay:
		vitoria_overlay.visible = true
		vitoria_overlay.modulate.a = 0.0
		var tw_overlay = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tw_overlay.tween_property(vitoria_overlay, "modulate:a", 1.0, 0.4)
		
	minigame_concluido.emit(true)

func resetar_minigame() -> void:
	total_conexoes_feitas = 0
	_atualizar_status_ui()
	
	if vitoria_overlay:
		vitoria_overlay.visible = false
		
	for node in container_linhas.get_children():
		node.queue_free()
		
	for ponto in lado_esquerdo.get_children():
		if ponto is PontoDrenagem:
			ponto.conectado = false
			ponto.scale = Vector2.ONE
			ponto.modulate = Color.WHITE
			
	for ponto in lado_direito.get_children():
		if ponto is PontoDrenagem:
			ponto.conectado = false
			ponto.scale = Vector2.ONE
			ponto.modulate = Color.WHITE

func tremer_tela(intensidade: float = 8.0, duracao: float = 0.2) -> void:
	if not shake_container:
		return
	var tw = create_tween()
	var passinhos = 6
	var tempo_passo = duracao / float(passinhos)
	for i in range(passinhos):
		var offset_rand = Vector2(randf_range(-intensidade, intensidade), randf_range(-intensidade, intensidade))
		tw.tween_property(shake_container, "position", offset_rand, tempo_passo)
	tw.tween_property(shake_container, "position", Vector2.ZERO, tempo_passo)

func emitir_particulas(pos_global: Vector2, cor: Color, quantidade: int = 24) -> void:
	var particles = CPUParticles2D.new()
	particles.global_position = pos_global
	particles.amount = quantidade
	particles.lifetime = 0.6
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.spread = 180.0
	particles.gravity = Vector2(0, 120)
	particles.initial_velocity_min = 90.0
	particles.initial_velocity_max = 220.0
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 8.0
	particles.color = cor
	particles.emitting = true
	container_particulas.add_child(particles)
	
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	if is_instance_valid(particles):
		particles.queue_free()

func emitir_particulas_erro(pos_global: Vector2) -> void:
	var particles = CPUParticles2D.new()
	particles.global_position = pos_global
	particles.amount = 20
	particles.lifetime = 0.4
	particles.one_shot = true
	particles.explosiveness = 0.95
	particles.spread = 180.0
	particles.gravity = Vector2(0, 300)
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 250.0
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0
	particles.color = Color(0.55, 0.35, 0.12) # Lama / terra encharcada
	particles.emitting = true
	container_particulas.add_child(particles)
	
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	if is_instance_valid(particles):
		particles.queue_free()

func tocar_som(tipo: String) -> void:
	var sample_rate = 22050
	var duration = 0.2
	var frequencies: Array[float] = []
	
	if tipo == "click":
		duration = 0.06
		frequencies = [580.0]
	elif tipo == "connect":
		duration = 0.22
		frequencies = [523.25, 659.25]
	elif tipo == "error":
		duration = 0.25
		frequencies = [164.81, 130.81]
	elif tipo == "victory":
		duration = 0.55
		frequencies = [523.25, 659.25, 784.0, 1046.5]
		
	var num_samples = int(sample_rate * duration)
	var buffer = PackedByteArray()
	buffer.resize(num_samples)
	
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var freq_idx = int(t / (duration / float(frequencies.size())))
		freq_idx = clampi(freq_idx, 0, frequencies.size() - 1)
		var freq = frequencies[freq_idx]
		
		var val = 0.0
		if tipo == "error":
			val = 0.35 if fmod(t * freq, 1.0) > 0.5 else -0.35
		else:
			val = sin(t * freq * TAU) * 0.35
			
		var env = 1.0 - (t / duration)
		val *= env * env
		
		var byte_val = clampi(int((val + 1.0) * 127.5), 0, 255)
		buffer[i] = byte_val
