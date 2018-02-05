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

vec2 rotate(vec2 v, vec2 c, float r){
	v -= c;
	v = vec2(
		cos(r) * v.x - sin(r) * v.y,
		sin(r) * v.x + cos(r) * v.y
	);
	v += c;
	return v;
}

float enlarge1(float x, vec2 a, vec2 b){
	return (x - a.x) * ((b.y - b.x)/(a.y - a.x)) + b.x;
}

float enlarge2(float x, vec2 a){
	return clamp(enlarge1(x, a, vec2(0.0, 1.0)), 0.0, 1.0);
}

float travertine1(vec2 v, float gap, float size, float len){
	v = v / gap * 4.0; // 座標調節
	size /= gap; // 模様の間隔に合わせてサイズ調節
	v.y += snoise(vec3(v, 0.0) * 4.8 / size) * 0.06 * size; // 細かいノイズ
	v.y += snoise(vec3(v, 0.0) * 0.1 / size) * 0.4 * size; // 大きいノイズ
	// 斜めに区切られたuvを作る
	v = rotate(v - vec2(0.5), vec2(0.0), PI / 6.0); // 座標を30°回転
	v = fract(v) - vec2(0.5); // 画面を0.0-1.0で分割し、各々のuvの原点をvec2(0.5)に移動
	v = rotate(v, vec2(0.0), -PI / 6.0); // 各々のuvの座標を-30°回転
	v /= vec2(len, 1.0) * size; // 各々のuvのx軸拡大
	float n = length(v); // 各々のuvでフレア描画
	n = enlarge2(n, vec2(0.0, 0.04)); // 値の拡大、クランプ
	return n;
}

float travertine2(vec2 v){
	float n = 0.0;
	n += 1.0 - travertine1(v, 0.8, 1.0, 8.0);
	n += 1.0 - travertine1(v + vec2(200.0), 0.5, 0.7, 2.0);
	n *= 0.7;
	n = 1.0 - n;
	return n;
}

float frame(vec2 v, vec2 w) {
	return (
		0.0 <= v.x - w.x && v.x + w.x <= 1.0 &&
		0.0 <= v.y - w.y && v.y + w.y <= 1.0
	)?1.0:0.6;
}

float frame2(vec2 v, float w){
	v.y *= 2.0;
	v.x += floor(v.y) / 2.0;
	v = fract(v);
	return frame(v, vec2(1.0, 2.0) * w);
}

void main( void ) {
	vec2 p = gl_FragCoord.xy / resolution.y;
	p *= mouse.x * 3.0;
		
	float n = travertine2(p * 3.0);
	vec3 col = vec3(n) * frame2(p * 0.8, 0.002);
	
	gl_FragColor = vec4(col, 1.0);

}