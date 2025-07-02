shader_type spatial;

uniform float height = 64.0;
uniform int layer_count = 4;

uniform vec4 color0 : source_color;
uniform vec4 color1 : source_color;
uniform vec4 color2 : source_color;
uniform vec4 color3 : source_color;

void fragment() {
    vec4 world_vertex = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
    vec3 model_vertex = (inverse(MODEL_MATRIX) * world_vertex).xyz;
    float gradient_uv = clamp((model_vertex.y / height) + 0.5, 0.0, 1.0);

    float layer_pos = gradient_uv * float(layer_count - 1);
    int layer0 = int(floor(layer_pos));
    int layer1 = min(layer0 + 1, layer_count - 1);
    float blend_factor = fract(layer_pos);

    vec3 col0;
    vec3 col1;

    if (layer0 == 0) col0 = color0.rgb;
    else if (layer0 == 1) col0 = color1.rgb;
    else if (layer0 == 2) col0 = color2.rgb;
    else col0 = color3.rgb;

    if (layer1 == 0) col1 = color0.rgb;
    else if (layer1 == 1) col1 = color1.rgb;
    else if (layer1 == 2) col1 = color2.rgb;
    else col1 = color3.rgb;

    ALBEDO = mix(col0, col1, blend_factor);

    NORMAL = NORMAL;
}
