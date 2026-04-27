extends Button

signal buraco_tapado # O manager vai escutar isso

func _ready():
	# Conecta o sinal nativo de clique ao nosso sinal customizado
	pressed.connect(_ao_ser_clicado)

func _ao_ser_clicado():
	buraco_tapado.emit()
	queue_free() # Remove o nó da árvore de forma segura no próximo frame
