### Main.gd

extends Node2D

# Node refs
@onready var map = $Ground
@onready var spawned_pickups = $SpawnedPickups


var rng = RandomNumberGenerator.new()

func _ready():
	# Spawn between 5 and 10 pickups
	var spawn_pickup_amount = rng.randf_range(5, 10)
	spawn_pickups(spawn_pickup_amount)  

# --------------------------------------- Pickup spawning ----------------------------------

# Spawn pickup
func spawn_pickups(amount):
	var spawned = 0
	var attempts = 0
	var max_attempts = 1000  # Arbitrary number, adjust as needed

	while spawned < amount and attempts < max_attempts:
		attempts += 1
		var random_position = Vector2(randi() % map.get_used_rect().size.x, randi() % map.get_used_rect().size.y)
		var layer = randi() % 2  
		
		var pickup_instance = Global.pickups_scene.instantiate()
		pickup_instance.item = Global.Pickups.values()[randi() % 3]
		pickup_instance.position = map.map_to_local(random_position)
		spawned_pickups.add_child(pickup_instance)
		spawned += 1
