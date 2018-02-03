/*
*ドキュメント
vec2 rotate(vec2 v, vec2 c, float r)
	位置ベクトルの回転をする関数
	v : 位置ベクトル
	c : 回転の中心点
	r : 回転角度(ラジアン)
*/

#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

float indexTile(vec2 v, vec2 div){
	if ((div.x * div.y) - 1.0 == 0.0) return 0.0;
	float index = 
		floor(fract(v.x) * div.x) + 
		floor(fract(v.y) * div.y) * div.x;
	index /= (div.x * div.y) - 1.0;
	return index;
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

const float freq = 1.0;
void main(void){
	vec2 p = gl_FragCoord.xy / resolution.y;

	vec2 pos = rotate(p, vec2(0.5 * resolution.x / resolution.y, 0.5), time);
	
	vec3 col = vec3(indexTile(pos, vec2(2.0, 2.0)));
	gl_FragColor = vec4(col, 1.0);
}