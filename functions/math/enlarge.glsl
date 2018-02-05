/*
float enlarge1(float x, vec2 a, vec2 b)
	座標の拡大縮小、移動関数
	x : 変換する値
	a.x : 変換前の座標空間の最小値
	a.y : 変換前の座標空間の最大値
	b.x : 変換後の座標空間の最小値
	b.y : 変換後の座標空間の最大値
	最小値、最大値ではなく、任意の2つの点でもよい

float enlarge2(float x, vec2 a)
	enlarge1のラッパー関数
	clamp(enlarge1(x, a, vec2(0.0, 1.0)), 0.0, 1.0)を返す
	(例)
		(0.5 <= x <= 0.7)->(0.0 <= x <= 1.0)
		のように変換したいとき
		x = enlarge2(x, vec2(0.5, 0.7))
		と使用する
*/

#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

float enlarge1(float x, vec2 a, vec2 b){
	return (x - a.x) * ((b.y - b.x)/(a.y - a.x)) + b.x;
}

float enlarge2(float x, vec2 a){
	return clamp(enlarge1(x, a, vec2(0.0, 1.0)), 0.0, 1.0);
}

void main(void){
	vec2 p = gl_FragCoord.xy / resolution;
	float n = enlarge1(p.x, vec2(0.0, 1.0), vec2(1.0, 0.0));
	gl_FragColor = vec4(vec3(n), 1.0);
}