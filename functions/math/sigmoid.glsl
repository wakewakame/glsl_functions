/*
*ドキュメント

float sigmoid(float x, float a)
	シグモイド関数
	xの範囲は-1.0, 1.0
	aはx=0のときの関数の傾き
	戻り値の範囲は0.0, 1.0
*/

#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

float sigmoid(float x, float a){
	return 1.0 / (1.0 + exp(-4.0 * a * x));
}

void main(void){
	vec2 p = gl_FragCoord.xy / resolution;
	float x = (p.x * 2.0) - 1.0;
	float a = mouse.x * 100.0;
	float n = sigmoid(x, a);
	gl_FragColor = vec4(vec3(n), 1.0);
}