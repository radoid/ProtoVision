#version 150

uniform mat4 uProjection;
uniform mat4 uModelView;
uniform mat3 uNormal;
uniform vec3 uLight, uEye;
uniform vec4 uColor, uColorAmbient;
uniform int uColorSize;
uniform bool uUseColorMap, uUseNormalMap;
in vec3 aPosition;
in vec3 aNormal, aTangent;
out vec3 vNormal;
in vec2 aTextureUV;
in vec4 aColorAmbient, aColor;
out vec4 vColorAmbient, vColor;
out vec2 vTextureUV;
out mat3 surface2world;

void main (void) {
	vNormal = normalize(uNormal * aNormal);

	surface2world[0] = normalize(vec3(uModelView * vec4(aTangent, 0.0)));
	surface2world[2] = normalize(uNormal * aNormal);
	surface2world[1] = normalize(cross(surface2world[2], surface2world[0]));

	if (uColorSize == 8) {
		vColorAmbient = aColorAmbient;
		vColor = aColor;
	} else {
		vColorAmbient = uColorAmbient;
		vColor = uColor;
	}

	if (uUseColorMap || uUseNormalMap)
		vTextureUV = aTextureUV;

	gl_Position = uProjection * uModelView * vec4(aPosition, 1.0);
}
