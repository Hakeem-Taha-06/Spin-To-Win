extends RigidBody2D
class_name Player

var LINEAR_SPEED := 300.0
var ANGULAR_ACCELERATION := 1.0
var MAX_ANGULAR_VELOCITY := 30.0

var TORQUE := 10000.0

var HEALTH := 100.0
var DAMAGE := 10.0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	angular_velocity = 0.0
	linear_velocity = Vector2(0.0, 0.0)
	add_to_group("player")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	handle_linear_velocity()
	handle_torque()
	
func _process(delta: float)->void:
	#print(angular_velocity)
	pass
	
func handle_torque():
	var r_direction = Input.get_axis("rotate_left", "rotate_right")
	if r_direction:
		if abs(angular_velocity) < MAX_ANGULAR_VELOCITY:
			apply_torque(TORQUE*r_direction)

func handle_linear_velocity():
	var h_direction = Input.get_axis("move_left", "move_right")
	if h_direction:
		linear_velocity.x = h_direction * LINEAR_SPEED
	else:
		linear_velocity.x = move_toward(linear_velocity.x, 0, LINEAR_SPEED)
	
	var v_direction = Input.get_axis("move_up", "move_down")
	if v_direction:
		linear_velocity.y = move_toward(0, v_direction*LINEAR_SPEED, LINEAR_SPEED)
	else:
		linear_velocity.y = move_toward(linear_velocity.y, 0, LINEAR_SPEED)
