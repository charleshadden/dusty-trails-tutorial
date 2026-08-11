extends Node2D

# Node refs
@onready var ground_layer: TileMapLayer = get_parent().get_node_or_null("Ground")
@onready var above_ground_layer: TileMapLayer = get_parent().get_node_or_null("AboveGround")
@onready var spawned_pickups: Node2D = $SpawnedPickups

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	if ground_layer == null:
		push_error("PickupSpawner: Ground layer not found under Main.")
		return

	# Spawn between 5 and 10 pickups.
	var spawn_pickup_amount = rng.randi_range(5, 10)
	spawn_pickups(spawn_pickup_amount)

func is_valid_spawn_location(cell_coords: Vector2i) -> bool:
	# Must be on painted ground cells.
	if ground_layer.get_cell_source_id(cell_coords) == -1:
		return false

	# Avoid placing pickups on above-ground detail tiles.
	if above_ground_layer != null and above_ground_layer.get_cell_source_id(cell_coords) != -1:
		return false

	return true

# Spawn pickup
func spawn_pickups(amount):
	var spawned = 0
	var attempts = 0
	var max_attempts = 1000  # Arbitrary number, adjust as needed
	var used_rect = ground_layer.get_used_rect()

	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		push_warning("PickupSpawner: Ground has no used cells.")
		return

	while spawned < amount and attempts < max_attempts:
		attempts += 1
		var random_position = Vector2i(
			used_rect.position.x + (rng.randi() % used_rect.size.x),
			used_rect.position.y + (rng.randi() % used_rect.size.y)
		)
		if is_valid_spawn_location(random_position):
			var pickup_instance = Global.pickups_scene.instantiate()
			pickup_instance.item = rng.randi() % 3
			pickup_instance.position = ground_layer.map_to_local(random_position)
			spawned_pickups.add_child(pickup_instance)
			spawned += 1