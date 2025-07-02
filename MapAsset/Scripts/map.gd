@tool
extends MeshInstance3D

const size := 256.0
@export var static_body: StaticBody3D
@export var collision_shape: CollisionShape3D

@export_range(4, 10000, 4) var resolution := 32:
	set(new_resolution):
		resolution = new_resolution
		update_mesh()

@export var noise: FastNoiseLite:
	set(new_noise):
		if noise and noise.changed.is_connected(update_mesh):
			noise.changed.disconnect(update_mesh)
		noise = new_noise
		update_mesh()
		if noise and not noise.changed.is_connected(update_mesh):
			noise.changed.connect(update_mesh)

@export_range(4.0, 128, 4.0) var height := 64.0:
	set(new_height):
		height = new_height
		update_mesh()

func get_height(x: float, y: float) -> float:
	if noise: # Added a null check for safety
		return noise.get_noise_2d(x, y) * height
	return 0.0 # Return a default if noise is not set

func get_normal(x: float, y: float) -> Vector3:
	if not noise: return Vector3.UP # Return default if noise is not set

	var epsilon := size / resolution
	var normal := Vector3(
		(get_height(x + epsilon, y) - get_height(x - epsilon, y)) / (2.0 * epsilon),
		1.0,
		(get_height(x, y + epsilon) - get_height(x, y - epsilon)) / (2.0 * epsilon),
	)
	return normal.normalized()


func update_mesh():
	var plane := PlaneMesh.new()
	plane.subdivide_depth = resolution
	plane.subdivide_width = resolution
	plane.size = Vector2(size, size)

	var plane_arrays := plane.get_mesh_arrays()
	var vertex_array : PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_VERTEX]
	var normal_array : PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_NORMAL]
	var tangent_array : PackedFloat32Array = plane_arrays[ArrayMesh.ARRAY_TANGENT]

	for i in range(vertex_array.size()):
		var vertex = vertex_array[i]
		var world_x = vertex.x + position.x
		var world_z = vertex.z + position.z

		# Calculate distance from center
		var dist_x = abs(vertex.x) / (size / 2)
		var dist_z = abs(vertex.z) / (size / 2)
		var dist = sqrt(dist_x*dist_x + dist_z*dist_z)

		# Clamp dist between 0 and 1
		dist = clamp(dist, 0.0, 1.0)

		# Create falloff curve, tweak exponent for softness (try 2 or 3)
		var falloff = pow(dist, 3) # Cubic falloff is smooth, feel free to tweak

		var normal := Vector3.UP
		var tangent := Vector3.RIGHT
		if noise:
			var noise_height = get_height(world_x, world_z)
			vertex.y = noise_height * (1.0 - falloff) # Apply falloff here
			normal = get_normal(world_x, world_z) * (1.0 - falloff) + Vector3.UP * falloff # Blend normals somewhat
			normal = normal.normalized()
			tangent = normal.cross(Vector3.UP)
		vertex_array[i] = vertex
		normal_array[i] = normal

		if tangent_array.size() > 4 * i + 2: # Check bounds
			tangent_array[4 * i] = tangent.x
			tangent_array[4 * i + 1] = tangent.y
			tangent_array[4 * i + 2] = tangent.z

	plane_arrays[ArrayMesh.ARRAY_VERTEX] = vertex_array
	plane_arrays[ArrayMesh.ARRAY_NORMAL] = normal_array
	plane_arrays[ArrayMesh.ARRAY_TANGENT] = tangent_array

	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_arrays)
	mesh = array_mesh

	if static_body == null or !is_instance_valid(static_body):
		static_body = get_node_or_null("StaticBody3D")
		if static_body == null:
			static_body = StaticBody3D.new()
			static_body.name = "StaticBody3D"
			add_child(static_body)
			static_body.owner = get_owner() # Important for saving scene

	if collision_shape == null or !is_instance_valid(collision_shape):
		collision_shape = static_body.get_node_or_null("CollisionShape3D")
		if collision_shape == null:
			collision_shape = CollisionShape3D.new()
			collision_shape.name = "CollisionShape3D"
			static_body.add_child(collision_shape)
			collision_shape.owner = get_owner()

	# 3. Create a ConcavePolygonShape3D from the mesh
	var faces = PackedVector3Array()
	var vertices = plane_arrays[ArrayMesh.ARRAY_VERTEX]
	var indices = plane_arrays[ArrayMesh.ARRAY_INDEX]

	for i in range(0, indices.size(), 3):
		faces.append(vertices[indices[i]])
		faces.append(vertices[indices[i + 1]])
		faces.append(vertices[indices[i + 2]])

	var concave_shape := ConcavePolygonShape3D.new()
	concave_shape.set_faces(faces)

	collision_shape.shape = concave_shape


func _ready():
	update_mesh()
