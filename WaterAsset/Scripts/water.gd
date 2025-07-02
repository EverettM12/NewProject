extends Node3D
class_name Water

@export var material: ShaderMaterial

var wave_a_img: Image
var wave_b_img: Image
var wave_a_size: Vector2i
var wave_b_size: Vector2i

func _ready():
	var wave_a_tex := material.get_shader_parameter("wave_a") as Texture2D
	var wave_b_tex := material.get_shader_parameter("wave_b") as Texture2D

	wave_a_img = wave_a_tex.get_image()
	wave_b_img = wave_b_tex.get_image()

	wave_a_size = Vector2i(wave_a_img.get_width(), wave_a_img.get_height())
	wave_b_size = Vector2i(wave_b_img.get_width(), wave_b_img.get_height())


# ----- public API -----
func get_height_at(world_x: float, world_z: float, time: float = Time.get_ticks_msec() / 1000.0) -> float:
	var height = _sample_wave_pair(world_x, world_z, time)
	var wave_height_scale = material.get_shader_parameter("wave_height_scale")
	return global_transform.origin.y + height * wave_height_scale

func get_normal_at(world_x: float, world_z: float, time: float = Time.get_ticks_msec() / 1000.0) -> Vector3:
	# Central differences (same epsilon as shader)
	var eps := 0.01
	var h_l = _sample_wave_pair(world_x - eps, world_z, time)
	var h_r = _sample_wave_pair(world_x + eps, world_z, time)
	var h_d = _sample_wave_pair(world_x, world_z - eps, time)
	var h_u = _sample_wave_pair(world_x, world_z + eps, time)

	var slope_x = (h_l - h_r) * 0.5
	var slope_z = (h_d - h_u) * 0.5
	return Vector3(slope_x, 1.0, slope_z).normalized()

# ----- internal helpers -----
func _sample_wave_pair(x: float, z: float, time: float) -> float:
	# Fetch all the uniforms we need (once per call is fine at floater rates)
	var scale_a      = material.get_shader_parameter("wave_noise_scale_a")
	var scale_b      = material.get_shader_parameter("wave_noise_scale_b")
	var dir_a: Vector2 = material.get_shader_parameter("wave_move_direction_a")
	var dir_b: Vector2 = material.get_shader_parameter("wave_move_direction_b")
	var tscale_a     = material.get_shader_parameter("wave_time_scale_a")
	var tscale_b     = material.get_shader_parameter("wave_time_scale_b")

	# World->UV translation (same as shader)
	var uv_a = Vector2(x, z) / scale_a + dir_a * time * tscale_a
	var uv_b = Vector2(x, z) / scale_b + dir_b * time * tscale_b

	var h1 = _sample_green_channel(wave_a_img, wave_a_size, uv_a)
	var h2 = _sample_green_channel(wave_b_img, wave_b_size, uv_b)
	return (h1 + h2) * 0.5          # shader averages them

func _sample_green_channel(img: Image, size: Vector2i, uv: Vector2) -> float:
	# Shader uses repeat() addressing, so wrap with fract()
	var wrapped = Vector2(fract(uv.x), fract(uv.y))
	var px = Vector2i(int(wrapped.x * size.x) % size.x,
					  int(wrapped.y * size.y) % size.y)
	return img.get_pixel(px.x, px.y).g        # .g == .y channel
func fract(x: float) -> float:
	return x - floor(x)
