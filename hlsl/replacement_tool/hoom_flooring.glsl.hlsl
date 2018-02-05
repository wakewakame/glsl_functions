#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform float2 mouse;
uniform float2 resolution;

static const float PI = 3.14159265;

float3 fmod289(float3 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 fmod289(float4 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 permute(float4 x) {
	return fmod289(((x*34.0)+1.0)*x);
}

float4 taylorInvSqrt(float4 r) {
	return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(float3 v) { 
	static const float2  C = float2(1.0/6.0, 1.0/3.0);
	static const float4  D = float4(0.0, 0.5, 1.0, 2.0);

	// First corner
	float3 i  = floor(v + dot(v, C.yyy) );
	float3 x0 =   v - i + dot(i, C.xxx);

	// Other corners
	float3 g = step(x0.yzx, x0.xyz);
	float3 l = 1.0 - g;
	float3 i1 = min( g.xyz, l.zxy );
	float3 i2 = max( g.xyz, l.zxy );

	//   x0 = x0 - 0.0 + 0.0 * C.xxx;
	//   x1 = x0 - i1  + 1.0 * C.xxx;
	//   x2 = x0 - i2  + 2.0 * C.xxx;
	//   x3 = x0 - 1.0 + 3.0 * C.xxx;
	float3 x1 = x0 - i1 + C.xxx;
	float3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
	float3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

	// Permutations
	i = fmod289(i); 
	float4 p = permute( permute( permute( 
	i.z + float4(0.0, i1.z, i2.z, 1.0 ))
	+ i.y + float4(0.0, i1.y, i2.y, 1.0 )) 
	+ i.x + float4(0.0, i1.x, i2.x, 1.0 ));

	// Gradients: 7x7 points over a square, mapped onto an octahedron.
	// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
	float n_ = 0.142857142857; // 1.0/7.0
	float3  ns = n_ * D.wyz - D.xzx;

	float4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  fmod(p,7*7)

	float4 x_ = floor(j * ns.z);
	float4 y_ = floor(j - 7.0 * x_ );    // fmod(j,N)

	float4 x = x_ *ns.x + ns.yyyy;
	float4 y = y_ *ns.x + ns.yyyy;
	float4 h = 1.0 - abs(x) - abs(y);

	float4 b0 = float4( x.xy, y.xy );
	float4 b1 = float4( x.zw, y.zw );

	//float4 s0 = float4(lessThan(b0,0.0))*2.0 - 1.0;
	//float4 s1 = float4(lessThan(b1,0.0))*2.0 - 1.0;
	float4 s0 = floor(b0)*2.0 + 1.0;
	float4 s1 = floor(b1)*2.0 + 1.0;
	float4 sh = -step(h, float4(0.0));

	float4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
	float4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

	float3 p0 = float3(a0.xy,h.x);
	float3 p1 = float3(a0.zw,h.y);
	float3 p2 = float3(a1.xy,h.z);
	float3 p3 = float3(a1.zw,h.w);

	//Normalise gradients
	float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;

	// Mix final noise value
	float4 m = max(0.6 - float4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
	m = m * m;
	float req = 42.0 * dot( m*m, float4( dot(p0,x0), dot(p1,x1), 
	dot(p2,x2), dot(p3,x3) ) );
	req = clamp(req, -1.0, 1.0);
	return req;
}

static const int  oct  = 4;
float octaves(float3 v, float p){
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

float3 grain1(float3 v, float n){
	float l, w, r, m;
	l = length(v.xy); // xyベクトルの長さを算出
	l = pow(l, 2.0); // xyベクトルの長さを二乗
	l += octaves(v  * n *  float3(0.014, 0.014, 0.0042), 2.3) * 1.6; // 長さにノイズを加える
	w =cos(2.0 * PI * l * 8.0); // xyベクトルの長さに応じて変化する波を作る
	w = sigmoid1(w + 0.85, 3.0); // 波の形を-1.0, 1.0に収まるように調節
	r = snoise(v * float3(160.0, 160.0, 6.5)) + 0.5; // ザラザラしたノイズを生成
	float p = 0.6;
	m = w * p + r * (1.0 - p); // 波とザラザラをp:1.0-pで配合
	m = (m + 1.0) / 2.0; // 0.0, 1.0に縮小
	// 色付け
	float3 col1 =  float3(243, 204, 163);
	float3 col2 = float3(229, 164, 108);
	float3 col = (col1 * m + col2 * (1.0 - m)) / 255.0;
	col += octaves(v * float3(1.0, 1.0, 0.2), 2.3) * 0.05; // 全体的に明暗ノイズを加える
	col = clamp(col, 0.0, 1.0); // 0.0, 1.0に収める
	return col;
}

float3 grain2(float2 v){
	float3 pos = float3(
		0.6,
		((v.y * 2.0) - 1.0),
		(v.x + 10.0) * 2.0
	);
	return grain1(pos, 6.0);
}

float3 tile(float2 uv, float2 div){
	float2 req_uv = frac(uv * div); // uvの分割
	float index = // 分割面のインデックス算出
		floor(uv.x * div.x) + 
		floor(uv.y * div.y) * ceil(div.x);
	return float3(req_uv, index);
}

float tileSize(float2 div){
	if (ceil(div.x) * ceil(div.y) < 1.0) return 1.0;
	return ceil(div.x) * ceil(div.y);
}

float checkered(float2 v, float2 div){
	v *= div;
	float req = 1.0;
	req *= 2.0 * (floor((v.x + 1.0) / 2.0) - floor(v.x / 2.0)) - 1.0;
	req *= 2.0 * (floor((v.y + 1.0) / 2.0) - floor(v.y / 2.0)) - 1.0;
	req = (req + 1.0) / 2.0;
	return req;
}

float2 rotate(float2 v, float2 c, float r){
	v -= c;
	v = float2(
		cos(r) * v.x - sin(r) * v.y,
		sin(r) * v.x + cos(r) * v.y
	);
	v += c;
	return v;
}

float frame(float2 v, float2 w) {
	return (
		0.0 <= v.x - w.x && v.x + w.x <= 1.0 &&
		0.0 <= v.y - w.y && v.y + w.y <= 1.0
	)?1.0:0.8;
}

void main( void ) {
	float2 p = ( gl_FragCoord.xy / resolution.y ) * mouse.x;
	float2 div = float2(2.0, 12.0);
	
	float2 uv = p;
	float3 buf1 = tile(frac(uv), float2(1.0, div.y));
	uv += float2(buf1.z / div.y, 0.0);
	float3 buf2 = tile(uv, div);
	uv = buf2.xy;
	float f = frame(frac(uv), div * 0.0009); // フレームのつなぎ目を暗くする
	float offset = buf2.z * tileSize(div) * 100.0;
	uv.x += offset;
	uv.y = uv.y * 0.9 + snoise(float3(offset)) * 0.3;
	
	float3 col = grain2(uv);
	// 面おきに色にばらつきをつける
	col += float3(199.0, 173.0, 122.0) * (snoise(float3(offset)) * 0.05 + 0.05) / 255.0;
	col *= f;
	
	gl_FragColor = float4( col, 1.0 );
}