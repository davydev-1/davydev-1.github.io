extends Sprite2D

# --- MOVEMENT PHYSICS ---
@export_group("Movement Physics")
@export var friction: float = 0.7        # Higher = feels 'heavy'/less responsive
@export var minVelocity: float = 00.0  # Prevents boids from stopping completely
@export var maxVelocity: float = 10000.0 # Caps speed to prevent 'teleporting'
@export var wallBounce: float = 1     # Energy retained after hitting a wall
@export var thrustPower:float = 80
@export var jitter:float=1000
@export var screenPadding:float = 700 

# --- FLOCKING RULES ---
@export_group("Flocking Rules")
@export var detectionRadius: float = 300.0 # How far a boid can see neighbors
@export var seperationRadius: float = 100.0 # Personal space bubble
@export var alignmentfactor: float = 0.1  # How strongly boids mimic neighbors' direction
@export var cohesion: float = 29 # How strongly boids are pulled to group center
		

# --- INTERACTION ---
@export_group("Interaction")
@export var mouseRadius: float = 1000.0   # Radius for cursor avoidance

var velocity: Vector2 = Vector2.ZERO
var localBoids: Array = []
var timer: float = 0.0
var maxtime: float = 0.1 

func _ready() -> void:
	velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * minVelocity

# --- LOGIC FUNCTIONS ---
func getLocalBoids(): 
	localBoids.clear()
	for mob in $"..".get_children():
		if mob != self and mob.position.distance_to(position) < detectionRadius:
			localBoids.append(mob)

func seperate():
	var correction = Vector2.ZERO
	for boid in localBoids:
		var distance_vec = position - boid.position
		var length_sq = distance_vec.length_squared()
		if length_sq < pow(seperationRadius, 2) and length_sq > 0:
			correction += distance_vec.normalized() * (1000.0 / sqrt(length_sq))
	velocity += correction * 100

func seperate_cursor():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mousepos = get_global_mouse_position()
		var distance_vec = position - mousepos
		var length_sq = distance_vec.length_squared()
		if length_sq < pow(mouseRadius, 2) and length_sq > 0:
			var correction = distance_vec.normalized() * (10000.0 / sqrt(length_sq))
			velocity += correction * 1000

func align():
	if localBoids.size() == 0: return
	var aimdirection = Vector2.ZERO
	for boid in localBoids:
		aimdirection += boid.velocity
	var target_vel = aimdirection.normalized() * velocity.length()
	velocity = velocity.lerp(target_vel, alignmentfactor)

func steertocentre():
	if localBoids.size() == 0: return
	var relativecentreofmass = Vector2.ZERO
	for boid in localBoids:
		relativecentreofmass += boid.position - position
	relativecentreofmass /= localBoids.size()
	
	if velocity.length() > 0.1:
		var target_pos = position + velocity.lerp(relativecentreofmass, cohesion)
		look_at(target_pos)

func _process(delta: float) -> void:
	velocity -= velocity * (delta / friction)
	
	if velocity.length() > 0.1:
		velocity = velocity.normalized() * clamp(velocity.length(), minVelocity, maxVelocity)
		look_at(position + velocity)
	var thrust=global_transform.x*thrustPower
	velocity+=thrust*randf_range(0.6,1)
	position += velocity * delta

	
	# Boundary logic
	# --- Boundary Repulsion ---
	var screenWidth = $"..".screenWidth
	var screenHeight = $"..".screenHeight
	var repelForce = 3 # Strength of the push-back

	# Left wall
	if position.x < screenPadding:
		var penetration = screenPadding - position.x
		velocity.x += pow(penetration,1.5) * repelForce * delta

	# Right wall
	elif position.x > screenWidth - screenPadding:
		var penetration = position.x - (screenWidth - screenPadding)
		velocity.x -= pow(penetration,1.5) * repelForce * delta

	# Top wall
	if position.y < screenPadding:
		var penetration = screenPadding - position.y
		velocity.y += pow(penetration,1.5) * repelForce * delta+thrustPower/2

	# Bottom wall
	elif position.y > screenHeight - screenPadding:
		var penetration = position.y - (screenHeight - screenPadding)
		velocity.y -= pow(penetration,1.5) * repelForce * delta+thrustPower/2
			
		timer += delta
		if timer > maxtime:
			
			velocity+=Vector2(randf()-0.5,randf()-0.5)*jitter
			timer = 0
			getLocalBoids()
