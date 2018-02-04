/*
*ドキュメント
float frame(vec2 v, vec2 w)
	vの(0.0, 0.0), (1.0, 1.0)内側の範囲に枠を描く
	wは線の太さ
*/
 
#ifdef GL_ES
precision mediump float;
#endif
 
#extension GL_OES_standard_derivatives : enable
 
uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

vec3 tile(vec2 uv, vec2 div){
	vec2 req_uv = fract(uv * div); // uvの分割
	float index = // 分割面のインデックス算出
		floor(uv.x * div.x) + 
		floor(uv.y * div.y) * ceil(div.x);
	return vec3(req_uv, index);
}

float frame(vec2 v, vec2 w) {
	return (
		0.0 <= v.x - w.x && v.x + w.x <= 1.0 &&
		0.0 <= v.y - w.y && v.y + w.y <= 1.0
	)?1.0:0.0;
}
 
void main( void ) {
	vec2 p = ( gl_FragCoord.xy / resolution.xy );
	vec2 div = mouse * 10.0;
	
	vec3 req = tile(p, div);
	float f = frame(req.xy, vec2(0.01));
	vec3 col = vec3(f);
	
	gl_FragColor = vec4( col, 1.0 );
}