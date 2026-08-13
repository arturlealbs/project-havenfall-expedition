extends AnimatableBody3D

## Plataforma com parte central deslizante.
## A parte central se move de um lado ao outro (eixo X) continuamente.

@export var move_distance: float = 4.0   ## Distância máxima do centro para cada lado
@export var move_speed: float = 1.5       ## Velocidade do movimento (ciclos por segundo)

var _time: float = 0.0
var _origin: Vector3

func _ready() -> void:
	_origin = position

func _physics_process(delta: float) -> void:
	_time += delta
	var offset = sin(_time * move_speed * TAU) * move_distance
	position = _origin + Vector3(offset, 0.0, 0.0)
