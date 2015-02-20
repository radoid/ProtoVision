#version 150

uniform bool uUseColorMap, uUseNormalMap, uUseSpecularMap, uUseAmbientOcclusionMap;
uniform sampler2D uColorMapSampler, uNormalMapSampler, uSpecularMapSampler, uAmbientOcclusionMapSampler;
uniform int uLightCount;
uniform vec4 uLight;
uniform vec3 uEye;
in mat3 surface2world;
in vec3 vPosition, vNormal;
in vec2 vTextureUV, vNormalMapUV;
in vec4 vColor, vColorAmbient, vColorSpecular;
out vec4 fragColor;

void main(void) {
	vec3 normal;
	if (uUseNormalMap)  // && dot(normal, light) > 0)
		normal = normalize(surface2world * (vec3(2.0, 2.0, 2.0) * texture(uNormalMapSampler, vTextureUV).rgb - vec3(1.0, 1.0, 1.0)));
	else
		normal = normalize(vNormal);

	vec4 uLightColor = vec4(1.0, 1.0, 1.0, 1.0);

	vec3 light;
	if (uLight.w == 0.0)
		light = -uLight.xyz;
	else
		light = normalize(uLight.xyz - vPosition);

	float diffuse_intensity = (dot(light, normal) + 1.0) / 2.0;
	//diffuse_intensity = max(0.0, dot(light, normal));

	vec3 diffuse_color;
	if (uUseColorMap)
		diffuse_color = texture(uColorMapSampler, vTextureUV).rgb;
	else
		diffuse_color = vColor.rgb;

	if (uUseAmbientOcclusionMap)
		diffuse_color *= texture(uAmbientOcclusionMapSampler, vTextureUV).rgb;

	vec3 view = normalize(uEye - vPosition);
	float shininess = 5.0;

	float specular_intensity;
	if (vColorSpecular.w > 0.0) // && dot(normal, light) > 0)
		specular_intensity = pow(max(0.0, dot(reflect(-light, normal), view)), shininess);
	else
		specular_intensity = 0.0;
	vec3 specular_color = vColorSpecular.rgb;
	if (uUseSpecularMap)
		specular_intensity *= texture(uSpecularMapSampler, vTextureUV).r;//specular_color *= texture(uSpecularMapSampler, vTextureUV).rgb;

	//vec3 gamma = vec3(1.0/2.2);
	fragColor = vec4(uLightColor.rgb * mix(mix(vColorAmbient.rgb, diffuse_color, diffuse_intensity), specular_color, specular_intensity), vColor.w);
	//fragColor = vec4(normal/2.0+0.5, 1.0);
}
