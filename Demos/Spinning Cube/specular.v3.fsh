#version 150

uniform bool uUseColorMap, uUseNormalMap, uUseSpecularMap;
uniform sampler2D uColorMapSampler, uNormalMapSampler, uSpecularMapSampler;
uniform vec3 uLight, uEye;
in mat3 surface2world;
in vec3 vPosition, vNormal;
in vec2 vTextureUV, vNormalMapUV;
in vec4 vColor, vColorAmbient, vColorSpecular;
out vec4 fragColor;

void main(void) {
	vec3 normal;
	if (uUseNormalMap)
		normal = normalize(surface2world * (2.0 * texture(uNormalMapSampler, vTextureUV).rgb - vec3(1.0)));
	else
		normal = normalize(vNormal);

	vec3 uLightPosition = vec3(-1, 1, 1);
	vec4 uLightColor = vec4(1, 1, 1, 1);

	vec3 light;
	light = normalize(vPosition - uLightPosition);
	light = uLight;

	float diffuse_intensity = (dot(-light, normal)+1.0)/2.0;
	//diffuse_intensity = max(0.0, dot(light, normal));

	vec3 diffuse_color;
	if (uUseColorMap)
		diffuse_color = texture(uColorMapSampler, vTextureUV).rgb;
	else
		diffuse_color = vColor.rgb;
	//else if (intensity < 0.5)
	//	diffuse_color = mix(vec4(15/256.0, 7/256.0, 21/256.0, 1.0), vColor, intensity*2.0);
	//else
	//	diffuse_color = mix(vColor, vec4(1.0, 1.0, 235.0/256.0, 1.0), (intensity-0.5)*2.0);
	//else
	//	diffuse_color = mix(vColorAmbient, vColor, intensity);

	vec3 view = normalize(uEye - vPosition);
	float shininess = 5;

	float specular_intensity;
	if (vColorSpecular.w > 0.0 /*&& dot(normal, -light) > 0.0*/)
		specular_intensity = pow(max(0.0, dot(reflect(light, normal), view)), shininess);
	else
		specular_intensity = 0.0;
	vec3 specular_color = vColorSpecular.rgb;
	if (uUseSpecularMap)
		specular_intensity *= texture(uSpecularMapSampler, vTextureUV).r;//specular_color *= texture(uSpecularMapSampler, vTextureUV).rgb;

	fragColor = vec4(uLightColor.rgb * mix(mix(vColorAmbient.rgb, diffuse_color, diffuse_intensity), specular_color, specular_intensity), vColor.w);
}
