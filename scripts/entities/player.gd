extends RigidBody2D
class_name Player

var LINEAR_SPEED := 300.0 #this is actually just a multiplier that determines the push force
var MAX_LINEAR_SPEED := LINEAR_SPEED #max speed allowed
var ANGULAR_ACCELERATION := 1.0
var MAX_ANGULAR_VELOCITY := 30.0
var BRAKE_MULTIPLIER := 2.0
var BRAKE_OFFSET := 5.0

var TORQUE := 10000.0

var HEALTH := 200.0
var DAMAGE := 10.0 
var WEAPON : Weapon

var isInvincible:= false
var invincibility_timer := 0.0
var invincibility_duration := 1.0

@onready var move_effects: GPUParticles2D = $MoveEffects
@onready var brake_effect: GPUParticles2D = $BrakeEffect
@onready var health_bar_pivot: Node2D = $HealthBarPivot
@onready var health_bar: ProgressBar = $HealthBarPivot/HealthBar

#damage handling
@onready var hurtbox = $HurtBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	angular_velocity = 0.0
	linear_velocity = Vector2(0.0, 0.0)
	LINEAR_SPEED = GameState.player_speed
	HEALTH = GameState.player_health
	DAMAGE = GameState.player_damage
	MAX_LINEAR_SPEED = LINEAR_SPEED
	add_to_group("player")
	_equip_weapon()
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	brake_effect.finished.connect(_on_brake_effect_finished)
	health_bar.min_value = 0.0
	health_bar.max_value = HEALTH
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	handle_linear_velocity()
	handle_torque()
	
func _process(delta: float)->void:
	health_bar_pivot.rotation = (-rotation)
	health_bar.value = HEALTH
	cooldowns(delta)

func handle_torque():
	var input := Input.get_axis("rotate_left", "rotate_right")
	if input != 0.0:
		var r_dot = sign(input) * sign(angular_velocity)
		var r_multiplier = BRAKE_MULTIPLIER if r_dot < 0 else 1.0
		if abs(angular_velocity) < MAX_ANGULAR_VELOCITY:
			apply_torque(TORQUE*input*r_multiplier)

#func handle_linear_velocity():
	#var h_direction = Input.get_axis("move_left", "move_right")
	#if h_direction and abs(linear_velocity.x) < MAX_LINEAR_SPEED:
		#apply_force(h_direction * LINEAR_SPEED * Vector2(1.0, 0.0))
	#
	#var v_direction = Input.get_axis("move_up", "move_down")
	#if v_direction and abs(linear_velocity.y) < MAX_LINEAR_SPEED:
		#apply_force(v_direction * LINEAR_SPEED * Vector2(0.0, 1.0))
		
func handle_linear_velocity():
	var input := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	var brake_offset := Vector2.ZERO
	
	if input != Vector2.ZERO:
		move_effects.emitting = true
		move_effects.rotation = (-input).angle()
	else: 
		move_effects.emitting = false
	
	if input.x != 0.0:
		var h_dot = sign(input.x) * sign(linear_velocity.x)
		var h_multiplier = BRAKE_MULTIPLIER if h_dot < 0 else 1.0
		if abs(linear_velocity.x) < MAX_LINEAR_SPEED:
			apply_force(Vector2(input.x * LINEAR_SPEED * h_multiplier, 0.0))
		if h_dot < 0:
			brake_offset.x = sign(linear_velocity.x) * BRAKE_OFFSET
			brake_effect.emitting = true
		else:
			brake_effect.emitting = false

	if input.y != 0.0:
		var v_dot = sign(input.y) * sign(linear_velocity.y)
		var v_multiplier = BRAKE_MULTIPLIER if v_dot < 0 else 1.0
		if abs(linear_velocity.y) < MAX_LINEAR_SPEED:
			apply_force(Vector2(0.0, input.y * LINEAR_SPEED * v_multiplier))
		if v_dot < 0:
			brake_offset.y = sign(linear_velocity.y) * BRAKE_OFFSET
			brake_effect.emitting = true
		else:
			brake_effect.emitting = false
			
	brake_effect.position = brake_offset
	brake_effect.rotation = (-input).angle()
	
	linear_velocity.x = clamp(linear_velocity.x, -MAX_LINEAR_SPEED, MAX_LINEAR_SPEED)
	linear_velocity.y = clamp(linear_velocity.y, -MAX_LINEAR_SPEED, MAX_LINEAR_SPEED)
	
	#only damp if there is no input
	if input == Vector2.ZERO:
		apply_damp()
	
func _equip_weapon():
	WEAPON = GameState.get_weapon(GameState.player_weapon, "player").instantiate() as Weapon
	if WEAPON == null:
		push_error("Weapon scene does not have a Weapon script attached or doesn't exist")
		return
	add_child(WEAPON)
	WEAPON.position = Vector2(0.0, -10.0)
	$Sprite2D.move_to_front()
	
func _on_hurtbox_area_entered(area: Area2D):
	if area.has_method("get_damage"):
		take_damage(area.get_damage(), area)
	
func _on_brake_effect_finished():
	brake_effect.emitting = false
	
func take_damage(amount: float, area: Area2D):
	if isInvincible:
		return
	
	invincibility_timer = invincibility_duration
	isInvincible = true
	
	#slowdown effect
	Engine.time_scale = 0.2
	get_tree().create_timer(0.2, true, false, true).timeout.connect(
		func(): Engine.time_scale = 1.0
	)
	
	var knockback_dir = (global_position - area.global_position).normalized()
	#                       direction   *    knockback force magnitude
	var knockback_force = knockback_dir * area.get_parent().get_knockback()
	
	apply_impulse(knockback_force)
	
	# angular knockback (had to rely on ai for this one)
	# offset = vector from enemy center to hit point (weapon position in local space)
	var hit_offset = area.global_position - global_position
	# 2D cross product: positive = clockwise spin, negative = counter-clockwise
	var torque_direction = hit_offset.cross(-knockback_dir)
	apply_torque_impulse(torque_direction * area.get_parent().KNOCKBACK)
	
	HEALTH -= amount
	if HEALTH <= 0:
		trigger_death()
	
func trigger_death():
	get_parent().add_score()
	GameState.game_over()

func cooldowns(delta: float):
	if isInvincible and invincibility_timer > 0:
		invincibility_timer -= delta
	if invincibility_timer <=0:
		isInvincible = false
		
func apply_damp():
	if linear_velocity.length() > 0.5:
		linear_velocity *= 0.95
	else:
		linear_velocity = Vector2.ZERO

func get_damage() -> float:
	return DAMAGE
