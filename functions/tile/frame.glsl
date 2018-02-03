/*
*ドキュメント
float frame(vec2 v, vec2 div, float gap, float delta)
	tile1の区切り目を返す
	引数1,2,3はtile1の引数と同じ
	deltaには線の太さを指定する
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
 
float tile1(vec2 v, vec2 div, float gap){
	vec2 p = v;
	p.x += indexTile(p, vec2(1.0, div.y)) * gap * (div.y - 1.0);
	p.x = indexTile(p, div);
	return p.x;
}

float frame(vec2 v, vec2 div, float gap, float delta) {
	return (
		(tile1(v + vec2(delta, 0.0), div, gap) == tile1(v - vec2(delta, 0.0), div, gap)) &&
		(tile1(v + vec2(0.0, delta), div, gap) == tile1(v - vec2(0.0, delta), div, gap))
	)?1.0:0.0;
}
 
void main( void ) {
	vec2 p = ( gl_FragCoord.xy / resolution.y );
	p.x += time * 0.2;
	vec2 div = vec2(2.0,6.0);
 
	float i = frame(p, div, 1.0 / 3.0, 0.001);

	gl_FragColor = vec4( vec3(i), 1.0 );
}
