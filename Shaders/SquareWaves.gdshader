shader_type spatial;

uniform vec4 mainColor:source_color;
uniform float wave_speed = 1.0;
uniform float wave_frequency = 2.0;
uniform float wave_amplitude = 0.01;

void fragment() {
    // Calculate the distance from the center of the model
    vec2 uv = UV - vec2(0.5);
    vec2 dist = abs(uv);

    // Calculate the wave offset based on time and speed
    float wave_offset = TIME * wave_speed;
	
	float max_distance = max(dist.x, dist.y);

    // Calculate the wave factor
      float wave_factor = sin((max_distance + wave_offset) * wave_frequency) * wave_amplitude;


    // Output the final color
	ALBEDO = mainColor.xyz;
    ALBEDO *= 1.0 - wave_factor;
}
