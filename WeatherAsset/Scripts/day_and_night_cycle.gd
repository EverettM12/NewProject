extends Node3D

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var directional_light_3d: DirectionalLight3D = $DirectionalLight3D
@onready var label: Label = $Label
var current_cycle_time: float = 0.0
@export var cycle_duration_seconds: float = 600.0 # 10 minute day


# =========================================================================
func _ready() -> void:
	_update_light_and_environment_state(0.0)

# =========================================================================
func _process(delta: float) -> void:
	current_cycle_time += delta
	if current_cycle_time >= cycle_duration_seconds:
		current_cycle_time -= cycle_duration_seconds
	
	var normalized_time = current_cycle_time / cycle_duration_seconds
	
	_update_light_and_environment_state(normalized_time)
	_update_time_state(normalized_time)

# =========================================================================
func _update_time_state(normalized_time):
	var total_minutes = int(normalized_time * 24 * 60)
	@warning_ignore("integer_division")
	var hours_24 = total_minutes / 60
	var minutes = total_minutes % 60
	
	var period = ""
	var hours_12 = 0
	
	if hours_24 >= 0 && hours_24 < 12:
		period = "PM"
		if hours_24 == 0:
			hours_12 = 12
		else:
			hours_12 = int(hours_24)
	else:
		period = "AM"
		if hours_24 == 12:
			hours_12 = 12
		else:
			hours_12 = int(hours_24) - 12

	label.text = "Time: %02d:%02d %s" % [hours_12, minutes, period]
