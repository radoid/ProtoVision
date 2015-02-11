#version 150

uniform mat4 uProjection;
uniform mat4 uModel, uModelView;
uniform mat3 uNormal;
uniform vec3 uLight, uEye;
uniform vec4 uColor, uColorAmbient, uColorSpecular;
uniform int uColorSize;
uniform bool uUseColorMap, uUseNormalMap, uUseSpecularMap, uUseAmbientOcclusionMap;
in  vec3 aPosition, aNormal, aTangent;
out vec3 vPosition, vNormal;
in  vec2 aTextureUV;
in  vec4 aColorAmbient, aColor;
out vec4 vColor, vColorAmbient, vColorSpecular;
out vec2 vTextureUV;
out mat3 surface2world;

void main (void) {
	vNormal = normalize(uNormal * aNormal);

	//surface2world[0] = normalize(vec3(uModel * vec4(aTangent, 0.0)));
	surface2world[0] = normalize(uNormal * aTangent);
	surface2world[2] = normalize(uNormal * aNormal);
	surface2world[1] = normalize(cross(surface2world[2], surface2world[0]) * 1.0);

	if (uColorSize == 8) {
		vColor = aColor;
		vColorAmbient = aColorAmbient;
	} else {
		vColor = uColor;
		vColorAmbient = uColorAmbient;
	}
	vColorSpecular = uColorSpecular;

	if (uUseColorMap || uUseNormalMap || uUseSpecularMap || uUseAmbientOcclusionMap)
		vTextureUV = aTextureUV;

	vPosition = (uModel * vec4(aPosition, 1.0)).xyz;
	gl_Position = uProjection * uModelView * vec4(aPosition, 1.0);
}
