#version 150

uniform mat4 uProjection;
uniform mat4 uModelView;
uniform vec4 uColor;
uniform bool uUseColorMap;
in vec3 aPosition;
in vec2 aTextureUV;
out vec4 vColor;
out vec2 vTextureUV;

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
	vColor = hsl2rgb(uColor);
	if (uUseColorMap)
		vTextureUV = aTextureUV;
	gl_Position = uProjection * uModelView * vec4(aPosition, 1.0);
}
