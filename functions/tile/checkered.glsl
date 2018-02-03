/*
*ドキュメント
float checkeredTile(vec2 v, vec2 div)
	市松模様を返す
	vは座標
	v(x, y)の範囲は(0.0, 0.0), (1.0, 1.0)
	divはx,yの分割数
	戻り値の範囲は0.0, 1.0
*/

#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

float checkeredTile(vec2 v, vec2 div){
	v *= div;
	float req = 1.0;
	req *= 2.0 * (floor((v.x + 1.0) / 2.0) - floor(v.x / 2.0)) - 1.0;
	req *= 2.0 * (floor((v.y + 1.0) / 2.0) - floor(v.y / 2.0)) - 1.0;
	req = (req + 1.0) / 2.0;
	return req;
}

const float freq = 1.0;
void main(void){
	vec2 p = gl_FragCoord.xy / resolution.xy;

	float n = checkeredTile(p, vec2(mouse.x, mouse.y) * 6.0);
	
	gl_FragColor = vec4(vec3(n), 1.0);
}