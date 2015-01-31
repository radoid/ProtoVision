#version 150

uniform mat4 uProjection;
uniform mat4 uModelView;
uniform mat3 uNormal;
uniform vec4 uColor, uColorDark, uColorLight;
uniform vec3 uLight, uEye;
in vec3 aPosition;
in vec3 aNormal;
out vec4 vColor;

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float hue2rgb(float tmp2, float tmp1, float H) {
	float ret;

	if (H < 0.0)
		H += 1.0;
	else if (H > 1.0)
		H -= 1.0;
	if (H < 1.0 / 6.0)
		ret = (tmp2 + (tmp1 - tmp2) * (360.0 / 60.0) * H);
	else if (H < 1.0 / 2.0)
		ret = tmp1;
	else if (H < 2.0 / 3.0)
		ret = (tmp2 + (tmp1 - tmp2) * ((2.0 / 3.0) - H) * (360.0 / 60.0));
	else
		ret = tmp2;
	return ret;
}

vec4 hsl2rgb(vec4 hsl) {
	vec3 rgb;
	float tmp1, tmp2;

	if (hsl.z < 0.5)
		tmp1 = hsl.z * (1.0 + hsl.y);
	else
		tmp1 = (hsl.z + hsl.y) - (hsl.z * hsl.y);
	tmp2 = 2.0 * hsl.z - tmp1;
	rgb.r = hue2rgb(tmp2, tmp1, hsl.x + (1.0 / 3.0));
	rgb.g = hue2rgb(tmp2, tmp1, hsl.x);
	rgb.b = hue2rgb(tmp2, tmp1, hsl.x - (1.0 / 3.0));
	return vec4(rgb, hsl.w);
}

void main (void) {
	float intensity = (dot(-normalize(uLight), normalize(uNormal * aNormal))+1.0)/2.0;
	vColor = hsl2rgb(mix(uColorDark, uColorLight, intensity));

	gl_Position = uProjection * uModelView * vec4(aPosition, 1.0);
}
