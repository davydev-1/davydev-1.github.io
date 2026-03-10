extends Node2D
@export var numBoids:int=100
@export var spawnRadius:int=100000
@export var startingBoidSpeed=200
@export var screenHeight=null
@export var screenWidth=null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screenHeight=(get_viewport_rect().size.y)
	screenWidth=(get_viewport_rect().size.x)
	get_viewport().size_changed.connect(updateScreenSize)
	for i in numBoids:
		var spawnloc = sqrt(randf())*spawnRadius
		var angle = randf()*2*PI
		var pos=Vector2(spawnloc*sin(angle),spawnloc*cos(angle))
		var mobscene = preload("res://mob.tscn")
		var mob = mobscene.instantiate()
		add_child(mob)
		mob.position=pos
		print(pos)
func updateScreenSize():
	screenHeight=(get_viewport_rect().size.y)*10
	screenWidth=(get_viewport_rect().size.x)*10
	$"../Camera2D".position=Vector2(screenWidth/2,screenHeight/2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
var timer=0
var maxtime=0.2
func _process(delta: float) -> void:
	timer+=delta
	if timer>maxtime:
		for mob in get_children():
			mob.getLocalBoids()
			mob.seperate()
			mob.seperate_cursor()
			mob.align()
			mob.steertocentre()
			pass
			
		