# =========================================================================
func _update_light_and_environment_state(t: float) -> void:
	directional_light_3d.rotation_degrees.x = lerp(-90.0, 270.0, t)
	

	
	var day_factor = clamp(sin(t * PI), 0.0, 1.0)
	var shader = world_environment.environment.sky.sky_material as ShaderMaterial


	var day_light : float = 1.0
	var night_light : float = 0.2
	
	directional_light_3d.light_energy = lerp(day_light, night_light, day_factor)
	
	
	
	# Bottom Sky Colors
	var bottom_color: Color = Color(0.2, 0.4, 0.9)
	var bottom_color_night: Color = Color(0.027, 0.102, 0.251)
	var sky_bottom_blend = lerp(bottom_color, bottom_color_night, day_factor)
	
	# Top Sky Colors
	var top_color: Color = Color(0.6, 0.7, 1.0)
	var top_color_night: Color = Color(0.027, 0.102, 0.251)
	var sky_top_blend = lerp(top_color, top_color_night, day_factor)
	
	# Sun Scatter Colors
	var sun_scatter: Color = Color(0.1, 0.0, 0.3)
	var sun_scatter_night: Color = Color(0.125, 0.086, 0.373)
	var sun_scatter_blend = lerp(sun_scatter, sun_scatter_night, day_factor)
	
	
	
	# Sets the sky Color
	shader.set_shader_parameter("bottom_color",sky_bottom_blend)
	shader.set_shader_parameter("top_color",sky_top_blend)
	shader.set_shader_parameter("sun_scatter",sun_scatter_blend)


	# Stars
	var stars_intensity: float = 0.0
	var stars_intensity_night: float = 5.0
	var star_blend = lerp(stars_intensity, stars_intensity_night, day_factor)

	# Sets the Stars Visibility
	shader.set_shader_parameter("stars_intensity",star_blend)


	# --- Shooting Stars ---

	# Intensity blend
	var shooting_stars_intensity: float = 0.0
	var shooting_stars_intensity_night: float = 4.0
	var shooting_stars_blend = lerp(shooting_stars_intensity, shooting_stars_intensity_night, day_factor)

	# Tint blend
	var shooting_star_tint: Color = Color(0, 0, 0)
	var shooting_star_tint_night: Color = Color(1.0, 0.663, 0.42)
	var shooting_star_tint_blend = lerp(shooting_star_tint, shooting_star_tint_night, day_factor)


	# Apply to shader
	shader.set_shader_parameter("shooting_stars_intensity", shooting_stars_blend)
	shader.set_shader_parameter("shooting_star_tint", shooting_star_tint_blend)


	# --- Astro ---


	var astro_tint: Color = Color(1, 1, 1)
	#var astro_sampler: GradientTexture2D
	var astro_scale: float = 6.0
	var astro_intensity: float = 1.2


	var astro_tint_night: Color = Color(1, 1, 1)
	var astro_scale_night: float = 6.0
	var astro_intensity_night: float = 1.2


	var astro_tint_blend = lerp(astro_tint, astro_tint_night, day_factor)

	# Scale blend
	var astro_scale_blend = lerp(astro_scale, astro_scale_night, day_factor)

	# Intensity blend
	var astro_intensity_blend = lerp(astro_intensity, astro_intensity_night, day_factor)

	# Texture selection (same as before, switch based on day factor)
	#var selected_astro_sampler: GradientTexture2D = astro_sampler

	# Apply to shader
	shader.set_shader_parameter("astro_tint", astro_tint_blend)
	shader.set_shader_parameter("astro_scale", astro_scale_blend)
	shader.set_shader_parameter("astro_intensity", astro_intensity_blend)
	#shader.set_shader_parameter("astro_sampler", selected_astro_sampler)



	#var high_clouds_sampler: NoiseTexture2D

	var high_clouds_density: float = 1.0

	var high_clouds_density_night: float = 0.5

	var high_clouds_density_blend = lerp(high_clouds_density, high_clouds_density_night, day_factor)

	# Set the shader parameters
	#shader.set_shader_parameter("high_clouds_sampler", high_clouds_sampler)
	shader.set_shader_parameter("high_clouds_density", high_clouds_density_blend)


	#var cloud_shape_sampler: NoiseTexture2D
	#var cloud_noise_sampler: NoiseTexture2D
	#var cloud_curves: CurveTexture
	
	var clouds_samples: int = 32
	var shadow_sample: int = 4
	var clouds_density: float = 0.5
	var clouds_scale: float = 1.0
	var clouds_smoothness: float = 0.05
	var clouds_light_color: Color = Color(1, 1, 1)
	var clouds_shadow_intensity: float = 8.0

	var clouds_samples_night: int = 32
	var shadow_sample_night: int = 4
	var clouds_density_night: float = 0.4
	var clouds_scale_night: float = 1.0
	var clouds_smoothness_night: float = 0.05
	var clouds_light_color_night: Color = Color(0.227, 0.447, 1.0)
	var clouds_shadow_intensity_night: float = 8.0

	var clouds_samples_blend = lerp(clouds_samples, clouds_samples_night, day_factor)
	var shadow_sample_blend = lerp(shadow_sample, shadow_sample_night, day_factor)
	var clouds_density_blend = lerp(clouds_density, clouds_density_night, day_factor)
	var clouds_scale_blend = lerp(clouds_scale, clouds_scale_night, day_factor)
	var clouds_smoothness_blend = lerp(clouds_smoothness, clouds_smoothness_night, day_factor)
	var clouds_light_color_blend = lerp(clouds_light_color, clouds_light_color_night, day_factor)
	var clouds_shadow_intensity_blend = lerp(clouds_shadow_intensity, clouds_shadow_intensity_night, day_factor)

	shader.set_shader_parameter("clouds_samples", clouds_samples_blend)
	shader.set_shader_parameter("shadow_sample", shadow_sample_blend)
	shader.set_shader_parameter("clouds_density", clouds_density_blend)
	shader.set_shader_parameter("clouds_scale", clouds_scale_blend)
	shader.set_shader_parameter("clouds_smoothness", clouds_smoothness_blend)
	shader.set_shader_parameter("clouds_light_color", clouds_light_color_blend)
	shader.set_shader_parameter("clouds_shadow_intensity", clouds_shadow_intensity_blend)
