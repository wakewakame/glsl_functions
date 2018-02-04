/*
*ドキュメント
参考元 : https://github.com/ashima/webgl-noise
float grain1(vec3 v, float n)
	木目模様を生成する関数
	v.zの方向に木が伸びている
	z軸に垂直な断面の模様が年輪の模様になる
	z軸に平行な断面の模様が木材の模様になる
	(v.x, v.y)の最小値、最大値の目安は(-1.0, -1.0), (1.0, 1.0)
	v.x : v.y : v.z の比率の目安は 1 : 1 : 1
	nはノイズの大きさ
	0.0を指定すると波のない木目
	大きくすると木目の波が大きくなる
	目安は1.0
	戻り値はrgb (0.0, 0.0, 0.0), (1.0, 1.0, 1.0)
vec3 grain2(vec2 v)
	grain1のラッパー関数
	木材の模様を生成する
	v : 座標
	vの範囲の目安は(0.0, 0.0), (1.0, 1.0)
	戻り値はrgb (0.0, 0.0, 0.0), (1.0, 1.0, 1.0)
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

const int  oct  = 4;
float octaves(vec3 v, float p){
	float req = 0.0;
	for(int i = 0; i < oct; i++){
		float freq = pow(p, float(i));
		float amp  = pow(p, float(-i));
		req += snoise(v * freq) * amp;
	}
	req = clamp(req, -1.0, 1.0);
	return req;
}

float sigmoid1(float x, float a){
	float ex = exp(-2.0 * a * x);
	return (1.0 - ex) / (1.0 + ex);
}

vec3 grain1(vec3 v, float n){
	float l, w, r, m;
	l = length(v.xy); // xyベクトルの長さを算出
	l = pow(l, 2.0); // xyベクトルの長さを二乗
	l += octaves(v  * n *  vec3(0.014, 0.014, 0.0042), 2.3) * 1.6; // 長さにノイズを加える
	w =cos(2.0 * PI * l * 8.0); // xyベクトルの長さに応じて変化する波を作る
	w = sigmoid1(w + 0.85, 3.0); // 波の形を-1.0, 1.0に収まるように調節
	r = snoise(v * vec3(160.0, 160.0, 6.5)) + 0.5; // ザラザラしたノイズを生成
	float p = 0.6;
	m = w * p + r * (1.0 - p); // 波とザラザラをp:1.0-pで配合
	m = (m + 1.0) / 2.0; // 0.0, 1.0に縮小
	// 色付け
	vec3 col1 =  vec3(243, 204, 163);
	vec3 col2 = vec3(229, 164, 108);
	vec3 col = (col1 * m + col2 * (1.0 - m)) / 255.0;
	col += octaves(v * vec3(1.0, 1.0, 0.2), 2.3) * 0.05; // 全体的に明暗ノイズを加える
	col = clamp(col, 0.0, 1.0); // 0.0, 1.0に収める
	return col;
}

vec3 grain2(vec2 v){
	vec3 pos = vec3(
		0.6,
		((v.y * 2.0) - 1.0),
		(v.x + 10.0) * 2.0
	);
	return grain1(pos, 1.0);
}

float enlarge(float x, vec2 a, vec2 b){
	return (x - a.x) * ((b.y - b.x)/(a.y - a.x)) + b.x;
}

void main(void){
	vec2 p = gl_FragCoord.xy / resolution.y;
	
	vec2 pos = p;
	pos.x *= mouse.y;
	pos.y = enlarge(pos.y, vec2(0.0, 1.0), vec2(0.5) + vec2(-1.0, 1.0) * mouse.y);
	vec3 col = grain2(pos + vec2(time * 0.5, 0.0));
	
	gl_FragColor = vec4(col, 1.0);
}