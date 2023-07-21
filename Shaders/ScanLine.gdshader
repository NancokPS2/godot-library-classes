shader_type spatial;
render_mode unshaded;

uniform float lineSeparation=0.1;
uniform float lineWidth=0.1;
uniform float alphaMult=1.0;
uniform float lineSpeedMult=3.0;

uniform vec3 color=vec3(0.5,1.0,0.0);

void fragment() {
	ALBEDO = color;
	float miliseconds = fract(TIME)*lineSpeedMult;
	vec2 targetUV = vec2(UV.x, -1.0 + (2.0 * miliseconds) );
//
	float distanceToTarget = distance(UV,targetUV);
	distanceToTarget = distanceToTarget / lineWidth;
//
	ALPHA = 1.0 - distanceToTarget;
	
	
	
//	if (UV.y <  miliseconds + lineWidth && UV.y > miliseconds - lineWidth ){
//		ALPHA = 0.9;
//	}else{
//		ALPHA = 0.0;
//	};
	
}
