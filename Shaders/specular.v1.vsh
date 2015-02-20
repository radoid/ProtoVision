uniform lowp mat4 uProjection;
uniform lowp mat4 uModel, uModelView;
uniform lowp mat3 uNormalMatrix;
uniform lowp vec3 uLight, uEye;
uniform lowp vec4 uColor, uColorAmbient, uColorSpecular;
uniform int uColorSize;
uniform bool uUseColorMap, uUseNormalMap, uUseSpecularMap, uUseAmbientOcclusionMap;
attribute lowp vec3 aPosition, aNormal, aTangent;
varying lowp vec3 vPosition, vNormal;
attribute vec2 aTextureUV;
attribute lowp vec4 aColorAmbient, aColor;
varying lowp vec4 vColor, vColorAmbient;
varying lowp vec2 vTextureUV;
varying lowp mat3 surface2world;

void main (void) {
	vNormal = normalize(uNormalMatrix * aNormal);

	//surface2world[0] = normalize(vec3(uModel * lowp vec4(aTangent, 0.0)));
	surface2world[0] = normalize(uNormalMatrix * aTangent);
	surface2world[2] = normalize(uNormalMatrix * aNormal);
	surface2world[1] = normalize(cross(surface2world[2], surface2world[0]) * 1.0);

	if (uColorSize == 8) {
		vColor = aColor;
		vColorAmbient = aColorAmbient;
	} else {
		vColor = uColor;
		vColorAmbient = uColorAmbient;
	}

	if (uUseColorMap || uUseNormalMap || uUseSpecularMap || uUseAmbientOcclusionMap)
		vTextureUV = aTextureUV;

	vPosition = (uModel * vec4(aPosition, 1.0)).xyz;
	gl_Position = uProjection * uModelView * vec4(aPosition, 1.0);
}
