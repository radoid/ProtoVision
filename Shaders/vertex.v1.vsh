uniform mat4 uProjection, uModelView;
uniform mat3 uNormal;
uniform vec4 uLight;
uniform vec3 uEye;
uniform vec4 uColor, uColorAmbient;
uniform int uLightCount, uColorSize;
attribute vec3 aPosition, aNormal;
attribute vec4 aColorAmbient, aColor;
varying lowp vec4 vColor;
uniform bool uUseColorMap;
uniform vec2 aTextureUV;
varying vec2 vTextureUV;

void main (void) {
	if (uLightCount > 0) {
		vec3 light;
		if (uLight.w == 0)
			light = -uLight.xyz;
		else
			light = normalize(uLight.xyz - aPosition);

		float intensity = (dot(normalize(light), normalize(uNormal * aNormal)) + 1.0) / 2.0;

		if (uColorSize == 8)
			vColor = mix(aColorAmbient, aColor, intensity);
		else if (uColorSize == 4)
			vColor = mix(uColorAmbient, aColor, intensity);
		else
			vColor = mix(uColorAmbient, uColor, intensity);
	}
	else if (uColorSize == 4)
		vColor = aColor;
	else
		vColor = uColor;

	if (uUseColorMap)
		vTextureUV = aTextureUV;

	gl_Position = uProjection * uModelView * vec4(aPosition, 1.0);
}
