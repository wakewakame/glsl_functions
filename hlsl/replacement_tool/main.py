# -*- coding: utf-8 -*- 

import sys

replace_list = [
	["const", "static const"],
	["fract", "frac"],
	["mod", "fmod"],
	["atan", "atan2"],
	["mix", "lerp"],
	["texture2D", "tex2D"],
	["vec2", "float2"],
	["vec3", "float3"],
	["vec4", "float4"],
	["bvec2", "bool2"],
	["bvec3", "bool3"],
	["bvec4", "bool4"],
	["ivec2", "int2"],
	["ivec3", "int3"],
	["ivec4", "int4"],
	["mat2", "float2x2"],
	["mat3", "float3x3"],
	["mat4", "float4x4"],
	["mat2", "float2x2"],
	["mat3", "float3x3"],
	["mat4", "float4x4"]
]

def main(filename):
	code = ""
	with open(filename, "r") as f1:
		code = f1.read()
	for i in replace_list:
		code = code.replace(i[0], i[1])
	with open(filename + ".hlsl", "w") as f2:
		f2.write(code)

if __name__ == '__main__':
	if (len(sys.argv)  != 2):
		print("error")
		sys.exit()
	main(sys.argv[1])
	print("finish")