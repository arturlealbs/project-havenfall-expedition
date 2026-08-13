extends AnimatableBody3D

## Obstáculo giratório que sobe e desce continuamente.
## O jogador precisa passar pela plataforma enquanto evita ser acertado.

@export var rotation_speed: float = 90.0   ## Graus por segundo de rotação (eixo Y)
@export var bob_height: float = 1.2        ## Amplitude do movimento vertical
@export var bob_speed: float = 1.2         ## Velocidade do vai-e-vem vertical

var _time: float = 0.0
var _angle: float = 0.0     ## Ângulo acumulado em radianos
var _origin: Vector3

func _ready() -> void:
	_origin = position

func _physics_process(delta: float) -> void:
	_time  += delta
	_angle += deg_to_rad(rotation_speed) * delta

	# Posição vertical (bobbing)
	var bob_y: float = sin(_time * bob_speed * TAU) * bob_height
	var new_pos := _origin + Vector3(0.0, bob_y, 0.0)

	# Rotação em torno do eixo Y
	var new_basis := Basis(Vector3.UP, _angle)

	# Atribui o transform de uma vez para que rotação E posição funcionem juntas
	transform = Transform3D(new_basis, new_pos)
