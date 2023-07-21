shader_type spatial;

// All hail fucking ChatGPT
uniform vec4 mainColor:source_color;
uniform float wave_speed = 1.0;
uniform float wave_frequency = 4.5;
uniform float wave_amplitude = 0.4;

void fragment() {
    // Calculate the distance from the center of the model
    float dist = 1.0 - distance(UV, vec2(0.5));

    // Calculate the wave offset based on time and speed
    float wave_offset = TIME * wave_speed;

    // Calculate the wave factor
    float wave_factor = sin((dist + wave_offset) * wave_frequency) * wave_amplitude;

    // Darken the color of the model using the wave factor
	ALBEDO = mainColor.xyz;
    ALBEDO *= 1.0 - wave_factor;

}
