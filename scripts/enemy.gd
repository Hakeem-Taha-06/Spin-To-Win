extends RigidBody2D
class_name Enemy

#reference to global player
var player : Player = null

#in-game stats
var HEALTH := 100.0
var DAMAGE := 10.0

#behaviour/ movement 
@export var DETECT_RANGE := 400.0
@export var ATTACK_RANGE := 100.0
@export var ATTACK_FORCE_MULT := 3.0
@export var TORQUE := 10000.0
@export var MOVE_FORCE := 100.0
@export var MAX_LINEAR_SPEED := 200.0
@export var MAX_ATTACK_LINEAR_SPEED := 400
@export var MAX_ANGULAR_SPEED := 30.0

#states
enum State{FOLLOW, IDLE, ATTACK}
var CURRENT_STATE := State.IDLE
var facing_direction := Vector2(0.0, 1.0)
var isInvincible:= false

#cooldown timers
var out_of_follow_timer := 0.0
var out_of_follow_cooldown := 2.0
var attack_timer := 0.0
var attack_duration := 2.0
var invincibility_timer := 0.0
var invincibility_duration := 0.25

#debug
@export var debug_line_length := 20.0

#damage handling
@onready var hurtbox = $HurtBox
var WEAPON : Weapon


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	_equip_weapon()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var distance_to_player : float = abs((global_position - player.global_position).length())
	match CURRENT_STATE:
		State.IDLE:
			if distance_to_player <= DETECT_RANGE:
				CURRENT_STATE = State.FOLLOW
				out_of_follow_timer = out_of_follow_cooldown
				print("set out of follow timer")
		State.FOLLOW:
			if out_of_follow_timer > 0.0:
				out_of_follow_timer -= delta
				
			if distance_to_player <= ATTACK_RANGE:
				CURRENT_STATE = State.ATTACK
				attack_timer = attack_duration
				print("set attack timer")
				
				
			if distance_to_player <= DETECT_RANGE:
				out_of_follow_timer = out_of_follow_cooldown
				
			if out_of_follow_timer <= 0.0:
				CURRENT_STATE = State.IDLE
		State.ATTACK:
			if attack_timer > 0.0:
				attack_timer -= delta
			
			if attack_timer <= 0.0:
				CURRENT_STATE = State.IDLE
				
	cooldowns(delta)


func _draw() -> void:
	#debug line showing facing direction
	var local_facing = facing_direction.rotated(-rotation)
	draw_line(Vector2.ZERO, local_facing * debug_line_length, Color.RED, 2.0)
	#debug circle showing detection range
	draw_circle(Vector2.ZERO, DETECT_RANGE, Color.BLUE, false, 2.0)
	draw_circle(Vector2.ZERO, ATTACK_RANGE, Color.RED, false, 2.0)


func _physics_process(delta: float) -> void:
	match CURRENT_STATE:
		State.IDLE:
			apply_damp()
		State.FOLLOW:
			face_player()
			if linear_velocity.length() < MAX_LINEAR_SPEED:
				apply_force(facing_direction*MOVE_FORCE)
			else:
				linear_velocity = linear_velocity.normalized()*MAX_LINEAR_SPEED
		State.ATTACK:
			face_player()
			if linear_velocity.length() < MAX_ATTACK_LINEAR_SPEED:
				apply_force(facing_direction*MOVE_FORCE*ATTACK_FORCE_MULT)
			
	queue_redraw()


func cooldowns(delta: float):
	if isInvincible and invincibility_timer > 0:
		invincibility_timer -= delta
	if invincibility_timer <=0:
		isInvincible = false
		

func _on_hurtbox_area_entered(area: Area2D):
	if area.has_method("get_damage") and player.has_method("get_damage"):
		var total_damage: float = area.get_damage() + player.get_damage() 
		take_damage(total_damage, area)
		
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
		pass
		#trigger_death()
		
#helper methods
func apply_damp():
	if linear_velocity.length() > 0.5:
		linear_velocity *= 0.95
	else:
		linear_velocity = Vector2.ZERO

func face_player():
	facing_direction = (player.global_position - global_position).normalized()
	
func trigger_death():
	#wait a little bit, disable collision, play some effects etc...
	queue_free()
	
func _equip_weapon():
	var weapon_type = GameState.weapon_list.pick_random()
	WEAPON = GameState.get_weapon(weapon_type, "enemy").instantiate() as Weapon
	if WEAPON == null:
		push_error("Weapon scene does not have a Weapon script attached or doesn't exist")
		return
	
	add_child(WEAPON)
	WEAPON.position = Vector2(0.0,-10.0)
	$Sprite2D.move_to_front()
