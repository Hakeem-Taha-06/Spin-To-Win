extends RigidBody2D
class_name Player

var LINEAR_SPEED := 300.0 #this is actually just a multiplier that determines the push force
var MAX_LINEAR_SPEED := LINEAR_SPEED #max speed allowed
var ANGULAR_ACCELERATION := 1.0
var MAX_ANGULAR_VELOCITY := 30.0

var TORQUE := 10000.0

var HEALTH := 100.0
var DAMAGE := 10.0 
var WEAPON : Weapon

var isInvincible:= false
var invincibility_timer := 0.0
var invincibility_duration := 2.0

#damage handling
@onready var hurtbox = $HurtBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	angular_velocity = 0.0
	linear_velocity = Vector2(0.0, 0.0)
	LINEAR_SPEED = GameState.player_speed
	MAX_LINEAR_SPEED = LINEAR_SPEED
	add_to_group("player")
	_equip_weapon()
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	handle_linear_velocity()
	handle_torque()
	
func _process(delta: float)->void:
	cooldowns(delta)
	
func handle_torque():
	var r_direction = Input.get_axis("rotate_left", "rotate_right")
	if r_direction:
		if abs(angular_velocity) < MAX_ANGULAR_VELOCITY:
			apply_torque(TORQUE*r_direction)

func handle_linear_velocity():
	var h_direction = Input.get_axis("move_left", "move_right")
	if h_direction and abs(linear_velocity.x) < MAX_LINEAR_SPEED:
		apply_force(h_direction * LINEAR_SPEED * Vector2(1.0, 0.0))
	
	var v_direction = Input.get_axis("move_up", "move_down")
	if v_direction and abs(linear_velocity.y) < MAX_LINEAR_SPEED:
		apply_force(v_direction * LINEAR_SPEED * Vector2(0.0, 1.0))
	
func _equip_weapon():
	var weapon_scene := GameState.get_weapon()
	WEAPON = weapon_scene.instantiate() as Weapon
	if WEAPON == null:
		push_error("Weapon scene does not have a Weapon script attached or doesn't exist")
		return
	add_child(WEAPON)
	WEAPON.position = Vector2(0.0, -10.0)
	
func _on_hurtbox_area_entered(area: Area2D):
	if area.has_method("get_damage"):
		take_damage(area.get_damage())
	
func take_damage(amount: float):
	if !isInvincible:
		invincibility_timer = invincibility_duration
		isInvincible = true
		print("ouch")
	
func cooldowns(delta: float):
	if isInvincible and invincibility_timer > 0:
		invincibility_timer -= delta
	if invincibility_timer <=0:
		isInvincible = false
