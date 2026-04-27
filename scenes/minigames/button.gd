extends Button

signal clicado(botao,id_enviado)
@export var id: int = 0

func _pressed():
	clicado.emit(self, id)
