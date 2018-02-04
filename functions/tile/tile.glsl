/*
*ドキュメント
vec3 tile(vec2 uv, vec2 div)
	uvを分割する関数
	uv : 分割するuv
	div : uvを(0.0, 0.0), (1.0, 1.0)の範囲で(div.x, div.y)分割する
	戻り値をreqとする。
	req.xy : 分割されたuv
	req.z : 分割面のインデックス (0.0<=req.z<=div.x*div.y-1.0)
float tileSize(vec2 div)
	tile関数の分割数
	(ceil(div.x) * ceil(div.y))を返す
	1未満の場合は1を返す
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

float tileSize(vec2 div){
	if (ceil(div.x) * ceil(div.y) < 1.0) return 1.0;
	return ceil(div.x) * ceil(div.y);
}

void main( void ) {
	vec2 p = ( gl_FragCoord.xy / resolution.xy );
	vec2 div = mouse * 10.0;
	
	vec3 req = tile(p, div);
	vec3 col = vec3(req.x, 0.0, req.y);
	col *= req.z / (tileSize(div) - 1.0);
	
	gl_FragColor = vec4( col, 1.0 );
}