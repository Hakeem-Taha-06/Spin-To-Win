extends RigidBody2D
class_name Enemy

#reference to global player
var player : Player = null

#in-game stats
var HEALTH := 100.0
var DAMAGE := 10.0

#behaviour/ movement 
@export var DETECT_RANGE := 200.0
@export var ATTACK_RANGE := 100.0
@export var TORQUE := 10000.0
@export var MOVE_FORCE := 100.0
@export var MAX_LINEAR_SPEED := 200.0
@export var MAX_ANGULAR_SPEED := 30.0

#states
enum State{FOLLOW, IDLE, ATTACK}
var CURRENT_STATE := State.IDLE
var facing_direction := Vector2(0.0, 1.0)

#cooldown timers
var out_of_follow_timer := 0.0
var out_of_follow_cooldown := 2.0
var attack_timer := 0.0
var attack_duration := 2.0

@export var debug_line_length := 20.0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var distance_to_player : float = abs((global_position - player.global_position).length())
	match CURRENT_STATE:
		State.IDLE:
			if distance_to_player <= DETECT_RANGE:
				CURRENT_STATE = State.FOLLOW
				out_of_follow_timer = out_of_follow_cooldown
		State.FOLLOW:
			if out_of_follow_timer > 0.0:
				out_of_follow_timer -= delta
				
			if distance_to_player <= ATTACK_RANGE:
				CURRENT_STATE = State.ATTACK
				attack_timer = attack_duration
				
			if out_of_follow_timer <= 0.0:
				CURRENT_STATE = State.IDLE
		State.ATTACK:
			if attack_timer > 0.0:
				attack_timer -= delta
			
			if attack_timer <= 0.0:
				CURRENT_STATE = State.IDLE
			
	print(linear_velocity)

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
		State.ATTACK:
			face_player()
			if linear_velocity.length() < MAX_LINEAR_SPEED:
				apply_force(facing_direction*MOVE_FORCE*2)
			
	queue_redraw()

func apply_damp():
	if linear_velocity.length() > 0.5:
		linear_velocity *= 0.95
	else:
		linear_velocity = Vector2.ZERO

func face_player():
	facing_direction = (player.global_position - global_position).normalized()
	
	
