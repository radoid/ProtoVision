uniform bool uUseColorMap, uUseNormalMap, uUseSpecularMap, uUseAmbientOcclusionMap;
uniform lowp sampler2D uColorMapSampler, uNormalMapSampler, uSpecularMapSampler, uAmbientOcclusionMapSampler;
uniform int uLightCount;
uniform lowp vec4 uLight, uColorSpecular;
uniform lowp vec3 uEye;
varying lowp mat3 surface2world;
varying lowp vec3 vPosition, vNormal;
varying lowp vec2 vTextureUV, vNormalMapUV;
varying lowp vec4 vColor, vColorAmbient;

void main(void) {
	lowp vec3 normal;
	if (uUseNormalMap)  // && dot(normal, light) > 0)
		normal = normalize(surface2world * (vec3(2.0, 2.0, 2.0) * texture2D(uNormalMapSampler, vTextureUV).rgb - vec3(1.0, 1.0, 1.0)));
	else
		normal = normalize(vNormal);

	lowp vec3 light;
	if (uLight.w == 0.0)
		light = -uLight.xyz;
	else
		light = normalize(uLight.xyz - vPosition);

	lowp float diffuse_intensity = (dot(light, normal) + 1.0) / 2.0;
	//diffuse_intensity = max(0.0, dot(light, normal));

	lowp vec3 diffuse_color;
	if (uUseColorMap)
		diffuse_color = texture2D(uColorMapSampler, vTextureUV).rgb;
	else
		diffuse_color = vColor.rgb;

	if (uUseAmbientOcclusionMap)
		diffuse_color *= texture2D(uAmbientOcclusionMapSampler, vTextureUV).rgb;

	lowp vec3 view = normalize(uEye - vPosition);
	lowp float shininess = 5.0;

	lowp float specular_intensity;
	if (uColorSpecular.w > 0.0) // && dot(normal, light) > 0)
		specular_intensity = pow(max(0.0, dot(reflect(-light, normal), view)), shininess);
	else
		specular_intensity = 0.0;
	lowp vec3 specular_color = uColorSpecular.rgb;
	if (uUseSpecularMap)
		specular_intensity *= texture2D(uSpecularMapSampler, vTextureUV).r;//specular_color *= texture(uSpecularMapSampler, vTextureUV).rgb;

	lowp vec4 uLightColor = vec4(1.0, 1.0, 1.0, 1.0);

	//vec3 gamma = lowp vec3(1.0/2.2);
	gl_FragColor = vec4(uLightColor.rgb * mix(mix(vColorAmbient.rgb, diffuse_color, diffuse_intensity), specular_color, specular_intensity), vColor.w);
	//fragColor = lowp vec4(normal/2.0+0.5, 1.0);
}
