/*
*ドキュメント

float sigmoid1(float x, float a)
	原点で点対称なシグモイド関数
	xの範囲は-1.0, 1.0
	aはx=0のときの関数の傾き
	戻り値の範囲は-1.0, 1.0

float sigmoid2(float x, float a)
	sigmoid1関数の(x, 戻り値)が(-1.0, -1.0), (1.0, 1.0)を通るように拡大縮小した関数
	xの範囲は-1.0, 1.0
	戻り値の範囲は-1.0, 1.0
	a=0.0のときはxをそのまま返す
*/

#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

float sigmoid1(float x, float a){
	float ex = exp(-2.0 * a * x);
	return (1.0 - ex) / (1.0 + ex);
}

float sigmoid2(float x, float a){
	float d = sigmoid1(1.0, a);
	if (d != 0.0) return sigmoid1(x, a) / d;
	else return x;
}

void main(void){
	vec2 p = gl_FragCoord.xy / resolution;
	float x = (p.x * 2.0) - 1.0;
	float a = mouse.x * 100.0;
	float n = sigmoid1(x, a);
	gl_FragColor = vec4(vec3(n), 1.0);
}