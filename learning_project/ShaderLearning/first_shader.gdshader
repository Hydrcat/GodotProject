shader_type canvas_item;
uniform float blue;


float plot(vec2 st){
	return smoothstep(0.02,0.0,abs(sin((st.x+TIME)*2.0)*0.5-st.y+0.5));
}

void fragment() {
	float y = UV.x;
	vec3 color = vec3(y);
	
	float pct = plot(UV);
	color = (1.0-pct)*color + pct*vec3(1.0,0.0,0.0);
//	color = color - pct* (vec3(1.0,0.0,0.0)-color);
	COLOR = vec4(color,1.0);
}


