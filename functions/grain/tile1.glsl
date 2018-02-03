/*
*ドキュメント
tile1とgrainの組み合わせサンプル
pic関数がgrainのラッパー関数
picの引数のv.xにtile1を加算、v.yをfractでループさせ、タイルっぽくさせている
*/
 
#ifdef GL_ES
precision mediump float;
#endif
 
#extension GL_OES_standard_derivatives : enable
 
uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

const float PI = 3.14159265;

vec3 mod289(vec3 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
	return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r) {
	return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(vec3 v) { 
	const vec2  C = vec2(1.0/6.0, 1.0/3.0);
	const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

	// First corner
	vec3 i  = floor(v + dot(v, C.yyy) );
	vec3 x0 =   v - i + dot(i, C.xxx);

	// Other corners
	vec3 g = step(x0.yzx, x0.xyz);
	vec3 l = 1.0 - g;
	vec3 i1 = min( g.xyz, l.zxy );
	vec3 i2 = max( g.xyz, l.zxy );

	//   x0 = x0 - 0.0 + 0.0 * C.xxx;
	//   x1 = x0 - i1  + 1.0 * C.xxx;
	//   x2 = x0 - i2  + 2.0 * C.xxx;
	//   x3 = x0 - 1.0 + 3.0 * C.xxx;
	vec3 x1 = x0 - i1 + C.xxx;
	vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
	vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

	// Permutations
	i = mod289(i); 
	vec4 p = permute( permute( permute( 
	i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
	+ i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
	+ i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

	// Gradients: 7x7 points over a square, mapped onto an octahedron.
	// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
	float n_ = 0.142857142857; // 1.0/7.0
	vec3  ns = n_ * D.wyz - D.xzx;

	vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

	vec4 x_ = floor(j * ns.z);
	vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

	vec4 x = x_ *ns.x + ns.yyyy;
	vec4 y = y_ *ns.x + ns.yyyy;
	vec4 h = 1.0 - abs(x) - abs(y);

	vec4 b0 = vec4( x.xy, y.xy );
	vec4 b1 = vec4( x.zw, y.zw );

	//vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
	//vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
	vec4 s0 = floor(b0)*2.0 + 1.0;
	vec4 s1 = floor(b1)*2.0 + 1.0;
	vec4 sh = -step(h, vec4(0.0));

	vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
	vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

	vec3 p0 = vec3(a0.xy,h.x);
	vec3 p1 = vec3(a0.zw,h.y);
	vec3 p2 = vec3(a1.xy,h.z);
	vec3 p3 = vec3(a1.zw,h.w);

	//Normalise gradients
	vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;

	// Mix final noise value
	vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
	m = m * m;
	float req = 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
	dot(p2,x2), dot(p3,x3) ) );
	req = clamp(req, -1.0, 1.0);
	return req;
}

const int  oct  = 8;
float octaves(vec3 v, float per){
	float req = 0.0;
	for(int i = 0; i < oct; i++){
		float freq = pow(per, float(i));
		float amp  = pow(per, float(i));
		req += snoise(v / freq) * amp;
	}
	return req;
}

float sigmoid1(float x, float a){
	float ex = exp(-2.0 * a * x);
	return (1.0 - ex) / (1.0 + ex);
}

float grain(vec3 v, float n){
	float l, w, r, req;
	l = length(v.xy); // xyベクトルの長さを算出
	l = pow(l, 2.0); // xyベクトルの長さを二乗
	l += octaves(v  * n *  vec3(0.014, 0.014, 0.0042), 0.43) * 1.6; // 長さにノイズを加える
	w =cos(2.0 * PI * l * 8.0); // xyベクトルの長さに応じて変化する波を作る
	w = sigmoid1(w + 0.85, 3.0); // 波の形を-1.0, 1.0に収まるように調節
	r = snoise(v * vec3(160.0, 160.0, 6.5)) + 0.5; // ザラザラしたノイズを生成
	float p = 0.6;
	req = w * p + r * (1.0 - p); // 波とザラザラをp:1.0-pで配合
	return req;
}
 
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

vec3 pic(vec2 v){
	vec3 pos = vec3(
		0.6,
		((v.y * 2.0) - 1.0),
		(v.x + 10.0) * 2.0
	);
	float n = grain(pos, 1.0);
	n = (n + 1.0) / 2.0;
	vec3 col1 =  vec3(243, 204, 163);
	vec3 col2 = vec3(229, 164, 108);
	vec3 col = (col1 * n + col2 * (1.0 - n)) / 255.0;
	return col;
}

float frame(vec2 v, vec2 div, float gap, float delta) {
	return (
		(tile1(v + vec2(delta, 0.0), div, gap) == tile1(v - vec2(delta, 0.0), div, gap)) &&
		(tile1(v + vec2(0.0, delta), div, gap) == tile1(v - vec2(0.0, delta), div, gap))
	)?1.0:0.85;
}

void main( void ) {
	vec2 p = ( gl_FragCoord.xy / resolution.y ) * mouse.x;
	p.x *= 0.6;
	p.x += time * 0.2;
	vec2 div = vec2(2.0,6.0);
 
	float i = tile1(p, div, 1.0 / 3.0) * (div.x * div.y);
	float j = frame(p, div, 1.0 / 3.0, 0.001);
	
	vec2 pos = vec2(
		p.x * div.y + i,
		fract(p.y * div.y) * 0.9 + snoise(vec3(i)) * 0.4
	);
	vec3 col = pic(pos) * j;

	gl_FragColor = vec4( col, 1.0 );
}
