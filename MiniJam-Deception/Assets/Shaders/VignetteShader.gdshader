shader_type canvas_item;
uniform vec2 player_position;
uniform vec4 color : source_color = vec4(0.305, 0.298, 0.341,1);

uniform float multiplier = 2;
uniform float scale = 1.5;
uniform float softness = 1.8;


float circle(vec2 position, float radius, float feather)
{
	return smoothstep(radius, radius + feather, dot(position, position ) * 8.0);
}

float vigTypeB(vec2 dude){
	float vignette = circle(dude - vec2(player_position.x,player_position.y ), 0.1, 0.5);
	return vignette;
}

float vigTypeA(vec2 dude){
	float val = distance(vec2(dude.x , dude.y * multiplier), vec2(player_position.x , player_position.y * multiplier));
	val = val / scale;
	float vignette = smoothstep(0.2, softness, val);
	return vignette;
}

void fragment(){
	COLOR = vec4(color.rgb , vigTypeA(UV));
}