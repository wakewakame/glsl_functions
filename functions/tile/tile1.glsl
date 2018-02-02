/*
*ドキュメント
float tile1(vec2 v, vec2 div, float gap)
	木材の床のタイルみたいな区切りの値を返す
	タイルの値はすべて異なる
	vは座標
	v(x, y)の範囲は(0.0, 0.0), (1.0, 1.0)
	divはx,yの分割数
	gapは上下のタイルのx方向のズレ
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
 
float tile1(vec2 v, vec2 div, float gap){
	vec2 p = v;
	p.x += indexTile(p, vec2(1.0, div.y)) * gap * (div.y - 1.0);
	p.x = indexTile(p, div);
	return p.x;
}
 
void main( void ) {
	vec2 p = ( gl_FragCoord.xy / resolution.xy );
	vec2 div = vec2(4.0 * (mouse.y + 0.5), 4.0);
 
	float i = tile1(p, div, mouse.x);

	gl_FragColor = vec4( vec3(i), 1.0 );
}
