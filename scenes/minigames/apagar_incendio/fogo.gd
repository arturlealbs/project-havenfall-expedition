extends Area2D

signal apagado(fogo)

@export var dano_por_segundo: float = 100.0 # O quão rápido a água reduz a vida do fogo por segundo
var vida_maxima = 100.0
var vida_atual = 100.0
var sofrendo_dano = false

@onready var particles = $CPUParticles2D

func _process(delta):
	if sofrendo_dano:
		vida_atual -= dano_por_segundo * delta
		var proporcao = max(0.1, vida_atual / vida_maxima)
		particles.scale = Vector2(proporcao, proporcao)
		
		if vida_atual <= 0:
			apagado.emit(self)
			queue_free()
	
	# Reseta o dano. A lógica principal ativará no próximo frame se o mouse continuar em cima
	sofrendo_dano = false

func receber_agua():
	sofrendo_dano = true
