/*
*ドキュメント
float indexTile(vec2 v, vec2 div)
	座標のインデックスをステップ化した値を返す
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

float indexTile(vec2 v, vec2 div){
	if ((div.x + div.y) - 1.0 == 0.0) return 0.0;
	float index = 
		floor(fract(v.x) * div.x) + 
		floor(fract(v.y) * div.y) * div.x;
	index /= (div.x * div.y) - 1.0;
	return index;
}

void main( void ) {
	vec2 p = ( gl_FragCoord.xy / resolution.xy );
	vec2 div = mouse * 10.0;
	
	float i = indexTile(p, div);
		
	vec3 col = vec3(i);
	
	gl_FragColor = vec4( col, 1.0 );

}