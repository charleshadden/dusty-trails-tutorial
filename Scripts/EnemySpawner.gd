extends Node2D

# Node refs
@onready var spawned_enemies: Node2D = $SpawnedEnemies
@onready var spawn_timer: Timer = $Timer
@onready var ground_layer: TileMapLayer = get_parent().get_node_or_null("Ground")
@onready var above_ground_layer: TileMapLayer = get_parent().get_node_or_null("AboveGround")

# Enemy stats
@export var max_enemies := 20
var enemy_count := 0
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	if ground_layer == null:
		push_error("EnemySpawner: Ground layer not found under Main.")
		set_process(false)
		return
	if spawn_timer.is_stopped():
		spawn_timer.start()

# --------------------------------- Spawning -------------------------------------
func spawn_enemy():
	var attempts = 0
	var max_attempts = 100  # Maximum number of attempts to find a valid spawn location
	var spawned = false
	var used_rect = ground_layer.get_used_rect()

	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		print("Warning: Ground has no painted cells for enemy spawn.")
		return

	while not spawned and attempts < max_attempts:
		# Randomly select a position on the map
		var random_position = Vector2i(
			used_rect.position.x + (rng.randi() % used_rect.size.x),
			used_rect.position.y + (rng.randi() % used_rect.size.y)
		)
		# Check if the position is a valid spawn location
		if is_valid_spawn_location(random_position):
			var enemy = Global.enemy_scene.instantiate()
			enemy.position = ground_layer.map_to_local(random_position)
			spawned_enemies.add_child(enemy)
			if enemy.has_signal("death"):
				enemy.death.connect(_on_enemy_death)
			enemy_count += 1
			spawned = true
		else:
			attempts += 1
	if attempts == max_attempts:
		print("Warning: Could not find a valid spawn location after", max_attempts, "attempts.")

# Valid spawn location
func is_valid_spawn_location(cell_coords: Vector2i) -> bool:
	# Must be on walkable ground.
	if ground_layer.get_cell_source_id(cell_coords) == -1:
		return false
	# Avoid cells occupied in above-ground details layer.
	if above_ground_layer != null and above_ground_layer.get_cell_source_id(cell_coords) != -1:
		return false
	return true

# Spawn enemy
func _on_timer_timeout():
	if enemy_count < max_enemies:
		spawn_enemy()

# Remove enemy
func _on_enemy_death():
	enemy_count = max(enemy_count - 1, 0)
