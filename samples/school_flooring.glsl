#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

const float PI = 3.14159265;

float checkeredTile(vec2 v, vec2 div){
	v *= div;
	float req = 1.0;
	req *= 2.0 * (floor((v.x + 1.0) / 2.0) - floor(v.x / 2.0)) - 1.0;
	req *= 2.0 * (floor((v.y + 1.0) / 2.0) - floor(v.y / 2.0)) - 1.0;
	req = (req + 1.0) / 2.0;
	return req;
}

vec2 rotate(vec2 v, vec2 c, float r){
	v -= c;
	v = vec2(
		cos(r) * v.x - sin(r) * v.y,
		sin(r) * v.x + cos(r) * v.y
	);
	v += c;
	return v;
}

vec2 pic(vec2 v){
	return fract(vec2(1.0, 4.0) * v);
}

const float freq = 1.0;
void main(void){
	vec2 p = gl_FragCoord.xy / resolution.y;
	vec2 div1 = vec2(2.0, 2.0);
	vec2 div2 = vec2(1.0, 4.0);
	
	float n = checkeredTile(p, div1);
	vec2 pos = p;
	pos = fract(pos * div1);
	pos = rotate(pos, vec2(0.5), 0.5 * n * PI);
	pos = fract(pos * div2);
	
	vec3 col = vec3(pos.x, 0.0, pos.y);
	gl_FragColor = vec4(col, 1.0);
}