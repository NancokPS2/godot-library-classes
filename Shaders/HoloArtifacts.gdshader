shader_type spatial;

render_mode blend_sub;
	
uniform float lineSpacing:hint_range(0.00001,0.1,0.001)=0.1;
uniform float lineSpeedMult:hint_range(0.01,2.0,0.1) = 0.6;
uniform float alphaMult:hint_range(0.01,10.0,0.01)=0.2;

void fragment() {
	float miliseconds = fract(TIME)*lineSpeedMult;
	
	ALPHA = mod(UV.y+miliseconds, lineSpacing) * alphaMult;
	
}
