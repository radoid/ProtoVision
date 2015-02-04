#version 150

uniform bool uUseColorMap, uUseNormalMap;
uniform sampler2D uColorMapSampler, uNormalMapSampler;
uniform vec3 uLight, uEye;
in mat3 surface2world;
in vec3 vNormal;
in vec2 vTextureUV, vNormalMapUV;
in vec4 vColorAmbient, vColor;
out vec4 fragColor;

void main(void) {
	vec3 normal;
	if (uUseNormalMap) {
		vec3 normalcoords = 2.0 * texture(uNormalMapSampler, vTextureUV).rgb - vec3(1.0);
		normal = normalize(surface2world * normalcoords);
	} else {
		normal = vNormal;
	}

	float intensity = (dot(-uLight, normal)+1.0)/2.0;

	vec3 color;
	if (uUseColorMap)
		color = texture(uColorMapSampler, vTextureUV).rgb;
	else
		color = vColor.rgb - vColorAmbient.rgb;
	//else if (intensity < 0.5)
	//	color = mix(vec4(15/256.0, 7/256.0, 21/256.0, 1.0), vColor, intensity*2.0);
	//else
	//	color = mix(vColor, vec4(1.0, 1.0, 235.0/256.0, 1.0), (intensity-0.5)*2.0);
	//else
	//	color = mix(vColorAmbient, vColor, intensity);

	fragColor = vec4(vColorAmbient.rgb + color * intensity, vColor.w);
}
